import treasury "canister:treasury";
import price_oracle "canister:price_oracle";
import stability_pool "canister:stability_pool";
import Float "mo:base/Float";
import Text "mo:base/Text";
import Troves "Troves";
import Map "mo:base/HashMap";
import Nat "mo:base/Nat";
import D "mo:base/Debug";
import Array "mo:base/Array";


//this will add troves to map and have functions for adding collateral, getting more sdr, paying back sdr, withdrawing collateral that call similar trove functions and alter overall parameters

actor product {

    //_______________________________________

    var icp_to_sdr : Float = 1.0; //null values to be rewritten using price_oracle
    var minCollateralRatio : Float = 1.1; //null values to be rewritten using updateTreasury

    func updateTreasury_and_Price() : async (){
    icp_to_sdr := await price_oracle.get_icp_to_sdr(); //these need to be updated periodicaly
    minCollateralRatio := await treasury.getMinCollateralRatio();
    };

    //_______________________________________

    //Functionality needed to create Troves
    type Trove = Troves.Trove;
    type User = Text;
    let map = Map.HashMap<User, Trove>(0,Text.equal, Text.hash);

    public func createTrove(id: Text, icp_request: Nat, sdr_request: Nat): async Text{
       

       switch (map.get(id)){
            case null {
                let ratio : Float = (Float.fromInt(icp_request)*icp_to_sdr)/(Float.fromInt(sdr_request));
                if (ratio < minCollateralRatio){
                    return "Failure, please improve your collateral ratio";
                }
                else{
                    map.put(id, await Troves.Trove(id, icp_request, sdr_request, minCollateralRatio));
                    return "Success, Trove for " # id # " created with " #Nat.toText(icp_request)# " ICP deposited and " # Nat.toText(sdr_request) # " SDR withdrawn.";
                };  
            };

            case (?Trove){
                return "Failure - A Trove with this ID already exists"
            };
        };
    };

    public func increaseSDR (id: Text, sdr_request: Nat): async (Text,Bool){ //add more debt
        switch (map.get(id)){
            case null {
                return ("Failure - A Trove associated with this ID does not exist",false);
            };

            case (?Trove){
                let temp = await Trove.increaseSDR(sdr_request);
                if (temp.1 == true){
                    return await treasury.mintSDR(sdr_request);
                };
                return temp; //this returns a failure in the Trove
            };
        };
        
    };
    

    public func increaseICP (id: Text, icp_request: Nat) : async (Text,Bool){ //add collateral
        switch (map.get(id)){
            case null {
                return ("Failure - A Trove associated with this ID does not exist",false);
            };

            case (?Trove){
                let temp = await Trove.increaseICP(icp_request);
                if (temp.1 == true){
                    return await treasury.addICP(icp_request);
                };
                return temp; //this returns a failure in the Trove
            };
        };
    };

    public func decreaseSDR (id: Text, sdr_request: Nat) : async (Text,Bool){
        switch (map.get(id)){
            case null {
                return ("Failure - A Trove associated with this ID does not exist",false);
            };

            case (?Trove){
                let temp = await Trove.decreaseSDR(sdr_request);
                if (temp.1 == true){
                    let temp2 = await treasury.burnSDR(sdr_request); //burning sdr
                    if (temp2.1 == true){
                        return temp2;
                    }
                    else{ //theoretically this should never trigger because they cannot return more than they borrowed, and the pool should always have at least what they owe
                        let ign = await Trove.increaseSDR(sdr_request); //overturn previous removal, ignore the value since it will have to execute since it's reverting to previous state which was shown to have worked
                        return temp2; //return error message
                    };
                };
                return temp; //this returns a failure
            };
        };
    };

    public func decreaseICP (id: Text, icp_request: Nat) : async (Text,Bool){
        switch (map.get(id)){
            case null {
                return ("Failure - A Trove associated with this ID does not exist",false);
            };

            case (?Trove){
                let temp = await Trove.decreaseICP(icp_request);
                if (temp.1 == true){
                    let temp2 = await treasury.removeICP(icp_request); //burning sdr
                    if (temp2.1 == true){
                        return temp2;
                    }
                    else{ //theoretically this should never trigger because their ICP balance can never be greater than the total ICP balance (and if they request more than their balance the Trove triggers the error, not this)
                        let ign = await Trove.increaseICP(icp_request); //overturn previous removal
                        return temp2; //return error message
                    };
                };
                return temp; //this returns a failure
            };
        };
    };

    public func closeTrove (id: Text, sdr_request: Nat) : async (Text, Nat,Bool){
        switch (map.get(id)){
            case null {
                return ("Failure - A Trove associated with this ID does not exist", 0, false);
            };

            case (?Trove){
                let temp = await Trove.closeTrove(sdr_request);
                if (temp.2 == true){
                    //neither of these should fail, otherwise we have a large problem and need to redo stuff
                    let temp2 = await treasury.burnSDR(sdr_request); //burning sdr
                    let temp3 = await Trove.decreaseICP(temp.1);
                    // eventually we need to figure out actual transfer features
                };
                let ignorE = map.remove(id);
                return temp;
            };
        };
    };

    public func getTroveICP (id: Text): async (Text,Nat,Bool){
        switch (map.get(id)){
            case null {
                return ("Failure - A Trove associated with this ID does not exist",0,false);
            };

            case (?Trove){
                return ("Success", await Trove.icpAmount(),true);
            };
        };
        
    };
    public func getTroveSDR (id: Text): async (Text,Nat,Bool){
        switch (map.get(id)){
            case null {
                return ("Failure - A Trove associated with this ID does not exist",0,false);
            };

            case (?Trove){
                return ("Success",await Trove.sdrAmount(),true);
            };
        };
        
    };

    public func getTroveCollateralRatio (id: Text): async (Text,Float,Bool){
        switch (map.get(id)){
            case null {
                return ("Failure - A Trove associated with this ID does not exist",0,false);
            };

            case (?Trove){
                return ("Success",await Trove.collateralRatio(),true);
            };
        };
        
    };

    public func checkLiquidation() : async Text {
        var total_SDR : Nat = 0;
        var total_ICP : Nat = 0;

        var closedTrovesList : Text = "Troves for";
        let copyClosedTrovesList = "Troves for";

        for (x in map.entries()){
            let tempTrove = x.1;
            let tempcollatRatio = await tempTrove.collateralRatio(); 
            if ( tempcollatRatio < minCollateralRatio){
                let sdrRequired = await tempTrove.sdrAmount();
                if (sdrRequired > 0 ){
                    let icp_heldTemp = await tempTrove.closeTrove(sdrRequired);
                    let icp_held = icp_heldTemp.1;
                    let ignorE = map.remove(x.0);
                    closedTrovesList := closedTrovesList # " " # x.0 # ",";
                    total_SDR += sdrRequired;
                    total_ICP += icp_held;
                };
            };
        };
        D.print("Total SDR: " #Nat.toText(total_SDR));
        D.print("Total ICP: " #Nat.toText(total_ICP));

        let tempResponse = await stability_pool.closedTrove(total_SDR,total_ICP);

        if (Text.equal(closedTrovesList, copyClosedTrovesList)){
            return "No Troves were Liquidated."
        };

        return closedTrovesList # " were closed.";

    };
      
};