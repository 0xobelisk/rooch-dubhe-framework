// module dubhe::storage_migration {
//     use aptos_framework::table::{Self, Table};
//     use std::vector;
//     use std::error;
//     use std::signer;

//     /// Error codes
//     const ENOT_INITIALIZED: u64 = 1;
//     const EALREADY_INITIALIZED: u64 = 2;
//     const ENOT_AUTHORIZED: u64 = 3;

//     struct Storage<V: store> has key {
//         data: Table<vector<u8>, V>
//     }

//     public fun initialize<V: store>(account: &signer) {
//         let addr = signer::address_of(account);
//         assert!(!exists<Storage<V>>(addr), error::already_exists(EALREADY_INITIALIZED));
        
//         move_to(account, Storage<V> {
//             data: table::new()
//         });
//     }

//     public fun add_field<V: store>(
//         account: &signer,
//         field_name: vector<u8>,
//         value: V
//     ) acquires Storage {
//         let addr = signer::address_of(account);
//         assert!(exists<Storage<V>>(addr), error::not_found(ENOT_INITIALIZED));
        
//         let storage = borrow_global_mut<Storage<V>>(addr);
//         table::add(&mut storage.data, field_name, value);
//     }

//     public fun borrow_field<V: store>(
//         addr: address,
//         field_name: vector<u8>
//     ): &V acquires Storage {
//         assert!(exists<Storage<V>>(addr), error::not_found(ENOT_INITIALIZED));
//         let storage = borrow_global<Storage<V>>(addr);
//         table::borrow(&storage.data, field_name)
//     }

//     public fun borrow_mut_field<V: store>(
//         account: &signer,
//         field_name: vector<u8>
//     ): &mut V acquires Storage {
//         let addr = signer::address_of(account);
//         assert!(exists<Storage<V>>(addr), error::not_found(ENOT_INITIALIZED));
//         let storage = borrow_global_mut<Storage<V>>(addr);
//         table::borrow_mut(&mut storage.data, field_name)
//     }

//     public fun field_exists<V: store>(
//         addr: address,
//         field_name: vector<u8>
//     ): bool acquires Storage {
//         if (!exists<Storage<V>>(addr)) {
//             return false
//         };
//         let storage = borrow_global<Storage<V>>(addr);
//         table::contains(&storage.data, field_name)
//     }

//     public fun remove_field<V: store>(
//         account: &signer,
//         field_name: vector<u8>
//     ): V acquires Storage {
//         let addr = signer::address_of(account);
//         assert!(exists<Storage<V>>(addr), error::not_found(ENOT_INITIALIZED));
//         let storage = borrow_global_mut<Storage<V>>(addr);
//         table::remove(&mut storage.data, field_name)
//     }
// }