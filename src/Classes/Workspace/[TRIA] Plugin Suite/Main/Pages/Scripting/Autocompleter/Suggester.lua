local Suggester = {}

local ScriptEditorService = game:GetService("ScriptEditorService")

local Package = script.Parent
local AutocompleteData = require(Package.AutocompleteData)
local AutocompleteUtil = require(Package.AutocompleteUtil)
local AutocompleteTypes = require(Package.AutocompleteTypes)
local PublicTypes = require(Package.Parent.Parent.Parent.PublicTypes)

local Lexer = require(Package.Lexer)
local GlobalSettings = require(Package.GlobalSettings)

local PROPERTY_INDEX = {
	Property = "=%s*(%w+)%.",
	Method = "=%s*(%w+):"
}
local FUNCTION_CALL = {
	Property = "%(%s*(%w+)%.",
	Method = "%(%s*(%w+):"
}

local MAPLIB_IDEN = "local (%w+)[:%s%w+]* = game.GetMapLib:Invoke%(%)%(%)"
local FUNC_MATCH = "function%(.+%)?%s*$"
local CALLBACK_NAME = "__MapLibCompletion"
 
function Suggester:registerCallback()
	ScriptEditorService:RegisterAutocompleteCallback(CALLBACK_NAME, 0, function(request: AutocompleteTypes.Request, response: AutocompleteTypes.Response): AutocompleteTypes.Response
		local currentScript = request.textDocument.script
		local currentScriptContext = ScriptEditorService:FindScriptDocument(currentScript)
		local currentDocument = request.textDocument.document

		-- Return Case 1: Command Bar
		if not currentScriptContext or currentScriptContext:IsCommandBar() then 
			return response
		end

		-- Return Case 2: Only MapScript
		if GlobalSettings.runOnlyInMapscript then
			if not table.find({"MapScript", "LocalMapScript", "EffectScript"}, currentScript.Name) then
				return response
			end
		end
		
		-- Return Case 3: Inside a comment
		if AutocompleteUtil.backTraceComments(currentDocument, request.position.line, request.position.character) then
			return response
		end

		-- Return Case 4: Inside a multiline string
		if AutocompleteUtil.backTraceMultiString(currentDocument, request.position.line, request.position.character) then
			return response
		end
		
		local prefixes = {}
		for prefix in currentScript.Source:gmatch(MAPLIB_IDEN) do
			table.insert(prefixes, prefix)
		end
		
		-- Return Case 5: No prefix
		if #prefixes < 1 then
			return response
		end
		
		local line = currentDocument:GetLine(request.position.line)
		local beforeCursor = line:sub(1, request.position.character)
		local afterCursor = line:sub(request.position.character)
		line = line:sub(1, -#afterCursor - 1)
		
		local tokens = AutocompleteUtil.lexerScanToTokens(line)

		-- Return Case 6: Multiple : or .
		if #tokens > 1 then
			if AutocompleteUtil.isTokenSeriesBroken(tokens) then
				return response
			end
		end
		
		local function addResponse(responseData: PublicTypes.propertiesTable, treeIndex: string)
			local suggestionData = responseData.data
			table.insert(response.items, {
				label = responseData.label,
				kind = responseData.kind,
				documentation = suggestionData.documentation,
				codeSample = suggestionData.codeSample,
				preselect = true,
				
				textEdit = AutocompleteUtil.buildReplacement(
					request.position, 
					(
						responseData.text 
						.. (treeIndex == "Methods" and "(" .. table.concat(suggestionData.autocompleteArgs, ", ") .. ")" or "")
						.. afterCursor
					),
					responseData.beforeCursor,
					responseData.afterCursor,
					responseData.alreadyTyped
				)
			})
		end
		
		local function suggestResponses(branchList: {string}, index: string, lineTokens: {AutocompleteTypes.Token})
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
					local isIndexer = lastToken == ":" or lastToken == "."

					if isIndexer or (name:lower():sub(1, #lastToken) == lastToken:lower()) then
						addResponse({
							label = name,
							kind = index == "Methods" and Enum.CompletionItemKind.Function or Enum.CompletionItemKind.Property,
							data = data,
							text = name, 
							
							beforeCursor = #beforeCursor,
							afterCursor = #afterCursor,
							alreadyTyped = isIndexer and 0 or #lastToken
						}, index)
					end
				end
			end
		end

		local function insertAll(index: string, tokens: {AutocompleteTypes.Token})
			local allVariables = {}
			for k in pairs(AutocompleteData[index].branches) do
				table.insert(allVariables, k)
			end
			suggestResponses({}, index, tokens)
		end

		if AutocompleteUtil.tokenMatches(tokens[1], "space") then
			table.remove(tokens, 1)
		end

		-- Match Case 1: Function end
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
	
				local function backtrackToFindFunction(startLine: number)
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

						if AutocompleteUtil.isTokenSeriesBroken(tempLineData.tokens) then
							tempLineData.failed = true
							break
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
		elseif line:match(PROPERTY_INDEX.Property) or line:match(PROPERTY_INDEX.Method) then 
			-- Match Case 2: Property index
			do
				local isProperty = table.find(prefixes, line:match(PROPERTY_INDEX.Property))
				local isMethod = table.find(prefixes, line:match(PROPERTY_INDEX.Method))
				if isProperty or isMethod then
					insertAll(isMethod and "Methods" or "Properties", tokens)
				end
			end
		elseif line:match(FUNCTION_CALL.Property) or line:match(FUNCTION_CALL.Method) then 
			-- Match Case 3: Function call
			do
				local isProperty = table.find(prefixes, line:match(FUNCTION_CALL.Property))
				local isMethod = table.find(prefixes, line:match(FUNCTION_CALL.Method))
				if isProperty or isMethod then
					insertAll(isMethod and "Methods" or "Properties", tokens)
				end
			end
		else 
			-- Match Case 4: Normal line
			if table.find(prefixes, tokens[1].value) then
				local branches, treeEntryIndex = AutocompleteUtil.getBranchesFromTokenList(tokens)
				suggestResponses(branches, treeEntryIndex, tokens)
			end
		end
		
		return response
	end)
end

function Suggester:disableCallback()
	pcall(ScriptEditorService.DeregisterAutocompleteCallback, ScriptEditorService, CALLBACK_NAME)
end

return Suggester
