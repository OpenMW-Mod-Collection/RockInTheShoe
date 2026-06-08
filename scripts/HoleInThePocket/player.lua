---@diagnostic disable: lowercase-global, missing-parameter
---@omw-context player
local storage = require('openmw.storage')
local self = require("openmw.self")
local async = require("openmw.async")
local time = require("openmw_aux.time")
local types = require("openmw.types")
local core = require("openmw.core")

local settingsCache = require("scripts.HoleInThePocket.utils.settingsCache")
local settings = settingsCache.new(storage.globalSection("SettingsHoleInThePocket_settings"), async)
local inv = types.Player.inventory(self)

local function collectCandidates()
    local equipped = types.Actor.getEquipment(self) or {}
    local equippedIds = {}
    for _, item in pairs(equipped) do
        equippedIds[item.id] = true
    end

    local candidates = {}

    for _, item in ipairs(inv:getAll()) do
        -- skip equipped items unless setting allows it
        if settings.dropEquipped or not equippedIds[item.id] then
            -- skip keys
            local isKey = false
            if settings.dropKeys and types.Miscellaneous.objectIsInstance(item) then
                local rec = types.Miscellaneous.records[item.recordId]
                isKey = rec and rec.isKey or false
            end
            if not isKey then
                table.insert(candidates, item)
            end
        end
    end

    return candidates
end

local function doDrop()
    local candidates = collectCandidates()
    if #candidates == 0 then return end

    core.sendGlobalEvent("HoleInThePoket_DropItem", {
        item   = candidates[math.random(#candidates)],
        player = self.object,
    })
end

local function scheduleNextDrop()
    time.newSimulationTimer(
        math.random(settings.minDelay, settings.maxDelay),
        callback
    )
end

callback = async:registerTimerCallback(
    "Drop Item Callback",
    function()
        doDrop()
        scheduleNextDrop()
    end
)

scheduleNextDrop()
