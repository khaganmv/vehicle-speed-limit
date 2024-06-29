public class VehicleSpeedLimit extends ScriptableSystem {
    @runtimeProperty("ModSettings.mod", "Vehicle Speed Limit")
    @runtimeProperty("ModSettings.displayName", "Speed")
    @runtimeProperty("ModSettings.step", "1")
    @runtimeProperty("ModSettings.min", "0")
    @runtimeProperty("ModSettings.max", "200")
    let speedLimit: Int32 = 40;

    @if(ModuleExists("ModSettingsModule"))
    private func OnAttach() -> Void {
        ModSettings.RegisterListenerToClass(this);
    }
    
    @if(ModuleExists("ModSettingsModule"))
    private func OnDetach() -> Void {
        ModSettings.UnregisterListenerToClass(this);
    }

    public static func GetInstance(gameInstance: GameInstance) -> ref<VehicleSpeedLimit> {
        return GameInstance
            .GetScriptableSystemsContainer(gameInstance)
            .Get(n"VehicleSpeedLimit") as VehicleSpeedLimit;
    }
}

@addField(VehicleComponent)
let toggledSprint: Bool = false;

@addMethod(VehicleComponent)
public func GetSpeedometerUnits() -> Int32 {
    let configVarListString = GameInstance
        .GetSettingsSystem(this.GetVehicle().GetGame())
        .GetGroup(n"/interface")
        .GetVar(n"SpeedometerUnits") as ConfigVarListString;
    
    return configVarListString.GetIndex();
}

@addMethod(VehicleComponent)
public func SpeedToSpeedometerUnits(speed: Float, isMetric: Bool) -> Int32 {
    let velocity = AbsF(speed);
    let multiplier = GameInstance
        .GetStatsDataSystem(this.GetVehicle().GetGame())
        .GetValueFromCurve(n"vehicle_ui", velocity, n"speed_to_multiplier");
    let unit = isMetric ? 1.61 : 1.00;

    return RoundMath(velocity * multiplier * unit);
}

@wrapMethod(VehicleComponent)
private final func RegisterInputListener() -> Void {
    wrappedMethod();
    
    GameInstance
        .GetPlayerSystem(this.GetVehicle().GetGame())
        .GetLocalPlayerMainGameObject()
        .RegisterInputListener(this, n"Unlimit");
}

@wrapMethod(VehicleComponent)
protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    wrappedMethod(action, consumer);

    if Equals(action.GetName(), n"Unlimit") 
    && Equals(action.GetType(), gameinputActionType.BUTTON_PRESSED) 
    {
        this.toggledSprint = !this.toggledSprint;
    };
}

@wrapMethod(VehicleComponent)
protected final func OnVehicleSpeedChange(speed: Float) -> Void {
    let speedLimit = VehicleSpeedLimit.GetInstance(this.GetVehicle().GetGame()).speedLimit;
    let isMetric = this.GetSpeedometerUnits() != 1;

    if this.SpeedToSpeedometerUnits(speed, isMetric) >= speedLimit 
    && !this.toggledSprint 
    {
        this.GetVehicle().ForceBrakesFor(0.01);
    };

    wrappedMethod(speed);
}
