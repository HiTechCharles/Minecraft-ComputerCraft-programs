function LoadCard ()  --get card name pin and balance
	f = io.open(CardLocation, "r")  --open file for reading 
	Name=f.read(f)  --read data name, pin, money 
	Pin=f.read(f)
	Pin=Pin+0
	DM=f.read(f)
	Money=DM / Pin
	io.close(f)  --close file 
end

rednet.open("back")
term.clear()
term.setCursorPos(1,1)
local i = 0
local TotalLines = 0
for line in io.lines("disk/Statement") do
    print(line)
    i = i + 1
    TotalLines=TotalLines+1
    if i/17==1 then
        term.write("---------- PRESS ENTER FOR MORE ----------")
        io.read()
        term.clear()
        term.setCursorPos(1,1)
        I=0
    end    
end
CardLocation = "disk/CardInfo"
LoadCard() 
print("Total lines in file:  "..TotalLines)
print("\n")
CurDate=os.date("%D %r")  --06/13/1983 08:05:44 PM  date and time 
LogString=CurDate.." | "..Name.." checked statement containing "..TotalLines.." entries\n"
rednet.send(1, LogString)
 
