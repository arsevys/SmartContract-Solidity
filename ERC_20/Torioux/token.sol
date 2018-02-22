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
        return a/b;
    }
    function restar(uint256 a,uint256 b)internal pure returns(uint256){
        return a-b;
    }
     function sumar(uint256 a,uint256 b)internal pure returns(uint256){
        return a+b;
    }
}

// ----------------------------------------------------------------------------
// ERC20Interface - Standard ERC20 Interface Definition
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

         // The initial balance of tokens is assigned to the given token holder address.
         balances[_initialTokenHolder] = _totalSupply;

         // Per EIP20, the constructor should fire a Transfer event if tokens are assigned to an account.
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
}




// ----------------------------------------------------------------------------
// ToriouxTokenConfig - Token Contract Configuration
//
// Copyright (c) 2018 TORIOUX GROUP
// 
// ----------------------------------------------------------------------------


contract ToriouxTokenConfig {
    string public constant symbol="TRIXr";
    string public constant name="Toriouxr";
    uint8  public constant  decimals= 5;
    uint256 public constant factorDecimal  = 10**uint256(decimals);
    uint256 public constant totalSupply = 150000 * factorDecimal;
    
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

/*
contract ToriouxTokenSaleConfig is ToriouxTokenConfig {

    //
    // Tiempo
    //
    uint256 public constant INITIAL_STARTTIME      = 1516240800; // 2018-01-18, 02:00:00 UTC
    uint256 public constant INITIAL_ENDTIME        = 1517536800; // 2018-02-02, 02:00:00 UTC
    uint256 public constant INITIAL_STAGE          = 1;


    //
    // Purchases
    //

    // Minimum amount of ETH that can be used for purchase.
    uint256 public constant CONTRIBUTION_MIN      = 0.1 ether;

    // Price of tokens, based on the 1 ETH = 1700 BLZ conversion ratio.
    uint256 public constant TOKENS_PER_KETHER     = 1700000;

    // Amount of bonus applied to the sale. 2000 = 20.00% bonus, 750 = 7.50% bonus, 0 = no bonus.
    uint256 public constant BONUS                 = 0;

    // Maximum amount of tokens that can be purchased for each account.
    uint256 public constant TOKENS_ACCOUNT_MAX    = 17000 * DECIMALSFACTOR;
}*/