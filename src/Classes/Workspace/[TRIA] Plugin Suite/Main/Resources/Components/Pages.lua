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
    local currentPage = self.pageData.currentPage
    if currentPage == NewPage then
        return
    end
    if self.pageData.pages[currentPage].onClose then
        self.pageData.pages[currentPage].onClose()
    end

    self.pageData.pages[currentPage].Visible:set(false)
    self.pageData.pages[NewPage].Visible:set(true)
    self.pageData.currentPage = NewPage
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
    self.pageData.pages[data.Name] = newPageData

    if newPageData.Visible:get(false) then
        self.pageData.currentPage = newPageData.Name
    end

    return newPageData.Frame
end

return PageHandler
