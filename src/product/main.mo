import user "canister:user"
actor product {

    let initial_SDR_supply : Nat = 1000000; // in stability pool

    var SDR_supply : Nat = 0; //total supply

    public func greet(name : Text) : async Bool {
        return await user.greet(name);
    };

    public func init () {
        SDR_supply := initial_SDR_supply;
    };

    public func get_SDR_Supply () : async Nat {
        return SDR_supply;
    }
};
