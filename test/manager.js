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

    it("Should fail for not being owner", async function () {
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

  context("function: changeTransferStatusTicket", async function () {
    it("Should change Ticket Transfer Status to owner address´s", async function () {
      let transferStatus = 0; // TransferStatus.TRANSFERIBLE
      await contract.createTicket(
        "Coldplay",
        "Concert Buenos Aires",
        1,
        10,
        {from: ownerTicket}
      );
      let tx = await contract.changeTransferStatusTicket(
        ownerTicket,
        0,
        {from: ownerTicket}
      );
      assert.equal(tx.logs[0].args.transferStatusTicket.toString(), transferStatus.toString(), "El Transfer Status deberia ser 0");
    });

    it("Should fail for not being owner", async function () {
      await contract.createTicket(
        "Coldplay",
        "Concert Buenos Aires",
        1,
        10,
        {from: ownerTicket}
      );
      await utils.shouldThrow(
        contract.changeTransferStatusTicket(
          ownerTicket,
          0,
          {from: noOwnerTicket}
        )
      )
    });
  });

  context("function: changeStatusTicket", async function () {
    it("Should change Ticket Status to owner address´s", async function () {
      let status = 1; // TransferStatus.TRANSFERIBLE
      await contract.createTicket(
        "Coldplay",
        "Concert Buenos Aires",
        1,
        10,
        {from: ownerTicket}
      );
      let tx = await contract.changeStatusTicket(
        ownerTicket,
        0,
        1,
        {from: ownerTicket}
      );
      assert.equal(tx.logs[0].args.statusTicket.toString(), status.toString(), "El Status deberia ser 1");
    });

    it("Should fail for not being owner", async function () {
      await contract.createTicket(
        "Coldplay",
        "Concert Buenos Aires",
        1,
        10,
        {from: ownerTicket}
      );
      await utils.shouldThrow(
        contract.changeStatusTicket(
          ownerTicket,
          0,
          1,
          {from: noOwnerTicket}
        )
      )
    });
  });

  context("function: transferTicket", async function () {
    it("Should change to Ticket owner address´s", async function () {
      let _addressOwner = ownerTicket;
      let _index = 0;
      let _newOwner = noOwnerTicket;
      let msg_value = 999;
      await contract.createTicket(
        "Coldplay",
        "Concert Buenos Aires",
        1,
        1,
        {from: _addressOwner}
      );
      await contract.changeTransferStatusTicket(
        _addressOwner,
        _index,
        {from: _addressOwner}
      );
      let tx = await contract.transferTicket(
        _addressOwner,
        _index,
        _newOwner,
        {value: msg_value, from: _newOwner}
      ); 
      assert.notEqual(tx.logs[1].args.oldOwner.toString(), tx.logs[1].args.newOwner.toString(), "Las Address deben ser diferentes");
    });

    it("Should fail for not being New Owner", async function () {
      let _addressOwner = ownerTicket;
      let _index = 0;
      let _newOwner = noOwnerTicket;
      let msg_value = 999;
      await contract.createTicket(
        "Coldplay",
        "Concert Buenos Aires",
        1,
        1,
        {from: _addressOwner}
      );
      await contract.changeTransferStatusTicket(
        _addressOwner,
        _index,
        {from: _addressOwner}
      );
      await utils.shouldThrow(
        contract.transferTicket(
          _addressOwner,
          _index,
          _newOwner,
          {value: msg_value, from: _addressOwner}
        )
      )
    });
  });
});
