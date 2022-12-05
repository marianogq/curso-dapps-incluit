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

    // it("Should add the Ticket to list", async function () {
    //   // Set up: Inicializar variables.
    //   //In BeforeEach
    //   await contract.createTicket(
    //     "Coldplay",
    //     "Concert Buenos Aires",
    //     1,
    //     150
    //   );
    //   // Act: Ejecutar.
    //   let logs = await contract.createTicket(
    //     "Coldplay",
    //     "Concert Buenos Aires",
    //     1,
    //     150
    //   );
    //   //let listTickets = await contract.OwnersTickets[0];
    //   console.log(logs);
    //   console.log(logs.logs[0].args[4]);
    //   console.log(contract.OwnersTickets[0]);
    //   // Assert: Comprobar datos
      
      
    //   console.log(ownerTicket);
    //   assert.equal(listTickets, ownerTicket, "El tamanio de la lista deberia ser 1");
    // });

  });

});
