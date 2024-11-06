Mon = peripheral.wrap("back")  --connect monitor
Mon.setBackgroundColor(colors.black) 
Mon.setTextColor(colors.red)
Mon.clear() 
Mon.setCursorPos(1,1) --set cursor position top left 
Mon.setTextScale(5.3)  --font size of monitor 

function MPrint (Line, Text)
    Mon.setCursorPos(1, Line)
    Mon.write(Text)
end

MPrint (1, "- Brew for You -" )
Mon.setTextColor(colors.white )
MPrint (3, "serving up super" )
MPrint (4, "coffee & snacks " )
MPrint (5, "since Sept 2007 " )
MPrint (7, "4082 W Vienna Rd" )
MPrint (8, "Clio, MI  48420"  )

print("\nBrew for you Sign on back monitor")
