local Resources = script.Parent.Parent
local Pages = Resources.Parent.Pages

local Fusion = require(Resources.Fusion)
local Signal = require(Resources.Parent.Util.Signal)
local PublicTypes = require(Resources.Parent.PublicTypes)

local Value = Fusion.Value

local PageHandler = {
    pageLayout = Value(),
    pageChanged = Signal.new(),
    pageData = {
        pages = {},
        disabledPages = {"Publish"},
        bypassedPages = {"Insert", "Publish"},
        currentPage = Value(nil),
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

function updatePageNum(pageName: string)
    PageHandler._currentPageNum:set(table.find(PageHandler._PageOrder, pageName))
end

function PageHandler:ChangePage(newPage: string)
    local mainPageData = self.pageData
    local currentPage = mainPageData.currentPage:get()
    if currentPage == newPage then
        return
    end

    local currentPageData = mainPageData.pages[currentPage]
    local newPageData = mainPageData.pages[newPage]

    if currentPageData.onClose then
        task.spawn(currentPageData.onClose)
    end

    PageHandler.pageChanged:Fire()
    mainPageData.currentPage:set(newPage)
    self.pageLayout:get():JumpToIndex(newPageData.PageIndex)
    updatePageNum(newPage)

    if newPageData.onOpen then
        task.spawn(newPageData.onOpen)
    end
end

function PageHandler:NewPage(data: PublicTypes.Dictionary, index: number): Instance
    local newPageData = {
        Name = data.Name,
        Frame = nil,
        Visible = true,
        PageIndex = index
    }

    local newPage = require(Pages:FindFirstChild(newPageData.Name))
    newPageData.Frame = newPage:GetFrame(newPageData)
    newPageData.Frame.LayoutOrder = index
    newPageData.onClose = newPage.OnClose
    newPageData.onOpen = newPage.OnOpen

    self.pageData.pages[data.Name] = newPageData
    if data.Default then
        self:ChangePage(data.Name)
    end

    return newPageData.Frame
end

return PageHandler
