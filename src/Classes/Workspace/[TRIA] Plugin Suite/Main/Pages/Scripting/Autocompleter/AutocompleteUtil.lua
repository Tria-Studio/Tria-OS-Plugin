local Util = {}
local AutocompleteTypes = require(script.Parent.AutocompleteTypes)
local Lexer = require(script.Parent.Lexer)

function Util.buildReplacement(
	position: AutocompleteTypes.CodePosition,
	newText: string,
	beforeCursor: number,
	afterCursor: number,
	alreadyTyped: number
): AutocompleteTypes.TextEdit
	return {
		newText = newText,
		replace = {
			["start"] = { line = position.line, character = position.character - alreadyTyped },
			["end"] = { line = position.line, character = position.character + #newText },
		},
	}
end

local function matchPatternOnMultiLine(
	document: ScriptDocument,
	line: number,
	char: number,
	patterns: { Start: string, End: string }
): boolean
	local startLine = document:GetLine(line)
	local lineCount = document:GetLineCount()

	if startLine:find(patterns.Start) then
		local endPos = startLine:find(patterns.End)

		if not endPos or endPos >= char then
			return true
		end
	end

	local exceptionCase = startLine:find(patterns.End)
	if exceptionCase then
		return char >= exceptionCase
	end

	local blockStart = nil
	local blockStartLine = nil

	local blockEnd = nil
	local blockEndLine = nil

	for count = line, 1, -1 do
		local currentLine = document:GetLine(count)
		blockStart = currentLine:find(patterns.Start)

		if blockStart then
			local sameLineBlockEnd = currentLine:find(patterns.End)
			if sameLineBlockEnd then
				return false
			end
			blockStartLine = count

			for nextLineNum = count + 1, lineCount do
				local nextLine = document:GetLine(nextLineNum)
				blockEnd = nextLine:find(patterns.End)

				if blockEnd then
					blockEndLine = nextLineNum
					break
				end
			end

			break
		end
	end

	if not blockStart or not blockEnd then
		return false
	end

	if line > blockStartLine and line <= blockEndLine then
		return true
	end

	return false
end

function Util.backTraceComments(document: ScriptDocument, line: number, char: number): boolean
	local startLine = document:GetLine(line)

	local SINGLE_LINE = "%-%-"
	if startLine:match(SINGLE_LINE) then
		return true
	end

	return matchPatternOnMultiLine(document, line, char, { Start = "%-%-%[%[", End = "%]%]" })
end

function Util.backTraceMultiString(document: ScriptDocument, line: number, char: number): boolean
	return matchPatternOnMultiLine(document, line, char, { Start = "%[%[", End = "%]%]" })
end

function Util.getBranchesFromTokenList(tokens: { AutocompleteTypes.Token }): ({ string }, string)
	local branches = {}
	local treeEntryIndex = nil

	for count = 1, #tokens do
		local token = tokens[count]
		if token.name == ":" or token.name == "." then
			if not treeEntryIndex then
				treeEntryIndex = token.name == ":" and "Methods" or "Properties"
			end

			local nextToken = tokens[count + 1]
			if not nextToken then
				break
			end

			if nextToken.name == "identifier" then
				table.insert(branches, nextToken.value)
			end
		end
	end

	return branches, treeEntryIndex
end

function Util.tokenMatches(token: AutocompleteTypes.Token, name: string | { string }, value: any | { any }): boolean
	local function nameMatch()
		return if typeof(name) == "table" then table.find(name, token.name) else token.name == name
	end
	local function valueMatch()
		return if typeof(value) == "table" then table.find(value, token.value) else token.value == value
	end

	if value == nil then
		return nameMatch()
	end
	return nameMatch() and valueMatch()
end

function Util.lexerScanToTokens(line: string): { AutocompleteTypes.Token }
	local tokens = {}
	for x in Lexer.scan(line) do
		table.insert(tokens, x)
	end
	return tokens
end

function Util.flipArray(t: { any })
	for i = 1, math.floor(#t / 2) do
		local j = #t - i + 1
		t[i], t[j] = t[j], t[i]
	end
end

function Util.isTokenSeriesBroken(tokens: { AutocompleteTypes.Token }): boolean
	local broken = false
	for count = 1, #tokens - 1 do
		if Util.tokenMatches(tokens[count], { ":", "." }) and Util.tokenMatches(tokens[count + 1], { ":", "." }) then
			broken = true
			break
		end
	end
	return broken
end

function Util.deepCopy(t: {}): {}
	local new = {}
	for k, v in pairs(t) do
		if type(v) == "table" then
			v = Util.deepCopy(v)
		end
		new[k] = v
	end
	return new
end

function Util.traverseBranchList(current: {}, branchList: { string }): (boolean, {})
	local reachedEnd = false

	if not current then
		return false, nil
	end

	for _, branch in ipairs(branchList) do
		if current.Branches ~= nil then
			if current.Branches[branch] then
				current = current.Branches[branch]
			end
		else
			reachedEnd = true
			break
		end
	end

	return reachedEnd, current
end

function Util.splitStringParameters(str: string): {string}
	local splits = {}
	local nestCount = 0
	local current = ""

	for count = 1, #str do
		local currentChar = str:sub(count, count)
		local ignore = false

		if currentChar:match("[\"(]") then
			nestCount += 1
		elseif currentChar:match("[\")]") then
			nestCount = math.max(nestCount - 1, 0)
		elseif currentChar == "," and CurrentParentheses == 0 then
			table.insert(splits, current)
			current = ""
			ignore = true
		end
		
		if not ignore and (current ~= "" or currentChar ~= " ") then
			current ..= currentChar
		end
	end
	if current ~= "" then
		table.insert(splits, current)
	end
	return splits
end

return Util
