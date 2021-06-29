import Float "mo:base/Float";

actor price_oracle{
    var icp_to_sdr : Float = 1.0;
    public func get_icp_to_sdr () : async Float {
        return icp_to_sdr;
    };

    public func update_icp_to_sdr (new_val : Float) : async () {
        icp_to_sdr := icp_to_sdr;
    };
}