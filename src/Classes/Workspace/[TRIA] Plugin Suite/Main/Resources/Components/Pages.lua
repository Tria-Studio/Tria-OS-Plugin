local Resources = script.Parent.Parent
local Fusion = require(Resources.Fusion)
local Pages = Resources.Parent.Pages

local Value = Fusion.Value

local PageHandler = {
    pageData = {
        pages = {},
        currentPage = nil,
    }
}

function PageHandler:ChangePage(NewPage: string)
    local currentPage = PageHandler.pageData.currentPage
    if currentPage == NewPage then
        return
    end
    if PageHandler.pageData.pages[currentPage].onClose then
        PageHandler.pageData.pages[currentPage].onClose()
    end

    PageHandler.pageData.pages[currentPage].Visible:set(false)
    PageHandler.pageData.pages[NewPage].Visible:set(true)
    PageHandler.pageData.currentPage = NewPage
end

function PageHandler:NewPage(data)
    local newPageData = {
        Name = data.Name,
        Frame = nil,
        Visible = Value(data.Default),

    }
    local newPage = require(Pages:FindFirstChild(newPageData.Name))
    newPageData.Frame = newPage:GetFrame(newPageData)
    newPageData.onClose = newPage.OnClose
    PageHandler.pageData.pages[data.Name] = newPageData

    if newPageData.Visible:get() then
        PageHandler.pageData.currentPage = newPageData.Name
    end

    return newPageData.Frame
end

return PageHandler
