/* *** Manager ***
X - Deberá tener una función para “tokenizar” un ticket. Esto significa crear un nuevo Ticket con los datos 
  correspondientes.
X - Deberá tener una función para ver todos los tickets que contiene la plataforma, sin importar quien sea el 
  dueño.
X - Deberá tener una función para ver los tickets que están asignados a un dueño particular (address).
X - Deberá tener una función para permitir la transferencia de un ticket según su estado, es decir que si un 
  Ticket tiene un estado Transferible, puede cambiar de dueño. Permitiendo que el nuevo dueño envíe ethers a 
  través de la plataforma y que el dueño anterior reciba esos ethers.
X - Deberá tener una función para permitir que el dueño de un ticket pueda cambiar el precio del mismo, pero en 
  ese caso el contrato Manager cobra un 5% de comisión y queda en su balance.
X - Deberá tener una función para retornar la cantidad de tickets que tiene la plataforma y el precio total de 
  los tickets. Esto está pensado para mostrar estadísticas y poder llamar la atención de futuros inversores.
X - Deberá tener una función para eliminar el ticket de la lista. */

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "./Ticket.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/** @title Contract Manager.*/
contract Manager is Ownable {
    // Mapping de Tickets
    mapping(address => Ticket[]) listTickets;

    // Owners Tickets
    address[] public OwnersTickets;
    address[] private noRepeatOwner;

    // Total de Tickets
    uint256 totalTickets = 0;

    // Valor total de Tickets
    uint256 balanceTickets = 0;

    // Valor del Fee
    uint256 Fee = 5;

    // Address del Manager
    address addressManager;

    // Control del Dueño del Ticket
    modifier onlyOwnerTicket(address _addressOwner, uint256 _index) {
        require(
            listTickets[_addressOwner][_index].getOwner() == msg.sender,
            "Solo el Owner del Ticket tiene permiso."
        );
        _;
    }

    // Events
    event CreatedTicket(string, string, EventType, uint256, address);
    event NewPrice(uint256);
    event ShowStatistics(uint256, uint256);
    event DeletedTicket(uint256);
    event ChangedTransferStatusTicket(TransferStatus transferStatusTicket);
    event ChangedStatusTicket(TicketStatus statusTicket);
    event TransferredTicket(address oldOwner, address newOwner);

    event FundsReceived(uint256 amount);

    receive() external payable {
        emit FundsReceived(msg.value);
    }

    fallback() external payable {
        emit FundsReceived(msg.value);
    }

    // Constructor
    constructor() {
        addressManager = msg.sender;
    }

    /**@dev Funcion para Tokenizar Tickets.
    * @param _eventName Nombre del Evento.
    * @param _eventDescription Descripción del Evento.
    * @param _eventType Tipo del Evento.
    * @param _price Precio del Ticket.
    // El Ticket se creará con STATUS siempre en TicketStatus.VALID.
    // El Ticket se creará con TRANSFER STATUS en TransferStatus.NO_TRANSFERIBLE.
    // El address (msg.sender) que interactue con la función 'createTicket' 
    // queda como dueño (owner) del Ticket.
    */
    function createTicket(
        string memory _eventName,
        string memory _eventDescription,
        EventType _eventType,
        uint256 _price
    ) public payable {
        Ticket ticketNew = new Ticket(
            _eventName,
            _eventDescription,
            _eventType,
            _price,
            msg.sender
        );
        listTickets[msg.sender].push(ticketNew);
        OwnersTickets.push(msg.sender);
        totalTickets += 1;
        balanceTickets = balanceTickets + _price;
        emit CreatedTicket(_eventName, _eventDescription, _eventType, _price, msg.sender);
    }

    /**@dev Funcion para cambiar el precio del ticket.
    * @param _addressOwner Address Dueño del Ticket Ingresado.
    * @param _index Index del Ticket Ingresado.
    * @param _newPriceTicket Nuevo Precio del Ticket Ingresado.
    // Controles realizados:
    // 1-Que listTickets[_addressOwner][_index].getOwner() sea = a msg.sender, 
    // solo el dueño puede cambiar el precio del Ticket,
    // 2-Que la _addressOwner ingresado sea realmente la dueña del Ticket (getOwner()).
    // 3-Que el monto a pagar sea mayor o igual al nuevo precio del ticket 
    // (newPriceTicket + commission para el Manager).
    */
    function changeTicketPrice(
        address _addressOwner,
        uint256 _index,
        uint256 _newPriceTicket
    ) public payable onlyOwnerTicket(_addressOwner, _index) {
        // 1er Control
        // 2do Control
        require(
            listTickets[_addressOwner][_index].getOwner() == _addressOwner,
            "No coicide el address ingresado con su owner"
        );
        // 3er Control
        uint256 commission = (_newPriceTicket * Fee) / 100;
        require(
            msg.value >= _newPriceTicket + commission,
            "El monto de la transferencia es insuficiente"
        );
        // Pago de comisión y cambio del Precio
        feeManage(commission);
        uint256 priceDifference = _newPriceTicket -
            listTickets[_addressOwner][_index].getPrice();
        balanceTickets = balanceTickets + priceDifference;
        listTickets[_addressOwner][_index].changePrice(_newPriceTicket);
        emit NewPrice(_newPriceTicket);
    }

    /**@dev Función para mostrar las estadisticas.
    // totalTickets: Total de Tickets en la Plataforma.
    // balanceTickets: Precio Total de Tickets en la Plataforma.
    // Solo Manager puede emitir las estadisticas.
    */
    function showStatistics() public onlyOwner {
        emit ShowStatistics(totalTickets, balanceTickets);
    }

    /**@dev Funcion para Eliminar un Ticket según address del Owner.
    * @param _addressOwner Address Dueño del Ticket.
    * @param _index Index del Ticket.
    // Solo Manager puede eliminar un ticket.
    */
    function deleteTicket(address _addressOwner, uint256 _index)
        public
        onlyOwner
    {
        uint256 deletedTicket = listTickets[_addressOwner][_index].getId();
        uint256 oldPrice = listTickets[_addressOwner][_index].getPrice();
        for (uint256 i = _index; i < listTickets[_addressOwner].length - 1; i++) {
            listTickets[_addressOwner][i] = listTickets[_addressOwner][i + 1];
        }
        listTickets[_addressOwner].pop();
        totalTickets -= 1;
        balanceTickets = balanceTickets - oldPrice;
        for (uint256 i = _index; i < OwnersTickets.length - 1; i++) {
            OwnersTickets[i] = OwnersTickets[i + 1];
        }
        OwnersTickets.pop();
        emit DeletedTicket(deletedTicket);
    }

    /**@dev Función para cambiar el Estado de Transferencia (TRANSFERIBLE, NO_TRANSFERIBLE).
    * @param _addressOwner Address Dueño del Ticket.
    * @param _index Index del Ticket.
    // Control realizado:
    // Que listTickets[_addressOwner][_index].getOwner() sea = a msg.sender, 
    // solo el dueño puede cambiar el TransferStatus.
    */
    function changeTransferStatusTicket(address _addressOwner, uint256 _index)
        public
        onlyOwnerTicket(_addressOwner, _index)
    {
        // Cambia el estado
        listTickets[_addressOwner][_index].changeTransferStatus();
        emit ChangedTransferStatusTicket(
            listTickets[_addressOwner][_index].getTransferStatus()
        );
    }

    /**@dev Función para cambiar el Estado del Ticket (VALID, USED, EXPIRED).
    * @param _addressOwner Address Dueño del Ticket.
    * @param _index Index del Ticket.
    * @param _newTicketStatus Nuevo Estado del Ticket.
    // Control realizado:
    // Que listTickets[_addressOwner][_index].getOwner() sea = a msg.sender, 
    // solo el dueño puede cambiar el TicketStatus.
    */
    function changeStatusTicket(
        address _addressOwner,
        uint256 _index,
        uint256 _newTicketStatus
    ) public onlyOwnerTicket(_addressOwner, _index) {
        // Cambia el estado
        listTickets[_addressOwner][_index].changeStatus(_newTicketStatus);
        emit ChangedStatusTicket(
            listTickets[_addressOwner][_index].getTicketStatus()
        );
    }

    /**@dev Función para Transferir un Ticket.
    * @param _addressOwner Address Dueño del Ticket.
    * @param _index Index del Ticket.
    * @param _newOwner Nuevo Dueño del Ticket.
    // Controles Realizados:
    // 1-Que la _addressOwner sea realmente la dueña del Ticket (getOwner()).
    // 2-Que el Ticket sea Trasferible (tenga TransferStatus.TRANSFERIBLE).
    // 3-Que el Ticket sea Valido (tenga TicketStatus.VALID).
    // 4-Que _newOwner sea msg.sender (_newOwner address pagador del Ticket a _addressOwner).
    // 5-Que el monto a pagar sea mayor o igual al costo del ticket (getPrice()) + el feeTicket para el Manager.
    // La Transferencia del Ticket solo se hará si el Ticket está en condición de Transferirse, 
    // esto significa que se encuentra en Estado TRANSFERIBLE y VALID, éstos estados del Ticket
    // solo pueden ser modificados por el Dueño del Ticket (Owner).
    // El Nuevo Dueño es quien puede realizar el Pago de la Transferencia del Ticket.
    */
    function transferTicket(
        address _addressOwner,
        uint256 _index,
        address _newOwner
    ) public payable {
        address oldOwner;
        address newOwner;
        // 1er Control
        require(
            _addressOwner == listTickets[_addressOwner][_index].getOwner(),
            "Address reseptora del pago No es el Owner"
        );
        // 2do Control
        require(
            listTickets[_addressOwner][_index].getTransferStatus() ==
                TransferStatus.TRANSFERIBLE,
            "Este Ticket No es Transferible"
        );
        // 3er Control
        require(
            listTickets[_addressOwner][_index].getTicketStatus() ==
                TicketStatus.VALID,
            "Este Ticket No es Valido"
        );
        // 4to Control
        require(
            _newOwner == msg.sender,
            "Solo el Pagador tiene permiso para esta accion"
        );
        // 5to Control
        uint256 feeTicket = feeCalculation(_addressOwner, _index);
        require(
            msg.value >=
                listTickets[_addressOwner][_index].getPrice() + feeTicket,
            "Por favor, ingrese un valor"
        );
        // Pago del ticket y cambio de dueño
        (bool sent, ) = _addressOwner.call{
            value: msg.value - feeManage(feeTicket)
        }("");
        require(sent, "Error en el envio de Ether");
        oldOwner = listTickets[_addressOwner][_index].getOwner();
        listTickets[_addressOwner][_index].changeOwner(_newOwner);
        newOwner = listTickets[_addressOwner][_index].getOwner();
        emit TransferredTicket(oldOwner, newOwner);
    }

    /**@dev Muestra información de los Tickets según dueño (owner).
     * @param _addressOwner Address Dueño de los Tickets.
     */
    function showTicketsByAddress(address _addressOwner) public {
        for (uint256 i = 0; i < listTickets[_addressOwner].length; i++) {
            listTickets[_addressOwner][i].showInformation();
        }
    }

    /**@dev Muestra informacion de todos los tickets en la Plataforma.
     */
    function showAllTickets() public {
        require(OwnersTickets.length > 0, "Lista de Tickets vacia");
        address previuOwner;
        bool repeat;
        for (uint256 j = 0; j < OwnersTickets.length; j++) {
            if(j == 0) {
                showTicketsByAddress(OwnersTickets[j]);
                previuOwner = OwnersTickets[j];
                noRepeatOwner.push(OwnersTickets[j]);
            } else if(previuOwner != OwnersTickets[j]) {
                repeat = false;
                for(uint256 z=0; z < noRepeatOwner.length; z++){
                    if(OwnersTickets[j] == noRepeatOwner[z]){
                        repeat = true;
                    }
                }
                if(!repeat){
                    showTicketsByAddress(OwnersTickets[j]);
                    previuOwner = OwnersTickets[j];
                }   
            }
        }
    }

    /**@dev Función para el pago de comisiones al contrato Manager.
     * @param _feeTicket Comisión (fee) a pagar al contrato Manager.
     */
    function feeManage(uint256 _feeTicket) public payable returns (uint256) {
        (bool success, ) = addressManager.call{value: _feeTicket}("");
        require(success == true, "Transferencia fallida!");
        return _feeTicket;
    }

    /**@dev Calculo del fee en las transferencias de ticket.
     * @param _addressOwner Address Dueño del Ticket.
     * @param _index Index del Ticket.
     */
    function feeCalculation(address _addressOwner, uint256 _index)
        public
        view
        returns (uint256)
    {
        return ((listTickets[_addressOwner][_index].getPrice() * Fee) / 100);
    }

    /**@dev Función que devuelve la lista de Owners.
    * @return OwnersTickets Lista de Address de Dueños de Tickets.
    */
    function getOwners() public view returns (address[] memory) {
        return OwnersTickets;
    }
}
