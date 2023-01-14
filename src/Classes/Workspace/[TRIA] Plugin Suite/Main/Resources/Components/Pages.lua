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
    if PageHandler.pageData.currentPage == NewPage then
        return
    end

    PageHandler.pageData.pages[PageHandler.pageData.currentPage].Visible:set(false)
    PageHandler.pageData.pages[NewPage].Visible:set(true)
    PageHandler.pageData.currentPage = NewPage
end

function PageHandler:NewPage(data)
    local newPageData = {
        Name = data.Name,
        Frame = nil,
        Visible = Value(data.Default)
    }

    newPageData.Frame = require(Pages:FindFirstChild(newPageData.Name)):GetFrame(newPageData)
    PageHandler.pageData.pages[data.Name] = newPageData

    if newPageData.Visible:get() then
        PageHandler.pageData.currentPage = newPageData.Name
    end

    return newPageData.Frame
end

return PageHandler