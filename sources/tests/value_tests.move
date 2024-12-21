#[test_only]
module dubhe::value_tests {
    use std::debug;
    use std::option;
    use dubhe::storage_value;

    struct TestValue has copy, drop, store {
        value: u64
    }

    #[test]
    fun test_storage_value_basic_operations() {
        let storage = storage_value::new<u64>();
        storage_value::set<u64>(&mut storage, 1);
        let value = storage_value::get<u64>(&storage);
        assert!(value == 1, 0);
        
        storage_value::set<u64>(&mut storage, 2);
        assert!(storage_value::get<u64>(&storage) == 2, 1);
    }

    #[test]
    fun test_storage_value_struct_operations() {
        let storage = storage_value::new<TestValue>();
        let test_value = TestValue { value: 1 };
        
        storage_value::set<TestValue>(&mut storage, test_value);
        let value = storage_value::get<TestValue>(&storage);
        assert!(value == TestValue { value: 1 }, 0);
    }

    #[test]
    fun test_storage_value_borrow_operations() {
        let storage = storage_value::new();
        storage_value::put(&mut storage, 100);
        
        let borrowed = storage_value::borrow<u64>(&storage);
        assert!(*borrowed == 100, 0);
        
        let borrowed_mut = storage_value::borrow_mut<u64>(&mut storage);
        *borrowed_mut = 200;
        assert!(storage_value::get<u64>(&storage) == 200, 1);
    }

    #[test]
    fun test_storage_value_try_get() {
        let storage = storage_value::new<u64>();
        
        assert!(option::is_none(&storage_value::try_get<u64>(&storage)), 0);
        
        storage_value::set<u64>(&mut storage, 1);
        let opt_value = storage_value::try_get<u64>(&storage);
        assert!(option::is_some(&opt_value), 1);
        assert!(option::extract(&mut opt_value) == 1, 2);
    }

    #[test]
    fun test_storage_value_remove_and_take() {
        let storage = storage_value::new();
        storage_value::set(&mut storage, 1);
        
        storage_value::remove<u64>(&mut storage);
        assert!(!storage_value::contains<u64>(&storage), 0);
        
        storage_value::set<u64>(&mut storage, 2);
        let taken = storage_value::take<u64>(&mut storage);
        assert!(taken == 2, 1);
        assert!(!storage_value::contains<u64>(&storage), 2);
    }

    #[test]
    #[expected_failure(abort_code = 4)]
    fun test_storage_value_put_existing_value() {
        let storage = storage_value::new<u64>();
        storage_value::put<u64>(&mut storage, 1);
        storage_value::put<u64>(&mut storage, 2);
    }

    #[test]
    #[expected_failure(abort_code = 3)]
    fun test_storage_value_get_non_existent() {
        let storage = storage_value::new<u64>();
        storage_value::get<u64>(&storage);
    }
}