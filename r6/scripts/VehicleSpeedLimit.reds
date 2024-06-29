@addField(VehicleComponent)
let toggledSprint: Bool = false;

@addMethod(VehicleComponent)
public func SpeedToMPH(speed: Float) -> Int32 {
    let velocity = AbsF(speed);
    let multiplier = GameInstance
        .GetStatsDataSystem(this.GetVehicle().GetGame())
        .GetValueFromCurve(n"vehicle_ui", velocity, n"speed_to_multiplier");

    return RoundMath(velocity * multiplier);
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
    if this.SpeedToMPH(speed) >= 40 && !this.toggledSprint {
        this.GetVehicle().ForceBrakesFor(0.01);
    };

    wrappedMethod(speed);
}
