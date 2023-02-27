// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract DRH {

    address drh;

    event InformationsForDRH(uint indexed, uint indexed);
    event InformationsForAnotherPerson(string, uint indexed, address indexed);
    event SalarySending(address, address, string, uint);
    event DisplayModifiedStatus(address indexed, address indexed, DRH.Status);

    enum Status {STAGIAIRE, EMPLOYE, FREELANCE, LICENCIE}

    struct EmployeesInformations {
        string fullName;
        uint age; 
        uint salary; 
        address matricule;
        string departement;
        DRH.Status _status;
    }
    mapping(address => EmployeesInformations) EmployeesInfosMapping;

    uint amount;

    constructor() {
        drh = msg.sender;
    }

    address[] matriculeTable;
    string[] public departements = ["informatique", "marketing", "juridique"];


    function EmployeesRegistration(string memory _fullName, uint _age, uint _salary, address _matricule, string memory _departement) public {
        EmployeesInfosMapping[_matricule].fullName = _fullName;
        EmployeesInfosMapping[_matricule].age = _age;
        EmployeesInfosMapping[_matricule].salary = _salary;
        EmployeesInfosMapping[_matricule].matricule = _matricule;
        EmployeesInfosMapping[_matricule].departement = _departement;

        EmployeesInfosMapping[_matricule]._status = Status.STAGIAIRE;

        matriculeTable.push(_matricule);
    }

    function EmployeeExist(address _matricule) view private returns(bool) {
        for(uint i = 0; i < matriculeTable.length; i++) {
            if(keccak256(abi.encodePacked(matriculeTable[i])) == keccak256(abi.encodePacked(_matricule))) {
                return true;
            }
        }
        return false;
    }
    
    function getEmployeesInformations(address _matricule) public {
        if(EmployeeExist(_matricule)) {
            if(msg.sender == drh) {
                emit InformationsForDRH(EmployeesInfosMapping[_matricule].age, EmployeesInfosMapping[_matricule].salary);
            }
            else if(msg.sender != drh || msg.sender == _matricule) {
                emit InformationsForAnotherPerson(EmployeesInfosMapping[_matricule].fullName, EmployeesInfosMapping[_matricule].salary, EmployeesInfosMapping[_matricule].matricule);
            }
        }
        else {
            console.log("Employee does not exist.");
        }
    }

    function deleteEmployees(address _matricule) public {
        require(msg.sender == drh, "Only DRH can do this action.!");
        if(EmployeeExist(_matricule)) {
            for(uint i = 0; i < matriculeTable.length; i++) {
                delete(matriculeTable[i]);
            }
        }
        else if(!EmployeeExist(_matricule)) {
            console.log("Employee does not exist or has already been deleted.");
        }
    }

    function ChangeEmployeeStatus(address _matricule, DRH.Status newStatus) public {
        require(msg.sender == drh, "Only DRH can do this action.!");
        if(EmployeeExist(_matricule)) {
            EmployeesInfosMapping[_matricule]._status = newStatus;
            emit DisplayModifiedStatus(msg.sender, _matricule, newStatus);
        }
        else {
            console.log("Employee does not exist.");
        }
    }


    function SendETH(address payable _matricule, string memory _departement) payable public {
        require(msg.sender == drh, "Only DRH can do this action.!");
        if(EmployeeExist(_matricule)) {
            if(keccak256(abi.encodePacked(_departement)) == keccak256(abi.encodePacked(departements[0]))) {
                amount = 4000000000000000000;
                payable(_matricule).transfer(amount);
                //(bool transferOne, ) = payable(_matricule).call{value : amount}(""); Une autre méthode.

                emit SalarySending(msg.sender, _matricule, _departement, amount);
            }
            else if(keccak256(abi.encodePacked(_departement)) == keccak256(abi.encodePacked(departements[1]))) {
                amount = 3000000000000000000;
                payable(_matricule).transfer(amount);

                emit SalarySending(msg.sender, _matricule, _departement, amount);
            }
            else if(keccak256(abi.encodePacked(_departement)) == keccak256(abi.encodePacked(departements[2]))) {
                amount = 2000000000000000000;
                payable(_matricule).transfer(amount);

                emit SalarySending(msg.sender, _matricule, _departement, amount);
            }
            else {
                console.log("Not exist.");
            }
        }
        else {
            console.log("Employee does not exist.");
        }
    }
}