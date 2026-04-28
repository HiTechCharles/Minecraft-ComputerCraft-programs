local Bank = dofile("BankCore.lua")

local drive = peripheral.wrap("left")
local cb = peripheral.wrap("right")
local mon = peripheral.wrap("top")

-- Load vending item
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

-- Wait for card
while not Bank.cardPresent() do
    sleep(0.5)
end

Bank.logEvent("CardInserted", "Card inserted into vending machine")

-- Load card
local card, err = Bank.loadCard()
if not card then
    print("Error reading card: " .. err)
    Bank.logEvent("CardError", "Vending failed to read card: " .. err)
    drive.ejectDisk()
    return
end

-- PIN entry
local pinTries = 0
while pinTries < 3 do
    print("\nEnter PIN:")
    local pin = read()

    Bank.logEvent("PinAttempt", "PIN attempt for " .. card.name)

    if Bank.verifyPin(card, pin) then
        Bank.logEvent("PinSuccess", "Correct PIN for " .. card.name)
        break
    end

    pinTries = pinTries + 1
    print("Incorrect PIN.")
    Bank.logEvent("PinFail", "Incorrect PIN for " .. card.name)

    if pinTries == 3 then
        print("Too many attempts. Erasing card.")
        Bank.logEvent("CardErased", "Vending erased card for " .. card.name)
        Bank.eraseCard()
        drive.ejectDisk()
        Bank.logEvent("CardEjected", "Vending ejected erased card")
        return
    end
end

-- Sell items
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
    Bank.logEvent("SaleCancelled", card.name .. " cancelled purchase")
    drive.ejectDisk()
    Bank.logEvent("CardEjected", "Vending ejected card for " .. card.name)
    return
end

local total = qty * ITEM_PRICE
print("\nTotal cost: $" .. total)

if card.money < total then
    print("\nInsufficient funds. Short by $" .. (total - card.money))
    Bank.logEvent("InsufficientFunds", card.name .. " attempted purchase but lacked $" .. (total - card.money))
    drive.ejectDisk()
    Bank.logEvent("CardEjected", "Vending ejected card for " .. card.name)
    return
end

local ok, msg = Bank.debit(card, total)
if not ok then
    print("Error debiting card: " .. msg)
    Bank.logEvent("DebitError", "Debit failed for " .. card.name .. ": " .. msg)
    drive.ejectDisk()
    return
end

Bank.logEvent("Purchase", card.name .. " bought " .. qty .. "x " .. ITEM_NAME .. " for $" .. total)

Bank.logStatement(qty .. " " .. ITEM_NAME .. " - $" .. total)

shell.run("redstone", "pulse", "bottom", tostring(qty))

print("\nSale complete!")
print("Ending balance: $" .. card.money)

drive.ejectDisk()
Bank.logEvent("CardEjected", "Vending ejected card for " .. card.name)
