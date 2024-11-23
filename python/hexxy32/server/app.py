from typing import Literal

import uvicorn
from fastapi import FastAPI, HTTPException, WebSocket, WebSocketDisconnect
from pydantic import BaseModel, TypeAdapter
from starlette.status import HTTP_503_SERVICE_UNAVAILABLE


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
async def websocket_endpoint(ws: WebSocket):
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
        host="localhost",
        port=8000,
    )
