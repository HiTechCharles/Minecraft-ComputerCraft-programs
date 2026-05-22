-- =========================
-- SALES LOGGING (Sales Server ID 13)
-- =========================

local SALES_SERVER_ID = 13

local function SalesLog(eventType, message)
    if not rednet.isOpen() then
        local sides = {"left","right","top","bottom","front","back"}
        for _, side in ipairs(sides) do
            if peripheral.getType(side) == "modem" then
                rednet.open(side)
            end
        end
    end
    if not rednet.isOpen() then return end

    local payload = {
        time = os.date("%D %r"),
        type = eventType,
        msg = message
    }

    rednet.send(SALES_SERVER_ID, payload, "SalesLog")
end


-- =========================
-- BANK API
-- =========================

local Bank = dofile("BankCore.lua")

local drive = peripheral.wrap("left")
local cb = peripheral.wrap("right")
local mon = peripheral.wrap("top")


-- =========================
-- VENDING LOGGING WRAPPER
-- =========================

local Vending = {}

function Vending.LogEvent(eventType, card, details)
    local name = card and card.name or "Unknown"
    local msg = string.format("[Vending] %s | %s", name, details)
    SalesLog(eventType, msg)
end


-- =========================
-- LOAD ITEM INFO
-- =========================

local f = fs.open("itemtoSell", "r")
local ITEM_NAME = f.readLine()
local ITEM_PRICE = tonumber(f.readLine())
f.close()

mon.setTextScale(2)
mon.clear()
mon.setCursorPos(1, 1)
mon.write(ITEM_NAME)
mon.setCursorPos(1, 2)
mon.write("1 for $" .. ITEM_PRICE)

term.clear()
print("Welcome to Brew for You!")
print("Please insert your card")


-- =========================
-- WAIT FOR CARD
-- =========================

while not Bank.cardPresent() do
    sleep(0.2)
end

Vending.LogEvent("CardInserted", nil, "Card inserted into vending machine")


-- =========================
-- LOAD CARD
-- =========================

local card, err = Bank.loadCard()
if not card then
    print("Error reading card: " .. err)
    Vending.LogEvent("CardError", nil, "Failed to read card: " .. err)
    drive.ejectDisk()
    return
end

Vending.LogEvent("CardLoaded", card, "Card data loaded")


-- =========================
-- PIN ENTRY
-- =========================

local pinTries = 0
while pinTries < 3 do
    print("\nEnter PIN:")
    local pin = read()

    Vending.LogEvent("PinAttempt", card, "PIN attempt")

    if Bank.verifyPin(card, pin) then
        Vending.LogEvent("PinSuccess", card, "Correct PIN")
        break
    end

    pinTries = pinTries + 1
    print("Incorrect PIN.")
    Vending.LogEvent("PinFail", card, "Incorrect PIN")

    if pinTries == 3 then
        print("Too many attempts. Erasing card.")
        Vending.LogEvent("CardErased", card, "Card erased after 3 failed PIN attempts")
        Bank.eraseCard()
        drive.ejectDisk()
        Vending.LogEvent("CardEjected", card, "Card ejected after erase")
        return
    end
end


-- =========================
-- PURCHASE FLOW
-- =========================

print("\nCurrent balance: $" .. card.money)
print("\nThis machine sells:")
print("1 " .. ITEM_NAME .. " for $" .. ITEM_PRICE)
print("\nHow many would you like? (0–64)")


local function getNumber(low, high)
    while true do
        local n = tonumber(read())
        if n and n >= low and n <= high then
            return n
        end
        print("Invalid choice. Range: " .. low .. " to " .. high)
    end
end


local qty = getNumber(0, 64)

if qty == 0 then
    print("\nSale cancelled.")
    Vending.LogEvent("SaleCancelled", card, "User cancelled purchase")
    drive.ejectDisk()
    Vending.LogEvent("CardEjected", card, "Card ejected after cancellation")
    return
end


local total = qty * ITEM_PRICE
print("\nTotal cost: $" .. total)


-- =========================
-- CHECK FUNDS
-- =========================

if card.money < total then
    print("\nInsufficient funds. Short by $" .. (total - card.money))
    Vending.LogEvent("InsufficientFunds", card,
        "Attempted purchase of $" .. total .. " but only had $" .. card.money
    )
    drive.ejectDisk()
    Vending.LogEvent("CardEjected", card, "Card ejected after insufficient funds")
    return
end


-- =========================
-- DEBIT CARD
-- =========================

local ok, msg = Bank.debit(card, total)
if not ok then
    print("Error debiting card: " .. msg)
    Vending.LogEvent("DebitError", card, "Debit failed: " .. msg)
    drive.ejectDisk()
    return
end


-- =========================
-- LOG PURCHASE
-- =========================

Vending.LogEvent("Purchase", card,
    "Bought " .. qty .. "x " .. ITEM_NAME .. " for $" .. total
)

Bank.logStatement(qty .. " " .. ITEM_NAME .. " - $" .. total)


-- =========================
-- DISPENSE ITEM
-- =========================

shell.run("redstone", "pulse", "bottom", tostring(qty))


print("\nSale complete!")
print("Ending balance: $" .. card.money)


drive.ejectDisk()
Vending.LogEvent("CardEjected", card, "Card ejected after purchase")
