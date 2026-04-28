local Bank = dofile("BankCore.lua")

local drive = peripheral.wrap("left")
local cb = peripheral.wrap("right")

term.clear()
term.setCursorPos(1,1)
print("=== Disability Bank — Card Issuer ===")
print("Insert a blank card to begin")

-- Wait for disk
while not drive.isDiskPresent() do
    sleep(0.2)
end

Bank.logEvent("CardInserted", "Blank card inserted into Card Issuer")

-- Ensure card is blank
if fs.exists(Bank.CARD_PATH) then
    print("\nThis card already contains data.")
    Bank.logEvent("CardIssuerError", "Attempted to issue card but card already had data")
    return
end

-- Collect user info
print("\nEnter customer name:")
local name = read()

local pin1, pin2
while true do
    print("\nEnter a new PIN:")
    pin1 = read("*")

    print("Confirm PIN:")
    pin2 = read("*")

    if pin1 == pin2 then
        break
    end

    print("\nPINs do not match. Try again.")
end

local money
while true do
    print("\nEnter starting balance:")
    local input = tonumber(read())
    if input then
        money = input
        break
    end
    print("Invalid number.")
end

-- Create card
local card = Bank.initNewCard(name, pin1, money)
Bank.logEvent("CardCreated", "Issued new card for " .. name .. " with $" .. money)

-- Label disk
drive.setDiskLabel("Debit card for " .. name)

-- Optional chatbox log
if cb then
    cb.sendMessage("Issued new card for " .. name .. " with $" .. money, "Financial", "[]", "", 7)
end

print("\nCard created successfully!")
print("Name: " .. name)
print("Balance: $" .. money)
print("PIN stored securely (hashed + salted).")

print("\nYou may now remove the card.")

Bank.logEvent("CardEjected", "Card Issuer completed card for " .. name)
