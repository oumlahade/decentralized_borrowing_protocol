# WaterPark Protocol for the Internet Computer

WaterPark is an application built on the Internet Computer as a decentralized, undercollateralized lending protocol. WaterPark is still currently in development in association with the Duke University CS+ Summer Internship. The application was developed by Oum Lahade (Duke 2024) and Rhys Banerjee (Duke 2023).

## Overview
Based on the Liquity Protocol built on Ethereum, WaterPark seeks to adapt this procedure to the Internet Computer. WaterPark allows users to retain the potential capital appreciation available for ICP coins while extracting value in the form of stablecoins. Users can deposit ICP coins in exchange for overcollateralized SDR stablecoins. This is in the form of interest free loans with a low collateral ratio. A dual functionality of lending and SDR stability is provided by the protocol.

## Canisters
There are 6 main canisters: the price oracle, product, stability pool, treasury, user, and user assets.
### Treasury
This canister has the logic of a central bank in any financial system, where currency is minted and burned. The treasury canister distributes ICP and SDR to the product canister.
### Product
This canister contains the functions for which money operates in WaterPark. The product canister distributes currency to the users, and facilitates user transactions, swapping out ICP for SDR.
### User
This canister contains all the functions a regular user of WaterPark would need in order to make regular transactions. This includes: creating an account, opening a Trove, depositing/withdrawing ICP, depositing/withdrawing SDR, and viewing current balances and collateral ratio.
### User Assets
This canister creates the front-end for the User canister above. The frontend assets are created in HTML and Javascript, with styling created in CSS.
### Price Oracle
This canister fetches the current price of ICP. This is important for calculating the collateral ratio of a user's SDR supply in relation to their ICP deposit.
### Stability Pool
This canister contains the Stability Pool mechanism, largely carried over from Liquity. Users may elect to deposit SDR into the stability pool, which allowing the system to stay solvent against risky troves. When troves become liquidated, the stability pool repossesses its ICP tokens and distributes it proportionally amongst users with stake in the stability pool.

## Running WaterPark
This ReadMe assumes that you have dfx downloaded and installed. Dfinity has provided this [tutorial for the purposes of quickstarting a local dfx environment](https://sdk.dfinity.org/docs/quickstart/local-quickstart.html).

Once you have the latest version of dfx installed, you should begin your local environment by enacting the following commands:
In one terminal, navigate to the project directory and run
```
dfx start
```
In another terminal, navigate to the project directory and run
```
npm install
dfx deploy
```
Now you'll want to find the canister ID for the User_assets canister, which can be achieved by doing as follows:
```
dfx canister id user_assets
```
You should receive a long string of characters. For example: rno2w-sqaaa-aaaaa-aaacq-cai is a real canister ID.

Now, navigate to a web browser of your choice, and go to the following localhost url:
```
http://127.0.0.1:8000/?canisterId=[YOUR CANISTER ID]
```
For example,
```
http://127.0.0.1:8000/?canisterId=rno2w-sqaaa-aaaaa-aaacq-cai
```
That should then bring you to the following view:
![image](https://user-images.githubusercontent.com/59941308/127052935-fb28baf0-5ef0-4669-bdf8-6fe6cbaab537.png)
Congratulations! You are now viewing the User-side for the WaterPark protocol!
