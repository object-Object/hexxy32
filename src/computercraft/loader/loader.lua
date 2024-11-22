local strings = require("cc.strings")

local NUM_TX_CHUNKS = 60
local CHUNK_SIZE = 512
local CHUNK_BYTES = CHUNK_SIZE * 4
local CHUNK_FMT = ">"..string.rep("I4", CHUNK_SIZE) -- CHUNK_SIZE 32-bit integers in big endian
local MAX_CHUNK_LUA_INDEX = 19*19*19

local CMD_GET_LAST_INDEX = 0
local CMD_WRITE = 1
local CMD_READ = 2

local data = {}
local isDone = false
local lastSuccessfulLuaIndex = 0

local focalLink = assert(peripheral.wrap("top"), "Expected focal link on top of computer")
---@cast focalLink FocalLink

---@param luaIndex number
---@return string
local function fmtChunk(luaIndex)
    return (luaIndex-1).." ("..luaIndex.."/"..#data..")"
end

---@param index number
---@param iotas Iota[]
---@return boolean
local function trySendIotas(index, iotas)
    local ok, err = pcall(focalLink.sendIota, 0, unpack(iotas))
    if not ok then print(err) end
    return ok
end

---@param luaIndex number
local function sendChunk(luaIndex)
    if luaIndex > #data then return end

    local iotas = {}
    local endIndex = math.min(luaIndex + NUM_TX_CHUNKS - 1, #data)
    for i = luaIndex, endIndex do
        table.insert(iotas, {data[i], i - 1, CMD_WRITE})
    end
    table.insert(iotas, {CMD_GET_LAST_INDEX})

    if focalLink.numLinked() == 0 then
        print("Wisp disconnected, waiting for wisp to reconnect...")
        return
    end

    print("Sending chunks: "..(luaIndex-1).." -> "..fmtChunk(endIndex))
    trySendIotas(0, iotas)
end

---@param handlers { [string]: fun(...: any) }
---@param event string
---@param ... any
local function handleEvent(handlers, event, ...)
    local handler = handlers[event]
    if handler ~= nil then handler(...) end
end

---@param filename string
local function cmdLoad(filename)
    filename = "data/"..filename..".bin"

    print("Loading data file: "..filename)
    local f = assert(fs.open(filename, "rb"), "Failed to open file: "..filename)
    while true do
        local line = f.read(CHUNK_BYTES)
        if not line then break end

        line = line..string.rep("\0", CHUNK_BYTES - #line)
        local row = {string.unpack(CHUNK_FMT, line)}
        table.remove(row) -- string.unpack returns the data and the next index to read

        assert(#row == CHUNK_SIZE, "Invalid chunk: expected "..CHUNK_SIZE.." elements but got "..#row)
        table.insert(data, row)
    end
    f.close()
    assert(#data > 0, "Invalid file, expected at least one element: "..filename)

    focalLink.clearReceivedIotas()
    if focalLink.numLinked() > 0 then
        sendChunk(1)
    else
        print("Waiting for wisp to connect...")
    end

    while lastSuccessfulLuaIndex < #data do
        handleEvent(
            {
                received_iota = function()
                    local hexIndex = focalLink.receiveIota() -- last index successfully written by the wisp
                    if type(hexIndex) == "table" then
                        print("Wisp reset, continuing from last successful chunk: "..fmtChunk(lastSuccessfulLuaIndex))
                    elseif type(hexIndex) == "number" then
                        lastSuccessfulLuaIndex = hexIndex + 1
                        print("Wisp successfully wrote chunk: "..fmtChunk(lastSuccessfulLuaIndex))
                    else
                        print("Ignoring unexpected iota: "..hexIndex)
                        return
                    end
                    sendChunk(lastSuccessfulLuaIndex + 1)
                end
            },
            os.pullEvent()
        )
    end

    print("Done.")
end

local function cmdDump(filename)
    filename = "data/"..filename..".bin"

    focalLink.clearReceivedIotas()
    if focalLink.numLinked() > 0 then
        local iotas = {}
        for i = 1, NUM_TX_CHUNKS do
            table.insert(iotas, {i - 1, CMD_READ})
        end
        table.insert(iotas, {CMD_GET_LAST_INDEX})
        print("Requesting "..#iotas.." chunks")
        trySendIotas(0, iotas)
    else
        print("Waiting for wisp to connect...")
    end

    while not isDone do
        handleEvent(
            {
                received_iota = function()
                    local packets = focalLink.receiveIotas()
                    print("Received "..#packets.." messages")
                    for _, packet in ipairs(packets) do
                        local index = packet[1]
                        local chunk = packet[2]
                        if type(index) == "number" and type(chunk) == "table" then
                            data[index + 1] = chunk
                        else
                            local n = NUM_TX_CHUNKS
                            local iotas = {}
                            for i = 1, MAX_CHUNK_LUA_INDEX do
                                if data[i] == nil then
                                    table.insert(iotas, {i - 1, CMD_READ})
                                    n = n - 1
                                    if n == 0 then break end
                                end
                            end
                            if #iotas > 0 then
                                print("Requesting "..#iotas.." chunks")
                                table.insert(iotas, {CMD_GET_LAST_INDEX})
                                trySendIotas(0, iotas)
                            else
                                print("Done reading chunks.")
                                isDone = true
                            end
                        end
                    end
                end,
            },
            os.pullEvent()
        )
    end

    local f = assert(fs.open(filename, "wb"), "Failed to open file: "..filename)
    for _, chunk in ipairs(data) do
        f.write(string.pack(CHUNK_FMT, chunk))
    end
    f.close()

    print("Done.")
end

---@class MsgLoadS2C
---@field type "load"
---@field filename string

---@alias MsgS2C
---| MsgLoadS2C

local function cmdClient()
    local url = "ws://localhost:8000/ws"
    local ws, err = http.websocket(url)
    assert(ws, "Failed to connect to websocket "..url..": "..tostring(err))

    while true do
        local rawMsg = ws.receive()
        assert(rawMsg, "Server disconnected")

        local msg = textutils.unserialiseJSON(rawMsg)
        assert(msg, "Failed to deserialize msg: "..rawMsg)
        ---@cast msg MsgS2C

        if msg.type == "load" then
            cmdLoad(msg.filename)
        else
            print("Unhandled message type: "..tostring(msg.type))
        end
    end
end

local function main(command, ...)
    if command == "load" then
        local filename = ...
        cmdLoad(filename)
    elseif command == "dump" then
        cmdDump("dump")
    elseif command == "client" then
        cmdClient()
    else
        print("Unknown command: "..command)
    end
end

main(...)

