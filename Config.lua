--Holds the settings for DeFogger

local SubSet = DeFogger.SubSet
local configFrame
local checkButtons = {}
local sliders = {}

local COLOR_WHITE = {1, 1, 1}
local TOOLTIP_TITLE_COLOR = {1, 1, 0}


local function ApplyProfileState()
    DeFogger.SetModuleState("coords", SubSet.GetParam("coords") == true)
    DeFogger.SetModuleState("fogClear", SubSet.GetParam("fogClear") == true)

    if DeFogger.UpdateFogClearSettings then
        DeFogger.UpdateFogClearSettings()
    end
end


function DeFogger.CreateConfigFrame()
    if configFrame then return end

    configFrame = CreateFrame("Frame", "DeFoggerConfigFrame", UIParent)
    configFrame:SetSize(260, 360)
    configFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 30)
    configFrame:SetFrameStrata("FULLSCREEN_DIALOG")
    configFrame:SetFrameLevel(20)
    configFrame:SetClampedToScreen(true)
    configFrame:EnableMouse(true)
    configFrame:SetMovable(true)
    configFrame:RegisterForDrag("LeftButton")
    configFrame:SetScript("OnDragStart", configFrame.StartMoving)
    configFrame:SetScript("OnDragStop", configFrame.StopMovingOrSizing)

