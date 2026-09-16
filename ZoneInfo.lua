-- Zone level ranges and recommended starting Fishing skill levels.

local ZoneInfo = {}
DeFogger.modules["zoneInfo"] = ZoneInfo

-- Always enable so the hover-text hook is available; the display options gate output.
ZoneInfo.alwaysEnable = true

local zoneData = {
    -- Eastern Kingdoms
    ["Alterac Mountains"] = { min = 30, max = 40, fish = "200" },
    ["Arathi Highlands"] = { min = 30, max = 40, fish = "200" },
    ["Badlands"] = { min = 35, max = 45, fish = "none" },
    ["Blasted Lands"] = { min = 45, max = 55, fish = "none" },
    ["Burning Steppes"] = { min = 50, max = 58, fish = "none" },
    ["Deadwind Pass"] = { min = 55, max = 60, fish = "none" },
    ["Dun Morogh"] = { min = 1, max = 10, fish = "1" },
    ["Duskwood"] = { min = 18, max = 30, fish = "125" },
    ["Eastern Plaguelands"] = { min = 53, max = 60, fish = "none" },
    ["Elwynn Forest"] = { min = 1, max = 10, fish = "1" },
    ["Eversong Woods"] = { min = 1, max = 10, fish = "1" },
    ["Ghostlands"] = { min = 10, max = 20, fish = "50" },
    ["Hillsbrad Foothills"] = { min = 20, max = 35, fish = "125" },
    ["Ironforge"] = { fish = "50" },
    ["Loch Modan"] = { min = 10, max = 20, fish = "50" },
    ["Redridge Mountains"] = { min = 15, max = 25, fish = "125" },
    ["Searing Gorge"] = { min = 45, max = 50, fish = "none" },
    ["Silvermoon City"] = { fish = "none" },
    ["Silverpine Forest"] = { min = 10, max = 20, fish = "50" },
    ["Stormwind City"] = { fish = "50" },
    ["Stranglethorn Vale"] = { min = 30, max = 45, fish = "200" },
    ["Swamp of Sorrows"] = { min = 35, max = 45, fish = "200" },
    ["The Hinterlands"] = { min = 40, max = 50, fish = "275" },
    ["Tirisfal Glades"] = { min = 1, max = 10, fish = "1" },
    ["Undercity"] = { fish = "50" },
    ["Westfall"] = { min = 10, max = 20, fish = "50" },
    ["Wetlands"] = { min = 20, max = 30, fish = "125" },
    ["Western Plaguelands"] = { min = 51, max = 58, fish = "275" },
    ["Isle of Quel'Danas"] = { min = 70, max = 73, fish = "425" },

    -- Kalimdor
    ["Ashenvale"] = { min = 18, max = 30, fish = "125" },
    ["Azshara"] = { min = 45, max = 55, fish = "275" },
    ["Azuremyst Isle"] = { min = 1, max = 10, fish = "1" },
    ["Bloodmyst Isle"] = { min = 10, max = 20, fish = "50" },
    ["Darkshore"] = { min = 10, max = 20, fish = "50" },
    ["Darnassus"] = { fish = "50" },
    ["Desolace"] = { min = 30, max = 40, fish = "200" },
    ["Durotar"] = { min = 1, max = 10, fish = "1" },
    ["Dustwallow Marsh"] = { min = 35, max = 45, fish = "200" },
    ["Felwood"] = { min = 48, max = 55, fish = "275" },
    ["Feralas"] = { min = 40, max = 50, fish = "275" },
    ["Moonglade"] = { fish = "275" },
    ["Mulgore"] = { min = 1, max = 10, fish = "1" },
    ["Orgrimmar"] = { fish = "50" },
    ["Silithus"] = { min = 55, max = 60, fish = "none" },
    ["Stonetalon Mountains"] = { min = 15, max = 27, fish = "125" },
    ["Tanaris"] = { min = 40, max = 50, fish = "275" },
    ["Teldrassil"] = { min = 1, max = 10, fish = "1" },
    ["The Barrens"] = { min = 10, max = 25, fish = "50" },
    ["Thousand Needles"] = { min = 25, max = 35, fish = "200" },
    ["Thunder Bluff"] = { fish = "50" },
    ["The Exodar"] = { fish = "none" },
    ["Un'Goro Crater"] = { min = 48, max = 55, fish = "275" },
    ["Winterspring"] = { min = 53, max = 60, fish = "none" },

    -- Outland
    ["Blade's Edge Mountains"] = { min = 65, max = 68, fish = "none" },
    ["Hellfire Peninsula"] = { min = 58, max = 63, fish = "350" },
    ["Nagrand"] = { min = 64, max = 67, fish = "450" },
    ["Netherstorm"] = { min = 67, max = 70, fish = "none" },
    ["Shadowmoon Valley"] = { min = 67, max = 70, fish = "none" },
    ["Shattrath City"] = { fish = "none" },
    ["Terokkar Forest"] = { min = 62, max = 65, fish = "425" },
    ["Zangarmarsh"] = { min = 60, max = 64, fish = "375" },

    -- Northrend
    ["Borean Tundra"] = { min = 68, max = 72, fish = "450" },
    ["Howling Fjord"] = { min = 68, max = 72, fish = "450" },
    ["Dragonblight"] = { min = 71, max = 75, fish = "450" },
    ["Grizzly Hills"] = { min = 73, max = 75, fish = "450" },
    ["Zul'Drak"] = { min = 74, max = 76, fish = "none" },
    ["Sholazar Basin"] = { min = 76, max = 78, fish = "500" },
    ["The Storm Peaks"] = { min = 77, max = 80, fish = "none" },
    ["Icecrown"] = { min = 77, max = 80, fish = "none" },
    ["Crystalsong Forest"] = { min = 77, max = 80, fish = "475" },
    ["Hrothgar's Landing"] = { min = 77, max = 80, fish = "none" },
    ["Dalaran"] = { fish = "500" },
    ["Wintergrasp"] = { min = 77, max = 80, fish = "500" },
    ["The Frozen Sea"] = { fish = "550" },
}

