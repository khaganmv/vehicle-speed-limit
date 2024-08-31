local GameUI = require("modules/psiberx/GameUI")
local config = require("modules/keanuWheeze/config")
local inputManager = require("modules/keanuWheeze/inputManager")
local utils = require("modules/utils")

local defaultSettings = {
    enabled = true,
    enabledLimitWidget = true,
    limited = false,
    speedLimit = 40,
    speedLimitIncrement = 20,
    bindings = {
        keyboard = {
            limit = {
                ["keyboardLimit_1"] = "IK_LShift",
                ["keyboardLimit_hold_1"] = false,
                ["keyboardLimit_keys"] = 1
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
            limit = {
                ["gamepadLimit_1"] = "IK_Pad_DigitDown",
                ["gamepadLimit_hold_1"] = false,
                ["gamepadLimit_keys"] = 1
            },
            increaseLimit = {
                ["gamepadIncreaseLimit_1"] = "IK_Pad_LeftShoulder",
                ["gamepadIncreaseLimit_hold_1"] = false,
                ["gamepadIncreaseLimit_keys"] = 1
            },
            decreaseLimit = {
                ["gamepadDecreaseLimit_1"] = "IK_Pad_DigitLeft",
                ["gamepadDecreaseLimit_hold_1"] = false,
                ["gamepadDecreaseLimit_keys"] = 1
            },
        }
    }
}

local settings = {}
local runtimeData = {
    inMenu = false,
    inGame = false,
    decelerating = false
}

local function shouldDisplayLimitWidget()
    return settings.enabled
       and settings.enabledLimitWidget
       and settings.limited
       and utils.isInVehicle()
end

local function initBindingInfo()
    local keyboardLimitBindingInfo = utils.createBindingInfo(
        inputManager,
        "/vehicleSpeedLimit/keyboardLimit",
        "keyboardLimit",
        defaultSettings.bindings.keyboard.limit,
        settings.bindings.keyboard.limit,
        function()
            if settings.enabled and utils.isInVehicle() then
                settings.limited = not settings.limited
            end
        end,
        function (name, value)
            settings.bindings.keyboard.limit[name] = value
            config.saveFile("config.json", settings)
        end
    )
    local keyboardIncreaseLimitBindingInfo = utils.createBindingInfo(
        inputManager,
        "/vehicleSpeedLimit/keyboardIncreaseLimit",
        "keyboardIncreaseLimit",
        defaultSettings.bindings.keyboard.increaseLimit,
        settings.bindings.keyboard.increaseLimit,
        function()
            if settings.enabled and utils.isInVehicle() then
                settings.speedLimit = settings.speedLimit + settings.speedLimitIncrement
            end
        end,
        function (name, value)
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
        function()
            if settings.enabled and utils.isInVehicle() then
                settings.speedLimit = settings.speedLimit - settings.speedLimitIncrement

                if settings.speedLimit < 0 then
                    settings.speedLimit = 0
                end
            end
        end,
        function (name, value)
            settings.keyboard.decreaseLimit[name] = value
            config.saveFile("config.json", settings)
        end
    )
    local gamepadLimitBindingInfo = utils.createBindingInfo(
        inputManager,
        "/vehicleSpeedLimit/gamepadLimit",
        "gamepadLimit",
        defaultSettings.bindings.gamepad.limit,
        settings.bindings.gamepad.limit,
        function()
            if settings.enabled and utils.isInVehicle() then
                settings.limited = not settings.limited
            end
        end,
        function (name, value)
            settings.bindings.gamepad.limit[name] = value
            config.saveFile("config.json", settings)
        end
    )
    local gamepadIncreaseLimitBindingInfo = utils.createBindingInfo(
        inputManager,
        "/vehicleSpeedLimit/gamepadIncreaseLimit",
        "gamepadIncreaseLimit",
        defaultSettings.bindings.gamepad.increaseLimit,
        settings.bindings.gamepad.increaseLimit,
        function()
            if settings.enabled and utils.isInVehicle() then
                settings.speedLimit = settings.speedLimit + settings.speedLimitIncrement
            end
        end,
        function (name, value)
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
        function()
            if settings.enabled and utils.isInVehicle() then
                settings.speedLimit = settings.speedLimit - settings.speedLimitIncrement

                if settings.speedLimit < 0 then
                    settings.speedLimit = 0
                end
            end
        end,
        function (name, value)
            settings.bindings.gamepad.decreaseLimit[name] = value
            config.saveFile("config.json", settings)
        end
    )

    inputManager.addNativeSettingsBinding(keyboardLimitBindingInfo)
    inputManager.addNativeSettingsBinding(keyboardIncreaseLimitBindingInfo)
    inputManager.addNativeSettingsBinding(keyboardDecreaseLimitBindingInfo)
    inputManager.addNativeSettingsBinding(gamepadLimitBindingInfo)
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
        function (state) settings.enabled = state end
    )
    nativeSettings.addSwitch(
        "/vehicleSpeedLimit/mod",
        "Limit Widget",
        "",
        settings.enabledLimitWidget,
        defaultSettings.enabledLimitWidget,
        function (state) 
            settings.enabledLimitWidget = state

            if runtimeData.limitWidget ~= nil then
                runtimeData.limitWidget:SetVisible(shouldDisplayLimitWidget())
            end
        end
    )
    nativeSettings.addRangeInt(
        "/vehicleSpeedLimit/mod",
        "Speed Limit",
        "",
        0, 300, 1, 
        settings.speedLimit, 40,
        function (value) settings.speedLimit = value end
    )
    nativeSettings.addRangeInt(
        "/vehicleSpeedLimit/mod",
        "Speed Limit Increment",
        "",
        0, 300, 1, 
        settings.speedLimitIncrement, 20,
        function (value) settings.speedLimitIncrement = value end
    )
    
    nativeSettings.addSubcategory("/vehicleSpeedLimit/keyboardLimit", "Keyboard Hotkey (Limit)")
    nativeSettings.addSubcategory("/vehicleSpeedLimit/keyboardIncreaseLimit", "Keyboard Hotkey (Increase Limit)")
    nativeSettings.addSubcategory("/vehicleSpeedLimit/keyboardDecreaseLimit", "Keyboard Hotkey (Decrease Limit)")
    nativeSettings.addSubcategory("/vehicleSpeedLimit/gamepadLimit", "Gamepad Hotkey (Limit)")
    nativeSettings.addSubcategory("/vehicleSpeedLimit/gamepadIncreaseLimit", "Gamepad Hotkey (Increase Limit)")
    nativeSettings.addSubcategory("/vehicleSpeedLimit/gamepadDecreaseLimit", "Gamepad Hotkey (Decrease Limit)")
    initBindingInfo()
