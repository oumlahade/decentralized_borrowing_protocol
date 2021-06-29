import Float "mo:base/Float";

actor price_oracle{
    var icp_to_sdr : Float = 1.0;
    public query func icp_to_sdr () : Float {
        return icp_to_sdr;
    };

    public func update_icp_to_sdr (Float new_val) : async () {
        icp_to_sdr := icp_to_sdr;
    };
}