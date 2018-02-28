pragma solidity ^0.4.18;

//propietario del contrato
contract owner {
     address own;
     
     function owner()public
     {
         own=msg.sender;
     }
     
     //Verificar que sea solo el propietario
    modifier onlyOwner(){
        require(msg.sender==own);
        _;
    }
}

library Math{
    function calcularPromedio(uint256 a,uint256 b)internal pure returns(uint256){
        return a/b ; //por la cantidad de decimales del token
    }
    function restar(uint256 a,uint256 b)internal pure returns(uint256){
        return a-b;
    }
     function sumar(uint256 a,uint256 b)internal pure returns(uint256){
        return a+b;
    }
}

// ----------------------------------------------------------------------------
// ERC20Interface - Standard ERC20 Interfas 
//Copyright (c) 2018 TORIOUX GROUP
// Interfas Standard ERC-20
// ----------------------------------------------------------------------------
contract ERC20Interface {

   event Transfer(address indexed _from, address indexed _to, uint256 _value);
   event Approval(address indexed _owner, address indexed _spender, uint256 _value);

   function nombreTrx() public view returns (string);
   function simboloTrx() public view returns (string);
   function decimalsTrx() public view returns (uint8);
   function TotalSupply() public view returns (uint256);

   function balanceOf(address _owner) public view returns (uint256 balance);
   function allowance(address _owner, address _spender) public view returns (uint256 remaining);

   function transfer(address _to, uint256 _value) public returns (bool success);
   function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
   function approve(address _spender, uint256 _value) public returns (bool success);
}



contract ERC20Token is ERC20Interface {

   using Math for uint256;
   address ultimoTransferencia;
   string  private names;
   string  private symbols;
   uint8   private decimalss;
   uint256 private  totalSupplys;
   
   //alamacenamos el balance de cada usuario por token
   mapping(address => uint256) internal balances;
   
   mapping(address => mapping (address => uint256)) allowed;


 function ERC20Token(string _name, string _symbol, uint8 _decimals, uint256 _totalSupply, address _initialTokenHolder) public {
         names = _name;
         symbols = _symbol;
         decimalss = _decimals;
         totalSupplys = _totalSupply;
       
         // El saldo inicial de tokens se asigna a la dirección del titular del token dado.
         balances[_initialTokenHolder] = _totalSupply;

        // Según EIP20, el constructor debe iniciar un evento de transferencia si los tokens se asignan a una cuenta.
         Transfer(0x0, _initialTokenHolder, _totalSupply);
      }

      //Devuelve el nombre del token
      function nombreTrx() public view returns (string) {
         return names;
      }

        //Devuelve el simbolo del token
      function simboloTrx() public view returns (string) {
         return symbols;
      }

       //Devuelve los decimales
      function decimalsTrx() public view returns (uint8) {
         return decimalss;
      }

       //Devuelve la cantidad de token
      function TotalSupply() public view returns (uint256) {
         return totalSupplys;
      }

      //Devuelve la cantidad de token por cuenta
      function balanceOf(address _owner) public view returns (uint256 balance) {
         return balances[_owner];
      }


      function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
         return allowed[_owner][_spender];
      }


      function transfer(address _to, uint256 _value) public returns (bool success) {
          require(balances[msg.sender]>=_value);
         ultimoTransferencia=msg.sender;
         balances[msg.sender] = balances[msg.sender].restar(_value);
         balances[_to] = balances[_to].sumar(_value);
         Transfer(msg.sender, _to, _value);
        
         return true;
      }


      function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
         balances[_from] = balances[_from].restar(_value);
         allowed[_from][msg.sender] = allowed[_from][msg.sender].restar(_value);
         balances[_to] = balances[_to].sumar(_value);

         Transfer(_from, _to, _value);

         return true;
      }


      function approve(address _spender, uint256 _value) public returns (bool success) {
         allowed[msg.sender][_spender] = _value;

         Approval(msg.sender, _spender, _value);

         return true;
      }
      function verultimo()public view returns(address){
          return ultimoTransferencia;
      }
}