end

registerForEvent("onHook", function ()
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
    end)

    GameUI.OnSessionEnd(function()
        runtimeData.inGame = false
    end)

    runtimeData.inGame = not GameUI.IsDetached()

    Observe('RadialWheelController', 'OnIsInMenuChanged', function(_, isInMenu)
        runtimeData.inMenu = isInMenu
    end)

    Observe("VehicleComponent", "RegisterInputListener", function (self)
        Game.GetPlayerSystem()
            :GetLocalPlayerMainGameObject()
            :RegisterInputListener(self, "Decelerate")
    end)

    Observe("VehicleComponent", "OnAction", function (self, action, consumer)
        if action:GetName().value == "Decelerate" then
            runtimeData.decelerating = true
        end
    end)

    Observe("VehicleComponent", "OnVehicleSpeedChange", function (self, speed)
        if settings.limited
        and utils.speedToSpeedometerUnits(speed) >= settings.speedLimit
        and not runtimeData.decelerating
        and settings.enabled
        then
            self:GetVehicle():ForceBrakesFor(0.01)
        end

        runtimeData.decelerating = false
    end)

    Observe("VehicleComponent", "OnMountingEvent", function ()
        if runtimeData.limitWidget == nil then
            runtimeData.limitWidget = utils.getOrCreateLimitWidget(shouldDisplayLimitWidget())
        end

        runtimeData.limitWidget:SetVisible(shouldDisplayLimitWidget())
	end)

    Observe("VehicleComponent", "OnUnmountingEvent", function ()
        if runtimeData.limitWidget then
            runtimeData.limitWidget:SetVisible(false)
        end
	end)

    Observe("hudCarController", "OnSpeedValueChanged", function (self)
        if runtimeData.limitWidget then
            local scale = self:GetRootWidget():GetParentWidget():GetScale()

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

registerForEvent("onShutdown", function ()
    config.saveFile("config.json", settings)
end)
