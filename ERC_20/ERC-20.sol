pragma solidity ^0.4.18;


contract erc20 {
    function totalSupply()public constant returns (uint256 );
    function balanceOf(address _owner)public constant returns (uint256 balance);
    function transfer(address _to, uint256 _value)public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value)public returns (bool success);
    function approve(address _spender, uint256 _value)public returns (bool success);
    function allowance(address _owner, address _spender)public  constant returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    
}


contract  torioux is erc20 {
    
    address private owner;
    string public name="ToriouxCoin";
    string public symbol="trx";
    uint public totalSupply =45000000000000;
    uint public decimals=10;
    
    mapping (address=>uint) balance;
    mapping(address=>bool) registrados;
    mapping(address=>mapping(address=>uint)) _allowances;
    
    function torioux()public {
        balance[msg.sender]=totalSupply;
        owner=msg.sender;
    }
    
    function totalSupply()public view returns(uint){
         return totalSupply;
    }
    
    function balanceOf(address _owner)public constant returns (uint256){
        return balance[_owner];
    }
    function transfer(address _to, uint256 _value)public returns (bool){
    
    //   require(_value>0);
        balance[msg.sender]-=_value;
        balance[_to]+=_value;
        totalSupply-=_value;
       
        return true;
    }
    
    function transferFrom(address _from, address _to, uint256 _value)public returns (bool success){
        require(_to != 0x0);
        if(balance[_from] < _value){
           revert();
        }
        
        balance[_to]+=_value;
        balance[_from]-=_value;
         Transfer(_from, _to, _value);
        return true;
    }
    
    
    function approve(address _spender, uint256 _value)public returns (bool success){
        
        _allowances[msg.sender][_spender] = _allowances[msg.sender][_spender];
        Approval(msg.sender, _spender, _value);
      
        
        return true;
    }
    function allowance(address _owner, address _spender)public  constant returns (uint256 remaining){
          return _allowances[_owner][_spender];
    }
    
}

