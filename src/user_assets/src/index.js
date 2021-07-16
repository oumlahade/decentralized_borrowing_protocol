import { Actor, HttpAgent } from "@dfinity/agent";
import { idlFactory as user1_idl, canisterID as user1_id } from 'dfx-generated/user1';

const agent = new HttpAgent();
const user1 = Actor.createActor(user1_idl, { agent, canisterId: user1_id });

document.getElementById("accntBtn").addEventListener("click", async () => {
  const name = document.getElementById("accntInput").value.toString();
  const opening = await user1.test_run(name);
  const creation = await user1.create_Account(name);
  document.getElementById("accntResult").innerText = opening;
});
document.getElementById("TroveBtn").addEventListener("click", async () => {
  const alert = await user1.create_Trove();
  document.getElementById("Trove-Result").innerText = alert;
});

document.getElementById("ICPDepBtn").addEventListener("click", async () => {
  const amount = document.getElementById("ICPInput").value.toString();
  const depositICP = await user1.deposit_ICP(amount);
  document.getElementById("ICPResults").innerText = opening;
});

document.getElementById("SDRDepBtn").addEventListener("click", async () => {
  const amount = document.getElementById("SDRInput").value.toString();
  const depositICP = await user1.deposit_SDR(amount);
  document.getElementById("SDRResults").innerText = opening;
});

document.getElementById("ICPWithBtn").addEventListener("click", async () => {
  const amount = document.getElementById("ICPWithInput").value.toString();
  const depositICP = await user1.withdraw_ICP(amount);
  document.getElementById("ICPWithResults").innerText = opening;
});

document.getElementById("SDRWithBtn").addEventListener("click", async () => {
  const amount = document.getElementById("SDRWithInput").value.toString();
  const depositICP = await user1.withdraw_SDR(amount);
  document.getElementById("SDRWithResults").innerText = opening;
});

document.getElementById("CloseTroveBtn").addEventListener("click", async () => {
  const alert = await user1.close_Trove();
  document.getElementById("CloseTroveResult").innerText = alert;
});