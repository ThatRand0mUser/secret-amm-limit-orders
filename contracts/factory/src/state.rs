  
use std::any::type_name;

use cosmwasm_storage::ReadonlyPrefixedStorage;
use serde::{de::DeserializeOwned, Serialize};

use cosmwasm_std::{CanonicalAddr, ReadonlyStorage, StdError, StdResult, Storage};

use secret_toolkit::serialization::{Bincode2, Serde};

pub const PREFIX_VIEW_KEY: &[u8] = b"viewingkey";

pub fn save<T: Serialize, S: Storage>(storage: &mut S, key: &[u8], value: &T) -> StdResult<()> {
    storage.set(key, &Bincode2::serialize(value)?);
    Ok(())
}

pub fn load<T: DeserializeOwned, S: ReadonlyStorage>(storage: &S, key: &[u8]) -> StdResult<T> {
    Bincode2::deserialize(
        &storage
            .get(key)
            .ok_or_else(|| StdError::not_found(type_name::<T>()))?,
    )
}

pub fn may_load<T: DeserializeOwned, S: ReadonlyStorage>(
    storage: &S,
    key: &[u8],
) -> StdResult<Option<T>> {
    match storage.get(key) {
        Some(value) => Bincode2::deserialize(&value).map(Some),
        None => Ok(None),
    }
}