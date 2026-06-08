---@diagnostic disable: missing-fields
---@omw-context global
local I = require('openmw.interfaces')

I.Settings.registerGroup {
    key = 'SettingsHoleInThePocket_settings',
    page = 'HoleInThePocket',
    l10n = 'HoleInThePocket',
    name = 'settings_groupName',
    permanentStorage = true,
    order = 1,
    settings = {
        {
            key = 'minDelay',
            name = 'minDelay_name',
            renderer = 'number',
            default = 60,
        },
        {
            key = 'maxDelay',
            name = 'maxDelay_name',
            renderer = 'number',
            default = 300,
        },
        {
            key = 'countMode',
            name = 'countMode_name',
            renderer = 'select',
            argument = {
                l10n = 'HoleInThePocket',
                items = {
                    "countMode_1",
                    "countMode_1_max",
                    "countMode_max"
                },
            },
            default = "countMode_1_max",
        },
        {
            key = 'dropEquipped',
            name = 'dropEquipped_name',
            renderer = 'checkbox',
            default = false,
        },
        {
            key = 'dropKeys',
            name = 'dropKeys_name',
            renderer = 'checkbox',
            default = false,
        },
        {
            key = 'sfxVolume',
            name = 'sfxVolume_name',
            description = 'sfxVolume_desc',
            renderer = 'number',
            default = .5,
        },
    }
}