-- Window background and border
    configFrame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 10,
        insets = {
            left = 0,
            right = 0,
            top = 0,
            bottom = 0
        }
    })

    configFrame:SetBackdropColor(0.2, 0.2, 0.2, 1)
    configFrame:SetBackdropBorderColor(0.05, 0.05, 0.05, 0.8)


    -- Window title
    local title = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", configFrame, "TOPLEFT", 18, -12)
    title:SetText("DeFogger Settings")
    title:SetTextColor(1, 1, 0)


    -- Close button
    local closeBtn = CreateFrame("Button", nil, configFrame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", configFrame, "TOPRIGHT", -2, -2)


    -- Single-column content area
    local content = CreateFrame("Frame", nil, configFrame)
    content:SetSize(220, 300)
    content:SetPoint("TOPLEFT", configFrame, "TOPLEFT", 20, -50)


    -- Creates a standard checkbox.
    --
    -- getter/setter are optional and are used for settings that do not
    -- use the normal SubSet.GetParam / SubSet.SetParam system.
    --
    -- onChanged is optional and runs after the setting changes.
    local function CreateCheckbox(
        panel,
        label,
        config,
        desc,
        x,
        y,
        getter,
        setter,
        onChanged
    )
        local cb = CreateFrame(
            "CheckButton",
            "DeFoggerOpt_" .. config,
            panel,
            "OptionsCheckButtonTemplate"
        )

        cb:SetPoint("TOPLEFT", panel, "TOPLEFT", x, y)


        local text = _G[cb:GetName() .. "Text"]

        text:SetText(label)
        text:SetTextColor(unpack(COLOR_WHITE))
        text:SetFontObject("GameFontNormal")


        -- Checkbox clicked
        cb:SetScript("OnClick", function(self)
            local value = self:GetChecked() and true or false

            if setter then
                setter(value)
            else
                SubSet.SetParam(config, value)
            end

            if onChanged then
                onChanged(value)
            end
        end)


        -- Tooltip
        cb:SetScript("OnEnter", function(self)
            local tooltipTitle = string.gsub(label, "\n", " ")

            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(
                tooltipTitle,
                unpack(TOOLTIP_TITLE_COLOR)
            )

            GameTooltip:AddLine(
                desc,
                1,
                1,
                1,
                true
            )

            GameTooltip:Show()
        end)


        cb:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)


        -- Refresh displayed checkbox state
        cb.UpdateValue = function()
            if getter then
                cb:SetChecked(getter())
            else
                cb:SetChecked(SubSet.GetParam(config) == true)
            end
        end


        table.insert(checkButtons, cb)

        return cb
    end


    -- Creates a standard slider
    local function CreateSlider(
        panel,
        label,
        config,
        minVal,
        maxVal,
        stepVal,
        fmt,
        desc,
        x,
        y
    )
        local slider = CreateFrame(
            "Slider",
            "DeFoggerSlider_" .. config,
            panel,
            "OptionsSliderTemplate"
        )

        slider:SetMinMaxValues(minVal, maxVal)
        slider:SetValueStep(stepVal)
        slider:SetPoint("TOPLEFT", panel, "TOPLEFT", x, y)
        slider:SetWidth(180)


        local titleText = _G[slider:GetName() .. "Text"]
        local lowText = _G[slider:GetName() .. "Low"]
        local highText = _G[slider:GetName() .. "High"]

        titleText:SetText(label)
        titleText:SetTextColor(1, 1, 1)

        lowText:SetText(tostring(minVal))
        highText:SetText(tostring(maxVal))


        local valueText = slider:CreateFontString(
            nil,
            "OVERLAY",
            "GameFontHighlightSmall"
        )

        valueText:SetPoint("TOP", slider, "BOTTOM", 0, -2)


        slider:SetScript("OnValueChanged", function(self, value)
            value = math.floor(value / stepVal + 0.5) * stepVal

            valueText:SetText(
                string.format(fmt, value)
            )

            if self.updating then
                return
            end

            SubSet.SetParam(config, value)

            if config == "fogTransparency"
            and DeFogger.UpdateFogClearSettings then
                DeFogger.UpdateFogClearSettings()
            end
        end)


        -- Tooltip
        slider:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")

            GameTooltip:SetText(
                label,
                unpack(TOOLTIP_TITLE_COLOR)
            )

            GameTooltip:AddLine(
                desc,
                1,
                1,
                1,
                true
            )

            GameTooltip:Show()
        end)


        slider:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)


        slider.UpdateValue = function()
            local value = SubSet.GetParam(config) or minVal

            slider.updating = true
            slider:SetValue(value)
            slider.updating = false

            valueText:SetText(
                string.format(fmt, value)
            )
        end


        slider.SetControlEnabled = function(self, enabled)
            self:EnableMouse(enabled)
            self:SetAlpha(enabled and 1 or 0.35)
        end


        table.insert(sliders, slider)

        return slider
    end


    -- Forward declaration because Clear Map Fog controls this slider.
    local fogSlider


    -- Show Fishing Levels
    CreateCheckbox(
        content,
        "Show Fishing Levels",
        "fishingLevels",
        "Shows the minimum recommended fishing level to fish in a given zone when hovering the mouse over a zone.",
        15,
        -10
    )


    -- Show Zone Levels
    CreateCheckbox(
        content,
        "Show Zone Levels",
        "zoneLevels",
        "Shows the level range of a given zone when hovering the mouse over a zone.",
        15,
        -45
    )


    -- Clear Map Fog
    CreateCheckbox(
        content,
        "Clear Map Fog",
        "fogClear",
        "Replaces default brown fog with a transparent grey. Can use slider to remove fog entirely.",
        15,
        -80,
        nil,
        nil,

        function(value)
            DeFogger.SetModuleState("fogClear", value)

            if fogSlider then
                fogSlider:SetControlEnabled(value)
            end
        end
    )


    -- Fog Transparency
    fogSlider = CreateSlider(
        content,
        "Fog Transparency",
        "fogTransparency",
        0,
        1,
        0.05,
        "%.2f",
        "Changes the intensity of the transparent fog. Setting it to 1 removes all fog entirely.",
        15,
        -145
    )


    -- Show Coordinates
    CreateCheckbox(
        content,
        "Show Coordinates",
        "coords",
        "Show player and cursor coordinates along the bottom of the world map.",
        15,
        -205,
        nil,
        nil,

        function(value)
            DeFogger.SetModuleState("coords", value)
        end
    )


    -- Keep settings for current character
    CreateCheckbox(
        content,
        "Keep settings for\nthis character only",
        "perCharacter",
        "When enabled, changes to DeFogger settings are saved for this character only.\n(Check this box first before making changes!)",
        15,
        -240,

        function()
            return SubSet.IsCharActive()
        end,

        function(value)
            SubSet.SetCharActive(value)
            ApplyProfileState()
            configFrame:UpdateAllValues()
        end
    )


    -- Restore Defaults
    local resetBtn = CreateFrame(
        "Button",
        nil,
        content,
        "UIPanelButtonTemplate"
    )

    resetBtn:SetSize(130, 24)

    resetBtn:SetPoint(
        "TOPLEFT",
        content,
        "TOPLEFT",
        40,
        -280
    )

    resetBtn:SetText("Restore Defaults")


    resetBtn:SetScript("OnClick", function()
        SubSet.Reset()
        ApplyProfileState()
        configFrame:UpdateAllValues()
    end)


    -- Update every control to reflect the currently active profile
    configFrame.UpdateAllValues = function()

        for _, cb in ipairs(checkButtons) do
            cb:UpdateValue()
        end

        for _, slider in ipairs(sliders) do
            slider:UpdateValue()
        end

        -- Fog transparency only works while fog clearing is enabled
        fogSlider:SetControlEnabled(
            SubSet.GetParam("fogClear") == true
        )
    end


    configFrame:UpdateAllValues()
    configFrame:Hide()
end