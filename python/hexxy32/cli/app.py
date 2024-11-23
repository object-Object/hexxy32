import sys

import httpx
import rich
from typer import Typer

from ..server.constants import DEFAULT_HOST, DEFAULT_PORT

app = Typer(
    pretty_exceptions_show_locals=False,
)


@app.command()
def load(
    filename: str,
    host: str = DEFAULT_HOST,
    port: int = DEFAULT_PORT,
    wait: bool = True,
):
    r = httpx.get(
        url=f"http://{host}:{port}/load",
        params={
            "filename": filename,
        },
    )
    handle_response(r, wait)


@app.command()
def run(
    filename: str,
    host: str = DEFAULT_HOST,
    port: int = DEFAULT_PORT,
    wait: bool = True,
):
    r = httpx.get(
        url=f"http://{host}:{port}/run",
        params={
            "filename": filename,
        },
    )
    handle_response(r, wait)


@app.command()
def dump(
    filename: str = "dumps/latest.bin",
    host: str = DEFAULT_HOST,
    port: int = DEFAULT_PORT,
    wait: bool = True,
):
    r = httpx.get(
        url=f"http://{host}:{port}/dump",
        params={
            "filename": filename,
        },
    )
    handle_response(r, wait)


def handle_response(r: httpx.Response, wait: bool):
    print_response(r)
    if r.is_error:
        sys.exit(1)

    if wait:
        # TODO: listen to server-sent events here
        pass


def print_response(r: httpx.Response):
    rich.print(f"{r.status_code} {r.reason_phrase}")
    rich.print(r.text)


if __name__ == "__main__":
    app()
