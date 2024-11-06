--This program displays information and configuration of
--the computer.

print() --blank line
shell.run("id")  --computer id and label if set
print()
print ("Today is", os.date ("%A, %B %d, %Y  %H:%M" ))  --date & time
print()
shell.run("peripherals")  --shows connected devices
print()
 
