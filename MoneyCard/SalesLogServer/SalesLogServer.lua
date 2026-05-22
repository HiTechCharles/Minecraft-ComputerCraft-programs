--SalesLogServer.lua
-- Central logging server for vending purchases

local LOG_FILE = "SalesMasterLog"
local PROTOCOL = "SalesLog"

-- Detect and open modem
local function openModem()
    local sides = {"left","right","top","bottom","front","back"}
    for _, side in ipairs(sides) do
        if peripheral.getType(side) == "modem" then
            if not rednet.isOpen(side) then
                rednet.open(side)
            end
        end
    end
end

openModem()

-- Detect monitor
local mon = nil
do
    local sides = {"left","right","top","bottom","front","back"}
    for _, side in ipairs(sides) do
        if peripheral.getType(side) == "monitor" then
            mon = peripheral.wrap(side)
            break
        end
    end
end

if not mon then
    print("No monitor found. Logging to file only.")
else
    mon.setTextScale(1)
    mon.clear()
end

-- Read existing log file into memory (for display)
local logLines = {}

if fs.exists(LOG_FILE) then
    local f = fs.open(LOG_FILE, "r")
    local line = f.readLine()
    while line do
        table.insert(logLines, line)
        line = f.readLine()
    end
    f.close()
end

-- Write a new line to the log file
local function appendToFile(text)
    local f = fs.open(LOG_FILE, "a")
    f.writeLine(text)
    f.close()
end

-- Draw log lines on monitor
local function redrawMonitor()
    if not mon then return end

    mon.clear()
    local w, h = mon.getSize()

    -- Show only the last h lines
    local start = math.max(1, #logLines - h + 1)
    local lineNum = 1

    for i = start, #logLines do
        mon.setCursorPos(1, lineNum)
        mon.write(logLines[i]:sub(1, w)) -- truncate long lines
        lineNum = lineNum + 1
    end
end

-- Initial draw
redrawMonitor()

print("Sales Logging Server running...")
print("Waiting for messages...")

-- Main loop
while true do
    local sender, msg, protocol = rednet.receive(PROTOCOL)

    if type(msg) == "table" then
        local line = string.format("[%s] (%s) %s",
            msg.time or "unknown",
            msg.type or "Event",
            msg.msg or ""
        )

        table.insert(logLines, line)
        appendToFile(line)
        redrawMonitor()

        print(line)
    end
end
