--[[

Original code from: https://devforum.roblox.com/t/lexer-for-rbx-lua/183115
Modified and adapted for TRIA.os Plugin :D

]]

local Lexer = {}
local AutocompleteTypes = require(script.Parent.AutocompleteTypes)

local NUMBER3	= "^0x[%da-fA-F]+"
local NUMBER4	= "^%d+%.?%d*[eE][%+%-]?%d+"
local NUMBER5	= "^%d+%.?%d*"
local IDEN		= "^[%a_][%w_]*"
local WSPACE	= "^%s+"
local STRING1	= "^(['\"])%1"							--Empty String
local STRING2	= [[^(['"])(\*)%2%1]]
local STRING3	= [[^(['"]).-[^\](\*)%2%1]]
local STRING4	= "^(['\"]).-.*"						--Incompleted String
local STRING5	= "^%[(=*)%[.-%]%1%]"					--Multiline-String
local STRING6	= "^%[%[.-.*"							--Incompleted Multiline-String
local CHAR1		= "^''"
local CHAR2		= [[^'(\*)%1']]
local CHAR3		= [[^'.-[^\](\*)%1']]
local PREPRO	= "^#.-[^\\]\n"
local MCOMMENT1	= "^%-%-%[(=*)%[.-%]%1%]"				--Completed Multiline-Comment
local MCOMMENT2	= "^%-%-%[%[.-.*"						--Incompleted Multiline-Comment
local SCOMMENT1	= "^%-%-.-\n"							--Completed Singleline-Comment
local SCOMMENT2	= "^%-%-.-.*"							--Incompleted Singleline-Comment

local KEYWORDS = require(script.Keywords) 
local BUILTIN = require(script.Builtins)

local function createToken(name: string, value: string): AutocompleteTypes.Token
	return {name = name, value = value}
end

local function basicToken(result: string): AutocompleteTypes.Token
	return coroutine.yield(createToken(result, result))
end

local function numberToken(result: string): AutocompleteTypes.Token
	return coroutine.yield(createToken("number", result))
end

local function stringToken(result: string): AutocompleteTypes.Token
	return coroutine.yield(createToken("string", result))
end

local function commentToken(result: string): AutocompleteTypes.Token
	return coroutine.yield(createToken("comment", result))
end

local function whitespaceToken(result: string): AutocompleteTypes.Token
	return coroutine.yield(createToken("space", result))
end

local function identifierToken(result: string): AutocompleteTypes.Token
	if (KEYWORDS[result]) then
		return coroutine.yield(createToken("keyword", result))
	elseif (BUILTIN[result]) then
		return coroutine.yield(createToken("builtin", result))
	else
		return coroutine.yield(createToken("identifier", result))
	end
end

local MATCHES = {
	{IDEN,      identifierToken},        -- Indentifiers
	{WSPACE,    whitespaceToken},           -- Whitespace
	{NUMBER3,   numberToken},            -- Numbers
	{NUMBER4,   numberToken},
	{NUMBER5,   numberToken},
	{STRING1,   stringToken},            -- Strings
	{STRING2,   stringToken},
	{STRING3,   stringToken},
	{STRING4,   stringToken},
	{STRING5,   stringToken},            -- Multiline-Strings
	{STRING6,   stringToken},            -- Multiline-Strings

	{MCOMMENT1, commentToken},            -- Multiline-Comments
	{MCOMMENT2, commentToken},			
	{SCOMMENT1, commentToken},            -- Singleline-Comments
	{SCOMMENT2, commentToken},

	{"^==",     basicToken},            -- Operators
	{"^~=",     basicToken},
	{"^<=",     basicToken},
	{"^>=",     basicToken},
	{"^%.%.%.", basicToken},
	{"^%.%.",   basicToken},
	{"^.",      basicToken}
}

function Lexer.scan(line: string): () -> () -> AutocompleteTypes.Token
	local function analyze(str: string): () -> AutocompleteTypes.Token
		local currentLine = 0
		local currentIndex = 1
		local stringSize = #line
		
		local function handleRequest(result: string)
			while result do
				local resultType = type(result)
				if (resultType == "table") then
					result = coroutine.yield("", "")
					for i = 1, #result do
						local tbl = result[i]
						result = coroutine.yield(tbl[1], tbl[2])
					end
				elseif (resultType == "string") then
					local startPos, endPos = string.find(line, result, currentIndex)
					if startPos then
						local token = line:sub(startPos, endPos)
						currentIndex = endPos + 1
						result = coroutine.yield("", token)
					else
						result = coroutine.yield("", "")
						currentIndex = (stringSize + 1)
					end
				else
					result = coroutine.yield(currentLine, currentIndex)
				end
			end
		end

		handleRequest(str)
		currentLine = 1

		while true do
			if (currentIndex > stringSize) then
				while true do
					handleRequest(coroutine.yield())
				end
			end

			for matchIndex = 1, #MATCHES do
				local matchTbl = MATCHES[matchIndex]
				
				local pattern = matchTbl[1]
				local tokenFunc = matchTbl[2]
				
				local findResult = {string.find(line, pattern, currentIndex)}
				local startPos, endPos = findResult[1], findResult[2]
				
				if startPos then
					local token = line:sub(startPos, endPos)
					
					currentIndex = endPos + 1
					Lexer.finished = (currentIndex > stringSize)
					
					local tokenResult = tokenFunc(token, findResult)
					
					if (token:find("\n")) then
						local _, newlines = token:gsub("\n", {})
						currentLine += newlines
					end
					
					handleRequest(tokenResult)
					break
				end
			end
		end
	end

	return coroutine.wrap(analyze)
end

return Lexer