local Bank = dofile("BankCore.lua")

local drive = peripheral.wrap("left")
local cb = peripheral.wrap("right")

term.clear()
print("Welcome to the Disability Bank ATM")
print("Please insert your card")

-- Wait for card
local tries = 0
while not Bank.cardPresent() do
    sleep(0.5)
end

Bank.logEvent("CardInserted", "Card inserted into ATM")

-- Load card
local card, err = Bank.loadCard()
if not card then
    print("Error reading card: " .. err)
    Bank.logEvent("CardError", "ATM failed to read card: " .. err)
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
        Bank.showBalance(cb, card, "Your")
        Bank.logEvent("BalanceCheck", card.name .. " checked balance: $" .. card.money)
        drive.ejectDisk()
        Bank.logEvent("CardEjected", "ATM ejected card for " .. card.name)
        return
    end

    pinTries = pinTries + 1
    print("Incorrect PIN.")
    Bank.logEvent("PinFail", "Incorrect PIN for " .. card.name)

    if pinTries == 3 then
        print("Too many attempts. Erasing card.")
        Bank.logEvent("CardErased", "ATM erased card for " .. card.name)
        Bank.eraseCard()
        drive.ejectDisk()
        Bank.logEvent("CardEjected", "ATM ejected erased card")
        return
    end
end
