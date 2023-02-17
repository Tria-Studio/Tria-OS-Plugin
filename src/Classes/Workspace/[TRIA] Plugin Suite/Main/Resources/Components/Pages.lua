local Resources = script.Parent.Parent
local Fusion = require(Resources.Fusion)
local Pages = Resources.Parent.Pages
local Signal = require(script.Parent.Parent.Parent.Util.Signal)

local Value = Fusion.Value

local PageHandler = {
    pageChanged = Signal.new(),
    pageData = {
        pages = {},
        bypassedPages = {"Insert", "Publish"},
        currentPage = Value(nil),
    }
}

function PageHandler:ChangePage(newPage: string)
    local currentPage = self.pageData.currentPage:get()
    if currentPage == newPage then
        return
    end
    if self.pageData.pages[currentPage].onClose then
        self.pageData.pages[currentPage].onClose()
    end

    PageHandler.pageChanged:Fire()
    self.pageData.pages[currentPage].Visible:set(false)
    self.pageData.pages[newPage].Visible:set(true)
    self.pageData.currentPage:set(newPage)

    if self.pageData.pages[newPage].onOpen then
        self.pageData.pages[newPage].onOpen()
    end
end

function PageHandler:NewPage(data: {[string]: any}): Instance
    local newPageData = {
        Name = data.Name,
        Frame = nil,
        Visible = Value(data.Default),
    }

    local newPage = require(Pages:FindFirstChild(newPageData.Name))
    newPageData.Frame = newPage:GetFrame(newPageData)
    newPageData.onClose = newPage.OnClose
    self.pageData.pages[data.Name] = newPageData

    if newPageData.Visible:get(false) then
        self.pageData.currentPage:set(newPageData.Name)
        -- Avoid loop
        require(Resources.Parent.Util)._currentPageNum:set(table.find(require(Resources.Parent.Util)._PageOrder, data.Name))
    end

    return newPageData.Frame
end

return PageHandler
