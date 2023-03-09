local widgets = ZODS_WIDGETS_LIB

local function CloseButton_Click(frame)
    frame.CloseTarget:Hide()
end

local function SizerSE_OnMouseDown(frame)
    frame:GetParent():StartSizing('BOTTOMRIGHT')
end

local function Title_OnMouseDown(frame)
    frame:GetParent():StartMoving()
end

local function MoverSizer_OnMouseUp(mover)
    local frame = mover:GetParent()
    frame:StopMovingOrSizing()
end

local createTitleBar = function(parent, title, movable)
    if not title then return end

    local titlebg = parent:CreateTexture(nil, 'OVERLAY')
    titlebg:SetTexture(131080) -- Interface\\DialogFrame\\UI-DialogBox-Header
    titlebg:SetTexCoord(0.31, 0.67, 0, 0.63)
    titlebg:SetPoint('TOP', 0, 0)
    titlebg:SetPoint('LEFT', 5, 0)
    titlebg:SetPoint('RIGHT', -35, 0)
    titlebg:SetHeight(40)

    if movable then
        local mover = CreateFrame('Frame', nil, parent)
        mover:EnableMouse(true)
        mover:SetScript('OnMouseDown', Title_OnMouseDown)
        mover:SetScript('OnMouseUp', MoverSizer_OnMouseUp)
        mover:SetAllPoints(titlebg)
    end

    if type(title) == 'string' then
        local titletext = parent:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
        titletext:SetPoint('TOP', titlebg, 'TOP', 0, -14)
        titletext:SetText(title)
        titlebg:SetWidth(titlebg:GetWidth())
    end
end

local createCloser = function(parent)
    local closebutton = CreateFrame('Button', nil, parent, 'UIPanelButtonTemplate')
    closebutton.CloseTarget = parent
    closebutton:SetScript('OnClick', CloseButton_Click)
    closebutton:SetPoint('TOPRIGHT', -2, -2)
    closebutton:SetHeight(30)
    closebutton:SetWidth(30)
    closebutton:SetText('X')
end

local createResizer = function(parent)
    local sizer_se = CreateFrame('Frame', nil, parent)
    sizer_se:SetPoint('BOTTOMRIGHT')
    sizer_se:SetWidth(30)
    sizer_se:SetHeight(30)
    sizer_se:EnableMouse()
    sizer_se:SetScript('OnMouseDown', SizerSE_OnMouseDown)
    sizer_se:SetScript('OnMouseUp', MoverSizer_OnMouseUp)

    local line1 = sizer_se:CreateTexture(nil, 'BACKGROUND')
    line1:SetWidth(14)
    line1:SetHeight(14)
    line1:SetPoint('BOTTOMRIGHT', -8, 8)
    line1:SetTexture(137057) -- Interface\\Tooltips\\UI-Tooltip-Border
    local x = 0.1 * 14 / 17
    line1:SetTexCoord(0.05 - x, 0.5, 0.05, 0.5 + x, 0.05, 0.5 - x, 0.5 + x, 0.5)

    local line2 = sizer_se:CreateTexture(nil, 'BACKGROUND')
    line2:SetWidth(8)
    line2:SetHeight(8)
    line2:SetPoint('BOTTOMRIGHT', -8, 8)
    line2:SetTexture(137057) -- Interface\\Tooltips\\UI-Tooltip-Border
    local x = 0.1 * 8 / 17
    line2:SetTexCoord(0.05 - x, 0.5, 0.05, 0.5 + x, 0.05, 0.5 - x, 0.5 + x, 0.5)
end

widgets.CreateWindow = function(width, height, options)
    options = options or {}
    local resizable = options.resizable
    local movable = options.movable
    local closable = options.closable
    local minWidth = options.minWidth or width
    local minHeight = options.minHeight or width
    local parent = options.parent or UIParent
    local title = options.title
    -- defaults over nil
    if type(closable) == 'nil' then closable = true end
    if type(title) == 'nil' then title = true end
    if type(movable) == 'nil' then movable = true end

    local window = CreateFrame('Frame', options.name, parent, 'InsetFrameTemplate')
    window:SetWidth(width)
    window:SetHeight(height)
    window:EnableMouse()
    window:SetMovable(true)
    window:SetResizable(true)
    window:SetResizeBounds(minWidth, minHeight)
    window:SetPoint('CENTER', 0, 0)
    window:Hide()

    if resizable then
        createResizer(window)
    end

    createTitleBar(window, title, movable)
    if closable then
        createCloser(window)
    end
    return window
end
