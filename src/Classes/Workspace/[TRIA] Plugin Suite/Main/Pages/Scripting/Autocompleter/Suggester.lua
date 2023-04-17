local Suggester = {}

local ScriptEditorService = game:GetService("ScriptEditorService")

local Package = script.Parent.Parent.Parent.Parent

local Autocomplete = script.Parent
local AutocompleteData = require(Autocomplete.AutocompleteData)
local AutocompleteUtil = require(Autocomplete.AutocompleteUtil)
local AutocompleteTypes = require(Autocomplete.AutocompleteTypes)

local Lexer = require(Autocomplete.Lexer)
local GlobalSettings = require(Autocomplete.GlobalSettings)

local PublicTypes = require(Package.PublicTypes)
local Util = require(Package.Util)

local AUTOCOMPLETE_IDEN = "([%.:])"
local ARGS_MATCH = "(%w+)[:%s%w+]*"
local ANY_CHAR = "[%w%p]*"

local VARIABLE_CREATE = `=%s*(%w+){AUTOCOMPLETE_IDEN}`
local FUNCTION_CREATE = `function (%w+){AUTOCOMPLETE_IDEN}(%w+)(%b())`

local PROPERTY_FUNCTION_CREATE = "(%w+)%.(%w+)%s*=%s*%(*function(%b())%s*"
local PROPERTY_VARIABLE_CREATE = `(%w+)%.(%w+)%s*=%s({ANY_CHAR})%s*`
local PROPERTY_FUNCTION_MATCH = `%s*function%({ANY_CHAR}%)%s*`
local END_FUNCTION_MATCH = `end%s(%w+){AUTOCOMPLETE_IDEN}`

local FUNCTION_CALL = `%(%s*(%w+){AUTOCOMPLETE_IDEN}`
local INLINE_FUNCTION = `function%({ANY_CHAR}%)?%s*$`

local MAPLIB_IDEN = `local {ARGS_MATCH} = game.GetMapLib:Invoke%(%)%(%)`
local CALLBACK_NAME = "__MapLibCompletion"
 
local function stringToTreeIndex(input: string): string
	return input == ":" and "Methods" or "Properties"
end

