term.clear()
term.setCursorPos(1,1)
local i = 0
local TotalLines = 0
for line in io.lines(arg[1]) do
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

print("Total lines in file:  "..TotalLines)
print("\n")


