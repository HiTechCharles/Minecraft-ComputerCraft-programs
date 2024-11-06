d=peripheral.wrap("left")
cb=peripheral.wrap("right") 

CardTries = 0 --number of times tried to read card
Pin = 0  --make sure pin number loaded is numeric
Pin1 = 0  --when asking for pin, makes sure both
Pin2 = 0  --entries are equal
Money = 0 --how much money to put on card

term.clear()
term.setCursorPos(1,1)
print("Welcome to the Disability Bank")
print("Please insert your card")

while d.isDiskPresent == false do
    print("\nHaving trouble accessing your card.")
    print("Make sure your card has been inserted")
    sleep(5)
    CardTries = CardTries + 1

    if CardTries == 4 then 
        print("\nNo card detected, exiting.")
    end
end            

f = io.open("disk/CardInfo", "w")

print("\nWhat is your name?")
Name=io.read()

print("\nHow much money do you want to start with?")
Money = io.read()

while true do
    print("\nPlease select a PIN number for your new card")
    Pin1=io.read()

    print ("\nConfirm the new PIN number")
    Pin2=io.read()

    if Pin1==Pin2 then
        f=io.open("disk/CardInfo", "w")
        f.write(f, Name.."\n")
        f.write(f, Pin1.."\n")
        f.write(f, Money*Pin1.."\n")
        rednet.open("back")
		CurDate=os.date("%D %r")  --06/13/1983 08:05:44 PM  date and time 
		DisplayString = Name.." has an updated card containing $"..Money
		LogString = CurDate.." | "..Name.." has an updated card containing $"..Money
		cb.sendMessage(DisplayString , "Financial", "[]", "", 7)
		rednet.send(1, LogString)
        print(DisplayString)
		f.close(f )
        return
     end
end