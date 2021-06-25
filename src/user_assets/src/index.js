import { Actor, HttpAgent } from "@dfinity/agent";
import { idlFactory as user_idl, canisterID as user_id } from 'dfx-generated/user';

const agent = new HttpAgent();
const user = Actor.createActor(user_idl, { agent, canisterId: user_id });

document.getElementById("accntBtn").addEventListener("click", async () => {
    const name = document.getElementById("accntInput").value.toString();
    const greeting = await user.test_run(name);
  
    document.getElementById("accntResult").innerText = greeting;
  });
document.getElementById("TroveBtn").addEventListener("click", async () => {
    const alert = await user.create_Trove();
    document.getElementById("Trove-Result").innerText = alert;
});
  document.getElementById('trove-test').innerHTML = user.create_Trove();
  