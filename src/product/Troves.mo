import Float "mo:base/Float";
import treasury "canister:treasury";
import price_oracle "canister:price_oracle";
import Nat "mo:base/Nat";
import Int "mo:base/Int";
import D "mo:base/Debug";
import Text "mo:base/Text";

actor class Trove (name: Text, icp: Nat, sdr: Nat, minCollatRatio: Float) {
    private var minCollateralRatio = minCollatRatio;
    private let userName = name;
    private var icp_held = icp;
    private var sdr_outstanding = sdr;

    //_______________________________________

    var icp_to_sdr : Float = 1.0; //null values to be rewritten using price_oracle

    func updateTreasury_and_Price() : async (){
    icp_to_sdr := await price_oracle.get_icp_to_sdr(); //these need to be updated periodicaly
    minCollateralRatio := await treasury.getMinCollateralRatio();
    };

    //_______________________________________

    public query func icpAmount() : async Nat {
        return icp_held;
    };
    public query func sdrAmount() : async Nat {
        return sdr_outstanding;
    };

    public query func collateralRatio() : async Float {
        let ratio = (Float.fromInt(icp_held)*icp_to_sdr)/(Float.fromInt(sdr_outstanding));
        return ratio;
    };

    //returns true if successful which should trigger the product canister to issue SDR to the user
    public func increaseSDR (sdr_request: Nat): async (Text,Bool){
        let futureSDR : Nat = sdr_outstanding + sdr_request;
        if ((Float.fromInt(icp_held)*icp_to_sdr)/(Float.fromInt(futureSDR)) < minCollateralRatio){
            return ("Failure - Deposit more ICP or Withdraw less SDR.",false);
        };
        sdr_outstanding := futureSDR;
        return ("Success",true);
    };

    public func increaseICP (icp_request: Nat) : async (Text,Bool){
        icp_held += icp_request;
        return ("Success", true);
    };

    public func decreaseSDR (sdr_request: Nat) : async (Text,Bool){
        if (sdr_request > sdr_outstanding){
            return ("Failure - Deposit is larger than SDR Outstanding",false);
        };
        sdr_outstanding -= sdr_request;
        return ("Success", true)
    };

    public func decreaseICP (icp_request: Nat) : async (Text,Bool){
        let futureICP : Nat = icp_held - icp_request;
        if ((Float.fromInt(futureICP)*icp_to_sdr)/(Float.fromInt(sdr_outstanding)) < minCollateralRatio){
            return ("Failure - Withdraw less ICP or Deposit more ICP.",false);
        };
        icp_held := futureICP;
        return ("Success",true);
    };

    public func closeTrove (sdr_request: Nat) : async (Text, Nat,Bool){
        if (sdr_request != sdr_outstanding){
            return ("Failure - You must return " # Nat.toText(sdr_outstanding) # " to close this Trove", 0,false)
        };
        return ("Success",icp_held,true);
        //we dont need to clear this trove because it will be deleted from the map anyways (idk about this if we implement a heap, then this will need to change)
    };

    public query func getName() : async Text {
        return userName;
    };
}