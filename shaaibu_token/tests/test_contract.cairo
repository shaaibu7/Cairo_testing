use starknet::ContractAddress;

use snforge_std::{declare, ContractClassTrait, DeclareResultTrait, start_cheat_caller_address, stop_cheat_caller_address};

#[starknet::interface]
pub trait IERC20Combined<TContractState> {
    // IERC20
    fn total_supply(self: @TContractState) -> u256;
    fn balance_of(self: @TContractState, account: ContractAddress) -> u256;
    fn allowance(self: @TContractState, owner: ContractAddress, spender: ContractAddress) -> u256;
    fn transfer(ref self: TContractState, recipient: ContractAddress, amount: u256) -> bool;
    fn transfer_from(
        ref self: TContractState, sender: ContractAddress, recipient: ContractAddress, amount: u256
    ) -> bool;
    fn approve(ref self: TContractState, spender: ContractAddress, amount: u256) -> bool;

    // IERC20Metadata
    fn name(self: @TContractState) -> ByteArray;
    fn symbol(self: @TContractState) -> ByteArray;
    fn decimals(self: @TContractState) -> u8;

    fn mint(ref self: TContractState, recipient: ContractAddress, amount: u256);
}



fn deploy_contract(name: ByteArray) -> ContractAddress {
    let contract = declare(name).unwrap().contract_class();
    let (contract_address, _) = contract.deploy(@ArrayTrait::new()).unwrap();
    contract_address
}

#[test]
fn test_constructor() {
    let contract_address = deploy_contract("ShaaibuToken");

    let token = IERC20CombinedDispatcher { contract_address };

    assert(token.name() == "Shaaibu Token", 'Wrong token name');
    assert(token.symbol() == "SHT", 'Wrong token symbol');

}


#[test]
fn test_total_supply() {
    let contract_address = deploy_contract("ShaaibuToken");

    let token = IERC20CombinedDispatcher { contract_address };

    let mint_amount: u256 = 100000_u256;
    let token_recipient: ContractAddress = starknet::contract_address_const::<0x123456711>();

    token.mint(token_recipient, mint_amount);

    assert(token.total_supply() == mint_amount, 'Wrong token supply');
}


#[test]
fn test_balance_of() {
    let contract_address = deploy_contract("ShaaibuToken");

    let token = IERC20CombinedDispatcher { contract_address };

    let mint_amount: u256 = 100000_u256;
    let token_recipient: ContractAddress = starknet::contract_address_const::<0x123456711>();

    token.mint(token_recipient, mint_amount);

    assert(token.balance_of(token_recipient) == mint_amount, 'Wrong address balance');

}


#[test]
fn test_approve() {
    let contract_address = deploy_contract("ShaaibuToken");

    let token = IERC20CombinedDispatcher { contract_address };

    let mint_amount: u256 = 100000_u256;
    let token_owner: ContractAddress = starknet::contract_address_const::<0x123456711>();

    token.mint(token_owner, mint_amount);

    let token_spender: ContractAddress = starknet::contract_address_const::<0x000456711>();
    let spend_amount: u256 = 500_u256;

    // Owner approves token_spender to spend token
    start_cheat_caller_address(contract_address, token_owner);
    token.approve(token_spender, spend_amount);
    stop_cheat_caller_address(contract_address);



    assert(token.allowance(token_owner, token_spender) == spend_amount, 'Wrong spend amount');

}


#[test]
fn test_transfer() {
    let contract_address = deploy_contract("ShaaibuToken");

    let token = IERC20CombinedDispatcher { contract_address };

    let mint_amount: u256 = 100000_u256;
    let token_owner: ContractAddress = starknet::contract_address_const::<0x123456711>();

    token.mint(token_owner, mint_amount);

    let token_recipient: ContractAddress = starknet::contract_address_const::<0x000456711>();
    let transfer_amount: u256 = 500_u256;

    // Owner approves token_spender to spend token
    start_cheat_caller_address(contract_address, token_owner);
    token.transfer(token_recipient, transfer_amount);
    stop_cheat_caller_address(contract_address);



    assert(token.balance_of(token_recipient) == transfer_amount, 'transfer failed');
    assert(token.balance_of(token_owner) == mint_amount - transfer_amount, 'wrong owner balance');

}


