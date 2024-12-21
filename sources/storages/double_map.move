module dubhe::storage_double_map {
    use std::vector;
    use std::option::{Self, Option};

    // This key does not exist in the map
    const EKeyDoesNotExist: u64 = 0;

    /// This key already exists in the map
    const EKeyAlreadyExists: u64 = 1;

    // An entry in the map
    struct Entry<K1: copy + drop + store, K2: copy + drop + store, V: store> has copy, drop, store {
        key1: K1,
        key2: K2,
        value: V,
    }

    // A map data structure backed by a vector. The map is guaranteed not to contain duplicate keys, but entries
    struct StorageDoubleMap<K1: copy + drop + store, K2: copy + drop + store, V: store> has copy, drop, store {
        contents: vector<Entry<K1, K2, V>>,
    }

    // Create an empty `StorageDoubleMap`
    public fun new<K1: copy + drop + store, K2: copy + drop + store, V: store>(): StorageDoubleMap<K1, K2,V> {
        StorageDoubleMap { contents: vector[] }
    }

    // Return true if `self` contains_key an entry for `key`, false otherwise
    public fun contains_key<K1: copy + drop + store, K2: copy + drop + store, V: store>(self: &StorageDoubleMap<K1, K2, V>, key1: K1, key2: K2): bool {
        option::is_some(&get_idx_opt(self, key1, key2))
    }

    // Return the number of entries in `self`
    public fun length<K1: copy + drop + store, K2: copy + drop + store, V: store>(self: &StorageDoubleMap<K1, K2, V>): u64 {
        vector::length(&self.contents)
    }

    // Get a reference to the value bound to `key` in `self`.
    // Aborts if `key` is not bound in `self`.
    public fun borrow<K1: copy + drop + store, K2: copy + drop + store, V: store>(self: &StorageDoubleMap<K1, K2, V>, key1: K1, key2: K2): &V {
        let idx = get_idx(self, key1, key2);
        let entry = vector::borrow<Entry<K1, K2, V>>(&self.contents, idx);
        &entry.value
    }

    // Get a mutable reference to the value bound to `key` in `self`.
    // Aborts if `key` is not bound in `self`.
    public fun borrow_mut<K1: copy + drop + store, K2: copy + drop + store, V: store>(self: &mut StorageDoubleMap<K1, K2, V>, key1: K1, key2: K2): &mut V {
        let idx = get_idx(self, key1, key2);
        let entry = vector::borrow_mut<Entry<K1, K2, V>>(&mut self.contents, idx);
        &mut entry.value
    }

    // Remove the entry `key` |-> `value` from self. Aborts if `key` is not bound in `self`.
    public fun take<K1: copy + drop + store, K2: copy + drop + store, V: store>(self: &mut StorageDoubleMap<K1, K2,V>, key1: K1, key2: K2): V {
        let idx = get_idx(self, key1, key2);
        let Entry { key1:_, key2:_, value } = vector::remove<Entry<K1, K2, V>>(&mut self.contents, idx);
        value
    }

    // Returns a list of keys in the map.
    // Do not assume any particular ordering.
    public fun keys<K1: copy + drop + store, K2: copy + drop + store, V: store>(self: &StorageDoubleMap<K1, K2, V>): (vector<K1>, vector<K2>) {
        let n = vector::length(&self.contents);
        let keys1 = vector[];
        let keys2 = vector[];
        let i = 0;
        while (i < n) {
            let entry = vector::borrow<Entry<K1, K2, V>>(&self.contents, i);
            vector::push_back<K1>(&mut keys1, entry.key1);
            vector::push_back<K2>(&mut keys2, entry.key2);
            i = i + 1;
        };
        (keys1, keys2)
    }

    // Find the index of `key` in `self`. Return `None` if `key` is not in `self`.
    // Note that map entries are stored in insertion order, *not* sorted by key.
    public fun get_idx_opt<K1: copy + drop + store, K2: copy + drop + store, V: store>(self: &StorageDoubleMap<K1, K2, V>, key1: K1, key2: K2): Option<u64> {
        let n = vector::length(&self.contents);
        let i = 0;
        while (i < n) {
            let entry = vector::borrow<Entry<K1, K2, V>>(&self.contents, i);
            if (entry.key1 == key1 && entry.key2 == key2) {
                return option::some(i)
            };
            i = i + 1;
        };
        option::none()
    }

    // Find the index of `key` in `self`. Aborts if `key` is not in `self`.
    // Note that map entries are stored in insertion order, *not* sorted by key.
    public fun get_idx<K1: copy + drop + store, K2: copy + drop + store, V: store>(self: &StorageDoubleMap<K1, K2, V>, key1: K1, key2: K2): u64 {
        let idx_opt = get_idx_opt(self, key1, key2);
        assert!(option::is_some(&idx_opt), EKeyDoesNotExist);
        option::destroy_some(idx_opt)
    }

    /// Insert the entry `key` |-> `value` into `self`.
    /// Aborts if `key` is already bound in `self`.
    public fun insert<K1: copy + drop + store, K2: copy + drop + store, V: store>(self: &mut StorageDoubleMap<K1, K2, V>, key1: K1, key2: K2, value: V) {
        assert!(!contains_key(self, key1, key2), EKeyAlreadyExists);
        vector::push_back<Entry<K1, K2, V>>(&mut self.contents, Entry { key1, key2, value })
    }

    // =======================================Value: drop + copy + store=======================================

    // Insert the entry `key` |-> `value` into `self`.
    public fun set<K1: copy + drop + store, K2: copy + drop + store, V: copy + drop + store>(self: &mut StorageDoubleMap<K1, K2,V>, key1: K1, key2: K2, value: V) {
        let idx = get_idx_opt(self, key1, key2);
        if (option::is_some(&idx)) {
            let entry = vector::borrow_mut<Entry<K1, K2, V>>(&mut self.contents, option::destroy_some(idx));
            entry.value = value;
        } else {
            vector::push_back<Entry<K1, K2, V>>(&mut self.contents, Entry { key1, key2, value })
        }
    }

    // Get a reference to the value bound to `key` in `self`.
    // Aborts if `key` is not bound in `self`.
    public fun get<K1: copy + drop + store, K2: copy + drop + store, V: copy + drop + store>(self: &StorageDoubleMap<K1, K2, V>, key1: K1, key2: K2): V {
        let idx = get_idx(self, key1, key2);
        let entry = vector::borrow<Entry<K1, K2, V>>(&self.contents, idx);
        entry.value
    }

    // Safely try borrow a value bound to `key` in `self`.
    // Return Some(V) if the value exists, None otherwise.
    // Only works for a "copyable" value as references cannot be stored in `vector`.
    public fun try_get<K1: copy + drop + store, K2: copy + drop + store, V: copy + drop + store>(self: &StorageDoubleMap<K1, K2, V>, key1: K1, key2: K2): Option<V> {
        if (contains_key(self, key1, key2)) {
            option::some(get(self, key1, key2))
        } else {
            option::none()
        }
    }

    // Remove the entry `key` |-> `value` from self.
    public fun remove<K1: copy + drop + store, K2: copy + drop + store, V: copy + drop + store>(self: &mut StorageDoubleMap<K1, K2,V>, key1: K1, key2: K2) {
        let idx = get_idx_opt(self, key1, key2);
        if (option::is_some(&idx)) {
            vector::remove<Entry<K1, K2, V>>(&mut self.contents, option::destroy_some(idx));
        }
    }

    // Returns a list of values in the map.
    // Do not assume any particular ordering.
    public fun values<K1: copy + drop + store, K2: copy + drop + store, V: copy + drop + store>(self: &StorageDoubleMap<K1, K2, V>): vector<V> {
        let n = vector::length(&self.contents);
        let values = vector[];
        let i = 0;
        while (i < n) {
            let entry = vector::borrow<Entry<K1, K2, V>>(&self.contents, i);
            vector::push_back<V>(&mut values, entry.value);
            i = i + 1;
        };
        values
    }
}
