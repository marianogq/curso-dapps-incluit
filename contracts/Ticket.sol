/* *** Ticket ***
El proceso de “tokenización” simplemente es recibir los datos del ticket por parámetros en el constructor.

Los atributos del contrato Ticket son:
- id: Un identificador único para cada ticket.
- eventName: El nombre del evento.
- eventDate: La fecha del evento.
- price: el precio en ethers del ticket.
- eventDescription: Una descripción corta del evento.
- eventType: el tipo de evento, en la v1 los tipos son Sports, Music, Cinema.
- status: el estado del ticket, en la v1 los estados son: Used, Valid, Expired.
- transferStatus: indica si es transferible o no, los estados son: Transferible, NoTransferible.
- owner: el address que es dueño del ticket.

X - Deberá tener una función para poder cambiar el precio del Ticket.
X - Deberá tener una función para cambiar el estado de TransferStatus.
X - Deberá tener una función para cambiar el estado del Ticket (status).
X - Deberá tener una función para cambiar de dueño en caso de ser vendido.
X - Deberá tener una función para generar el id único (hash).
X - Deberá tener una función que retorne los datos relevantes del ticket, para poder mostrarlo 
  (eventName, eventDate, price, eventDescription, eventType y status).*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

enum TransferStatus {
    TRANSFERIBLE,
    NO_TRANSFERIBLE
}

enum EventType {
    SPORT,
    MUSIC,
    CINEMA
}

enum TicketStatus {
    VALID,
    USED,
    EXPIRED
}

/** @title Contract Ticket.*/
contract Ticket {
    /** Event para mostrar detalles del ticket. */
    event ShowTicket(
        uint256,
        string,
        uint256,
        string,
        EventType,
        uint256,
        TicketStatus,
        TransferStatus,
        address
    );

    /** El hash será de 8 dígitos, por lo tanto, almacenamos 10 ^ 8,
    que se usa para extraer los primeros 8 dígitos más tarde por Modulus. */
    uint256 hashDigits = 8;
    uint256 hashModulus = 10**hashDigits;

    uint256 private _id;
    string private _eventName;
    uint256 private _eventDate;
    string private _eventDescription;
    EventType private _eventType;
    uint256 private _price;
    TicketStatus private _status;
    TransferStatus private _transferStatus;
    address private _owner;

    constructor(
        string memory eventNameTicket,
        string memory eventDescriptionTicket,
        EventType eventTypeTicket,
        uint256 priceTicket,
        address ownerTicket
    ) { 
        _id = generateId(); 
        _eventDate = block.timestamp; 
        _eventName = eventNameTicket;
        _eventDescription = eventDescriptionTicket;
        _eventType = eventTypeTicket;
        _price = priceTicket;
        _status = TicketStatus.VALID;
        _transferStatus = TransferStatus.NO_TRANSFERIBLE;
        _owner = ownerTicket;
    }

    /**@dev Función para cambiar de dueño del Ticket.
    * @param _newOwner Nuevo dueño del Ticket.
    * @param _oldId Id original del Ticket.
    * @param _oldEventDate Event Date original del Ticket.
    // Esta función se usa solo en caso de una Transferencia del Ticket a un nuevo dueño.
    // Cambia por el Id original del Ticket y el Event Date original del Ticket del antiguo dueño.
     */
    function changeOwner(address _newOwner, uint256 _oldId, uint256 _oldEventDate) public {
        require(_newOwner != address(0));
        _id = _oldId;
        _eventDate = _oldEventDate;
    }

    /**@dev Funcion para cambiar el precio del ticket.
     * @param _newPriceTicket Nuevo precio del Ticket.
     */
    function changePrice(uint256 _newPriceTicket) public {
        _price = _newPriceTicket;
    }

    /**@dev Función para cambiar el Estado de Transferencia (TRANSFERIBLE, NO_TRANSFERIBLE).
     */
    function changeTransferStatus() public {
        if (_transferStatus == TransferStatus.NO_TRANSFERIBLE) {
            _transferStatus = TransferStatus.TRANSFERIBLE;
        } else {
            _transferStatus = TransferStatus.NO_TRANSFERIBLE;
        }
    }

    /**@dev Función para cambiar el Estado del Ticket (VALID, USED, EXPIRED).
     * @param _newTicketStatus Status del Ticket.
     */
    function changeStatus(uint256 _newTicketStatus) public {
        if (_newTicketStatus == 0) {
            _status = TicketStatus.VALID;
        } else if (_newTicketStatus == 1) {
            _status = TicketStatus.USED;
        } else if (_newTicketStatus == 2) {
            _status = TicketStatus.EXPIRED;
        }
    }

    /**@dev Función para generar el hash para el _ID.
    //El hash será de 8 dígitos, por lo tanto, almacenamos 10 ^ 8,
    //que se usa para extraer los primeros 8 dígitos más tarde por Modulus.
    */
    function generateId() private view returns (uint256) {
        uint256 idTicket = uint256(
            keccak256(abi.encodePacked(msg.sender, block.timestamp))
        );
        return idTicket % hashModulus;
    }

    /**@dev Función para mostrar los datos relevantes del Ticket.
     */
    function showInformation() public {
        emit ShowTicket(
            _id,
            _eventName,
            _eventDate,
            _eventDescription,
            _eventType,
            _price,
            _status,
            _transferStatus,
            _owner
        );
    }

    /** Geters. */
    function getId() public view returns (uint256) {
        return _id;
    }

    function getEventName() public view returns (string memory) {
        return _eventName;
    }

    function getEventDate() public view returns (uint256) {
        return _eventDate;
    }

    function getEventDescription() public view returns (string memory) {
        return _eventDescription;
    }

    function getEventType() public view returns (EventType) {
        return _eventType;
    }

    function getPrice() public view returns (uint256) {
        return _price;
    }

    function getTransferStatus() public view returns (TransferStatus) {
        return _transferStatus;
    }

    function getTicketStatus() public view returns (TicketStatus) {
        return _status;
    }

    function getOwner() public view returns (address) {
        return _owner;
    }
}