local function handleCallback(request: AutocompleteTypes.Request, response: AutocompleteTypes.Response): AutocompleteTypes.Response
	local currentScript = request.textDocument.script
	local currentScriptContext = ScriptEditorService:FindScriptDocument(currentScript)
	local currentDocument = request.textDocument.document

	-- Return Case 1: Command Bar
	if not currentScriptContext or currentScriptContext:IsCommandBar() then 
		return response
	end

	-- Return Case 2: No map selected

	if not Util.mapModel:get(false) then
		return response
	end

	-- Return Case 3: Outside of map model

	if not currentScript:IsDescendantOf(Util.mapModel:get(false)) then
		return response
	end

	-- Return Case 4: Only specific scripts

	if GlobalSettings.runsInTriaScripts then
		if not table.find({"MapScript", "LocalMapScript", "EffectScript"}, currentScript.Name) then
			return response
		end
	end
	
	-- Return Case 5: Inside a comment
	if AutocompleteUtil.backTraceComments(currentDocument, request.position.line, request.position.character) then
		return response
	end

	-- Return Case 6: Inside a multiline string
	if AutocompleteUtil.backTraceMultiString(currentDocument, request.position.line, request.position.character) then
		return response
	end
	
	local prefixes = {}
	for prefix in currentScript.Source:gmatch(MAPLIB_IDEN) do
		table.insert(prefixes, prefix)
	end

	-- Return Case 7: No prefix
	if #prefixes < 1 then
		return response
	end
	
	local line = currentDocument:GetLine(request.position.line)
	local beforeCursor = line:sub(1, request.position.character)
	local afterCursor = line:sub(request.position.character)
	line = line:sub(1, -#afterCursor - 1)
	
	local tokens = AutocompleteUtil.lexerScanToTokens(line)

	-- Return Case 8: Multiple : or .
	if #tokens > 1 then
		if AutocompleteUtil.isTokenSeriesBroken(tokens) then
			return response
		end
	end

	AutocompleteData.Methods = AutocompleteUtil.deepCopy(AutocompleteData.Methods)
	AutocompleteData.Properties = AutocompleteUtil.deepCopy(AutocompleteData.Properties)
	
	local function insertCustomFunction(funcName: string, funcArgs: string, index: string, isFunction: boolean?)
		local newArgs = {}
		for arg in funcArgs:gmatch(ARGS_MATCH) do
			table.insert(newArgs, arg)
		end
		AutocompleteData[index].Branches[funcName] = {
			AutocompleteArgs= newArgs,
			Name = funcName,
			IsFunction = isFunction,
			Branches = nil
		}
	end

	-- Special Case 1: Creating a custom function

	for prefix, index, funcName, funcArgs in currentScript.Source:gmatch(FUNCTION_CREATE) do
		if table.find(prefixes, prefix) then
			insertCustomFunction(funcName, funcArgs, stringToTreeIndex(index))
		end
	end

	-- Special Case 2: Creating a custom function with a dot index

	for prefix, funcName, funcArgs in currentScript.Source:gmatch(PROPERTY_FUNCTION_CREATE) do
		if table.find(prefixes, prefix) then
			insertCustomFunction(funcName, funcArgs, "Properties", true)
		end
	end

	-- Special Case 3: Creating a custom property with a dot index

	for prefix, funcName, endString in currentScript.Source:gmatch(PROPERTY_VARIABLE_CREATE) do
		if table.find(prefixes, prefix) and not endString:match(PROPERTY_FUNCTION_MATCH) then
			insertCustomFunction(funcName, "", "Properties", false)
		end
	end

	local function addResponse(responseData: PublicTypes.Dictionary, treeIndex: string)
		local suggestionData = responseData.data
		table.insert(response.items, {
			label = responseData.label,
			kind = responseData.kind,
			documentation = suggestionData.Documentation,
			codeSample = suggestionData.CodeSample,
			preselect = true,
			tags = (treeIndex == "Methods" or suggestionData.IsFunction) and {
				Enum.CompletionItemTag.AddParens, 
				Enum.CompletionItemTag.PutCursorInParens
			} or {},
			textEdit = AutocompleteUtil.buildReplacement(
				request.position, 
				responseData.text,
				#responseData.beforeCursor,
				#responseData.afterCursor,
				responseData.alreadyTyped
			)
		})
	end
	
	local function suggestResponses(branchList: {string}, index: string, lineTokens: {AutocompleteTypes.Token})
		local reachedEnd, current, _ = AutocompleteUtil.traverseBranchList(AutocompleteData[index], branchList)
		if current and current.Branches and not reachedEnd then
			for name, data in pairs(current.Branches) do
				local lastToken = lineTokens[#lineTokens].value
				local isIndexer = lastToken == ":" or lastToken == "."

				if isIndexer or (name:lower():sub(1, #lastToken) == lastToken:lower()) then
					addResponse({
						label = name,
						kind = Enum.CompletionItemKind[index == "Methods" and "Function" or "Property"],
						data = data,
						text = name,
						beforeCursor = beforeCursor,
						afterCursor = afterCursor,
						alreadyTyped = isIndexer and 0 or #lastToken
					}, index)
				end
			end
		end
	end

	local function suggestAll(index: string, tokens: {AutocompleteTypes.Token})
		local allVariables = {}
		for k in pairs(AutocompleteData[index].Branches) do
			table.insert(allVariables, k)
		end
		suggestResponses({}, index, tokens)
	end

	if AutocompleteUtil.tokenMatches(tokens[1], "space") then
		table.remove(tokens, 1)
	end

	-- Match Case 1: Function end
	if
		#tokens > 2 
		and AutocompleteUtil.tokenMatches(tokens[1], "keyword", "end") 
		and not AutocompleteUtil.tokenMatches(tokens[2], ")") 
		and AutocompleteUtil.tokenMatches(tokens[3], {":", "."}) 
	then
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
							if tempStr:reverse():match(INLINE_FUNCTION) then
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
	elseif 
		line:match(VARIABLE_CREATE) 
		or line:match(FUNCTION_CALL)
		or line:match(END_FUNCTION_MATCH)
	then 
		-- Match Case 2: Property index
		-- Match Case 3: Function call
		-- Match Case 4: End with inline

		do
			for _, pattern in ipairs({VARIABLE_CREATE, FUNCTION_CALL, END_FUNCTION_MATCH}) do
				local prefix, index = line:match(pattern)
				if table.find(prefixes, prefix) then
					suggestAll(stringToTreeIndex(index), tokens)
					break
				end
			end
		end
	else 
		-- Match Case 5: Normal line
		if table.find(prefixes, tokens[1].value) then
			local branches, treeEntryIndex = AutocompleteUtil.getBranchesFromTokenList(tokens)
			suggestResponses(branches, treeEntryIndex, tokens)
		end
	end
	
	return response
end

local responseTimes = {}
function Suggester:registerCallback()
	ScriptEditorService:RegisterAutocompleteCallback(CALLBACK_NAME, 0, function(request: AutocompleteTypes.Request, response: AutocompleteTypes.Response): AutocompleteTypes.Response
		local start = os.clock()
		local newResponse = handleCallback(request, response)

		table.insert(responseTimes, (os.clock() - start) * 1000)
		Util._DEBUG._SuggesterResponse:set(string.format("%.2fms", Util.getRollingAverage(responseTimes, 20)))
		return newResponse
	end)
end

function Suggester:disableCallback()
	pcall(ScriptEditorService.DeregisterAutocompleteCallback, ScriptEditorService, CALLBACK_NAME)
end

return Suggester