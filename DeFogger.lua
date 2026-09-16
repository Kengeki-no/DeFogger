--Core initialization

DeFogger = DeFogger or CreateFrame("Frame")
DeFogger:RegisterEvent("ADDON_LOADED")
DeFogger.modules = DeFogger.modules or {}

local coreDefaults = {
    coords = true,
    fogClear = true,
    fogTransparency = 0,
    zoneLevels = true,
    fishingLevels = false,
}

_G["BINDING_HEADER_DEFOGGER"] = "DeFogger"
_G["BINDING_NAME_DEFOGGER_TOGGLE_CONFIG"] = "Toggle Options Panel"

--[[local function Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cff7583ff<DeFogger>|r " .. msg)
end
DeFogger.Print = Print]]

function DeFogger.SetModuleState(name, enable)
    local module = DeFogger.modules[name]
    if not module then return end
    if enable then
        if module.Enable then module.Enable() end
    else
        if module.Disable then module.Disable() end
    end
end

function DeFogger.ToggleConfigFrame()
    if not DeFoggerConfigFrame then return end
    if DeFoggerConfigFrame:IsShown() then
        DeFoggerConfigFrame:Hide()
    else
        DeFoggerConfigFrame:Show()
        DeFoggerConfigFrame:UpdateAllValues()
    end
end

function DeFogger:OnEvent(event, arg1)
    if event ~= "ADDON_LOADED" or arg1 ~= "DeFogger" then return end

    DeFogger.SubSet.SetDefaults(coreDefaults)
    for _, module in pairs(DeFogger.modules) do
        if module.defaults then
            DeFogger.SubSet.SetDefaults(module.defaults)
        end
    end
    DeFogger.SubSet.Start()

    for name, module in pairs(DeFogger.modules) do
        if module.alwaysEnable or DeFogger.SubSet.GetParam(name) == true then
            if module.Enable then module.Enable() end
        end
    end

    if DeFogger.CreateConfigFrame then
        DeFogger.CreateConfigFrame()
    end

end

DeFogger:SetScript("OnEvent", DeFogger.OnEvent)

local function SlashHandler(msg)
    msg = msg and strtrim(msg) or ""
    local cmd = strlower(msg)

    if cmd == "" or cmd == "config" or cmd == "options" then
        DeFogger.ToggleConfigFrame()
    elseif cmd == "reset" then
        DeFogger.SubSet.Reset()
        DeFogger.SetModuleState("coords", DeFogger.SubSet.GetParam("coords") == true)
        DeFogger.SetModuleState("fogClear", DeFogger.SubSet.GetParam("fogClear") == true)
        if DeFoggerConfigFrame then DeFoggerConfigFrame:UpdateAllValues() end
    elseif cmd == "help" then
        DEFAULT_CHAT_FRAME:AddMessage("  |cff00ffb0/df reset|r - Reset settings")
    else
        DeFogger.ToggleConfigFrame()
    end
end

SLASH_DEFOGGER1 = "/defogger"
SLASH_DEFOGGER2 = "/df"
SlashCmdList["DEFOGGER"] = SlashHandler
