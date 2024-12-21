module dubhe::storage_map {
    use std::vector;
    use std::option::{Self, Option};

    /// Error codes
    const ENOT_INITIALIZED: u64 = 1;
    const EALREADY_INITIALIZED: u64 = 2;
    const EKEY_ALREADY_EXISTS: u64 = 3;
    const EKEY_NOT_FOUND: u64 = 4;
    const EKeyDoesNotExist: u64 = 5;
    
    struct Entry<K: copy + drop + store, V: copy + drop + store> has copy, drop, store {
        key: K,
        value: V
    }

    struct StorageMap<K: copy + drop + store, V: copy + drop + store> has copy, drop, store {
        contents: vector<Entry<K, V>>,
    }

    public fun new<K: copy + drop + store, V: copy + drop + store>(): StorageMap<K, V> {
        StorageMap {
            contents: vector[]
        }
    }

    public fun contains_key<K: copy + drop + store, V: copy + drop + store>(
        map: &StorageMap<K, V>,
        key: K
    ): bool {
        let length = vector::length(&map.contents);
        let i = 0;
        while (i < length) {
            let entry = vector::borrow(&map.contents, i);
            if (entry.key == key) {
                return true
            };
            i = i + 1;
        };
         false
    }

    public fun length<K: copy + drop + store, V: copy + drop + store>(self: &StorageMap<K, V>): u64 {
        vector::length(&self.contents)
    }

    public fun borrow<K: copy + drop + store, V: copy + drop + store>(self: &StorageMap<K, V>, key: K): &V {
        let idx = get_idx(self, key);
        let entry = vector::borrow(&self.contents, idx);
        &entry.value
    }

    public fun borrow_mut<K: copy + drop + store, V: copy + drop + store>(
        self: &mut StorageMap<K, V>,
        key: K
    ): &mut V {
        let idx = get_idx(self, key);
        let entry = vector::borrow_mut<Entry<K, V>>(&mut self.contents, idx);
        &mut entry.value
    }

    public fun take<K: copy + drop + store, V: copy + drop + store>(
        self: &mut StorageMap<K, V>,
        key: K
    ): V {
        let idx = get_idx(self, key);
        let entry = vector::remove(&mut self.contents, idx);
        entry.value
    }

    public fun keys<K: copy + drop + store, V: copy + drop + store>(self: &StorageMap<K, V>): vector<K> {
        let length = vector::length(&self.contents);
        let keys = vector[];
        let i = 0;
        while (i < length) {
            let entry = vector::borrow(&self.contents, i);
            vector::push_back(&mut keys, entry.key);
            i = i + 1;
        };
        keys
    }




        /// Find the index of `key` in `self`. Return `None` if `key` is not in `self`.
    /// Note that map entries are stored in insertion order, *not* sorted by key.
    public fun get_idx_opt<K: copy + drop + store, V: copy + drop + store>(self: &StorageMap<K,V>, key: K): Option<u64> {
        let length = vector::length(&self.contents);
        let i = 0;
        while (i < length) {
            let entry = vector::borrow(&self.contents, i);
            if (entry.key == key) {
                return option::some(i)
            };
            i = i + 1;
        };
        option::none()
    }

    /// Find the index of `key` in `self`. Aborts if `key` is not in `self`.
    /// Note that map entries are stored in insertion order, *not* sorted by key.
    public fun get_idx<K: copy + drop + store, V: copy + drop + store>(self: &StorageMap<K,V>, key: K): u64 {
        let idx_opt = get_idx_opt(self, key);
        assert!(option::is_some(&idx_opt), EKeyDoesNotExist);
        option::destroy_some(idx_opt)
    }

    public fun insert<K: copy + drop + store, V: copy + drop + store>(
        self: &mut StorageMap<K, V>,
        key: K,
        value: V
    ) {
        assert!(!contains_key<K, V>(self, key), EKEY_ALREADY_EXISTS);
        vector::push_back(&mut self.contents, Entry { key, value });
    }

    public fun set<K: copy + drop + store, V: copy + drop + store>(
        self: &mut StorageMap<K, V>,
        key: K,
        value: V
    ) {
        let idx = get_idx_opt(self, key);
        if (option::is_some(&idx)) {
            let entry = vector::borrow_mut<Entry<K, V>>(&mut self.contents, option::destroy_some(idx));
            entry.value = value;
        } else {
            vector::push_back(&mut self.contents, Entry { key, value })
        }
    }

    public fun get<K: copy + drop + store, V: copy + drop + store>(
        self: &StorageMap<K, V>,
        key: K
    ): V {
        let idx = get_idx(self, key);
        let entry = vector::borrow(&self.contents, idx);
        entry.value
    }

    public fun try_get<K: copy + drop + store, V: copy + drop + store>(
        self: &StorageMap<K, V>,
        key: K
    ): Option<V> {
        if (contains_key(self, key)) {
            option::some(get(self, key))
        } else {
            option::none()
        }
    }

    public fun remove<K: copy + drop + store, V: copy + drop + store>(
        self: &mut StorageMap<K, V>,
        key: K
    ): V {
        let idx = get_idx(self, key);
        let entry = vector::remove(&mut self.contents, idx);
        entry.value
    }

    public fun values<K: copy + drop + store, V: copy + drop + store>(
        self: &StorageMap<K, V>
    ): vector<V> {
        let length = vector::length(&self.contents);
        let values = vector[];
        let i = 0;
        while (i < length) {
            let entry = vector::borrow(&self.contents, i);
            vector::push_back(&mut values, entry.value);
            i = i + 1;
        };
        values
    }


    // /// Get a reference to the value bound to `key` in `self`.
    // / // Aborts if `key` is not bound in `self`.
    // public fun get<K: copy + drop + store, V: copy + drop + store>(self: &StorageMap<K,V>, key: K): V {
    //     let idx = self.get_idx(key);
    //     let entry = &self.contents[idx];
    //     entry.value
    // }

}
