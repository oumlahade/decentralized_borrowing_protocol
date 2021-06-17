import user "canister:user";
import treasury "canister:treasury";
import Float "mo:base/Float";
import Text "mo:base/Text";
import Troves "Troves";
import Map "mo:base/HashMap";
import Nat "mo:base/Nat";
import D "mo:base/Debug";

//this will add troves to map and have functions for adding collateral, getting more sdr, paying back sdr, withdrawing collateral that call similar trove functions and alter overall parameters

actor product {

    //_______________________________________

    var icp_to_dollar : Float = 1.0; //null values to be rewritten using updateTreasury
    var sdr_to_dollar : Float = 1.0; //null values to be rewritten using updateTreasury
    var minCollateralRatio : Float = 1.1; //null values to be rewritten using updateTreasury

    func updateTreasury() : async (){
    icp_to_dollar := await treasury.icp_to_dollar(); //these need to be updated periodicaly (price of ICP in Dollars)
    sdr_to_dollar := await treasury.sdr_to_dollar(); //these need to be updated periodicaly (price of SDR in Dollars)
    minCollateralRatio := await treasury.getMinCollateralRatio();
    };

    //_______________________________________

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

    public func increaseSDR (id: Text, sdr_request: Nat): async (Text,Bool){
        //let trove : Troves.Trove = map.get(id);
        switch (map.get(id)){
            case null {
                return ("Failure - A Trove associated with this ID does not exist",false)
            };

            case (?Trove){
                let temp = await Trove.increaseSDR(sdr_request);
                return temp;
            };
        };
        
    };
    

    /*public func increaseICP (icp_request: Nat) : async (Text,Bool){
        
    };

    public func decreaseSDR (sdr_request: Nat) : async (Text,Bool){
        
    };

    public func decreaseICP (icp_request: Nat) : async (Text,Bool){
        
    };

    public func closeTrove (sdr_request: Nat) : async (Text, Bool){
        
    }; */
};