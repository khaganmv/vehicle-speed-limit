local GameUI = require("modules/psiberx/GameUI")
local config = require("modules/keanuWheeze/config")
local inputManager = require("modules/keanuWheeze/inputManager")
local utils = require("modules/utils")

local defaultSettings = {
    enabled = true,
    enabledLimitWidget = true,
    displayLimitWidgetInFPP = true,
    useCurrentSpeed = false,
    inFPP = false,
    speedLimit = 40,
    limited = false,
    speedLimitPresets = {
        40,
        60,
        80,
    },
    speedLimitIncrement = 20,
    bindings = {
        keyboard = {
            toggleLimit = {
                ["keyboardToggleLimit_1"] = "IK_LShift",
                ["keyboardToggleLimit_hold_1"] = false,
                ["keyboardToggleLimit_keys"] = 1
            },
            selectPreset1 = {
                ["keyboardSelectPreset1_1"] = "IK_5",
                ["keyboardSelectPreset1_hold_1"] = false,
                ["keyboardSelectPreset1_keys"] = 1
            },
            selectPreset2 = {
                ["keyboardSelectPreset2_1"] = "IK_6",
                ["keyboardSelectPreset2_hold_1"] = false,
                ["keyboardSelectPreset2_keys"] = 1
            },
            selectPreset3 = {
                ["keyboardSelectPreset3_1"] = "IK_7",
                ["keyboardSelectPreset3_hold_1"] = false,
                ["keyboardSelectPreset3_keys"] = 1
            },
            increaseLimit = {
                ["keyboardIncreaseLimit_1"] = "IK_Comma",
                ["keyboardIncreaseLimit_hold_1"] = false,
                ["keyboardIncreaseLimit_keys"] = 1
            },
            decreaseLimit = {
                ["keyboardDecreaseLimit_1"] = "IK_Period",
                ["keyboardDecreaseLimit_hold_1"] = false,
                ["keyboardDecreaseLimit_keys"] = 1
            },
        },
        gamepad = {
            toggleLimit = {
                ["gamepadToggleLimit_1"] = "",
                ["gamepadToggleLimit_hold_1"] = false,
                ["gamepadToggleLimit_keys"] = 1
            },
            selectPreset1 = {
                ["gamepadSelectPreset1_1"] = "",
                ["gamepadSelectPreset1_hold_1"] = false,
                ["gamepadSelectPreset1_keys"] = 1
            },
            selectPreset2 = {
                ["gamepadSelectPreset2_1"] = "",
                ["gamepadSelectPreset2_hold_1"] = false,
                ["gamepadSelectPreset2_keys"] = 1
            },
            selectPreset3 = {
                ["gamepadSelectPreset3_1"] = "",
                ["gamepadSelectPreset3_hold_1"] = false,
                ["gamepadSelectPreset3_keys"] = 1
            },
            increaseLimit = {
                ["gamepadIncreaseLimit_1"] = "",
                ["gamepadIncreaseLimit_hold_1"] = false,
                ["gamepadIncreaseLimit_keys"] = 1
            },
            decreaseLimit = {
                ["gamepadDecreaseLimit_1"] = "",
                ["gamepadDecreaseLimit_hold_1"] = false,
                ["gamepadDecreaseLimit_keys"] = 1
            },
        }
    },
}

local settings = {}
local runtimeData = {
    inMenu = false,
    inGame = false,
    decelerating = false,
    currentSpeed = -1,
}

local function isHotkeyBound(bindingTable, hotkey)
    if type(bindingTable) ~= "table" then return false end

    for _, v in pairs(bindingTable) do
        if type(v) == "string" and v == hotkey then
            return true
        end
    end

    return false
end

local function toggleSpeedLimit()
    if settings.enabled and utils.isInVehicle() then
        settings.limited = not settings.limited

        if settings.limited and settings.useCurrentSpeed then
            settings.speedLimit = runtimeData.currentSpeed
        end
    end
end

local function applySpeedLimitPreset(preset)
    if settings.enabled and utils.isInVehicle() then
        settings.speedLimit = settings.speedLimitPresets[preset]
    end
end

local function incrementSpeedLimit(increment)
    if settings.enabled and utils.isInVehicle() then
        settings.speedLimit = settings.speedLimit + increment

        if settings.speedLimit < 0 then
            settings.speedLimit = 0
        end
    end
