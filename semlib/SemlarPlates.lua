-------------------------------------
-- Stripped core from SemlarPlates
-------------------------------------

local addonName, addon = ...
local E = addon:Eve()
local Nameplates = {} -- [plate] = f, holds all nameplate frames
local ActiveNameplates = {} -- [plate] = f, only stores currently visible nameplates
local GUIDs = {}            -- [guid] = plate

local LibGetFrame = LibStub('LibGetFrame-1.0')

function addon:GetActiveNameplates()
    return ActiveNameplates
end

function addon:GetAllNameplates()
    return Nameplates
end

function addon:GetFrameFromNameplate(plate)
    return Nameplates[plate]
end

function addon:GetPlateForUnit(unitID)
    local plate = LibGetFrame.GetUnitNameplate(unitID)
    local f = plate and Nameplates[plate]

    return plate, f
end

function addon:GetUnitForPlate(plate)
    return Nameplates[plate] and Nameplates[plate]._unitID
end

function addon:GetPlateForGUID(guid)
    local plate = GUIDs[guid]
    if plate then
        return plate, ActiveNameplates[plate]
    end
end

local function getNameplateFrame(plate)
    if Nameplates[plate] then return Nameplates[plate] end

    local f = CreateFrame('frame', nil, plate)
    f:SetAllPoints()
    Nameplates[plate] = f
    -- plate._frame = f
    E('OnNewPlate', f, plate)

    return f
end

function E:NAME_PLATE_UNIT_ADDED(unitID)
    RunNextFrame(function()
        local plate = LibGetFrame.GetUnitNameplate(unitID)
        local f = getNameplateFrame(plate)
        ActiveNameplates[plate] = f
        f._unitID = unitID

        local guid = UnitGUID(unitID)
        if guid then
            GUIDs[guid] = plate
        end

        E('OnPlateShow', f, plate, unitID)
    end)
end

function E:NAME_PLATE_UNIT_REMOVED(unitID)
    local plate = LibGetFrame.GetUnitNameplate(unitID)
    local f = Nameplates[plate]
    ActiveNameplates[plate] = nil

    local guid = UnitGUID(unitID)
    if guid then
        GUIDs[guid] = nil
    end

    E('OnPlateHide', f, plate, unitID)
end