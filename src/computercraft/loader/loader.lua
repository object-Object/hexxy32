local NUM_TX_CHUNKS = 60
local CHUNK_SIZE = 512

local data
local lastSuccessfulLuaIndex = 0

local focalLink = assert(peripheral.wrap("top"), "Expected focal link on top of computer")
---@cast focalLink FocalLink

---@param luaIndex number
---@return string
local function fmtChunk(luaIndex)
    return (luaIndex-1).." ("..luaIndex.."/"..#data..")"
end

---@param luaIndex number
local function sendChunk(luaIndex)
    if luaIndex > #data then return end

    local iotas = {}
    local endIndex = math.min(luaIndex + NUM_TX_CHUNKS - 1, #data)
    print("Preparing chunks: "..fmtChunk(luaIndex).." -> "..fmtChunk(endIndex))
    for i = luaIndex, endIndex do
        assert(#data[i] == CHUNK_SIZE, "Invalid chunk: expected "..CHUNK_SIZE.." elements but got "..#data[i])
        table.insert(iotas, {data[i], i - 1})
    end
    table.insert(iotas, {true})

    if focalLink.numLinked() == 0 then
        print("Wisp disconnected, waiting for wisp to reconnect...")
        return
    end

    print("Sending data.")
    local ok, err = pcall(focalLink.sendIota, 0, unpack(iotas))
    if not ok then print(err) end
end

---@type { [string]: fun(...: any) }
local handlers = {
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
}

---@param event string
---@param ... any
local function handleEvent(event, ...)
    local handler = handlers[event]
    if handler ~= nil then handler(...) end
end

local function main(command, ...)
    if command == "load" then
        local filename = ...
        filename = "data/"..filename..".bin.json"
        print("Loading data file: "..filename)

        local f = assert(fs.open(filename, "r"), "Failed to open file: "..filename)
        local contents = assert(f.readAll(), "Failed to read file: "..filename)
        f.close()

        print("Parsing data file...")
        data = textutils.unserialiseJSON(contents)
        assert(type(data) == "table", "Invalid file, expected table: "..filename)
        assert(#data > 0, "Invalid file, expected array with at least one element: "..filename)

        focalLink.clearReceivedIotas()
        if focalLink.numLinked() > 0 then
            sendChunk(1)
        else
            print("Waiting for wisp to connect...")
        end

        while lastSuccessfulLuaIndex < #data do
            handleEvent(os.pullEvent())
        end

        print("Done.")
    else
        print("Unknown command: "..command)
    end
end

main(...)

