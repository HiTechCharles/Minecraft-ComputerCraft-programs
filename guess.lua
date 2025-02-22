print("Guess-A-Number by Charles Martin")

io.write("\nHow high can the number go?  ")
hi=io.read()
HighNum = tonumber(hi)
math.randomseed(os.time())
number = math.random(1,HighNum)
Guess=0
Tries=0
print("")

print("Guess a number between 1 and " ..HighNum)
while ( Guess ~= number ) do
	Tries=Tries+1
	io.write("\nTry #"..Tries..":  ")
	gs = io.read()
	Guess = tonumber(gs)
	 if ( Guess > number ) then
    print("Too high")
  elseif ( Guess < number) then
    print("Too low")
  else
    print("That's right!")
    os.exit()
  end
end
  