// ----------------------------------------------------------------------------
// ToriouxTokenConfig - Token Contract Configuration
//
// Copyright (c) 2018 TORIOUX GROUP
// 
// ----------------------------------------------------------------------------


contract ToriouxTokenConfig {
    string public constant symbol="TRX";
    string public constant name="Torioux";
    uint8  public constant  decimals= 5;
    uint256 public constant factorDecimal  = 10**uint256(decimals);
    uint256 public constant totalSupply = 1500000 * factorDecimal;
    uint256 public constant trx=0.5 ether;
    uint public constant montoActual=1500000 * factorDecimal;
}


// ----------------------------------------------------------------------------
// Finalizar - Token Contract Finalizar
//
// Copyright (c) 2018 TORIOUX GROUP
// 
// ----------------------------------------------------------------------------

contract Finalizar is owner {
    bool public finalizado ;
    
    function Finalizar()public owner(){
        finalizado=false;
    }
    
    function finalizarTRX()public onlyOwner returns(bool){
        require(!finalizado);
        
        finalizado=true;
        return true;
    }
    
}





contract FinalizarToken is Finalizar,ERC20Token{
    using Math for uint256;
    
    function FinalizarToken(string _name, string _symbol, uint8 _decimals, uint256 _totalSupply)public 
    Finalizar() 
    ERC20Token(_name, _symbol,_decimals,_totalSupply,msg.sender) 
    {
        
    }
    
         function transfer(address _to, uint256 _value) public returns (bool success) {
            validarTransferencia(msg.sender, _to);

            return super.transfer(_to, _value);
         }


         function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
            validarTransferencia(msg.sender, _to);
            return super.transferFrom(_from, _to, _value);
         }


         function validarTransferencia(address _sender, address _to) private view {
            
            require(_to != address(0));
            require(_sender!=_to);
            // verificamos si el owner principal a finalizado
            if (finalizado) {
               return;
            }
            // verificamos que el addres no sea igual al owner
            if (_to == own) {
               return;
            }
         }
}




// ------------------------------------------------ ----------------------------
// Token Torioux - ERC20 -Deploy
//
// Copyright (c) 2018 TORIOUX GROUP
// ------------------------------------------------ ----------------------------
contract ToriouxToken is ToriouxTokenConfig,FinalizarToken{
    
   function ToriouxToken()public FinalizarToken(name,symbol,decimals,totalSupply) {
       
   }
}


// ------------------------------------------------ ----------------------------
// Token Torioux - Venta de Token Torioux - Configuracion
//
// Copyright (c) 2018 TORIOUX GROUP
// ------------------------------------------------ ----------------------------


contract ToriouxTokenSaleConfig is ToriouxTokenConfig{
    
    //tiempo inicial cuando se empieza l ico 
    uint256 public constant INICIO_start=1516240800;


    //tiempo de finalizacion de las ico 
    uint256 public constant INICIO_terminar=1586240800;
    
    //etapa inicial
    uint8 public  stage_inicial=1;
    
    //COMPRAS 
    
    //cantidad minima de ethereum que se puede usar para comprar
    uint256 public constant CONTRIBUCION_minima = 0.5 ether;
    
    
   // Cantidad máxima de tokens que se pueden comprar para cada cuenta.
   uint256 public constant TOKENS_CUENTA_MAXIMO    = 12000 * factorDecimal;

    
    
}




// ------------------------------------------------ ----------------------------
// Token Torioux - Venta de Token Torioux - Configuracion
//
// Copyright (c) 2018 TORIOUX GROUP
// ------------------------------------------------ ----------------------------

