pragma solidity ^0.4.11;
contract AlmacenarEther {
    address owner;
    uint banco;
    uint tope=18 ether;
    
    modifier comprobar {
        if(banco+msg.value>tope){
            revert();
        }
        else {
            _;
        }
    }
    
    function AlmacenarEther () public payable{
        owner=msg.sender;
        banco=msg.value;
    }
    
    function estadoBanco() public view returns(uint){
        
        return banco;
    }
    
    function donar() comprobar  public payable {
        
        banco+=msg.value;
        
        if(banco==tope){
            //se realiza la transferencia
            envio();
        }
        
    }
    function envio()private {
        owner.transfer(banco);
    }
}