local Package = script.Parent.Parent.Parent
local Resources = Package.Resources
local Pages = Resources.Parent.Pages

local Fusion = require(Resources.Fusion)
local PublicTypes = require(Package.PublicTypes)
local Signal = require(Package.Util.Signal)

local Value = Fusion.Value
local plugin = script:FindFirstAncestorWhichIsA("Plugin")

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
        "DataVisualizer",
        "Settings",
        "Scripting",
        "Publish",
        "Insert",
        "AudioLibrary"
    }
}

local welcomeData = require(script.WelcomeData)

local function updatePageNum(pageName: string)
    PageHandler._currentPageNum:set(table.find(PageHandler._PageOrder, pageName))
end

local function showPageWelcome(pageName: string)
    local pageWelcomeData = welcomeData[pageName]
    if pageWelcomeData then
        local settingName = "TRIA_HasViewed-" .. pageWelcomeData.Setting
        if not plugin:GetSetting(settingName) then
            plugin:SetSetting(settingName, true)
            require(Package.Util):ShowMessage(pageWelcomeData.Title, pageWelcomeData.Description)
        end
    end
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

    task.delay(.05, function()
        if self.pageData.currentPage.currentPage:get() == newPage then
            showPageWelcome(newPage)
        end
    end)
end

function PageHandler:NewPage(data: PublicTypes.Dictionary): Instance
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
        task.defer(showPageWelcome, data.Name)
    end

    return newPageData.Frame
end

return PageHandler
