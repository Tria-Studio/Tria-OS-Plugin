export type Token = {
	name: string, 
	value: string
}

export type CodePosition = {
	line: number,
	character: number
}

export type TextEdit = {
	newText: string,
	replace: {
		["start"]: CodePosition,
		["end"]: CodePosition
	}
}

export type Request = {
	position: CodePosition,
	textDocument: {
		document: ScriptDocument?,
		script: LuaSourceContainer?
	}
}

export type Response = {
	items: {
	  {
		label: string, -- The label
		kind: Enum.CompletionItemKind?,
		tags: {Enum.CompletionItemTag}?,
		detail: string?,
		documentation: {
		  value: string,
		}?,
		overloads: number?,
		learnMoreLink: string?,
		codeSample: string?,
		preselect: boolean?,
		textEdit: TextEdit?
	  }
	}
  }

return nil