---@omw-context global
local storage = require("openmw.storage")
local async = require("openmw.async")

local settingsCache = require("scripts.HoleInThePocket.utils.settingsCache")
local settings = settingsCache.new(storage.globalSection("SettingsHoleInThePocket_settings"), async)
local itemInteractionSFX = require("scripts.HoleInThePocket.utils.itemInteractionSFX")

local splitters = {
    countMode_1 = function(item)
        return item:split(1)
    end,
    countMode_1_max = function(item)
        local dropCount = math.random(item.count)
        if dropCount ~= item.count then
            return item:split(dropCount)
        end
        return item
    end,
    countMode_max = function(item)
        return item
    end
}

local function dropItem(data)
    local item   = data.item
    local player = data.player

    if not item or not item:isValid() then return end
    if not player or not player:isValid() then return end

    local cell = player.cell
    if not cell then return end

    local toDrop = splitters[settings.countMode](item)
    toDrop:teleport(cell.name, player.position, { onGround = true })

    if settings.sfxVolume <= 0 then
        player:sendEvent('PlaySound3d', {
            sound = itemInteractionSFX.get(item, false),
            options = { volume = settings.sfxVolume }
        })
    end
end

return {
    eventHandlers = {
        HoleInThePoket_DropItem = dropItem,
    },
}
