MoneyCard by HiTechCharles
April 15, 2026
Dependencies: Advanced Peripherals, cc-tweaked 

the MoneyCard system uses a floppy disk to store the following files:
     CardInfo:  stores name, balance, PIN, and Pin Hash
	 Statement - list of transactions

There are 3 types of computers that are used:
	ATM -  allows checking balance
	Setup:  Disk drive left, chatbox right, 
	wireless modem back, monitor top (3 wide)

	Bank - allows balance checking, transaction display,
	and card information creation & update
	Setup:  Disk drive left, chatbox right, 
	wireless modem back
	
	Vending:  sells items and deducts money from the card balance
	Setup:  Disk drive left, chatbox right, wireless
			modem back, monitor top
	

FILE COPY
after all computers are ready, files need to be copied to 
the desired machine.  In the package, there are 3 folders
ATM, Bank, and Vending.  copy the folder contents to appropriate computer.

Here is a file overview:

ATM			atm.lua, BankCore.lua, startup.lua
Bank		BankCore.lua, CardIssuer.lua, DisplayTrans.lua, 
			BankMenu.lua, startup.lua
Vending		vending.lua, BankCore.lua
			Also a file called ItemsToSell that contains:
			line 1:  item name  example banana bread
			line 2:  price example 1.75, no $ signs please
			
	
	