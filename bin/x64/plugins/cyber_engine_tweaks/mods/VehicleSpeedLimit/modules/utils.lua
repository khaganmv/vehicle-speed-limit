local utils = {}

function utils.isInVehicle()
    return Game.GetMountedVehicle(Game.GetPlayer()) ~= nil
end

function utils.speedToSpeedometerUnits(speed)
    local velocity = AbsF(speed)
    local multiplier = GameInstance
        .GetStatsDataSystem()
        :GetValueFromCurve("vehicle_ui", velocity, "speed_to_multiplier")
    local unit = 1
    local isMetric = GameInstance
        .GetSettingsSystem()
        :GetGroup("/interface")
        :GetVar("SpeedometerUnits")
        :GetIndex() ~= 1

    if isMetric then
        unit = 1.61
    end

    return RoundMath(velocity * multiplier * unit)
end

function utils.createBindingInfo(
    inputManager,
    nativeSettingsPath,
    id,
    defaultSettings,
    settings,
    callback,
    saveCallback
)
    return inputManager.createBindingInfo(
        -- nativeSettingsPath
        nativeSettingsPath,
        -- keybindLabel
        "Key",
        -- isHoldLabel
        "Hold",
        -- keybindDescription
        "",
        -- isHoldDescription
        "Controls whether the bound key below needs to be held down for some time to be activated",
        -- id
        id,
        -- maxKeys
        3,
        -- maxKeysLabel
        "Hotkey Keys Amount",
        -- maxKeysDescription
        "Changes how many keys this hotkey has, all of them have to pressed for the hotkey to be activated",
        -- supportsHold
        true,
        -- defaultOptions
        defaultSettings,
        -- savedOptions
        settings,
        -- callback
        callback,
        -- saveCallback
        saveCallback
    )
end

return utils
