local Fusion = require(script.Parent.Resources.Fusion)
local Signal = require(script.Signal)
local Maid = require(script.Maid)

local State = Fusion.State
local Computed = Fusion.Computed

local defaultMessageResponses = {
    "Ok",
    "Fine",
    "Sure",
    "Whatever",
    "k",
    "Got it",
    "Alright",
    "Yeah",
}
local util = {
    Signal = Signal,
    Maid = Maid,

    Widget = nil,
    mapModel = State(nil),
    MapChanged = Signal.new(),
    MainMaid = Maid.new(),

    buttonsActive = State(true),

    _Topbar = {
        FreezeFrame = State(false)
    },
    _Message = {
        Text = State(""),
        Header = State(""),
        Option1 = State({}),
        Option2 = State({}),
    }
}



util.buttonActiveFunc = function()
    return util.mapModel:get() and util.buttonsActive:get()
end

Computed(function()
    util.buttonsActive:set(util._Message.Text:get() == "")
end)


function util.CloseMessage()
    util._Message.Text:set("")
    util._Message.Header:set("")
    util._Message.Option1:set({})
    util._Message.Option2:set({})
end

function util:ShowMessage(header: string, text: string, option1: any?, option2: any?)
    util._Message.Text:set(text)
    util._Message.Header:set(header)
    util._Message.Option1:set(option1 or {Text = defaultMessageResponses[math.random(1, #defaultMessageResponses)], Callback = util.CloseMessage})
    util._Message.Option2:set(option2 or {})
end

return util
