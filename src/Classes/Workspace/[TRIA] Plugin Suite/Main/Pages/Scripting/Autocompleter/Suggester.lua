local Suggester = {}

local ScriptEditorService = game:GetService("ScriptEditorService")

local AutocompleteData = require(script.Parent.AutocompleteData)
local AutocompleteUtil = require(script.Parent.AutocompleteUtil)
local Lexer = require(script.Parent.Lexer)
local GlobalSettings = require(script.Parent.GlobalSettings)

function Suggester:registerCallback()
	ScriptEditorService:RegisterAutocompleteCallback("__MapLibCompletion", 0, function(request, response)
		local currentScript = request.textDocument.script
		local currentScriptContext = ScriptEditorService:FindScriptDocument(currentScript)
		local currentDocument = request.textDocument.document

		if not currentScriptContext or currentScriptContext:IsCommandBar() then 
			return response
		end

		if GlobalSettings.runOnlyInMapscript then
			if currentScript.Name ~= "MapScript" then
				return response
			end
		end
		
		if AutocompleteUtil.backTraceComments(currentDocument, request.position.line, request.position.character) then
			return response
		end
		
		local prefixes = {}
		for prefix in currentScript.Source:gmatch("local (%w+)[:%s%w+]* = game.GetMapLib:Invoke%(%)%(%)") do
			table.insert(prefixes, prefix)
		end
		
		if #prefixes < 1 then
			return response
		end
		
		local line = currentDocument:GetLine(request.position.line)
		local beforeCursor = line:sub(1, request.position.character)
		local afterCursor = line:sub(request.position.character)
		line = line:sub(1, -#afterCursor - 1)
		
		local tokens = AutocompleteUtil.lexerScanToTokens(line)
		
		local function addResponse(responseData, treeIndex)
			local suggestionData = responseData.data
			table.insert(response.items, {
				label = responseData.label,
				kind = responseData.kind,
				documentation = suggestionData.documentation,
				codeSample = suggestionData.codeSample,
				preselect = true,
				
				textEdit = AutocompleteUtil.buildReplacement(
					request.position, 
					(responseData.text .. (treeIndex == "Methods" and "(" .. table.concat(suggestionData.autocompleteArgs, ", ") .. ")" or "")),
					responseData.beforeCursor,
					responseData.afterCursor,
					responseData.alreadyTyped
				)
			})
		end
		
		local function suggestResponses(branchList: {string}, index: string, lineTokens: {Lexer.Token})
			local current = AutocompleteData[index]
			local reachedEnd = false
			
			for _, branch in ipairs(branchList) do
				if current.branches ~= nil then
					if current.branches[branch] then
						current = current.branches[branch]
					end
				else
					reachedEnd = true
					break
				end
			end
			
			if current and current.branches and not reachedEnd then
				for name, data in pairs(current.branches) do
					local lastToken = lineTokens[#lineTokens].value
					if (lastToken == ":" or lastToken == ".") or (name:lower():sub(1, #lastToken) == lastToken:lower()) then
						addResponse({
							label = name,
							kind = index == "Methods" and Enum.CompletionItemKind.Function or Enum.CompletionItemKind.Property,
							data = data,
							text = name, 
							
							beforeCursor = #beforeCursor,
							afterCursor = #afterCursor,
							alreadyTyped = (lastToken == ":" or lastToken == ".") and 0 or #lastToken
						}, index)
					end
				end
			end
		end

		if AutocompleteUtil.tokenMatches(tokens[1], "space") then
			table.remove(tokens, 1)
		end

		-- CASE 1: Function end
		if AutocompleteUtil.tokenMatches(tokens[1], "keyword", "end") then
			do			
				local tempLineData = {
					line = "",
					lineNumber = 0,
					tokens = {},
					hasFunction = false,
					failed = false
				}
	
				--[[
					Not the neatest way to backtrack lines
					but it was annoying working with a while loop
				]]
	
				local FUNC_MATCH = "function%([%w%,]*%)?%s*$"
	
				local function backtrackToFindFunction(startLine)
					if startLine < 2 then
						tempLineData.failed = true
						return
					end
					
					tempLineData.hasFunction = false
					for lineNumber = startLine - 1, 1, -1 do
						tempLineData.lineNumber = lineNumber
						tempLineData.line = currentDocument:GetLine(lineNumber)
						tempLineData.tokens = AutocompleteUtil.lexerScanToTokens(tempLineData.line)
	
						if #tempLineData.tokens > 0 then
							if AutocompleteUtil.tokenMatches(tempLineData.tokens[1], "space") then
								table.remove(tempLineData.tokens, 1)
							end
						end

						local tempStr = ""
						for count = #tempLineData.tokens, 1, -1 do
							local currentToken = tempLineData.tokens[count]
							tempStr ..= currentToken.value:reverse()
							
							if AutocompleteUtil.tokenMatches(currentToken, "keyword", "function") then
								if tempStr:reverse():match(FUNC_MATCH) then
									tempLineData.hasFunction = true
									break
								end
							end
						end
	
						if tempLineData.hasFunction then
							break
						end
					end
				end
				
				local lineTokens = AutocompleteUtil.lexerScanToTokens(line)
				local allBranches = AutocompleteUtil.getBranchesFromTokenList(lineTokens)
				AutocompleteUtil.flipArray(allBranches)
				backtrackToFindFunction(request.position.line)
				
				while true do
					if tempLineData.failed then
						break
					end
					
					if tempLineData.hasFunction then	
						if AutocompleteUtil.tokenMatches(tempLineData.tokens[1], "keyword", "end") or table.find(prefixes, tempLineData.tokens[1].value) then
							local backtrackedBranches = AutocompleteUtil.getBranchesFromTokenList(AutocompleteUtil.lexerScanToTokens(tempLineData.line))
							AutocompleteUtil.flipArray(backtrackedBranches)
							
							for _, branch in ipairs(backtrackedBranches) do
								table.insert(allBranches, branch)
							end
						else
							break
						end
					else
						break
					end
					
					backtrackToFindFunction(tempLineData.lineNumber)
				end
				
				if not tempLineData.failed then
					AutocompleteUtil.flipArray(allBranches)

					if #allBranches > 0 then
						local _, treeEntryIndex = AutocompleteUtil.getBranchesFromTokenList(lineTokens)
						suggestResponses(allBranches, treeEntryIndex, lineTokens)
					end
				end
			end
		elseif line:match("=%s*(%w+)%.") then 
			-- CASE 2: Property index
			do
				local variableName = line:match("=%s*(%w+)%.")
				if table.find(prefixes, variableName) then
					local allVariables = {}
					for k in pairs(AutocompleteData.Properties.branches) do
						table.insert(allVariables, k)
					end
					suggestResponses({}, "Properties", tokens)
				end
			end
		else 
			-- CASE 3: Normal line
			if table.find(prefixes, tokens[1].value) then
				local branches, treeEntryIndex = AutocompleteUtil.getBranchesFromTokenList(tokens)
				suggestResponses(branches, treeEntryIndex, tokens)
			end
		end
		
		return response
	end)
end

function Suggester:disableCallback()
	pcall(ScriptEditorService.DeregisterAutocompleteCallback, ScriptEditorService, "__MapLibCompletion")
end

return Suggester
