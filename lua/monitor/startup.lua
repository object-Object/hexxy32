local pixelbox = require("pixelbox_lite")

local MONITOR = "top"
local IO_PORT = "focal_port_5"
local MEMORY_1 = "focal_port_6"
local MEMORY_2 = "focal_port_7"

local PAGE_WORDS = 512
local PAGE_BYTES = 4 * PAGE_WORDS

-- https://monitorsize.madefor.cc/
local TEXT_SCALE = 2
local WIDTH = 64
local HEIGHT = 48
local X_OFFSET = 9
local Y_OFFSET = 6

---@param name string | ccTweaked.peripheral.computerSide
---@return ccTweaked.peripheral.Monitor
local function getMonitor(name)
    local p = peripheral.wrap(name)
    assert(p ~= nil and peripheral.hasType(p, "monitor"), "Monitor not found: "..name)
    ---@cast p ccTweaked.peripheral.Monitor
    return p
end

---@param name string | ccTweaked.peripheral.computerSide
---@return FocalPort
local function getFocalPort(name)
    local p = peripheral.wrap(name)
    assert(p ~= nil and peripheral.hasType(p, "focal_port"), "Focal port not found: "..name)
    ---@cast p FocalPort
    return p
end

---@param ... FocalPort
local function readMemory(...)
    ---@type number[]
    local result = {}

    for _, port in ipairs({...}) do
        local data = port.readIota()
        assert(type(data) == "table" and #data == PAGE_WORDS)

        for _, word in ipairs(data) do
            assert(type(word) == "number")

            for field = 24, 0, -8 do
                local byte = bit32.extract(word, field, 8)
                table.insert(result, byte)
            end
        end
    end

    return result
end

---@param byte number
local function byteToColor(byte)
    assert(0 <= byte and byte <= 255, "Invalid color: "..tostring(byte))
    return byte / 255
end

local function main()
    local monitor = getMonitor(MONITOR)
    local ioPort = getFocalPort(IO_PORT)
    local memory1 = getFocalPort(MEMORY_1)
    local memory2 = getFocalPort(MEMORY_2)

    monitor.setTextScale(TEXT_SCALE)

    local box = pixelbox.new(monitor)
    assert(
        box.width >= WIDTH + X_OFFSET and box.height >= HEIGHT + Y_OFFSET,
        "Invalid box size: "..tostring(box.width).."x"..tostring(box.height)
    )

    box:clear()
    box:render()

    while true do
        local portValue = ioPort.readIota()
        if type(portValue) == "number" and portValue ~= 0 then
            local data = readMemory(memory1, memory2)

            -- bit 0: update buffer
            if bit32.extract(portValue, 0) == 1 then
                for y = 1, HEIGHT do
                    for x = 1, WIDTH do
                        local byte = data[(y - 1) * WIDTH + x]
                        assert(0 <= byte and byte <= 15, "Invalid pixel: "..tostring(byte))
                        box.canvas[y + Y_OFFSET][x + X_OFFSET] = 2^byte
                    end
                end
            end

            -- bit 1: update palettes
            if bit32.extract(portValue, 1) == 1 then
                for color = 0, 15 do
                    local i = color * 3 + 1
                    monitor.setPaletteColor(
                        2^color,
                        byteToColor(data[i]),
                        byteToColor(data[i + 1]),
                        byteToColor(data[i + 2])
                    )
                end
            end

            box:render()

            -- reset the port so we don't read it again next tick (unless the processor sets it again)
            ioPort.writeIota(0)
        else
            sleep(0)
        end
    end
end

main()
