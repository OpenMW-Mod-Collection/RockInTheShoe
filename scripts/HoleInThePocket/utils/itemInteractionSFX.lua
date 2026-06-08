---@diagnostic disable: param-type-mismatch
---@omw-context local | global
--
-- Resolves the correct pickup ("Up") and drop ("Down") sound ID for any item object.
-- Works from both local and global script scopes.
--
-- Usage:
--   local itemInteractionSFX = require('scripts/mymod/itemInteractionSFX.lua')
--
--   local up   = itemInteractionSFX.get(item, true)
--   local down = itemInteractionSFX.get(item, false)

local core = require('openmw.core')
local types = require('openmw.types')

local M = {}

-- ── Weapon type → sound suffix ──────────────────────────────────────────────

local WEAPON_SOUND = {
    [types.Weapon.TYPE.MarksmanBow]       = "Bow",
    [types.Weapon.TYPE.MarksmanCrossbow]  = "Crossbow",
    [types.Weapon.TYPE.LongBladeOneHand]  = "Longblade",
    [types.Weapon.TYPE.LongBladeTwoHand]  = "Longblade",
    [types.Weapon.TYPE.ShortBladeOneHand] = "Shortblade",
    [types.Weapon.TYPE.SpearTwoWide]      = "Spear",
    [types.Weapon.TYPE.BluntOneHand]      = "Blunt",
    [types.Weapon.TYPE.BluntTwoClose]     = "Blunt",
    [types.Weapon.TYPE.BluntTwoWide]      = "Blunt",
    [types.Weapon.TYPE.AxeOneHand]        = "Blunt", -- axes use blunt sounds
    [types.Weapon.TYPE.AxeTwoHand]        = "Blunt",
    [types.Weapon.TYPE.MarksmanThrown]    = "Ammo",
    [types.Weapon.TYPE.Arrow]             = "Ammo",
    [types.Weapon.TYPE.Bolt]              = "Ammo",
}

-- ── Armor weight → sound suffix ──────────────────────────────────────────────
-- Mirrors the engine formula exactly (verified on OpenMW wiki):
--   epsilon = 5e-4
--   if weight == 0                               → NONE  (treated as Light here)
--   if weight <= referenceWeight * fLightMaxMod + epsilon → LIGHT
--   if weight <= referenceWeight * fMedMaxMod   + epsilon → MEDIUM
--   else                                         → HEAVY
--
-- referenceWeight is slot-specific: each slot has its own iXxxWeight GMST.
-- Both pauldron sides share iPauldronWeight; both bracers share iGauntletWeight.

local ARMOR_SLOT_GMST = {
    [types.Armor.TYPE.Helmet]    = core.getGMST("iHelmWeight"),
    [types.Armor.TYPE.Cuirass]   = core.getGMST("iCuirassWeight"),
    [types.Armor.TYPE.LPauldron] = core.getGMST("iPauldronWeight"),
    [types.Armor.TYPE.RPauldron] = core.getGMST("iPauldronWeight"),
    [types.Armor.TYPE.Greaves]   = core.getGMST("iGreavesWeight"),
    [types.Armor.TYPE.Boots]     = core.getGMST("iBootsWeight"),
    [types.Armor.TYPE.LGauntlet] = core.getGMST("iGauntletWeight"),
    [types.Armor.TYPE.RGauntlet] = core.getGMST("iGauntletWeight"),
    [types.Armor.TYPE.LBracer]   = core.getGMST("iGauntletWeight"),
    [types.Armor.TYPE.RBracer]   = core.getGMST("iGauntletWeight"),
    [types.Armor.TYPE.Shield]    = core.getGMST("iShieldWeight"),
}

local ARMOR_CLASS_EPSILON = 5e-4
local fLightMaxMod = core.getGMST("fLightMaxMod")
local fMedMaxMod = core.getGMST("fMedMaxMod")

---@param item GameObject
---@return string
local function getArmorClass(item)
    local rec = item.type.records[item.recordId]
    local w   = rec.weight or 0
    if w == 0 then return "Light" end

    local refWeight = ARMOR_SLOT_GMST[rec.type]
    local lightMax  = fLightMaxMod * refWeight + ARMOR_CLASS_EPSILON
    local medMax    = fMedMaxMod * refWeight + ARMOR_CLASS_EPSILON

    if w <= lightMax then return "Light" end
    if w <= medMax then return "Medium" end
    return "Heavy"
end

-- ── Gold record IDs ──────────────────────────────────────────────────────────

local GOLD_IDS = {
    gold_001 = true,
    gold_005 = true,
    gold_010 = true,
    gold_025 = true,
    gold_100 = true,
}

-- ── Type → resolver function ─────────────────────────────────────────────────

local TYPE_RESOLVER = {
    ---@param item GameObject
    ---@return string
    [types.Weapon] = function(item)
        return "Item Weapon " .. WEAPON_SOUND[item.type.records[item.recordId].type]
    end,
    ---@param item GameObject
    ---@return string
    [types.Armor] = function(item)
        return "Item Armor " .. getArmorClass(item)
    end,
    ---@param item GameObject
    ---@return string
    [types.Clothing] = function(item)
        if item.type.records[item.recordId].type == types.Clothing.TYPE.Ring then
            return "Item Ring"
        end
        return "Item Clothes"
    end,
    ---@param item GameObject
    ---@return string
    [types.Miscellaneous] = function(item)
        if GOLD_IDS[item.recordId] then
            return "Item Gold"
        end
        return "Item Misc"
    end,
    ---@return string
    [types.Apparatus] = function(_) return "Item Apparatus" end,
    ---@return string
    [types.Book] = function(_) return "Item Book" end,
    ---@return string
    [types.Ingredient] = function(_) return "Item Ingredient" end,
    ---@return string
    [types.Lockpick] = function(_) return "Item Lockpick" end,
    ---@return string
    [types.Potion] = function(_) return "Item Potion" end,
    ---@return string
    [types.Probe] = function(_) return "Item Probe" end,
    ---@return string
    [types.Repair] = function(_) return "Item Repair" end,
}

--- Returns the base sound name (without " Up" / " Down") for the given item,
--- or nil if no matching sound is known.
---@param item GameObject
---@return string|nil
local function baseSoundName(item)
    local resolver = TYPE_RESOLVER[item.type]
    if resolver then
        return resolver(item)
    end
    return "Item Misc"
end

-- ── Public API ────────────────────────────────────────────────────────────────

--- Returns the pickup sound ID for the item, or nil.
--- @param item GameObject
--- @param up boolean            When true, returns pickup SFX, else returns drop SFX
---@return string|nil
function M.get(item, up)
    local base = baseSoundName(item)
    if base then
        return base .. (up and " Up" or " Down")
    end
    return nil
end

return M
