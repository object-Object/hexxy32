#[cfg(not(feature = "alloc"))]
pub use crate::io::print_str;

#[cfg(feature = "alloc")]
pub use crate::println;

pub use crate::{entry, halt, sleep, sleep_n};

#[cfg(feature = "alloc")]
pub use alloc;