end

local function shouldDisplayLimitWidget()
    return utils.isInVehicle()
        and utils.isDriver()
        and settings.enabled
        and settings.enabledLimitWidget
        and settings.limited
        and not (settings.inFPP and not settings.displayLimitWidgetInFPP)
end

local function initBindingInfo()
    local keyboardToggleLimitBindingInfo = utils.createBindingInfo(
        inputManager,
        "/vehicleSpeedLimit/keyboardToggleLimit",
        "keyboardToggleLimit",
        defaultSettings.bindings.keyboard.toggleLimit,
        settings.bindings.keyboard.toggleLimit,
        function() toggleSpeedLimit() end,
        function(name, value)
            settings.bindings.keyboard.toggleLimit[name] = value
            config.saveFile("config.json", settings)
        end
    )
    local keyboardSelectPreset1BindingInfo = utils.createBindingInfo(
        inputManager,
        "/vehicleSpeedLimit/keyboardSelectPreset1",
        "keyboardSelectPreset1",
        defaultSettings.bindings.keyboard.selectPreset1,
        settings.bindings.keyboard.selectPreset1,
        function() applySpeedLimitPreset(1) end,
        function(name, value)
            settings.bindings.keyboard.selectPreset1[name] = value
            config.saveFile("config.json", settings)
        end
    )
    local keyboardSelectPreset2BindingInfo = utils.createBindingInfo(
        inputManager,
        "/vehicleSpeedLimit/keyboardSelectPreset2",
        "keyboardSelectPreset2",
        defaultSettings.bindings.keyboard.selectPreset2,
        settings.bindings.keyboard.selectPreset2,
        function() applySpeedLimitPreset(2) end,
        function(name, value)
            settings.bindings.keyboard.selectPreset2[name] = value
            config.saveFile("config.json", settings)
        end
    )
    local keyboardSelectPreset3BindingInfo = utils.createBindingInfo(
        inputManager,
        "/vehicleSpeedLimit/keyboardSelectPreset3",
        "keyboardSelectPreset3",
        defaultSettings.bindings.keyboard.selectPreset3,
        settings.bindings.keyboard.selectPreset3,
        function() applySpeedLimitPreset(3) end,
        function(name, value)
            settings.bindings.keyboard.selectPreset3[name] = value
            config.saveFile("config.json", settings)
        end
    )
    local keyboardIncreaseLimitBindingInfo = utils.createBindingInfo(
        inputManager,
        "/vehicleSpeedLimit/keyboardIncreaseLimit",
        "keyboardIncreaseLimit",
        defaultSettings.bindings.keyboard.increaseLimit,
        settings.bindings.keyboard.increaseLimit,
        function() incrementSpeedLimit(settings.speedLimitIncrement) end,
        function(name, value)
            settings.bindings.keyboard.increaseLimit[name] = value
            config.saveFile("config.json", settings)
        end
    )
    local keyboardDecreaseLimitBindingInfo = utils.createBindingInfo(
        inputManager,
        "/vehicleSpeedLimit/keyboardDecreaseLimit",
        "keyboardDecreaseLimit",
        defaultSettings.bindings.keyboard.decreaseLimit,
        settings.bindings.keyboard.decreaseLimit,
        function() incrementSpeedLimit(-settings.speedLimitIncrement) end,
        function(name, value)
            settings.bindings.keyboard.decreaseLimit[name] = value
            config.saveFile("config.json", settings)
        end
    )
    local gamepadToggleLimitBindingInfo = utils.createBindingInfo(
        inputManager,
        "/vehicleSpeedLimit/gamepadToggleLimit",
        "gamepadToggleLimit",
        defaultSettings.bindings.gamepad.toggleLimit,
        settings.bindings.gamepad.toggleLimit,
        function() toggleSpeedLimit() end,
        function(name, value)
            settings.bindings.gamepad.toggleLimit[name] = value
            config.saveFile("config.json", settings)
        end
    )
    local gamepadSelectPreset1BindingInfo = utils.createBindingInfo(
        inputManager,
        "/vehicleSpeedLimit/gamepadSelectPreset1",
        "gamepadSelectPreset1",
        defaultSettings.bindings.gamepad.selectPreset1,
        settings.bindings.gamepad.selectPreset1,
        function() applySpeedLimitPreset(1) end,
        function(name, value)
            settings.bindings.gamepad.selectPreset1[name] = value
            config.saveFile("config.json", settings)
        end
    )
    local gamepadSelectPreset2BindingInfo = utils.createBindingInfo(
        inputManager,
        "/vehicleSpeedLimit/gamepadSelectPreset2",
        "gamepadSelectPreset2",
        defaultSettings.bindings.gamepad.selectPreset2,
        settings.bindings.gamepad.selectPreset2,
        function() applySpeedLimitPreset(2) end,
        function(name, value)
            settings.bindings.gamepad.selectPreset2[name] = value
            config.saveFile("config.json", settings)
        end
    )
    local gamepadSelectPreset3BindingInfo = utils.createBindingInfo(
        inputManager,
        "/vehicleSpeedLimit/gamepadSelectPreset3",
        "gamepadSelectPreset3",
        defaultSettings.bindings.gamepad.selectPreset3,
        settings.bindings.gamepad.selectPreset3,
        function() applySpeedLimitPreset(3) end,
        function(name, value)
            settings.bindings.gamepad.selectPreset3[name] = value
            config.saveFile("config.json", settings)
        end
    )
    local gamepadIncreaseLimitBindingInfo = utils.createBindingInfo(
        inputManager,
        "/vehicleSpeedLimit/gamepadIncreaseLimit",
        "gamepadIncreaseLimit",
        defaultSettings.bindings.gamepad.increaseLimit,
        settings.bindings.gamepad.increaseLimit,
        function() incrementSpeedLimit(settings.speedLimitIncrement) end,
        function(name, value)
            settings.bindings.gamepad.increaseLimit[name] = value
            config.saveFile("config.json", settings)
        end
    )
    local gamepadDecreaseLimitBindingInfo = utils.createBindingInfo(
        inputManager,
        "/vehicleSpeedLimit/gamepadDecreaseLimit",
        "gamepadDecreaseLimit",
        defaultSettings.bindings.gamepad.decreaseLimit,
        settings.bindings.gamepad.decreaseLimit,
        function() incrementSpeedLimit(-settings.speedLimitIncrement) end,
        function(name, value)
            settings.bindings.gamepad.decreaseLimit[name] = value
            config.saveFile("config.json", settings)
        end
    )

    inputManager.addNativeSettingsBinding(keyboardToggleLimitBindingInfo)
    inputManager.addNativeSettingsBinding(keyboardSelectPreset1BindingInfo)
    inputManager.addNativeSettingsBinding(keyboardSelectPreset2BindingInfo)
    inputManager.addNativeSettingsBinding(keyboardSelectPreset3BindingInfo)
    inputManager.addNativeSettingsBinding(keyboardIncreaseLimitBindingInfo)
    inputManager.addNativeSettingsBinding(keyboardDecreaseLimitBindingInfo)
    inputManager.addNativeSettingsBinding(gamepadToggleLimitBindingInfo)
    inputManager.addNativeSettingsBinding(gamepadSelectPreset1BindingInfo)
    inputManager.addNativeSettingsBinding(gamepadSelectPreset2BindingInfo)
    inputManager.addNativeSettingsBinding(gamepadSelectPreset3BindingInfo)
    inputManager.addNativeSettingsBinding(gamepadIncreaseLimitBindingInfo)
    inputManager.addNativeSettingsBinding(gamepadDecreaseLimitBindingInfo)
