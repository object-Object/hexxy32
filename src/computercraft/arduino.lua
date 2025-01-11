local RX_NAME = "focal_port_3"
local TX_NAME = "focal_port_4"

local URL = "ws://localhost:8000/ws/arduino"

---@param handlers { [string]: fun(...: any) }
---@param event string
---@param ... any
local function handleEvent(handlers, event, ...)
    local handler = handlers[event]
    if handler ~= nil then handler(...) end
end

---@param rx FocalPort
---@param tx FocalPort
---@param ws ccTweaked.http.Websocket
local function handleIota(rx, tx, ws)
    local msg = rx.readIota()
    if type(msg) ~= "number" then sleep(0) return end

    rx.writeIota({ null = true }) -- reset the port so we don't read it again next tick

    print("send "..tostring(msg))
    ws.send(tostring(msg))

    local rawResponse = ws.receive()
    assert(rawResponse ~= nil, "Websocket closed!")
    print("recv "..rawResponse)

    if rawResponse ~= "" then
        local response = tonumber(rawResponse)
        assert(response ~= nil, "Invalid response: "..rawResponse)

        tx.writeIota(response)
    end
end

local function main(device)
    local rx = assert(peripheral.wrap(RX_NAME), "RX focal port not found: "..RX_NAME)
    ---@cast rx FocalPort
    local tx = assert(peripheral.wrap(TX_NAME), "TX focal port not found: "..TX_NAME)
    ---@cast tx FocalPort

    local ws, err = http.websocket(URL)
    assert(ws, "Failed to connect to websocket "..URL..": "..tostring(err))

    ws.send(device)

    while true do
        handleIota(rx, tx, ws)

        -- handleEvent({
        --     new_iota = function(peripheral_name)
        --         if peripheral_name ~= RX_NAME then return end

        --         local msg = rx.readIota()
        --         if type(msg) ~= "number" then return end

        --         print("send "..tostring(msg))
        --         ws.send(tostring(msg))

        --         local rawResponse = ws.receive()
        --         assert(rawResponse ~= nil, "Websocket closed!")
        --         print("recv "..rawResponse)

        --         if rawResponse ~= "" then
        --             local response = tonumber(rawResponse)
        --             assert(response ~= nil, "Invalid response: "..rawResponse)

        --             tx.writeIota(response)
        --         end
        --     end
        -- }, os.pullEvent())
    end
end

main(...)
