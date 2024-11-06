Product menu with cash register function
by Charles Martin - April 5, 2023
Dependencies: Advanced Peripherals

DATA FILES
----------

items - stores the products and prices in CSV
format.  There is a limit of 15 products.
Example:  Coffee,2.00
          Yogurt,1.75

PROGRAMS
--------

MenuSign - prints products and prices on a 
monitor 3 wide by 3 high.

MakeFiles - creates two printable files:
 ProductMenu - contains product names and prices.
ProductCodes - shows codes for the register
after printing, both can be put into an item frame.

Register - ring up items and get change.
check the ProductCodes file for product numbers
after products 1-15,
16 - cancel current sale
17 - All done adding items
18 - sales stats
19 - close the shop

SETUP GUIDE
-----------

1. Computer setup:  chat box bottom, printer top,
   monitor back 3 wide and 3 high

2. edit the items file then add the products and
   prices you want.

3. run MakeFiles to get printable menu and 
   product codes files

4. run MenuSign to display the menu
   (this is done at computer startup)

5. run Register program to make sales.
