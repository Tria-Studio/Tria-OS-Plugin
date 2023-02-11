local Util = {}
local Lexer = require(script.Parent.Lexer)

function Util.buildReplacement(position, newText: string, beforeCursor: number, afterCursor: number, alreadyTyped: number)
	return {
		newText = newText,
		replace = {
			["start"] = {line = position.line, character = position.character - alreadyTyped},
			["end"] = {line = position.line, character = position.character + #newText + afterCursor},
		}
	}
end

function Util.backTraceComments(document: ScriptDocument, line: number, char: number): boolean
	local startLine = document:GetLine(line)
	local lineCount = document:GetLineCount()

	local SINGLE_LINE = "%-%-"
	local COMMENT_START = "%-%-%[%["
	local COMMENT_END = "%]%]"

	if startLine:find(COMMENT_START) then
		local commentEnd = startLine:find(COMMENT_END)

		if not commentEnd or commentEnd >= char then
			return true
		end
	elseif startLine:match(SINGLE_LINE) then
		return true
	end

	local exceptionCase = startLine:find(COMMENT_END)
	if exceptionCase and char >= exceptionCase then
		return false
	end

	local blockStart = nil
	local blockStartLine = nil

	local blockEnd = nil
	local blockEndLine = nil

	for count = line, 1, -1 do
		local currentLine = document:GetLine(count)
		blockStart = currentLine:find(COMMENT_START)

		if blockStart then
			local sameLineBlockEnd = currentLine:find(COMMENT_END)
			if sameLineBlockEnd then
				return false
			end
			blockStartLine = count

			for nextLineNum = count + 1, lineCount do
				local nextLine = document:GetLine(nextLineNum)
				blockEnd = nextLine:find(COMMENT_END)

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

function Util.getBranchesFromTokenList(tokens: {Lexer.Token}): {string}	
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

function Util.tokenMatches(token: Lexer.Token, name: string, value: any)
	if value == nil then
		return token.name == name
	end
	return token.name == name and token.value == value
end

function Util.lexerScanToTokens(line: string): {Lexer.Token}
	local tokens = {}
	for x in Lexer.scan(line) do
		table.insert(tokens, x)
	end
	return tokens
end

function Util.flipArray(t: {any})
	for i = 1, math.floor(#t / 2) do
		local j = #t - i + 1
		t[i], t[j] = t[j], t[i]
	end
end

return Util