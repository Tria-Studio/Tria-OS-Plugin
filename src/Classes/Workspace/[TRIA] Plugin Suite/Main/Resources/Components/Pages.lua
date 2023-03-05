local Resources = script.Parent.Parent
local Fusion = require(Resources.Fusion)
local Pages = Resources.Parent.Pages
local Signal = require(script.Parent.Parent.Parent.Util.Signal)

local Value = Fusion.Value

local PageHandler = {
    pageChanged = Signal.new(),
    pageData = {
        pages = {},
        disabledPages = {"Publish"},
        bypassedPages = {"Insert", "Publish"},
        currentPage = Value(nil),
        previousPage = Value(nil),
    },
    _currentPageNum = Value(0),
    _PageOrder = {
        "ObjectTags",
        "ViewModes",
        "Settings",
        "Scripting",
        "Publish",
        "Insert",
        "AudioLibrary"
    }
}

local function updatePageNum(pageName: string)
    PageHandler._currentPageNum:set(table.find(PageHandler._PageOrder, pageName))
end

function PageHandler:ChangePage(newPage: string)
    local currentPage = self.pageData.currentPage:get()
    if currentPage == newPage then
        return
    end
    if self.pageData.pages[currentPage].onClose then
        task.spawn(self.pageData.pages[currentPage].onClose)
    end

    PageHandler.pageChanged:Fire()
    self.pageData.pages[currentPage].Visible:set(false)
    self.pageData.pages[newPage].Visible:set(true)

    self.pageData.previousPage:set(currentPage)
    self.pageData.currentPage:set(newPage)
    updatePageNum(newPage)

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
    newPageData.onOpen = newPage.OnOpen
    self.pageData.pages[data.Name] = newPageData

    if newPageData.Visible:get(false) then
        self.pageData.currentPage:set(newPageData.Name)
        updatePageNum(data.Name)
        if newPageData.onOpen then
            task.spawn(newPageData.onOpen)
        end
    end

    return newPageData.Frame
end

return PageHandler