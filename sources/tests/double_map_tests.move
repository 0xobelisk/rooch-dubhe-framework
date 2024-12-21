#[test_only]
module dubhe::double_map_tests {
    use std::vector;
    use std::option;
    use dubhe::storage_double_map::{Self, StorageDoubleMap};

    struct TestValue has copy, drop, store {
        value: u64
    }

    #[test]
    fun test_storage_double_map_basic_operations() {
        let map = storage_double_map::new<u64, u64, u64>();
        
        storage_double_map::insert(&mut map, 1, 2, 100);
        assert!(storage_double_map::contains_key(&map, 1, 2), 0);
        assert!(storage_double_map::get<u64, u64, u64>(&map, 1, 2) == 100, 1);
        
        storage_double_map::set(&mut map, 1, 2, 200);
        assert!(storage_double_map::get<u64, u64, u64>(&map, 1, 2) == 200, 2);
        
        assert!(storage_double_map::length<u64, u64, u64>(&map) == 1, 3);
    }

    #[test]
    fun test_storage_double_map_borrow_operations() {
        let map = storage_double_map::new<u64, u64, TestValue>();
        storage_double_map::insert(&mut map, 1, 2, TestValue { value: 100 });
        
        let borrowed = storage_double_map::borrow(&map, 1, 2);
        assert!(borrowed.value == 100, 0);
        
        let borrowed_mut = storage_double_map::borrow_mut(&mut map, 1, 2);
        borrowed_mut.value = 200;
        assert!(storage_double_map::get<u64, u64, TestValue>(&map, 1, 2).value == 200, 1);
    }

    #[test]
    fun test_storage_double_map_remove_and_take() {
        let map = storage_double_map::new<u64, u64, u64>();
        storage_double_map::insert<u64, u64, u64>(&mut map, 1, 2, 100);
        
        let value = storage_double_map::take(&mut map, 1, 2);
        assert!(value == 100, 0);
        assert!(!storage_double_map::contains_key(&map, 1, 2), 1);
        
        storage_double_map::insert<u64, u64, u64>(&mut map, 3, 4, 200);
        storage_double_map::remove<u64, u64, u64>(&mut map, 3, 4);
        assert!(!storage_double_map::contains_key<u64, u64, u64>(&map, 3, 4), 2);
    }

    #[test]
    fun test_storage_double_map_keys_and_values() {
        let map = storage_double_map::new<u64, u64, u64>();
        storage_double_map::insert<u64, u64, u64>(&mut map, 1, 2, 100);
        storage_double_map::insert<u64, u64, u64>(&mut map, 3, 4, 200);
        
        let (keys1, keys2) = storage_double_map::keys<u64, u64, u64>(&map);
        let values = storage_double_map::values<u64, u64, u64>(&map);
        
        assert!(vector::length(&keys1) == 2, 0);
        assert!(vector::length(&keys2) == 2, 1);
        assert!(vector::length(&values) == 2, 2);
        assert!(*vector::borrow(&values, 0) == 100, 3);
        assert!(*vector::borrow(&values, 1) == 200, 4);
    }

    #[test]
    fun test_storage_double_map_try_get() {
        let map = storage_double_map::new<u64, u64, u64>();
        
        assert!(option::is_none(&storage_double_map::try_get<u64, u64, u64>(&map, 1, 2)), 0);
        
        storage_double_map::insert(&mut map, 1, 2, 100);
        let value_opt = storage_double_map::try_get<u64, u64, u64>(&map, 1, 2);
        assert!(option::is_some(&value_opt), 1);
        assert!(option::extract(&mut value_opt) == 100, 2);
    }

    #[test]
    #[expected_failure(abort_code = 1)]
    fun test_storage_double_map_duplicate_insert() {
        let map = storage_double_map::new<u64, u64, u64>();
        storage_double_map::insert(&mut map, 1, 2, 100);
        storage_double_map::insert(&mut map, 1, 2, 200);
    }
} 