--Shows coordinates at the bottom of the map for the player location and cursor location.

local Coords = {}
DeFogger.modules["coords"] = Coords

Coords.defaults = {
    coords = true,
}

local coordstext

local function MouseXY()
    if not WorldMapDetailFrame or not WorldMapDetailFrame:IsShown() then return nil, nil end

    local left = WorldMapDetailFrame:GetLeft()
    local top = WorldMapDetailFrame:GetTop()
    local width = WorldMapDetailFrame:GetWidth()
    local height = WorldMapDetailFrame:GetHeight()
    local scale = WorldMapDetailFrame:GetEffectiveScale()

    if not left or not top or not width or not height or not scale or width <= 0 or height <= 0 then
        return nil, nil
    end

    local x, y = GetCursorPosition()
    local cx = (x / scale - left) / width
    local cy = (top - y / scale) / height

    if cx < 0 or cx > 1 or cy < 0 or cy > 1 then
        return nil, nil
    end

    return cx, cy
end

local function OnUpdate()
    if not coordstext then return end

    local cx, cy = MouseXY()
    local px, py = GetPlayerMapPosition("player")
    local pStr, cStr

    -- Accuracy is intentionally fixed at one decimal place.
    if px and px > 0 and py and py > 0 then
        pStr = string.format("Player: %.1f, %.1f", px * 100, py * 100)
    end
    if cx then
        cStr = string.format("Cursor: %.1f, %.1f", cx * 100, cy * 100)
    end

    if pStr and cStr then
        coordstext:SetText(pStr .. "   " .. cStr)
    elseif pStr then
        coordstext:SetText(pStr)
    elseif cStr then
        coordstext:SetText(cStr)
    else
        coordstext:SetText("")
    end
end

local function UpdatePosition()
    local display = _G["DeFogger_CoordsFrame"]
    if not display or not WorldMapDetailFrame then return end

    display:ClearAllPoints()
    if WORLDMAP_SETTINGS and WORLDMAP_SETTINGS.size == WORLDMAP_WINDOWED_SIZE then
        -- Put coordinates on the stock bottom control line, relative to the actual map texture.
		-- Portable map
        display:SetPoint("TOP", WorldMapDetailFrame, "BOTTOM", 0, -3)
    else
		-- Fullscreen map
        display:SetPoint("BOTTOM", WorldMapPositioningGuide or WorldMapFrame, "BOTTOM", 0, 7)
    end
    display:SetFrameLevel((WorldMapFrame:GetFrameLevel() or 1) + 15)
end

function Coords.Enable()
    Coords.enabled = true

    local display = _G["DeFogger_CoordsFrame"]
    if not display then
        display = CreateFrame("Frame", "DeFogger_CoordsFrame", WorldMapFrame)
        display:SetSize(450, 20)
    end

    if not coordstext then
        coordstext = display:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        coordstext:SetPoint("CENTER", display, "CENTER", 0, 0)
        coordstext:SetShadowColor(0, 0, 0, 1)
        coordstext:SetShadowOffset(1, -1)
    end

    UpdatePosition()
    display:SetScript("OnUpdate", OnUpdate)
    display:Show()

    if not Coords.hookedSize then
        hooksecurefunc("WorldMapFrame_SetFullMapView", UpdatePosition)
        hooksecurefunc("WorldMapFrame_SetQuestMapView", UpdatePosition)
        hooksecurefunc("WorldMap_ToggleSizeDown", UpdatePosition)
        hooksecurefunc("WorldMap_ToggleSizeUp", UpdatePosition)
        Coords.hookedSize = true
    end
end

function Coords.Disable()
    Coords.enabled = false
    local display = _G["DeFogger_CoordsFrame"]
    if display then
        display:SetScript("OnUpdate", nil)
        display:Hide()
    end
end
