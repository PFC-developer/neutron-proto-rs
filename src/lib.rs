//! ibc-proto library gives the developer access to the Cosmos SDK IBC proto-defined structs.

// Todo: automate the creation of this module setup based on the dots in the filenames.
// This module setup is necessary because the generated code contains "super::" calls for dependencies.
#![cfg_attr(not(feature = "std"), no_std)]
#![deny(warnings, trivial_casts, trivial_numeric_casts, unused_import_braces)]
#![allow(clippy::large_enum_variant, clippy::needless_borrows_for_generic_args)]
#![allow(rustdoc::bare_urls)]
#![cfg_attr(
    feature = "serde",
    expect(
        clippy::needless_lifetimes,
        reason = "triggered in pbjson generated code; addressed by https://github.com/influxdata/pbjson/pull/138"
    )
)]
#![forbid(unsafe_code)]

pub use tendermint_proto::Error;
pub use tendermint_proto::Protobuf;

extern crate alloc;

#[cfg(not(feature = "std"))]
#[macro_use]
extern crate core as std;

#[macro_export]
macro_rules! include_proto {
    ($path:literal) => {
        include!(concat!("prost/", $path));
    };
}

/// The version (commit hash) of IBC Go used when generating this library.
pub const NEUTRON_GO_COMMIT: &str = include_str!("NEUTRON_GO_COMMIT");

/// File descriptor set of compiled proto.
#[cfg(feature = "proto-descriptor")]
pub const FILE_DESCRIPTOR_SET: &[u8] = include_bytes!("prost/proto_descriptor.bin");

// Re-export the Google protos from the `tendermint_proto` crate
pub mod google {
    pub use tendermint_proto::google::*;
}

// Re-export Cosmos SDK protos from the `cosmos_sdk_proto` crate
pub use cosmos_sdk_proto::cosmos;

// Re-export the ICS23 proto from the `ics23` crate
pub use ics23;

pub mod neutron {
 
    pub mod dex {
        pub mod transfer {
            pub mod v1 {
                include_proto!("neutron.dex.rs");
                #[cfg(feature = "serde")]
                include_proto!("neutron.dex.v1.serde.rs");
            }
            pub mod v2 {
                include_proto!("neutron.dex.v2.rs");
                #[cfg(feature = "serde")]
                include_proto!("neutron.dex.v2.serde.rs");
            }
        }
        pub mod contractmanager {
            include_proto!("neutron.contractmanager.rs");
            #[cfg(feature = "serde")]
            include_proto!("neutron.contractmanager.serde.rs");
            pub mod v1 {
                include_proto!("neutron.contractmanager.v1.rs");
                #[cfg(feature = "serde")]
                include_proto!("neutron.contractmanager.v1.serde.rs");
            }
        }
        pub mod cron {
            include_proto!("neutron.cron.rs");
            #[cfg(feature = "serde")]
            include_proto!("neutron.cron.serde.rs");
            pub mod v1 {
                include_proto!("neutron.cron.v1.rs");
                #[cfg(feature = "serde")]
                include_proto!("neutron.cron.v1.serde.rs");
            }


        }

    }
}

