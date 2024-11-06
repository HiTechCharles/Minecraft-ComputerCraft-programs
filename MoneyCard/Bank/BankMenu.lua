function GetNumber (Low, High)  --get number in a certain range
    C=io.read()  --read a number 
    C=C+0  --ensure number is numeric CC tweaked doesn't have *n read formatter
     if (C < Low) or (C > High) then  --if out of range, try again
        print("Invalid Choice, Range is "..Low.." to "..High.."\n")
        GetNumber(Low,High)
    else
        return C  --return valid choice
    end 
end

Program = { }  --store program names to run for each menu option number 
table.insert(Program, 1, "CheckBalance")
table.insert(Program, 2, "DisplayTrans")
table.insert(Program, 3, "delete /disk/CardInfo")
table.insert(Program, 4, "NewCard")
table.insert(Program, 5, "shutdown")

term.clear()
term.setCursorPos(1,1)  --clear screen with top left cursor
print("Welcome to Disability bank!")
print("\nChoose from the following options:")
print("\n1 - Check Balance")
print("2 - Display Transactions")
print("3 - Erase")
print("4 - Update Information")
print("5 - Exit\n")
Choice=GetNumber(1,5)  --get a number 1-4

shell.run(Program[Choice])  --run program stored in table slot c
