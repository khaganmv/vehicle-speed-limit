local decelerating = false
local enabled = true
local limited = false
local speedLimit = 40

local function initializeNativeSettingsUI()
    local nativeSettings = GetMod("nativeSettings")

    if not nativeSettings then 
        print("Native Settings UI not found")
        return false 
    end

    nativeSettings.addTab(
        "/vehicleSpeedLimit", 
        "Vehicle Speed Limit"
    )
    nativeSettings.addSwitch(
        "/vehicleSpeedLimit",
        "Enabled",
        "",
        enabled,
        true,
        function (state) enabled = state end
    )
    nativeSettings.addRangeInt(
        "/vehicleSpeedLimit",
        "Speed Limit",
        "",
        0, 300, 1, 
        speedLimit, 40,
        function (value) speedLimit = value end
    )

    return true
end

local function isInVehicle()
    return Game.GetMountedVehicle(Game.GetPlayer()) ~= nil
end

local function getSpeedometerUnits()
    local configVarListString = GameInstance
        .GetSettingsSystem()
        :GetGroup("/interface")
        :GetVar("SpeedometerUnits")

    return configVarListString:GetIndex()
end

local function speedToSpeedometerUnits(speed, isMetric)
    local velocity = AbsF(speed)
    local multiplier = GameInstance
        .GetStatsDataSystem()
        :GetValueFromCurve("vehicle_ui", velocity, "speed_to_multiplier")
    local unit = 1

    if isMetric then
        unit = 1.61
    end

    return RoundMath(velocity * multiplier * unit)
end

registerInput("release", "Release", function (keypress)
    if keypress 
    and isInVehicle() 
    and enabled
    then
        limited = not limited
    end
end)

registerForEvent("onInit", function ()
    if not initializeNativeSettingsUI() then
        print("Failed to initialize Native Settings UI")
    end

    Observe("VehicleComponent", "RegisterInputListener", function (self)
        Game.GetPlayerSystem()
            :GetLocalPlayerMainGameObject()
            :RegisterInputListener(self, "Decelerate")

        Game.GetPlayerSystem()
            :GetLocalPlayerMainGameObject()
            :RegisterInputListener(self, "Release")
    end)
    
    Observe("VehicleComponent", "OnAction", function (self, action, consumer)
        local actionName = action:GetName().value
        
        if actionName == "Decelerate" then
            decelerating = true
        end

        if actionName == "Release"
        and ListenerAction.IsButtonJustPressed(action)
        then
            limited = not limited
        end
    end)

    Observe("VehicleComponent", "OnVehicleSpeedChange", function (self, speed)
        local isMetric = getSpeedometerUnits() ~= 1

        if limited
        and speedToSpeedometerUnits(speed, isMetric) >= speedLimit
        and not decelerating 
        and enabled
        then
            self:GetVehicle():ForceBrakesFor(0.01)
        end

        decelerating = false
    end)
end)
