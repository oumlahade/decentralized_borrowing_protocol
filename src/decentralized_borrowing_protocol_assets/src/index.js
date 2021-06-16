import { Actor, HttpAgent } from '@dfinity/agent';
import { idlFactory as decentralized_borrowing_protocol_idl, canisterId as decentralized_borrowing_protocol_id } from 'dfx-generated/decentralized_borrowing_protocol';

const agent = new HttpAgent();
const decentralized_borrowing_protocol = Actor.createActor(decentralized_borrowing_protocol_idl, { agent, canisterId: decentralized_borrowing_protocol_id });

document.getElementById("clickMeBtn").addEventListener("click", async () => {
  const name = document.getElementById("name").value.toString();
  const greeting = await decentralized_borrowing_protocol.greet(name);

  document.getElementById("greeting").innerText = greeting;
});