--[[
Zone hover display
WorldMapFrameAreaLabel keeps the zone name
DeFogger creates separate level/fishing lines underneath it.
]]

-- Level Range and Fishing Level Font Sizes
local LEVEL_FONT_SIZE_FULL = 24
local FISH_FONT_SIZE_FULL = 20

local LEVEL_FONT_SIZE_PORTABLE = 48
local FISH_FONT_SIZE_PORTABLE = 40

--[[
Vertical spacing
More negative = more down
]]
local LEVEL_Y_OFFSET = -4
local FISH_Y_OFFSET = -4
local FISH_ONLY_Y_OFFSET = -4

local levelText
local fishText


local function SetFontSize(fontString, size)
    local font, _, flags = fontString:GetFont()

    if font then
        if flags then
            fontString:SetFont(font, size, flags)
        else
            fontString:SetFont(font, size)
        end
    end
end


local function CreateExtraLabels()
    if levelText and fishText then
        return true
    end

    if not WorldMapFrameAreaFrame or not WorldMapFrameAreaLabel then
        return false
    end

    -- Level range
    levelText = WorldMapFrameAreaFrame:CreateFontString(
        nil,
        "OVERLAY",
        "WorldMapTextFont"
    )

    levelText:SetJustifyH("CENTER")
    SetFontSize(levelText, LEVEL_FONT_SIZE_FULL)
    levelText:Hide()

    -- Fishing level
    fishText = WorldMapFrameAreaFrame:CreateFontString(
        nil,
        "OVERLAY",
        "WorldMapTextFont"
    )

    fishText:SetJustifyH("CENTER")
    SetFontSize(fishText, FISH_FONT_SIZE_FULL)
    fishText:Hide()

    return true
end


