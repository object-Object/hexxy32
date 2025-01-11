from typing import Literal

import uvicorn
from fastapi import FastAPI, HTTPException, WebSocket, WebSocketDisconnect
from pydantic import BaseModel, TypeAdapter
from starlette.status import HTTP_503_SERVICE_UNAVAILABLE

from hexxy32.utils.arduino import MsgGPIOC2S, SerialInterface

from .constants import DEFAULT_HOST, DEFAULT_PORT


class MsgLoadS2C(BaseModel):
    type: Literal["load"] = "load"
    filename: str
    """Transformed to `data/{filename}` by the loader."""
    run: bool


class MsgDumpS2C(BaseModel):
    type: Literal["dump"] = "dump"
    filename: str
    """Transformed to `data/{filename}` by the loader."""


type MsgS2C = MsgLoadS2C | MsgDumpS2C


class MsgDoneC2S(BaseModel):
    type: Literal["done"]
    status: int


type MsgC2S = MsgDoneC2S


app = FastAPI()

client_ws: WebSocket | None = None


async def send_s2c_message(msg: MsgS2C):
    if not client_ws:
        raise HTTPException(
            status_code=HTTP_503_SERVICE_UNAVAILABLE,
            detail="Client is not connected",
        )
    await client_ws.send_text(msg.model_dump_json())


@app.websocket("/ws")
async def ws_loader(ws: WebSocket):
    global client_ws

    await ws.accept()
    client_ws = ws

    ta = TypeAdapter[MsgC2S](MsgC2S)
    try:
        while True:
            data = await ws.receive_text()
            match ta.validate_json(data):
                case MsgDoneC2S(status=status):
                    print(f"done: {status}")
    except WebSocketDisconnect:
        client_ws = None


@app.websocket("/ws/arduino")
async def ws_arduino(ws: WebSocket):
    await ws.accept()

    device = await ws.receive_text()
    with SerialInterface(device, baudrate=115200) as interface:
        try:
            while True:
                msg = MsgGPIOC2S()
                msg.asbyte = int(await ws.receive_text())

                response = handle_gpio(interface, msg)

                await ws.send_text(response)

        except WebSocketDisconnect:
            pass


def handle_gpio(interface: SerialInterface, msg: MsgGPIOC2S) -> str:
    pin = msg.b.pin
    if not (0 <= pin < 14):
        raise ValueError(f"Invalid pin: {pin}")

    match msg.b.command:
        case 0:  # read
            return str(interface.digital_read(pin))

        case 1:  # write
            value = msg.b.arg
            if value not in (0, 1):
                raise ValueError(f"Invalid pin value: {value}")
            interface.digital_write(pin, value)
            return ""

        case 2:  # mode
            mode = msg.b.arg
            if mode not in (0, 1, 2):
                raise ValueError(f"Invalid pin mode: {mode}")
            interface.pin_mode(pin, mode)
            return ""

        case command:
            raise ValueError(f"Invalid command: {command}")


@app.get("/load")
async def get_load(filename: str):
    msg = MsgLoadS2C(filename=filename, run=False)
    await send_s2c_message(msg)


@app.get("/run")
async def get_run(filename: str):
    msg = MsgLoadS2C(filename=filename, run=True)
    await send_s2c_message(msg)


@app.get("/dump")
async def get_dump(filename: str):
    msg = MsgDumpS2C(filename=filename)
    await send_s2c_message(msg)


if __name__ == "__main__":
    uvicorn.run(
        app,
        host=DEFAULT_HOST,
        port=DEFAULT_PORT,
    )
