    Product = { }  --Product table 
      Price = { }  --item prices
 CurProduct = { } --products for current transaction
   CurPrice = { } --prices for purchased products
   CurItems = 0 --number of purchased items so far
   CurTotal = 0  --total for current sale
NumProducts = 0  --number of products
 TotalSales = 0  --total sales
  ItemsSold = 0  --total items sold
 TotalTrans = 0  --total number of sales 
       Code = 0  --number input by user

function LoadProducts()  --loads product names and prices 

    ItemsHandle = io.input("items")  --open file 
    
    for i = 1,15 do    --loop for each line 
        line = io.read()  --read a line from the file
        Name, Cost = line:match("([^,]+),([^,]+)")   --split line at comma
        NumProducts = NumProducts + 1   --total products 
        table.insert(Product, i, Name)  --add names to table	
        table.insert(Price, i, Cost)    --add prices to table
    end
    io.close(ItemsHandle)  --close file 
end

function ClearTrans()  --start a new sale, resets variables
    for i = 1, CurItems do  --remove all items from 'current' tables 
        table.remove(CurPrice, i )  
        table.remove(CurProduct, i )
    end
    
    CurItems=0   --selected items
    CurTotal=0   
	
	term.clear()  --show user keyboard help
	term.setCursorPos(1,1)
	print(CashierName..", Use the following to perform actions:")
	print("Product Codes - 1 to 15, Start Over - 16,")
 print("Finish sale - 17, See Today's Sales - 18,")
 print("Close up the shop - 19")
end

function GetNumber()   --gets a number from the keyboard 
    term.setCursorPos(30,4)
    term.write("ENTER A CODE:  ")  
    Code=tonumber(read())  --take input 
    if Code <1 or Code > 19 then   --out of range
        GetNumber()  --rerun function 
    elseif Code > 0 and Code < 16 then  --range 1-15 for products
        AddItem()  --add item chosen to current sale tables 
    elseif Code == 16 then   --reset sale 
        ClearTrans()
    elseif Code == 17 then
        FinishTrans()  --get customer payement and display change
    elseif Code== 18 then
        ShowSales()  --shows stats for today 
    elseif Code== 19 then
        CloseShop()  --show stats and ends program
    end
    GetNumber()
end        

function AddItem()  --add item chosen to tables 
    CurItems = CurItems + 1  --increment items 
    table.insert(CurProduct, CurItems, Product[Code])
    table.insert(CurPrice, CurItems, Price[Code])
    CurTotal = CurTotal + Price[Code]  --keep running total
    term.setCursorPos(1,6)
    ShowReceipt()  --show items and totals
end

function ShowReceipt ()  --print receipt for current sale
    if CurItems ==0 then
        return 0
    end
    print("CURRENT SALE:  ", CurItems, "items for $"..CurTotal, "        ")
    for i = 1, CurItems do  --print table items 
        print(CurProduct[i], " $", CurPrice[i])
    end
end

function FinishTrans ()  --get customer payment and change 
    if CurItems ==0 then
        term.setCursorPos(1,6)
		print("Add items first, then try again!")
        sleep(3)
        return 0
    end
          term.clear()
    term.setCursorPos(1,1)
    ShowReceipt()
    print()
    print("How much money is the customer giving you?  ")
    CustPayment=tonumber(read())  --get customer payment 
    Change=CustPayment - CurTotal  --compute change 
    print()
    print("The customer's change is $"..Change)	TotalSales = TotalSales + CurTotal  --add current sales to total 
    ItemsSold=ItemsSold + CurItems  --ttl items sold 
    TotalTrans = TotalTrans + 1  --# of customers 
    print()
    print("Press ENTER to start a new sale!")
    Code=read()
      
   	ClearTrans()  --start new sale 
end   

function ShowSales() --show stats 
 	if ItemsSold == 0 then
	    	term.setCursorPos(1,6)
    		print ("No sales yet!  Hustle!          ")
    		return 0
	end
    term.setCursorPos(1,6)
    print ("TOTALS SO FAR:")
    print("       Cashier:  ",CashierName)
    print("  Transactions:  ",TotalTrans)      
    print("    Items Sold:  ",ItemsSold)
    print("         Sales:  ",TotalSales)
    print()
    print("Press ENTER to continue!")
    Code=read()
    ClearTrans()
end

function CloseShop()
    term.clear()
    ShowSales()
    cb=peripheral.wrap("bottom")
    cb.sendMessage("Brew for you is now closed.","Attention")
    shell.run("shutdown")
end

----------------- ENTRYPOINT -----------------

LoadProducts()  --load products and prices to tables
print("     Brew for You Point of Sale")
print()
term.write("What's your name?  ")  --get cashier name
CashierName=read()
ClearTrans()
GetNumber()
