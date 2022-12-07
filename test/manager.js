const Manager = artifacts.require("Manager");
const Ticket = artifacts.require("Ticket");
const utils = require("./helpers/utils");

contract("Manager", function (accounts) {
  let contract;
  const [ownerTicket, noOwnerTicket] = accounts;

  beforeEach(async () => {
    contract = await Manager.new();
  });

  context("function: createTicket", async function () {
    it("Should add the Ticket to list", async function () {
      await contract.createTicket(
        "Coldplay",
        "Concert Buenos Aires",
        1,
        150
      );
      let listOwners = await contract.getOwners();
      assert.equal(listOwners.length, 1, "El tamaño de la lista deberia ser 1");
    });

    it("Should add the Ticket to list with address no owner", async function () {
      await contract.createTicket(
        "Coldplay",
        "Concert Buenos Aires",
        1,
        150,
        { from: noOwnerTicket }
      );
      let listOwners = await contract.getOwners();
      assert.equal(listOwners.length, 1, "El tamaño de la lista deberia ser 1");
    });
  });

  context("function: changeTicketPrice", async function () {
    it("Should be owner Ticket equal to address input", async function () {
      let msg_value = 99999;
      let price_commission = 30;
      await contract.createTicket(
        "Coldplay",
        "Concert Buenos Aires",
        1,
        10,
        {from: ownerTicket}
      );
      await contract.changeTicketPrice(
        ownerTicket,
        0,
        price_commission,
        {value: msg_value}
      );
      contractTicket = await Ticket.new("Coldplay", "Concert Buenos Aires", 1, 10, ownerTicket);
      let ticketOwner = await contractTicket.getOwner();
      assert.equal(ticketOwner, ownerTicket, "Los address deberian ser iguales");
    });

    it("Should be owner Ticket different to address input", async function () {
      let msg_value = 99999;
      let price_commission = 30;
      await contract.createTicket(
        "Coldplay",
        "Concert Buenos Aires",
        1,
        10,
        {from: ownerTicket}
      );
      await contract.changeTicketPrice(
        ownerTicket,
        0,
        price_commission,
        {value: msg_value}
      );
      contractTicket = await Ticket.new("Coldplay", "Concert Buenos Aires", 1, 10, ownerTicket);
      let ticketOwner = await contractTicket.getOwner();
      assert.notEqual(ticketOwner, noOwnerTicket, "Los address deberian ser diferentes");
    });

    it("Should fail if the amount available is insufficient", async function () {
      let msg_value = 20;
      let price_commission = 30;
      await contract.createTicket(
        "Coldplay",
        "Concert Buenos Aires",
        1,
        25,
        {from: ownerTicket}
      );
      await utils.shouldThrow(
        contract.changeTicketPrice(
          ownerTicket,
          0,
          price_commission,
          {value: msg_value}
        )   
      )
    });
  });
  context("function: deleteTicket", async function () {
    it("Should delete Ticket to owner address´s", async function () {
      await contract.createTicket(
        "Coldplay",
        "Concert Buenos Aires",
        1,
        10,
        {from: ownerTicket}
      );
      await contract.deleteTicket(
        ownerTicket,
        0,
        {from: ownerTicket}
      );
      let listOwners = await contract.getOwners();
      assert.equal(listOwners.length, 0, "El tamaño de la lista deberia ser 0");
    });

    it("Should should fail for not being owner", async function () {
      await contract.createTicket(
        "Coldplay",
        "Concert Buenos Aires",
        1,
        10,
        {from: ownerTicket}
      );
      await utils.shouldThrow(
        contract.deleteTicket(
          ownerTicket,
          0,
          {from: noOwnerTicket}
        )
      )
    });
  });
});
