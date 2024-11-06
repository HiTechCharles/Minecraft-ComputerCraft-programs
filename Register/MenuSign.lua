ItemsHandle = io.input("items")  --open file for reading

Product = { } --create empty product and price tables
  Price = { }
NumProducts = 0 --number of products in file

--can't figure out how to run until eof so i made it a 15 item list
for i = 1,15 do    --loop for each line 
line = io.read()  --read a line from the file
	
    Name, Cost = line:match("([^,]+),([^,]+)")   --split line at comma
    NumProducts = NumProducts + 1   --total products 
    table.insert(Product, i, Name)  --add names to table	
    table.insert(Price, i, Cost)    --add prices to table
end

io.close(ItemsHandle)  --close file 

--print all items on monitor 
mon=peripheral.wrap("back")  --connect screen
mon.clear()  
mon.setTextScale(1)  --font size
mon.setCursorPos(1,1) 
mon.write("   Welcome to Brew for You!   ")
mon.setCursorPos(1,3)
mon.write("----------- MENU -----------")
for i=1, 15  do  --for each item 
    mon.setCursorPos(1,i+4)  --set cursor pos 
    mon.write(Product[i]) --print product #, name, price
    mon.write(" - $")
    mon.write(Price[i])
end

print("Brew for You menu on back monitor.")  --tell terminal program done
