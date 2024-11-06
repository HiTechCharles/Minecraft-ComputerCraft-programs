ItemsHandle = io.input("items")  --open file for reading
MenuHandle = io.open("ProductMenu", "w")
ProductHandle= io.open("ProductCodes", "w") -- product codes


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
 
MenuHandle.write(MenuHandle, " Brew for You - 2023 Menu\n\n")
ProductHandle.write(ProductHandle, "       BFY Product Codes\n")
MenuHandle.write(MenuHandle, "  Items include 6% MI tax\n")
MenuHandle.write(MenuHandle, "   Cash, card,  Apple Pay\n\n")

for i=1, 15  do  --for each item 
    MenuHandle.write(MenuHandle, Product[i]) --print product #, name, price
    ProductHandle.write(ProductHandle, Product[i])
    MenuHandle.write(MenuHandle ,"  $")
    ProductHandle.write(ProductHandle, " - ")
    MenuHandle.write(MenuHandle, Price[i])
    ProductHandle.write(ProductHandle, i)
    MenuHandle.write(MenuHandle, "\n")
    ProductHandle.write(ProductHandle, "\n")
end
io.close(MenuHandle)

ProductHandle.write(ProductHandle, "Clear Current Sale - 16\n")
ProductHandle.write(ProductHandle, " Finalize the Sale - 17\n")
ProductHandle.write(ProductHandle, "Obtain Sales Stats - 18\n")
ProductHandle.write(ProductHandle, " Close up the shop - 19")
io.close(ProductHandle)

shell.run("edit ProductMenu")
shell.run("edit ProductCodes")
