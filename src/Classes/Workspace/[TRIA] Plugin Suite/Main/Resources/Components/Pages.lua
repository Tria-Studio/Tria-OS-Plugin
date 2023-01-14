local Resources = script.Parent.Parent
local Fusion = require(Resources.Fusion)
local Pages = Resources.Parent.Pages

local State = Fusion.State

local pages = {
    pageData = {
        pages = {},
        currentPage = nil,
    }
}

function pages:ChangePage(NewPage: string)
    if pages.pageData.currentPage == NewPage then
        return
    end

    pages.pageData.pages[pages.pageData.currentPage].Visible:set(false)
    pages.pageData.pages[NewPage].Visible:set(true)
    pages.pageData.currentPage = NewPage
end

function pages:NewPage(data)
    local newPageData = {
        Name = data.Name,
        Frame = nil,
        Visible = State(data.Default)
    }

    newPageData.Frame = require(Pages:FindFirstChild(newPageData.Name)):GetFrame(newPageData)
    pages.pageData.pages[data.Name] = newPageData

    if newPageData.Visible:get() then
        pages.pageData.currentPage = newPageData.Name
    end

    return newPageData.Frame
end

return pages