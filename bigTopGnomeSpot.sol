// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC721/ERC721.sol)

pragma solidity ^0.8.0;  

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721Receiver.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Context.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Strings.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/introspection/ERC165.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Counters.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/MerkleProof.sol";
interface SpoilToken{
     function mint(address add, uint amount)external;
}


contract BigTopGnome  is Context, ERC165, IERC721, IERC721Metadata, Ownable, IERC721Enumerable {
    using Address for address;
    using Strings for uint256;
    using Counters for Counters.Counter;

    
   

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // uint public totalSupply;

    Counters.Counter private _tokenIds;
    bool paused;
    
    

    string public baseURI_ = "ipfs://QmeU3irSstLSxiv61eXah63b2Vs8LBrNi8JU4n3Kny7GWH/";
    string public baseExtension = ".json";

    uint256 public maxSupply = 10000;

    address companyWallet= 0xebE448F7347DcF4cf7872e82C6F11880aFd704C0;
    address communityWallet=0xF111053338a340bBabde350702E43254C201A4Ed;
    address devTeamWallet= 0x9817C311F6897D30e372C119a888028baC879d1c;

    SpoilToken _SpoilsToken; 
    uint256 public cost = 0.01 ether;
    uint256 public discountcost = 0.001 ether;
    
    uint256 public maxMintAmount = 10;
    bytes32 public root=0x74f4666169faccda89a45d47ab1997a62f24c3cd534a01539db8f0e40d3eb8b1;
    
   
    mapping(uint => mapping(address => uint)) private idtoStartingTime;

        
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;


   
    constructor(string memory name_, string memory symbol_,address erc20add) {
        _name = name_;
        _symbol = symbol_;
        _SpoilsToken = SpoilToken(erc20add);
     
       

    }

   
    /**
     * @dev See {IERC721Enumerable-tokenOfOwnerByIndex}.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }

    /**
     * @dev See {IERC721Enumerable-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev See {IERC721Enumerable-tokenByIndex}.
     */
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }

  
 
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual  {
     

        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }

   
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }

   
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

  
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }

   
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }

  
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }

  
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }


    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

   
    function name() public view virtual override returns (string memory) {
        return _name;
    }

   
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString(),".json")) : "";
    }

  
    function _baseURI() internal view virtual returns (string memory) {
        return baseURI_;
    }

   
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

   
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

  
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }


    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

  
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

   
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

   
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }


    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

   
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
        _checkOnERC721Received(address(0), to, tokenId, _data),"ERC721: transfer to non ERC721Receiver implementer");
    }


    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;
        idtoStartingTime[tokenId][to]=block.timestamp;

        // totalSupply+=1;

        emit Transfer(address(0), to, tokenId);

        _afterTokenTransfer(address(0), to, tokenId);
    }

  

    function _burn(uint256 tokenId) internal virtual {
        address owner = ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];
        

        // totalSupply-=1;

        emit Transfer(owner, address(0), tokenId);

        _afterTokenTransfer(owner, address(0), tokenId);
    }
     
    
     function whiteListMint(
        address _to,
        uint256 _mintAmount,
        bytes32[] memory proof
        
     ) public payable {
        // get total NFT token supply
       require(isValid( proof ,_to)==true,"you are not whitelisted");
       require(_mintAmount > 0,"mintamount cant be zero");
       uint _cost=cost;
       if (_mintAmount>1){
         _cost=discountcost;
       }
       require(_mintAmount <= maxMintAmount,"mint amount  must be less than maxmint amount");
       require( totalSupply() + _mintAmount <= maxSupply,"cant mint above totalsupply");
       require(msg.value >= _cost * _mintAmount,"please pass in the correct payment");
          
          // execute mint
       if (_tokenIds.current()==0){
            _tokenIds.increment();
       }
        
       for (uint256 i = 1; i <= _mintAmount; i++) {
            uint256 newTokenID = _tokenIds.current();
            _safeMint(_to, newTokenID);
            _tokenIds.increment();
        }  
          
    }

     function publicMint(
        address _to,
        uint256 _mintAmount
        
     ) public payable {
       require(paused==true ,"public mint not available ");
       require(_mintAmount > 0,"mintamount cant be zero");
       require(_mintAmount <= maxMintAmount,"mint amount  must be less than maxmint amount");
       require( totalSupply() + _mintAmount <= maxSupply,"cant mint above totalsupply");
       require(msg.value >= cost * _mintAmount,"please pass in the correct payment");
      
          
          
       if (_tokenIds.current()==0){
            _tokenIds.increment();
       }
        
       for (uint256 i = 1; i <= _mintAmount; i++) {
            uint256 newTokenID = _tokenIds.current();
            _safeMint(_to, newTokenID);
            _tokenIds.increment();
        }  
          
    }

    function adminMint(address _to,uint256 _mintAmount)public onlyOwner{
        require(_mintAmount > 0);
        require( totalSupply() + _mintAmount <= maxSupply);
        if (_tokenIds.current()==0){
            _tokenIds.increment();
        }
        
        for (uint256 i = 1; i <= _mintAmount; i++) {
            uint256 newTokenID = _tokenIds.current();
            _safeMint(_to, newTokenID);
            _tokenIds.increment();
        } 
    }

    function isValid(bytes32[] memory proof,address add)internal view returns(bool){
       bytes32 leaf= keccak256(abi.encodePacked(add));
       return MerkleProof.verify(proof,root,leaf);
    }
    
    function setPaused(bool _set)public onlyOwner {
        paused=_set;
    }
    function setRoot(bytes32 _root) public onlyOwner {
        root = _root;
    }  
                
    
    function setmaxSupply(uint256 _maxsupply) public onlyOwner {
        maxSupply = _maxsupply;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI_ = _newBaseURI;
    }

    // set metadata base extention
    function setBaseExtension(string memory _newBaseExtension)public onlyOwner    {
        baseExtension = _newBaseExtension;    
    }

    
    function setCost(uint256 _newCost) public onlyOwner {
        cost = _newCost;
    }

    function setdiscountCost(uint256 _newCost) public onlyOwner {
        discountcost = _newCost;
    }

    // set or update max number of mint per mint call
    function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
        maxMintAmount = _newmaxMintAmount;
    }
     
    

   

    function walletofNFT(address _owner)
        public
        view
        returns (uint256[] memory)
    {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }

    function checkrewardbal()public view returns(uint){

        uint256 ownerTokenCount = balanceOf(msg.sender);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        tokenIds= walletofNFT(msg.sender);
         
        uint current;
        uint reward;
        uint rewardbal;
        for (uint i ;i<ownerTokenCount; i++){
             
           if (idtoStartingTime[tokenIds[i]][msg.sender]>0 ){
           current = block.timestamp - idtoStartingTime[tokenIds[i]][msg.sender];
           reward = ((1*10**18)*current)/86400;
           rewardbal+=reward;
          
        }
        }

        return rewardbal;
    }

   

    function claimreward() public {
         require(balanceOf(msg.sender)>0, "Not Qualified For Reward");
         uint256 ownerTokenCount = balanceOf(msg.sender);
         uint256[] memory tokenIds = new uint256[](ownerTokenCount);
         tokenIds= walletofNFT(msg.sender);
         
         uint current;
         uint reward;
         uint rewardbal;
         for (uint i ;i<ownerTokenCount; i++){
             
         if (idtoStartingTime[tokenIds[i]][msg.sender]>0 ){
         current = block.timestamp - idtoStartingTime[tokenIds[i]][msg.sender];
         reward = ((1*10**18)*current)/86400;
         rewardbal+=reward;
         idtoStartingTime[tokenIds[i]][msg.sender]=block.timestamp;
         }
        }

         _SpoilsToken.mint(msg.sender,rewardbal);
  


    }

    
    function claim() public onlyOwner {
        // get contract total balance
        uint256 balance = address(this).balance;
        // begin withdraw based on address percentage

        // 50%
        payable(companyWallet).transfer((balance / 100) * 50);

        uint256 _balance = address(this).balance;

       
        // 97% of 50%
        payable(communityWallet).transfer(( _balance / 100) * 97);
        // 3% of  50%
        payable(devTeamWallet).transfer((_balance  / 100) * 3);
       
    }

    function checkb()public view returns(uint,uint,uint){
        return(companyWallet.balance,communityWallet.balance,devTeamWallet.balance);
    }

     function checkcontbal()public view returns(uint){
        return address(this).balance;
    }

  


 


    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;
        idtoStartingTime[tokenId][to]=block.timestamp;
        idtoStartingTime[tokenId][from]=0;

      
        

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

   
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

  
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }


  
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
}