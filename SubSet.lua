--[[Stores DeFogger sub-settings

Settings are shared between characters by default.
When "Keep settings for this character only" is enabled,
that character gets its own copy of the settings instead.]]

DeFogger = DeFogger or CreateFrame("Frame")
DeFoggerSubSet = DeFoggerSubSet or {}

local SubSet = {}
DeFogger.SubSet = SubSet


-- Default values by DeFogger and its modules.
local defaults = {}

-- Returns a unique name for the current character.
local charName

local function GetCharName()
    if not charName then
        local name = UnitName("player")
        local realm = GetRealmName()

        if name and name ~= "" and realm and realm ~= "" then
            charName = name .. "-" .. realm
        end
    end

    return charName or "Unknown-Default"
end

-- Registers default setting values.
function SubSet.SetDefaults(tbl)
    for config, value in pairs(tbl) do
        defaults[config] = value
    end
end

-- Creates the saved settings tables and fills in any missing defaults.
function SubSet.Start()
    DeFoggerSubSet.global = DeFoggerSubSet.global or {}
    DeFoggerSubSet.char = DeFoggerSubSet.char or {}
    DeFoggerSubSet.charActive = DeFoggerSubSet.charActive or {}

    for config, value in pairs(defaults) do
        if DeFoggerSubSet.global[config] == nil then
            DeFoggerSubSet.global[config] = value
        end
    end
end

-- Returns whether this character is using its own settings.
function SubSet.IsCharActive()
    local char = GetCharName()

    return DeFoggerSubSet.charActive[char] == true
end

-- Enables or disables character-specific settings.
function SubSet.SetCharActive(active)
    local char = GetCharName()

    if active then
        DeFoggerSubSet.charActive[char] = true
        DeFoggerSubSet.char[char] = DeFoggerSubSet.char[char] or {}

        -- Start the character profile with the current shared settings.
        for setting, value in pairs(DeFoggerSubSet.global) do
            if DeFoggerSubSet.char[char][setting] == nil then
                DeFoggerSubSet.char[char][setting] = value
            end
        end

    else
        DeFoggerSubSet.charActive[char] = nil

        -- Remove the character-specific settings when returning to shared settings.
        DeFoggerSubSet.char[char] = {}
    end
end

-- Gets the currently active value for a setting.
function SubSet.GetParam(config)
    local char = GetCharName()

    -- Use the character-specific value when enabled.
    if DeFoggerSubSet.charActive[char]
    and DeFoggerSubSet.char[char]
    and DeFoggerSubSet.char[char][config] ~= nil then
        return DeFoggerSubSet.char[char][config]
    end

    -- Otherwise use the shared value.
    if DeFoggerSubSet.global[config] ~= nil then
        return DeFoggerSubSet.global[config]
    end

    -- Fallback in case the saved database is missing this setting.
    return defaults[config]
end

-- Saves a setting to either the character profile or shared profile.
function SubSet.SetParam(config, value)
    local char = GetCharName()

    if DeFoggerSubSet.charActive[char] then
        DeFoggerSubSet.char[char] = DeFoggerSubSet.char[char] or {}
        DeFoggerSubSet.char[char][config] = value

    else
        DeFoggerSubSet.global[config] = value
    end
end

-- Restores the currently active settings profile to DeFogger's defaults.
function SubSet.Reset()
    local char = GetCharName()

    if DeFoggerSubSet.charActive[char] then
        DeFoggerSubSet.char[char] = {}

        for config, value in pairs(defaults) do
            DeFoggerSubSet.char[char][config] = value
        end

    else
        DeFoggerSubSet.global = {}

        for config, value in pairs(defaults) do
            DeFoggerSubSet.global[config] = value
        end
    end
end