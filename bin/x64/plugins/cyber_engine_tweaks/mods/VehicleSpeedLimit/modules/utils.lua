local utils = {}

function utils.isInVehicle()
    return Game.GetMountedVehicle(Game.GetPlayer()) ~= nil
end

function utils.isDriver()
    local mountedVehicle = Game.GetMountedVehicle(Game.GetPlayer())

    if mountedVehicle == nil then
        return false
    end

    return VehicleComponent.IsDriver(Game.GetPlayer())
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

function utils.updateLimitWidgetMargin(widget)
    -- local function determineScale(width, height)
    --     local scales = {
    --         ["3440x1440"] = 0.67,
    --         ["2560x1440"] = 0.67,
    --         ["2560x1080"] = 0.50,
    --         ["1920x1440"] = 0.50,
    --         ["1920x1200"] = 0.50,
    --         ["1920x1080"] = 0.50,
    --         ["1720x1440"] = 0.45,
    --         ["1680x1050"] = 0.44,
    --         ["1600x1200"] = 0.42,
    --         ["1600x1024"] = 0.42,
    --         ["1600x900"]  = 0.42,
    --         ["1440x1080"] = 0.38,
    --         ["1440x900"]  = 0.38,
    --         ["1366x768"]  = 0.36,
    --         ["1360x768"]  = 0.35,
    --     }

    --     return scales[string.format("%dx%d", width, height)] or scales["3440x1440"]
    -- end

    local function determineMargin(width, height)
        local margins = {
            ["5160x2160"] = inkMargin.new({ left = 500, top = 1400, right = 0, bottom = 0 }),
            ["3440x1440"] = inkMargin.new({ left = 415, top = 1170, right = 0, bottom = 0 }),
            ["2560x1440"] = inkMargin.new({ left = 405, top = 1170, right = 0, bottom = 0 }),
            ["2560x1080"] = inkMargin.new({ left = 310, top =  869, right = 0, bottom = 0 }),
            ["1920x1440"] = inkMargin.new({ left = 295, top = 1217, right = 0, bottom = 0 }),
            ["1920x1200"] = inkMargin.new({ left = 295, top =  985, right = 0, bottom = 0 }),
            ["1920x1080"] = inkMargin.new({ left = 295, top =  869, right = 0, bottom = 0 }),
            ["1720x1440"] = inkMargin.new({ left = 265, top = 1233, right = 0, bottom = 0 }),
            ["1680x1050"] = inkMargin.new({ left = 255, top =  857, right = 0, bottom = 0 }),
            ["1600x1200"] = inkMargin.new({ left = 245, top = 1009, right = 0, bottom = 0 }),
            ["1600x1024"] = inkMargin.new({ left = 245, top =  839, right = 0, bottom = 0 }),
            ["1600x900"]  = inkMargin.new({ left = 245, top =  719, right = 0, bottom = 0 }),
            ["1440x1080"] = inkMargin.new({ left = 220, top =  903, right = 0, bottom = 0 }),
            ["1440x900"]  = inkMargin.new({ left = 220, top =  729, right = 0, bottom = 0 }),
            ["1366x768"]  = inkMargin.new({ left = 205, top =  608, right = 0, bottom = 0 }),
            ["1360x768"]  = inkMargin.new({ left = 205, top =  608, right = 0, bottom = 0 }),
        }

        return margins[string.format("%dx%d", width, height)] or margins["3440x1440"]
    end

    local width, height = GetDisplayResolution()
    local margin = determineMargin(width, height)

    widget:SetMargin(margin)
end

function utils.getOrCreateLimitWidget(visible)
    local virtualWindow = GameInstance
        .GetInkSystem()
        :GetLayer("inkHUDLayer")
        :GetVirtualWindow()
    local existingLimitWidget = virtualWindow:GetWidget("LimitWidget")

    if existingLimitWidget and existingLimitWidget:GetName().value == "LimitWidget" then
        return existingLimitWidget
    end

    local limitWidget = inkText.new()

    limitWidget:SetName(StringToName("LimitWidget"))
    limitWidget:SetFontFamily("base\\gameplay\\gui\\fonts\\digital_readout\\digitalreadout.inkfontfamily")
    limitWidget:SetFontSize(70)
    limitWidget:SetTintColor(HDRColor.new({
        Red = 0.36862745881081, 
        Green = 0.96470594406128, 
        Blue = 0.96470594406128, 
        Alpha = 1
    }))
    limitWidget:SetHorizontalAlignment(textHorizontalAlignment.Center)
    limitWidget:SetVerticalAlignment(textVerticalAlignment.Center)
    limitWidget:SetText("L")

    limitWidget:Reparent(virtualWindow, -1)
    limitWidget:SetVisible(visible)

    return limitWidget
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