end

local function initNativeSettingsUI()
    local nativeSettings = GetMod("nativeSettings")

    if not nativeSettings then
        print("[VehicleSpeedLimit] Info: NativeSettings lib not found!")
        return
    end

    nativeSettings.addTab("/vehicleSpeedLimit", "Vehicle Speed Limit")
    nativeSettings.addSubcategory("/vehicleSpeedLimit/mod", "Mod")

    nativeSettings.addSwitch(
        "/vehicleSpeedLimit/mod",
        "Enabled",
        "",
        settings.enabled,
        true,
        function(state) settings.enabled = state end
    )
    nativeSettings.addSwitch(
        "/vehicleSpeedLimit/mod",
        "Limit Widget",
        "",
        settings.enabledLimitWidget,
        defaultSettings.enabledLimitWidget,
        function(state)
            settings.enabledLimitWidget = state

            if runtimeData.limitWidget ~= nil then
                runtimeData.limitWidget:SetVisible(shouldDisplayLimitWidget())
            end
        end
    )
    nativeSettings.addSwitch(
        "/vehicleSpeedLimit/mod",
        "Display Limit Widget in FPP",
        "",
        settings.displayLimitWidgetInFPP,
        defaultSettings.displayLimitWidgetInFPP,
        function(state)
            settings.displayLimitWidgetInFPP = state

            if runtimeData.limitWidget ~= nil then
                runtimeData.limitWidget:SetVisible(shouldDisplayLimitWidget())
            end
        end
    )
    nativeSettings.addSwitch(
        "/vehicleSpeedLimit/mod",
        "Use Current Speed as Limit",
        "",
        settings.useCurrentSpeed,
        defaultSettings.useCurrentSpeed,
        function(state) settings.useCurrentSpeed = state end
    )
    nativeSettings.addRangeInt(
        "/vehicleSpeedLimit/mod",
        "Speed Limit",
        "",
        0, 300, 1,
        settings.speedLimit, 40,
        function(value) settings.speedLimit = value end
    )
    nativeSettings.addRangeInt(
        "/vehicleSpeedLimit/mod",
        "Speed Limit Preset 1",
        "",
        0, 300, 1,
        settings.speedLimitPresets[1], 40,
        function(value) settings.speedLimitPresets[1] = value end
    )
    nativeSettings.addRangeInt(
        "/vehicleSpeedLimit/mod",
        "Speed Limit Preset 2",
        "",
        0, 300, 1,
        settings.speedLimitPresets[2], 60,
        function(value) settings.speedLimitPresets[2] = value end
    )
    nativeSettings.addRangeInt(
        "/vehicleSpeedLimit/mod",
        "Speed Limit Preset 3",
        "",
        0, 300, 1,
        settings.speedLimitPresets[3], 80,
        function(value) settings.speedLimitPresets[3] = value end
    )
    nativeSettings.addRangeInt(
        "/vehicleSpeedLimit/mod",
        "Speed Limit Increment",
        "",
        0, 300, 1,
        settings.speedLimitIncrement, 20,
        function(value) settings.speedLimitIncrement = value end
    )

    nativeSettings.addSubcategory("/vehicleSpeedLimit/keyboardToggleLimit", "Keyboard Hotkey (Toggle Limit)")
    nativeSettings.addSubcategory("/vehicleSpeedLimit/keyboardSelectPreset1", "Keyboard Hotkey (Select Preset 1)")
    nativeSettings.addSubcategory("/vehicleSpeedLimit/keyboardSelectPreset2", "Keyboard Hotkey (Select Preset 2)")
    nativeSettings.addSubcategory("/vehicleSpeedLimit/keyboardSelectPreset3", "Keyboard Hotkey (Select Preset 3)")
    nativeSettings.addSubcategory("/vehicleSpeedLimit/keyboardIncreaseLimit", "Keyboard Hotkey (Increase Limit)")
    nativeSettings.addSubcategory("/vehicleSpeedLimit/keyboardDecreaseLimit", "Keyboard Hotkey (Decrease Limit)")
    nativeSettings.addSubcategory("/vehicleSpeedLimit/gamepadToggleLimit", "Gamepad Hotkey (Toggle Limit)")
    nativeSettings.addSubcategory("/vehicleSpeedLimit/gamepadSelectPreset1", "Gamepad Hotkey (Select Preset 1)")
    nativeSettings.addSubcategory("/vehicleSpeedLimit/gamepadSelectPreset2", "Gamepad Hotkey (Select Preset 2)")
    nativeSettings.addSubcategory("/vehicleSpeedLimit/gamepadSelectPreset3", "Gamepad Hotkey (Select Preset 3)")
    nativeSettings.addSubcategory("/vehicleSpeedLimit/gamepadIncreaseLimit", "Gamepad Hotkey (Increase Limit)")
    nativeSettings.addSubcategory("/vehicleSpeedLimit/gamepadDecreaseLimit", "Gamepad Hotkey (Decrease Limit)")
    initBindingInfo()
