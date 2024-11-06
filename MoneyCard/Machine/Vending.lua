function file_exists(name)  --see if file exists
    local f=io.open(name,"r")  --open file for reading
    if f~=nil then io.close(f) return true else return false end
end

function MPrint (Line, Text)  --print on a specific monitor line
    Mon.setCursorPos(1, Line)
    Mon.write(Text)
end

function LoadCard ()  --get card name pin and balance
	f = io.open(CardLocation, "r")  --open file for reading 
	Name=f.read(f)  --read data name, pin, money 
	Pin=f.read(f)
	Pin=Pin+0
	DM=f.read(f)
	Money=DM / Pin
	io.close(f)  --close file 
end

function SaveCard () --save current balance to card 
    f=io.open(CardLocation, "w")
    f.write(f, Name.."\n")
    f.write(f, Pin.."\n")
    f.write(f, Money*Pin.."\n")
	io.close(f)
end

function ShowBalance (Period) --show current bank balance, Period is string to put next to balance 
    print("\n"..Period.." balance for "..Name)
    print("$"..Money)
    cb.sendMessage(Period.." balance for "..Name.." is $"..Money, "Financial", "[]", "", 7)  --put balance in chat only nearby players get it 
end 

function GetNumber (Low, High)  --get number in a certain range
    C=0
	C=io.read()  --read a number 
    C=C+0  --ensure number is numeric CC tweaked doesn't have *n read formatter
     if (C < Low) or (C > High) then  --if out of range, try again
        print("Invalid Choice, Range is "..Low.." to "..High.."\n")
        GetNumber(Low,High)
    else
        return C  --return valid choice
    end 
end

function SellItems ()  --sell a particular item, deduct money then hand over the goods
	term.clear()
	term.setCursorPos(1,1)
	ShowBalance("Beginning")  --show current balance 
	print()
	print("This Vending machine sells:")  --each machine sells one item
	print("1 "..ItemName.." for $"..ItemPrice)
	print()
	print("How many "..ItemName.." would you like?  (0 to 64)")
	QTYSelected = GetNumber (0, 64)  --get number to purchase 
	
	if QTYSelected == 0 then  --if 0 items selected 
		print("\Cancelling sale")
		ShowBalance("ending")
		return
	else
		TotalPrice=ItemPrice*QTYSelected  --total cost of items 
		print()
		print(QTYSelected.." "..ItemName.." will cost $"..TotalPrice)  --print qty and price 
		
		if Money - TotalPrice < 0 then   --if money is too low 
			print("\nThere is not enough funds for this")
			print("transaction.  You are short by $"..math.abs(TotalPrice-Money))
			ShowBalance("ending")  --show end balance (no change)
			return 
		else	  --there's enough money, complete the sale 
			Money=Money-TotalPrice  --deduct cost of items 
			ShowBalance("ending")  --show new balance 
			SaveCard()  --save new balance 
			t=io.open("disk/Statement", "a")  --append to statement file 
			t.write(t, QTYSelected.." "..ItemName.." - $"..TotalPrice.."\n")
			io.close(t)
			RS="redstone pulse bottom "..QTYSelected  --dispense items 
			shell.run(RS)
		end
	end
end 

function GetVendingItem ()  --read an item and price from file to sell 
	v=io.open("itemtoSell", "r")
	ItemName=v.read(v)
	ItemPrice=v.read(v)
	itemPrice=ItemPrice+0  --ensure numeric 
end

GetVendingItem()

CardLocation="disk/CardInfo"  --card information file path
Mon=peripheral.wrap("top")  --connect monitor 
Mon.setCursorPos(1,1)  --set cursor top left 
Mon.setTextScale(2)  --font size of monitor 
Mon.clear()  --clear screen 
MPrint(1, ItemName)
MPrint(2, "1 for $"..ItemPrice)

d=peripheral.wrap("left")  --access disk methods
cb=peripheral.wrap("right")  --chat box 
CardTries = 0  --number of attempts to access card
PinTries = 0  -- # of times asked to type pin
PinInput = 0  --for pin input after card loads 

term.clear()
term.setCursorPos(1,1)  --clear screen with top left cursor position
print("Welcome to Brew for You!")
print("Please insert your card")  --tell user what to do 

while file_exists(CardLocation) == false do  --if that file does not exist keep looping 
    print("\nHaving trouble accessing your card.")
    print("Make sure your card has been inserted")
    sleep(5)  --give time for the user to insert card 
    CardTries = CardTries + 1 -- count attempts  

    if CardTries == 4 then   --really 5
        print("\nNot able to work with the card,")
        print("returning it to you.")
        sleep(2)  
        d.ejectDisk()  --eject card 
        shell.run("shutdown")  --turn off pc 
    end
end            

LoadCard()

while ( PinTries < 3 ) do  --3 chances to get it right 

    print("\nEnter PIN number:  ")
    PinInput=io.read()
	PinInput=PinInput+0
	
	if Pin == PinInput then  --got it correct 
		
		SellItems()
		d.ejectDisk()  --eject card 
        return  --exit loop 
    else
        PinTries = PinTries + 1  --count attempts 
        print("\nThe PIN number was incorrect.")
        if PinTries ==3 then 
            print("\nThree strikes, you're out!")
            shell.run("delete disk/CardInfo")  --delete card info file 
            textutils.slowPrint("ERASING CARD...  Done!")  --prints this line slower 
            d.ejectDisk()  --eject card 
            return  --exit loop 
        end  
    end
end