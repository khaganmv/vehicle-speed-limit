@wrapMethod(VehicleComponent)
protected final func OnVehicleSpeedChange(speed: Float) -> Void {
    let velocity: Float = AbsF(speed);
    let multiplier: Float = GameInstance
        .GetStatsDataSystem(this.GetVehicle().GetGame())
        .GetValueFromCurve(n"vehicle_ui", velocity, n"speed_to_multiplier");
    let speedValue: Int32 = RoundMath(velocity * multiplier);

    if speedValue >= 40 {
        this.GetVehicle().ForceBrakesFor(0.01);
    };

    wrappedMethod(speed);
}
