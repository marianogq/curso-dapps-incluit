const Manager = artifacts.require("Manager");
const Ticket = artifacts.require("Ticket");
const utils = require("./helpers/utils");

contract("Manager", function (accounts) {
  let contract;
  const [ownerTicket, noOwnerTicket] = accounts;

  beforeEach(async () => {
    contract = await Manager.new(ownerTicket);
  });

  context("function: createTicket", async function () {
    it("Should add the Ticket to list", async function () {
      // Set up: Inicializar variables.
      //In BeforeEach

      // Act: Ejecutar.
      await contract.createTicket(
        "Coldplay",
        "Concert Buenos Aires",
        1,
        150,
        ownerTicket
      );

      // Assert: Comprobar datos
      let listTickets = await contract.listTickets[ownerTicket][0];
      assert.equal(listTickets.length, 1, "El tamanio de la lista deberia ser 1");
    });

    // it("Should add the Ticket to list with address no owner", async function () {
    //   // Set up:
    //   //In BeforeEach

    //   // Act:
    //   await contract.createTicket(
    //     "Coldplay",
    //     "Concert Buenos Aires",
    //     1,
    //     150,
    //     noOwnerTicket,
    //     { from: noOwnerTicket }
    //   );

    //   // Assert:
    //   let Ticket = await contract.showTicketsByAddress(ownerTicket);
    //   assert.equal(Ticket.length, 1, "El tamanio de la lista deberia ser 1");
    // });
  });

});
