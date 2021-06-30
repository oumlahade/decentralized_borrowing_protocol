import Float "mo:base/Float";
import Text "mo:base/Text";
import Accounts "Accounts";
import Map "mo:base/HashMap";
import Nat "mo:base/Nat";
import D "mo:base/Debug";
import Iter "mo:base/Iter";
import Int "mo:base/Int";

actor stability_pool{
        var icp_amount : Int = 0;
        var sdr_amount : Int = 0;
        var deposited_sdr_amount : Int = 0;
        var reserve_sdr_amount : Int = 0;
        var sdr_burn_request : Int = 0;

        type Account = Accounts.Account;
        type User = Text;
        let map = Map.HashMap<User, Account>(0,Text.equal, Text.hash);
        
    public func create_Stability_Account(id: Text): async (Text,Bool){ //user call
       switch (map.get(id)){
            case null {
                map.put(id, await Accounts.Account(id));
                    return ("Success, Stability Account for " # id # " created with " #Nat.toText(0)# " SDR deposited.",true);  
            };

            case (?Account){
                return ("Failure - A Stability Account with this ID already exists",true)
            };
        };
    };

    public func deposit_SDR (id: Text, sdr_request: Nat): async (Text,Bool){//user call
        switch (map.get(id)){
            case null {
                return ("Failure - A Stability Account associated with this ID does not exist",false);
            };

            case (?Account){
                await Account.add_SDR(sdr_request);
                deposited_sdr_amount += sdr_request;
                sdr_amount += sdr_request;
                return ("Success",true);
            };
        };
    };

    public func deposit_Reserve (sdr_request : Nat) : async () {
        sdr_amount += sdr_request;
        reserve_sdr_amount += sdr_request;
    };

    public func burn_reserve (sdr_request : Int) : async (Text, Bool) { //self call
        if (sdr_request > reserve_sdr_amount) {
            return ("Failure - Reserve SDR amount too low. Please signal system to mint new reserve SDR tokens.",false);
        };
        reserve_sdr_amount -= sdr_request;
        sdr_amount -= sdr_request;
        return ("Success",true);
    };

    public func get_SDR (id: Text) : async Int { //user and self call; from account, not overall
        switch (map.get(id)){
            case null {
                return -1; //failure
            };

            case (?Account){
                return await Account.get_SDR();
            };
        };
    };

    public func get_ICP (id: Text) : async Int { //user and self call; from account, not overall
        switch (map.get(id)){
            case null {
                return -1; //failure
            };

            case (?Account){
                return await Account.get_ICP();
            };
        };
    };

    public func collect_ICP (id: Text) : async Nat { //user call
        switch (map.get(id)){
            case null {
                return 0; //failure
            };

            case (?Account){
                return await Account.collect_ICP();
            };
        };
    };

    public func deposit_ICP (icp_request: Nat) : async () {
        icp_amount += icp_request;
    };

    public func closedTrove (sdr_requests: Nat, icp_request: Nat) : async Text { //disburse and burn
        sdr_burn_request += sdr_requests;
        icp_amount += icp_request;
        if (sdr_burn_request > deposited_sdr_amount){
            let temp: (Text,Bool) = await burn_reserve(sdr_burn_request-deposited_sdr_amount);
            if (temp.1 == false){
                return temp.0;
            };
            sdr_burn_request -= deposited_sdr_amount;
        };
        var sdr_burned_incrementer : Nat = 0;
        var icp_given_incrementer : Nat = 0;
        for (x in map.entries()){
            let tempAccount = x.1;
            let tempSDR : Int = await tempAccount.get_SDR();
            
            let amountToBeBurned : Nat = Int.abs((tempSDR*sdr_burn_request)/deposited_sdr_amount);
            let icpToBeGiven : Nat = Int.abs((tempSDR*icp_amount)/deposited_sdr_amount); //accounts for truncating in previous iterations


            await tempAccount.burn_SDR(amountToBeBurned);
            sdr_burned_incrementer += amountToBeBurned;

            await tempAccount.disburse_ICP(icpToBeGiven);
            icp_given_incrementer += icpToBeGiven;

        };

        sdr_amount -= sdr_burned_incrementer;
        deposited_sdr_amount -= sdr_burned_incrementer;
        sdr_burn_request -= sdr_burned_incrementer;

        icp_amount -= icp_given_incrementer;

        return "Success";
    };

    public func icp_remaining () : async Int {
        return icp_amount;
    };

    public func sdr_to_burn_remaining () : async Int {
        return sdr_burn_request;
    };

    public func totalSDR () : async Int {
        return sdr_amount;
    };

    public func get_total_deposited_sdr () : async Int {
        return deposited_sdr_amount;
    };

    public func get_reserve_sdr_amount () : async Int {
        return reserve_sdr_amount; 
    };
};