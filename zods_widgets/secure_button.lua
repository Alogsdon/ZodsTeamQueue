local widgets = ZODS_WIDGETS_LIB

widgets.CreateSecureButton = function(width, height, options)
    options = options or {}
    local parent = options.parent or UIParent
    local text = options.text
    local macrotext = options.macrotext
    local button = CreateFrame('Button', nil, parent, 'SecureActionButtonTemplate')
    button:SetWidth(width)
    button:SetHeight(height)
    button:SetAttribute('type', 'macro')
    button:SetAttribute('macrotext', macrotext)
    button:SetText(text)
	button:SetNormalFontObject("GameFontNormal")
    button:RegisterForClicks("AnyUp","AnyDown")

    local ntex = button:CreateTexture()
	ntex:SetTexture('Interface/Buttons/UI-Panel-Button-Up')
	ntex:SetTexCoord(0, 0.625, 0, 0.6875)
	ntex:SetAllPoints()	
	button:SetNormalTexture(ntex)

	local htex = button:CreateTexture()
	htex:SetTexture('Interface/Buttons/UI-Panel-Button-Highlight')
	htex:SetTexCoord(0, 0.625, 0, 0.6875)
	htex:SetAllPoints()
	button:SetHighlightTexture(htex)

	local ptex = button:CreateTexture()
	ptex:SetTexture('Interface/Buttons/UI-Panel-Button-Down')
	ptex:SetTexCoord(0, 0.625, 0, 0.6875)
	ptex:SetAllPoints()
	button:SetPushedTexture(ptex)

	local dtex = button:CreateTexture()
	dtex:SetTexture('Interface/Buttons/UI-Panel-Button-Disabled')
	dtex:SetTexCoord(0, 0.625, 0, 0.6875)
	dtex:SetAllPoints()
	button:SetDisabledTexture(dtex)

	return button
end

