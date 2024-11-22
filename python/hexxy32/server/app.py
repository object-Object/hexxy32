from typing import Literal

import uvicorn
from fastapi import FastAPI, HTTPException, WebSocket, WebSocketDisconnect
from pydantic import BaseModel, TypeAdapter
from starlette.status import HTTP_503_SERVICE_UNAVAILABLE


class MsgLoadS2C(BaseModel):
    type: Literal["load"] = "load"
    filename: str
    """Transformed to `data/{filename}.bin"""


class MsgDoneC2S(BaseModel):
    type: Literal["done"]
    status: bool


type MsgC2S = MsgDoneC2S


app = FastAPI()

client_ws: WebSocket | None = None


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
    if not client_ws:
        raise HTTPException(
            status_code=HTTP_503_SERVICE_UNAVAILABLE,
            detail="Client is not connected",
        )
    msg = MsgLoadS2C(filename=filename)
    await client_ws.send_text(msg.model_dump_json())


if __name__ == "__main__":
    uvicorn.run(
        app,
        host="localhost",
        port=8000,
    )
