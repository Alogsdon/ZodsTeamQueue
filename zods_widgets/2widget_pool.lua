local AddonName, AddonVars = ...


local WidgetPools = {}
AddonVars.ZodsWigets.pools = WidgetPools

function WidgetPools.pop(widgetType)

end


--[[ Entire block commented out
print( 10 )
print( 15 )


local function WidgetCustructorWrapper(widgetType, parent)
    local frameLevel = WidgetLevels[widgetType] or 0
    local widget = WidgetConstructors[widgetType](parent, frameLevel)
    widget.widgetType = widgetType
    if widget.SetFrameStrata then widget:SetFrameStrata(DYNAMIC_STRATA) end
    if widget.SetFrameLevel and frameLevel then widget:SetFrameLevel(frameLevel) end
    local Reset = WidgetReseters[widgetType] or dummyReset
    widget.Reset = Reset
    return widget
end

local function WidgetResetWrapper(widget)
    widget.released = false
    widget.inflatedHeight = nil
    widget.topOffset = nil
    if widget.AddChild then widget.children = {} end
    widget.Reset()
end

function Addon:CreateDynamicWidget(widgetType, parent)
    Addon.poolsByType = Addon.poolsByType or {}
    Addon.poolsByType[widgetType] = Addon.poolsByType[widgetType] or {}
    local pool = Addon.poolsByType[widgetType]
    local widget
    if #pool >= 1 then
        widget = table.remove(pool)
    else
        widget = WidgetCustructorWrapper(widgetType, parent)
    end
    WidgetResetWrapper(widget)
    return widget
end

function Addon:ReleaseDynamicWidget(widget)
    if widget.released == true then print('widget already released') return end
    local widgetType = widget.widgetType
    Addon.poolsByType = Addon.poolsByType or {}
    Addon.poolsByType[widgetType] = Addon.poolsByType[widgetType] or {}
    local pool = Addon.poolsByType[widgetType]
    if widget.children then
        for _, child in ipairs(widget.children) do
            self:ReleaseDynamicWidget(child)
        end
        widget.children = {}
    end
    widget.released = true
    widget:Hide()
    table.insert(pool, widget)
end

--]]