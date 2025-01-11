from __future__ import annotations

import ctypes
from ctypes import c_uint8, c_uint32
from typing import TYPE_CHECKING, Literal, Self

from simple_rpc import SerialInterface as _SerialInterface

LED_BUILTIN = 13

HIGH = 1
LOW = 0

INPUT = 0
OUTPUT = 1
INPUT_PULLUP = 2


class SerialInterface(_SerialInterface):
    if TYPE_CHECKING:

        def __enter__(self) -> Self: ...

        def digital_read(self, pin: int) -> int: ...
        def digital_write(self, pin: int, value: Literal[0, 1]) -> None: ...
        def pin_mode(self, pin: int, mode: Literal[0, 1, 2]) -> None: ...


class MsgGPIOC2S_bytes(ctypes.LittleEndianStructure):
    _fields_ = [
        ("command", c_uint8, 2),
        ("pin", c_uint8, 4),
        ("arg", c_uint8, 2),
    ]

    if TYPE_CHECKING:
        command: int
        pin: int
        arg: int


class MsgGPIOC2S(ctypes.Union):
    _fields_ = [
        ("b", MsgGPIOC2S_bytes),
        ("asbyte", c_uint32),
    ]

    if TYPE_CHECKING:
        b: MsgGPIOC2S_bytes
        asbyte: int
