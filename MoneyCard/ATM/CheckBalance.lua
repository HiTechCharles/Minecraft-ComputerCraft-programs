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

function ShowBalance()
	CurDate=os.date("%D %r")  --06/13/1983 08:05:44 PM  date and time 
	DisplayString = Name..", your balance as of\n"..CurDate.." is $"..Money
	LogString=CurDate.." | "..Name.." has a balance of $"..Money.."\n"
    print("\n"..DisplayString)
    cb.sendMessage(DisplayString, "Financial", "[]", "", 7)  --put balance in chat only nearby players get it 
	rednet.send(1, LogString)
end 

CardLocation="disk/CardInfo"  --card information file path
Mon=peripheral.wrap("top")  --connect monitor 
Mon.setCursorPos(1,1)  --set cursor top left 
Mon.setTextScale(5.3)
Mon.clear()  --clear screen 
MPrint(1, "A T M")

d=peripheral.wrap("left")  --access disk methods
cb=peripheral.wrap("right")  --chat box 
rednet.open("back")
CardTries = 0  --number of attempts to access card
PinTries = 0  -- # of times asked to type pin
PinInput = 0  --for pin input after card loads 

term.clear()
term.setCursorPos(1,1)  --clear screen with top left cursor position
print("Welcome to the Disability Bank ATM")
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
		
		ShowBalance()
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