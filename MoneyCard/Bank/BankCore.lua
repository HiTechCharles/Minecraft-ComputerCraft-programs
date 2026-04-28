-- BankCore.lua
-- Unified banking API with salted SHA-256 PIN hashing
--Developed by HiTechCharles

local Bank = {}

-- =========================
-- CONFIG
-- =========================

Bank.CARD_PATH = "disk/CardInfo"
Bank.STATEMENT_PATH = "disk/Statement"

-- =========================
-- UTILITIES
-- =========================

local function file_exists(path)
    return fs.exists(path)
end

local function read_all_lines(path)
    local f = fs.open(path, "r")
    if not f then return nil end
    local lines = {}
    while true do
        local line = f.readLine()
        if not line then break end
        table.insert(lines, line)
    end
    f.close()
    return lines
end

local function write_lines(path, lines)
    local f = fs.open(path, "w")
    for _, l in ipairs(lines) do
        f.writeLine(l)
    end
    f.close()
end

-- =========================
-- SHA-256 (pure Lua, CC:Tweaked-friendly)
-- =========================

local bit = bit32
local band, bor, bxor = bit.band, bit.bor, bit.bxor
local rshift, rrotate, lshift = bit.rshift, bit.rrotate, bit.lshift
local bnot = bit.bnot

