import user "canister:user";
import Float "mo:base/Float";
import Text "mo:base/Text";
import Troves "Troves";
import Map "mo:base/HashMap";
import Nat "mo:base/Nat";
import D "mo:base/Debug";

//this will add troves to map and have functions for adding collateral, getting more sdr, paying back sdr, withdrawing collateral that call similar trove functions and alter overall parameters

actor product {

    //initialize stuff
    private let initial_SDR_supply : Int = 1000000; // in stability pool
    private let minCollateralRatio : Float = 1.1; //make this information and some of the other information come from a different file

    private var sdr_supply : Int = 0; //total supply
    private var icp_supply : Int = 0; //total supply

    public func get_SDR_Supply () : async Int {
        return sdr_supply;
    };

    public func get_ICP_Supply () : async Int {
        return icp_supply;
    };

    public func init () {
        sdr_supply := initial_SDR_supply;
    };


    private var icp_to_dollar : Float = 1.0; //these need to be updated periodicaly (price of ICP in Dollars)
    private var sdr_to_dollar : Float = 1.0; //these need to be updated periodicaly (price of SDR in Dollars)

    //Functionality needed to create Troves
    type Trove = Troves.Trove;
    type User = Text;
    let map = Map.HashMap<User, Trove>(0,Text.equal, Text.hash);

    public func createTrove(id: Text, icp_request: Nat, sdr_request: Nat): async Text{
        
       let ratio : Float = (Float.fromInt(icp_request)*icp_to_dollar)/(Float.fromInt(sdr_request)*sdr_to_dollar);
       if (ratio < minCollateralRatio){
           return "Failure, please improve your collateral ratio";
       }
       else{
           map.put(id, await Troves.Trove(id, icp_request, sdr_request, minCollateralRatio));
           return "Success, Trove for " # id # " created with " #Nat.toText(icp_request)# " ICP deposited and " # Nat.toText(sdr_request) # " SDR withdrawn.";
       }
    };
};