pragma solidity ^0.4.18;

import "browser/Tiempo.sol";
import "browser/token.sol";
contract IcoTorioux {
    Tiempo p=new Tiempo();
    uint lanzamiento=0;
    uint16 hora=3600;
    uint8 minutos=60;
    uint8 segundo=1;
    torioux t=new torioux();
    uint banco= 0;
    
    uint trx=80000000000000000; //precio en weit 
    
    /*
    1 trx=0.08 ether
     */
     
    function IcoTorioux() public {
        lanzamiento=now+hora;
        }
    
    
    function mostrarHora() public  view returns(uint e){
       e= p.getHora();
       e =78;
    
        
        
    }
    
    function buy()payable public  {
      if(now<lanzamiento+hora){
        uint   count=msg.value/trx;
          
            t.transfer(msg.sender,count); 
      }
    
        
    }
    
    
    function getHorfa() public view returns (uint8,uint) {
                  return (uint8(((now+hora) / 60 / 60) % 24),now);
    }
    
    function verFechaDeLanzamiento() public view returns(uint) {
        
    return lanzamiento;    
    }
}