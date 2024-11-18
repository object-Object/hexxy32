#[cfg(not(feature = "alloc"))]
pub use crate::io::print_str;

#[cfg(feature = "alloc")]
pub use crate::println;

pub use crate::{entry, halt};

#[cfg(feature = "alloc")]
pub use alloc;
