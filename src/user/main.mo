import product "canister:product"
import Float "mo:base/Float";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import D "mo:base/Debug";

actor user{
    public func greet(name : Text) : async Bool {
        return true;
    };
};
