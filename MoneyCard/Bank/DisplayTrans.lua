local Bank = dofile("BankCore.lua")

local drive = peripheral.wrap("left")
local cb = peripheral.wrap("right")

term.clear()
term.setCursorPos(1,1)
print("=== Disability Bank — Transaction History ===")
print("Insert your card to continue")

-- Wait for card
while not Bank.cardPresent() do
    sleep(0.2)
end

-- Load card
local card, err = Bank.loadCard()
if not card then
    print("\nError reading card: " .. err)
    drive.ejectDisk()
    return
end

term.clear()
term.setCursorPos(1,1)
print("Transaction History for " .. card.name)
print("----------------------------------------")

-- Read statement file
local path = "disk/Statement"

if not fs.exists(path) then
    print("\nNo transactions found.")
    drive.ejectDisk()
    return
end

local f = fs.open(path, "r")
local line = f.readLine()
local count = 0

while line do
    print(line)
    count = count + 1
    line = f.readLine()
end

f.close()

if count == 0 then
    print("\nNo transactions recorded.")
else
	print ("Total transactions:  "..count)
end
os.sleep(count *2.5)

print("\n----------------------------------------")
print("End of statement.")
print("Returning your card.")

drive.ejectDisk()
