#[test_only]
module dubhe::map_tests {
    use std::vector;
    use std::option;
    use dubhe::storage_map::{Self, StorageMap};

    struct TestValue has copy, drop, store {
        value: u64
    }

    // Tests basic map operations including insert, query, update and length check
    #[test]
    fun test_map_basic_operations() {
        let map = storage_map::new<u64, u64>();
        storage_map::insert(&mut map, 1, 100);
        assert!(storage_map::contains_key(&map, 1), 0);
        assert!(storage_map::get(&map, 1) == 100, 1);
        storage_map::set(&mut map, 1, 200);
        assert!(storage_map::get(&map, 1) == 200, 2);
        assert!(storage_map::length(&map) == 1, 3);
    }

    // Tests borrow and borrow_mut operations on map entries
    #[test]
    fun test_map_borrow_operations() {
        let map = storage_map::new<u64, TestValue>();
        storage_map::insert(&mut map, 1, TestValue { value: 100 });
        let borrowed = storage_map::borrow(&map, 1);
        assert!(borrowed.value == 100, 0);
        let borrowed_mut = storage_map::borrow_mut(&mut map, 1);
        borrowed_mut.value = 200;
        assert!(storage_map::get(&map, 1).value == 200, 1);
    }

    // Tests remove and take operations on map entries
    #[test]
    fun test_map_remove_and_take() {
        let map = storage_map::new<u64, u64>();
        storage_map::insert(&mut map, 1, 100);
        let value = storage_map::take(&mut map, 1);
        assert!(value == 100, 0);
        assert!(!storage_map::contains_key(&map, 1), 1);
        storage_map::insert(&mut map, 2, 200);
        storage_map::remove(&mut map, 2);
        assert!(!storage_map::contains_key(&map, 2), 2);
    }

    // Tests keys and values retrieval from map
    #[test]
    fun test_map_keys_and_values() {
        let map = storage_map::new<u64, u64>();
        storage_map::insert(&mut map, 1, 100);
        storage_map::insert(&mut map, 2, 200);
        let keys = storage_map::keys(&map);
        let values = storage_map::values(&map);
        assert!(vector::length(&keys) == 2, 0);
        assert!(vector::length(&values) == 2, 1);
        assert!(*vector::borrow(&values, 0) == 100, 2);
        assert!(*vector::borrow(&values, 1) == 200, 3);
    }

    // Tests try_get operation for both existing and non-existing keys
    #[test]
    fun test_map_try_get() {
        let map = storage_map::new<u64, u64>();
        assert!(option::is_none(&storage_map::try_get(&map, 1)), 0);
        storage_map::insert(&mut map, 1, 100);
        let value_opt = storage_map::try_get(&map, 1);
        assert!(option::is_some(&value_opt), 1);
        assert!(option::extract(&mut value_opt) == 100, 2);
    }

    // Tests that inserting duplicate keys fails as expected
    #[test]
    #[expected_failure(abort_code = 3)]
    fun test_map_duplicate_insert() {
        let map = storage_map::new<u64, u64>();
        storage_map::insert(&mut map, 1, 100);
        storage_map::insert(&mut map, 1, 200);
    }
} 