local function GetLevelColor(data)
    local playerLevel = UnitLevel("player")

    if playerLevel > (data.max + 5) then
        -- Grey
        return "ff808080"

    elseif playerLevel > data.max then
        -- Green
        return "ff00aa00"

    elseif playerLevel >= data.min then
        -- Yellow
        return "ffffff00"

    elseif playerLevel >= (data.min - 5) then
        -- Orange
        return "ffff8000"

    else
        -- Red
        return "ffff1a1a"
    end
end


local function UpdateExtraLabels(zoneName)
    if not CreateExtraLabels() then
        return
    end

    -- Always clear the previous zone first.
    levelText:Hide()
    fishText:Hide()

    if not ZoneInfo.enabled then
        return
    end

    if not zoneName or zoneName == "" then
        return
    end

    local data = zoneData[zoneName]

    if not data then
        return
    end
	
	local portable = WORLDMAP_SETTINGS.size == WORLDMAP_WINDOWED_SIZE

	if portable then
		SetFontSize(levelText, LEVEL_FONT_SIZE_PORTABLE)
		SetFontSize(fishText, FISH_FONT_SIZE_PORTABLE)
	else
		SetFontSize(levelText, LEVEL_FONT_SIZE_FULL)
		SetFontSize(fishText, FISH_FONT_SIZE_FULL)
	end

    local showLevels =
        DeFogger.SubSet.GetParam("zoneLevels") == true

    local showFishing =
        DeFogger.SubSet.GetParam("fishingLevels") == true


--[[
-- LEVEL RANGE
]]

    local levelVisible = false

    if showLevels and data.min and data.max then
        local colorStr = GetLevelColor(data)

        levelText:SetText(
            string.format(
                "|c%s(%d-%d)|r",
                colorStr,
                data.min,
                data.max
            )
        )

        levelText:ClearAllPoints()

        levelText:SetPoint(
            "TOP",
            WorldMapFrameAreaLabel,
            "BOTTOM",
            0,
            LEVEL_Y_OFFSET
        )

        levelText:Show()
        levelVisible = true
    end


--[[
FISHING LEVEL
]]

    if showFishing and data.fish and data.fish ~= "none" then
        fishText:SetText(
            "|cff008fc2[Fish: " .. data.fish .. "]|r"
        )

        fishText:ClearAllPoints()

        if levelVisible then
            -- Level exists, so fishing goes underneath it.
            fishText:SetPoint(
                "TOP",
                levelText,
                "BOTTOM",
                0,
                FISH_Y_OFFSET
            )
        else
            -- No level line, so fishing goes directly under zone name.
            fishText:SetPoint(
                "TOP",
                WorldMapFrameAreaLabel,
                "BOTTOM",
                0,
                FISH_ONLY_Y_OFFSET
            )
        end

        fishText:Show()
    end
end


-- Allows the config panel to immediately refresh these lines.
function DeFogger.RefreshZoneInfo()
    if WorldMapFrameAreaLabel then
        UpdateExtraLabels(WorldMapFrameAreaLabel:GetText())
    end
end


function ZoneInfo.Enable()
    ZoneInfo.enabled = true
    DeFogger.RefreshZoneInfo()
end


function ZoneInfo.Disable()
    ZoneInfo.enabled = false

    if levelText then
        levelText:Hide()
    end

    if fishText then
        fishText:Hide()
    end
end


-- Zone Name Source
local function HookAreaLabel()
    if ZoneInfo.hookedAreaLabel then
        return
    end

    if not WorldMapFrameAreaLabel then
        return
    end

    CreateExtraLabels()

    hooksecurefunc(
        WorldMapFrameAreaLabel,
        "SetText",
        function(self, text)
            UpdateExtraLabels(text)
        end
    )

    ZoneInfo.hookedAreaLabel = true

    UpdateExtraLabels(WorldMapFrameAreaLabel:GetText())
end


HookAreaLabel()

if not ZoneInfo.hookedAreaLabel then
    local f = CreateFrame("Frame")
    f:RegisterEvent("ADDON_LOADED")

    f:SetScript("OnEvent", function(self)
        if WorldMapFrameAreaLabel then
            HookAreaLabel()
            self:UnregisterEvent("ADDON_LOADED")
        end
    end)
end