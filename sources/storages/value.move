module dubhe::storage_value {
    use std::option::{Self, Option};
    use std::vector;
    /// Error codes
    const EVALUE_NOT_EXIST: u64 = 3;
    const EVALUE_ALREADY_EXIST: u64 = 4;

    struct Entry<V: copy + drop + store> has copy, drop, store {
        value: V
    }

    struct StorageValue<V: copy + drop + store> has copy, drop, store {
        contents: vector<Entry<V>>
    }

    public fun new<V: copy + drop + store>(): StorageValue<V> {
        StorageValue {
            contents: vector::empty()
        }
    }

    /// Gets the value of the StorageValue `self: &StorageValue<Value>`.
    public fun borrow<V: copy + drop + store>(self: &StorageValue<V>): &V {
        assert!(contains(self), EVALUE_NOT_EXIST);
        let entry = vector::borrow<Entry<V>>(&self.contents, 0);
        &entry.value
    }

    /// Gets the value of the StorageValue `self: &mut StorageValue<Value>`.
    public fun borrow_mut<V: copy + drop + store>(self: &mut StorageValue<V>): &mut V {
        assert!(contains(self), EVALUE_NOT_EXIST);
        let entry = vector::borrow_mut<Entry<V>>(&mut self.contents, 0);
        &mut entry.value
    }

    /// Return true if `self` contains_key an entry for `key`, false otherwise
    public fun contains<V: copy + drop + store>(self: &StorageValue<V>): bool {
        vector::length(&self.contents) == 1
    }

    /// Remove the entry `key` |-> `value` from self. Aborts if `key` is not bound in `self`.
    public fun take<V: copy + drop + store>(self: &mut StorageValue<V>): V {
        assert!(contains(self), EVALUE_NOT_EXIST);
        let entry = vector::remove<Entry<V>>(&mut self.contents, 0);
        entry.value
    }

    /// Put the `value` of the `StorageValue`.
    public fun put<V: copy + drop + store>(self: &mut StorageValue<V>, value: V) {
        assert!(!contains(self), EVALUE_ALREADY_EXIST);
        vector::push_back<Entry<V>>(&mut self.contents, Entry { value });
    }


    // ======================================= Value: drop + copy + store =======================================

    /// Set the `value` of the `StorageValue`.
    public fun set<V: copy + drop + store>(self: &mut StorageValue<V>, value: V) {
        if (contains(self)) {
            *borrow_mut(self) = value;
        } else {
            vector::push_back<Entry<V>>(&mut self.contents, Entry { value });
        }
    }

    /// Get the `value` of the `StorageValue`.
    public fun get<V: copy + drop + store>(self: &StorageValue<V>): V {
        assert!(contains(self), EVALUE_NOT_EXIST);
        let entry = vector::borrow<Entry<V>>(&self.contents, 0);
        entry.value
    }

    /// Safely try borrow a value bound to `key` in `self`.
    /// Return Some(V) if the value exists, None otherwise.
    /// Only works for a "copyable" value as references cannot be stored in `vector`.
    public fun try_get<V: copy + drop + store>(self: &StorageValue<V>): Option<V> {
        if (contains(self)) {
            option::some(get(self))
        } else {
            option::none()
        }
    }

    /// Remove the entry `key` |-> `value` from self. Aborts if `key` is not bound in `self`.
    public fun remove<V: copy + drop + store>(self: &mut StorageValue<V>) {
        if (contains(self)) {
            vector::remove<Entry<V>>(&mut self.contents, 0);
        }
    }

    // ============================================================================================
}