end

registerForEvent("onHook", function()
    inputManager.onHook()
end)

registerForEvent("onInit", function()
    if not Codeware then
        print("[VehicleSpeedLimit] Error: Missing Codeware")
    end

    config.tryCreateConfig("config.json", defaultSettings)
    config.backwardComp("config.json", defaultSettings)
    settings = config.loadFile("config.json")

    initNativeSettingsUI()

    GameUI.OnSessionStart(function()
        runtimeData.inGame = true
        runtimeData.limitWidget = utils.getOrCreateLimitWidget(shouldDisplayLimitWidget())
    end)

    GameUI.OnSessionEnd(function()
        runtimeData.inGame = false
    end)

    runtimeData.inGame = not GameUI.IsDetached()

    Observe('RadialWheelController', 'OnIsInMenuChanged', function(_, isInMenu)
        runtimeData.inMenu = isInMenu
    end)

    Observe("VehicleComponent", "RegisterInputListener", function(self)
        local player = Game.GetPlayerSystem():GetLocalPlayerMainGameObject()

        player:RegisterInputListener(self, "Decelerate")
        player:RegisterInputListener(self, "mouse_wheel")
    end)

    Observe("VehicleComponent", "OnAction", function(self, action, consumer)
        local actionName = action:GetName().value

        if actionName == "Decelerate" then
            runtimeData.decelerating = true
            return
        end

        if actionName == "mouse_wheel" then
            if runtimeData.inMenu or not runtimeData.inGame then return end
            if not settings.enabled then return end
            if not utils.isInVehicle() then return end

            local amount = action:GetValue()
            if amount == 0 then return end

            local wheelUpBoundToIncrease =
                isHotkeyBound(settings.bindings.keyboard.increaseLimit, "IK_MouseWheelUp")
                or isHotkeyBound(settings.bindings.gamepad.increaseLimit, "IK_MouseWheelUp")

            local wheelDownBoundToDecrease =
                isHotkeyBound(settings.bindings.keyboard.decreaseLimit, "IK_MouseWheelDown")
                or isHotkeyBound(settings.bindings.gamepad.decreaseLimit, "IK_MouseWheelDown")

            if amount > 0 and wheelUpBoundToIncrease then
                incrementSpeedLimit(settings.speedLimitIncrement)
            elseif amount < 0 and wheelDownBoundToDecrease then
                incrementSpeedLimit(-settings.speedLimitIncrement)
            end

            return
        end
    end)


    Observe("VehicleComponent", "OnVehicleSpeedChange", function(self, speed)
        local speedometerSpeed = utils.speedToSpeedometerUnits(speed)

        if (
                settings.limited
                and speedometerSpeed >= settings.speedLimit
                and not runtimeData.decelerating
                and settings.enabled
            ) then
            self:GetVehicle():ForceBrakesFor(0.01)
        end

        runtimeData.decelerating = false
        runtimeData.currentSpeed = speedometerSpeed
    end)

    Observe("VehicleComponent", "OnMountingEvent", function()
        if runtimeData.limitWidget == nil then
            runtimeData.limitWidget = utils.getOrCreateLimitWidget(shouldDisplayLimitWidget())
        end

        runtimeData.limitWidget:SetVisible(shouldDisplayLimitWidget())
    end)

    Observe("VehicleComponent", "OnUnmountingEvent", function()
        if runtimeData.limitWidget then
            runtimeData.limitWidget:SetVisible(false)
        end
    end)

    Observe("VehicleComponent", "OnVehicleCameraChange", function(self, state)
        settings.inFPP = not state
    end)

    Observe("hudCarController", "OnSpeedValueChanged", function(self)
        if runtimeData.limitWidget then
            local scale = self:GetRootWidget().parentWidget:GetScale()

            utils.updateLimitWidgetMargin(runtimeData.limitWidget)
            runtimeData.limitWidget:SetScale(scale)
            runtimeData.limitWidget:SetVisible(shouldDisplayLimitWidget())
        end
    end)
end)

registerForEvent("onUpdate", function(dt)
    if not runtimeData.inMenu and runtimeData.inGame then
        inputManager.onUpdate(dt)
    end
end)

registerForEvent("onShutdown", function()
    config.saveFile("config.json", settings)
end)
