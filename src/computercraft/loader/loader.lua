local NUM_TX_CHUNKS = 32

local focalLink = assert(peripheral.wrap("top"), "Expected focal link on top of computer")
---@cast focalLink FocalLink

-- program args
local filename = ...

filename = "data/"..filename..".bin.json"
print("Loading data file: "..filename)

local f = assert(fs.open(filename, "r"), "Failed to open file: "..filename)
local contents = assert(f.readAll(), "Failed to read file: "..filename)
f.close()

local data = textutils.unserialiseJSON(contents)
assert(type(data) == "table", "Invalid file, expected table: "..filename)
assert(#data > 0, "Invalid file, expected array with at least one element: "..filename)

---@param luaIndex number
local function sendChunk(luaIndex)
    for i = luaIndex, luaIndex + NUM_TX_CHUNKS - 1 do
        if i > #data then break end
        print("Sending chunk: "..i.."/"..#data)
        focalLink.sendIota(0, {data[i], i - 1})
    end
end

local lastSuccessfulLuaIndex = 0

---@type { [string]: fun(...: any) }
local handlers = {
    received_iota = function()
        local hexIndex = focalLink.receiveIota() -- last index successfully written by the wisp
        if type(hexIndex) == "table" then
            pretty.pretty_print(hexIndex)
            print("Wisp reset, continuing from last successful chunk: "..lastSuccessfulLuaIndex.."/"..#data)
        elseif type(hexIndex) == "number" then
            lastSuccessfulLuaIndex = hexIndex + 1
            print("Wisp successfully wrote chunk: "..lastSuccessfulLuaIndex.."/"..#data)
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

-- main loop

if focalLink.numLinked() > 0 then
    focalLink.clearReceivedIotas()
    sendChunk(1)
else
    print("Waiting for wisp to connect...")
end

while lastSuccessfulLuaIndex < #data do
    handleEvent(os.pullEvent())
end

print("Done.")
