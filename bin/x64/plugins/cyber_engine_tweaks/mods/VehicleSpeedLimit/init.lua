local GameUI = require("modules/psiberx/GameUI")
local config = require("modules/keanuWheeze/config")
local inputManager = require("modules/keanuWheeze/inputManager")
local utils = require("modules/utils")

local defaultSettings = {
    enabled = true,
    enabledLimitWidget = true,
    speedLimit = 40,
    limited = false,
    keyboard = {
        ["mkbBinding_1"] = "IK_LShift",
        ["mkbBinding_hold_1"] = false,
        ["mkbBinding_keys"] = 1
    },
    pad = {
        ["padBinding_1"] = "IK_Pad_DigitDown",
        ["padBinding_hold_1"] = false,
        ["padBinding_keys"] = 1
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
    local keyboardBindingInfo = utils.createBindingInfo(
        inputManager,
        "/vehicleSpeedLimit/hotkeyMKB",
        "mkbBinding",
        defaultSettings.keyboard,
        settings.keyboard,
        function()
            if settings.enabled and utils.isInVehicle() then
                settings.limited = not settings.limited
            end
        end,
        function (name, value)
            settings.keyboard[name] = value
            config.saveFile("config.json", settings)
        end
    )
    local gamepadBindingInfo = utils.createBindingInfo(
        inputManager,
        "/vehicleSpeedLimit/hotkeyPad",
        "padBinding",
        defaultSettings.pad,
        settings.pad,
        function()
            if settings.enabled and utils.isInVehicle() then
                settings.limited = not settings.limited
            end
        end,
        function (name, value)
            settings.pad[name] = value
            config.saveFile("config.json", settings)
        end
    )

    inputManager.addNativeSettingsBinding(keyboardBindingInfo)
    inputManager.addNativeSettingsBinding(gamepadBindingInfo)
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
    
    nativeSettings.addSubcategory("/vehicleSpeedLimit/hotkeyMKB", "Keyboard Hotkey")
    nativeSettings.addSubcategory("/vehicleSpeedLimit/hotkeyPad", "Controller Hotkey")
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