local function sha256(msg)
    local K = {
        0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,
        0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,
        0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,
        0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,
        0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,
        0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,
        0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,
        0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2
    }

    local function preproc(msg)
        local len = #msg
        local bitLen = len * 8

        msg = msg .. string.char(0x80)
        local padLen = (56 - (len + 1) % 64) % 64
        msg = msg .. string.rep("\0", padLen)

        local t = {}
        for i = 7, 0, -1 do
            t[#t+1] = string.char(band(rshift(bitLen, i*8), 0xff))
        end
        msg = msg .. table.concat(t)
        return msg
    end

    msg = preproc(msg)

    local h0 = 0x6a09e667
    local h1 = 0xbb67ae85
    local h2 = 0x3c6ef372
    local h3 = 0xa54ff53a
    local h4 = 0x510e527f
    local h5 = 0x9b05688c
    local h6 = 0x1f83d9ab
    local h7 = 0x5be0cd19

    for chunkStart = 1, #msg, 64 do
        local w = {}
        for i = 0, 15 do
            local b1 = string.byte(msg, chunkStart + i*4)
            local b2 = string.byte(msg, chunkStart + i*4 + 1)
            local b3 = string.byte(msg, chunkStart + i*4 + 2)
            local b4 = string.byte(msg, chunkStart + i*4 + 3)
            w[i] = bor(
                bor(lshift(b1, 24), lshift(b2, 16)),
                bor(lshift(b3, 8), b4)
            )
        end

        for i = 16, 63 do
            local s0 = bxor(rrotate(w[i-15], 7), rrotate(w[i-15], 18), rshift(w[i-15], 3))
            local s1 = bxor(rrotate(w[i-2], 17), rrotate(w[i-2], 19), rshift(w[i-2], 10))
            w[i] = band((w[i-16] + s0 + w[i-7] + s1), 0xffffffff)
        end

        local a,b,c,d,e,f,g,h = h0,h1,h2,h3,h4,h5,h6,h7

        for i = 0, 63 do
            local S1 = bxor(rrotate(e, 6), rrotate(e, 11), rrotate(e, 25))
            local ch = bxor(band(e, f), band(bnot(e), g))
            local temp1 = band((h + S1 + ch + K[i+1] + w[i]), 0xffffffff)
            local S0 = bxor(rrotate(a, 2), rrotate(a, 13), rrotate(a, 22))
            local maj = bxor(band(a, b), band(a, c), band(b, c))
            local temp2 = band((S0 + maj), 0xffffffff)

            h = g
            g = f
            f = e
            e = band((d + temp1), 0xffffffff)
            d = c
            c = b
            b = a
            a = band((temp1 + temp2), 0xffffffff)
        end

        h0 = band((h0 + a), 0xffffffff)
        h1 = band((h1 + b), 0xffffffff)
        h2 = band((h2 + c), 0xffffffff)
        h3 = band((h3 + d), 0xffffffff)
        h4 = band((h4 + e), 0xffffffff)
        h5 = band((h5 + f), 0xffffffff)
        h6 = band((h6 + g), 0xffffffff)
        h7 = band((h7 + h), 0xffffffff)
    end

    return string.format(
        "%08x%08x%08x%08x%08x%08x%08x%08x",
        h0,h1,h2,h3,h4,h5,h6,h7
    )
end

local function hash(str)
    return sha256(str)
end

-- =========================
-- BALANCE ENCODING
-- =========================

local function get_factor(salt)
    local hex = salt:gsub("[^0-9a-fA-F]", "")
    if #hex < 8 then
        hex = (hex .. "00000000"):sub(1, 8)
    else
        hex = hex:sub(1, 8)
    end
    local n = tonumber(hex, 16) or 1
    if n == 0 then n = 1 end
    return n
end

local function encode_balance(money, salt)
    local factor = get_factor(salt)
    return money * factor
end

local function decode_balance(encoded, salt)
    local factor = get_factor(salt)
    return encoded / factor
end

-- =========================
-- PUBLIC API
-- =========================

function Bank.cardPresent()
    return file_exists(Bank.CARD_PATH)
end

function Bank.loadCard()
    local lines = read_all_lines(Bank.CARD_PATH)
    if not lines or #lines < 4 then
        return nil, "Invalid card data"
    end

    local name = lines[1]
    local pinHash = lines[2]
    local salt = lines[3]
    local encoded = tonumber(lines[4])

    if not encoded then
        return nil, "Invalid balance encoding"
    end

    local money = decode_balance(encoded, salt)

    return {
        name = name,
        pinHash = pinHash,
        salt = salt,
        money = money
    }
end

function Bank.saveCard(card)
    local encoded = encode_balance(card.money, card.salt)
    local lines = {
        card.name,
        card.pinHash,
        card.salt,
        tostring(encoded)
    }
    write_lines(Bank.CARD_PATH, lines)
end

function Bank.initNewCard(name, pin, startingMoney)
    local salt = tostring(os.epoch("utc")) .. tostring(math.random(100000, 999999))
    local pinHash = hash(pin .. salt)
    local card = {
        name = name,
        pinHash = pinHash,
        salt = salt,
        money = startingMoney or 0
    }
    Bank.saveCard(card)
    return card
end

function Bank.verifyPin(card, pin)
    return card.pinHash == hash(pin .. card.salt)
end

function Bank.changePin(card, newPin)
    card.pinHash = hash(newPin .. card.salt)
    Bank.saveCard(card)
end

function Bank.debit(card, amount)
    if amount < 0 then return false, "Negative amount" end
    if card.money < amount then
        return false, "Insufficient funds"
    end
    card.money = card.money - amount
    Bank.saveCard(card)
    return true
end

function Bank.credit(card, amount)
    if amount < 0 then return false, "Negative amount" end
    card.money = card.money + amount
    Bank.saveCard(card)
    return true
end

function Bank.showBalance(cb, card, label)
    local msg = (label or "Current") .. " balance for " .. card.name .. " is $" .. card.money
    print("\n" .. msg)
    if cb then
        cb.sendMessage(msg, "Financial", "[]", "", 7)
    end
end

function Bank.logStatement(text)
    local f = fs.open(Bank.STATEMENT_PATH, "a")
    f.writeLine(text)
    f.close()
end

function Bank.eraseCard()
    if fs.exists(Bank.CARD_PATH) then
        fs.delete(Bank.CARD_PATH)
    end
end

-- =========================
-- REDNET LOGGING
-- =========================

-- Set this to the ID of your bank logging server
Bank.LOG_SERVER_ID = 6

-- Opens rednet automatically if possible
local function ensureRednet()
    if not rednet.isOpen() then
        -- Try common modem sides
        local sides = {"left","right","top","bottom","front","back"}
        for _, side in ipairs(sides) do
            if peripheral.getType(side) == "modem" then
                rednet.open(side)
                break
            end
        end
    end
end

-- Send a log message to the bank server
function Bank.logEvent(eventType, message)
    ensureRednet()

    if not rednet.isOpen() then
        -- No modem available — fail silently
        return
    end

    local timestamp = os.date("%D %r")
    local payload = {
        time = timestamp,
        type = eventType,
        msg = message
    }

    rednet.send(Bank.LOG_SERVER_ID, payload, "BankLog")
end

return Bank