contract FlexibleTokenSale is ToriouxTokenSaleConfig ,Finalizar{
      using Math for uint256;

//
// ciclo de vida de la venta de token 
//

   uint256 public tiempoInicio;
   uint256 public tiempoFinal;
    /* EL owner puede suspender la venta de token hazta que lo active*/
   bool public suspendido;
  
  
  // Wallet - Billetera donde se alamacenara los ether enviados por los usuario
  address public walletAddress;
  
  //token
  FinalizarToken public token;
  //cantidad 
  
  //llevar control de los tokens vendido
  uint256 public totalTokensVendido;
   
  //llevar control de ether recolectado
  uint256 public totalEtherRecolectado;
  
  // almacenar una lista blanca para los primeros usuarios
     mapping(address => uint256) public whitelist;
  uint256 public dv;
 function FlexibleTokenSale
 (uint256 _startTime, uint256 _endTime, address _walletAddress) public
 {
        //tiempo de inicio debe ser menor que el tiempo Final
        require(_endTime>_startTime);
        // validar que el address nosea igual al del owner o contrato
        require(_walletAddress != address(0));
        require(_walletAddress != address(this));
        //ingresamos el address donde se almacenara el ether
        walletAddress=_walletAddress;
        finalizado = false;
        suspendido= false;
   
    }
    
    //cambiar estado de stage
    function changeState(uint8 i) external onlyOwner returns(bool) {
        
           require(i>0 && i<4);

            stage_inicial = i;

            return true;
         }


       // Permite al propietario suspender la venta - 
      function suspender() external onlyOwner returns(bool) {
            if (suspendido == true) {
                return false;
            }

            suspendido = true;

            return true;
         }



       // Permite al propietario reanudar la venta.    
      function resume() external onlyOwner returns(bool){
            if (suspendido == false) {
                return false;
            }
            suspendido = false;

            return true;
      }    
      
      
      
      
       
      
      
      
      
      
    
     // Inicializar debe ser llamado por el propietario como parte de la fase de despliegue + instalación.
     // Asociará el contrato de venta con el contrato de token y realizará controles básicos. 
      
       function Inicializar(FinalizarToken _token) external onlyOwner returns(bool) {
            require(address(token) == address(0));
            require(address(_token) != address(0));
            require(address(_token) != address(this));
            require(address(_token) != address(walletAddress));
            token = _token;
            return true;
         }
         
       function comprarToken (address beneficiario )payable public  {
           require(!suspendido);
           
           //require(CONTRIBUCION_minima<=msg.value);
           
           
           uint256 cantidad=msg.value;
           uint256 tokens=cantidad.calcularPromedio(trx);
           
           // saldo actual del crowsale debemos validar que tenga los suficientes token para la venta del contribuyente
            uint256 saldoCrowsale = token.balanceOf(address(this));
            require(saldoCrowsale> 0 && saldoCrowsale>=tokens);
           totalTokensVendido+=tokens;
           if(stage_inicial==1){whitelist[beneficiario]=whitelist[beneficiario]+tokens;}
           
          
           
           // si el usuario se excede de ether lo restante se le devolvera
           dv=msg.value - (trx*tokens); 
           if(dv>0){
                msg.sender.transfer(dv);
           }
           
           //realizamos la tranferencia de token
          if(stage_inicial==1){
             token.transfer(beneficiario,(tokens*100000)*3); 
          }
          else {
              token.transfer(beneficiario,tokens*100000);
          }
          
           
           
           //enviamos los ether ala wallet del propietario
           walletAddress.transfer(msg.value);
       }


}



  contract ToriouxTokenVenta is FlexibleTokenSale{
     
     

     /*
     Stage 1 : inicio y el triple de tokens porcada compra 
     Stage 2 : Venta normal de tokens ;
     Stage 3 : Finalizacion de token;
     */

    
     
    function ToriouxTokenVenta(address dirToken)public 
     FlexibleTokenSale(INICIO_start,INICIO_terminar,dirToken)
    {  
        stage_inicial=1;
        }
    
    function()payable public {
        comprarTokenInternal(msg.sender);
    }
    function comprarTokenInternal(address beneficiario)payable public{
        require(stage_inicial!=3);
      super.comprarToken(beneficiario);
    }
    
}