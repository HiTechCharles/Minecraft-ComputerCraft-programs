-- Safe numeric input function
local function GetNumber(low, high)
    while true do
        local input = tonumber(read())
        if input and input >= low and input <= high then
            return input
        end
        print("Invalid choice. Range is " .. low .. " to " .. high .. "\n")
    end
end

-- Menu options mapped to program names
local Program = {
    [1] = "atm",
    [2] = "DisplayTrans",
    [3] = "CardIssuer",
    [4] = "shutdown"
}

term.clear()
term.setCursorPos(1,1)
print("Welcome to Disability Bank!")
print("\nChoose from the following options:\n")
print("1 - Check Balance")
print("2 - Display Transactions")
print("3 - Update Information")
print("4 - Exit\n")

local choice = GetNumber(1, 4)

shell.run(Program[choice])
