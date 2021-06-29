import Float "mo:base/Float";
import Nat "mo:base/Nat";
import Int "mo:base/Int";
import D "mo:base/Debug";
import Text "mo:base/Text";

actor class Account (name: Text) {
    private let id : Text = name;
    private var sdr_amount : Int = 0;
    private var icp_held : Nat = 0;

    public func add_SDR (sdr_request : Nat): async (){
        sdr_amount += sdr_request;
    };

    public func burn_SDR (sdr_request : Nat): async (){
        sdr_amount -= sdr_request; //can happen that request is greater than amount, but that is a concern for later
    };

    public func collect_ICP () : async Nat {
        let temp = icp_held;
        icp_held := 0;
        return temp;
    };

    public func disburse_ICP (icp_request : Nat) : async () {
        icp_held += icp_request;
    };

    public query func get_SDR () : async Int {
        return sdr_amount;
    }
}