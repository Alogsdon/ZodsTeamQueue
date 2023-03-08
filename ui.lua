local AddonName, AddonVars = ...

AddonVars.modules.ui = {}
local ui = AddonVars.modules.ui

local frameName = 'ZODS_TEAM_QUEUE_FRAME'
local frame -- let the initializer make it

local function CloseButton_Click(frame)
    frame.CloseTarget:Hide()
end

local function Title_OnMouseDown(frame)
	frame:GetParent():StartMoving()
end

local function MoverSizer_OnMouseUp(mover)
	local frame = mover:GetParent()
	frame:StopMovingOrSizing()
end

local function CreateWindowFrame()
    frame = CreateFrame("Frame", frameName, UIParent, 'InsetFrameTemplate')
    frame:SetWidth(500)
    frame:SetHeight(400)
    frame:EnableMouse()
    frame:SetMovable(true)
    frame:SetResizable(true)
    frame:SetResizeBounds(500, 400)
    frame:SetPoint("CENTER",0,0)
    ui.windowFrame = frame
    frame:Hide()

    local titlebg = frame:CreateTexture(nil, "OVERLAY")
	titlebg:SetTexture(131080) -- Interface\\DialogFrame\\UI-DialogBox-Header
	titlebg:SetTexCoord(0.31, 0.67, 0, 0.63)
	titlebg:SetPoint("TOP", 0, 0)
	titlebg:SetPoint("LEFT", 5, 0)
    titlebg:SetPoint("RIGHT", -20, 0)
	titlebg:SetHeight(25)

	local title = CreateFrame("Frame", nil, frame)
	title:EnableMouse(true)
	title:SetScript("OnMouseDown", Title_OnMouseDown)
	title:SetScript("OnMouseUp", MoverSizer_OnMouseUp)
	title:SetAllPoints(titlebg)


    local closebutton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    closebutton.CloseTarget = frame
	closebutton:SetScript("OnClick", CloseButton_Click)
	closebutton:SetPoint("TOPRIGHT", 0, 0)
	closebutton:SetHeight(20)
	closebutton:SetWidth(20)
	closebutton:SetText('X')
end

function ui:Show()
    local frame = self.windowFrame
    if frame then
        frame:Show()
    end
end

function ui:Init()
    _G[frameName] = CreateWindowFrame()
end

