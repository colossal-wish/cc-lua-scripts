-- Coal Quarry Turtle

local stepsBetweenDrops = 20

local function flipRotation()
   turtle.turnLeft()
   turtle.turnLeft()
end

local function refuel()
   for i = 1, 16 do
	  local detail = turtle.getItemDetail(i)
	  if detail and detail.name:find("coal") then
		 turtle.select(i)
		 turtle.refuel(1)
	  end
   end
end

local function dumpCoal()
   for i = 1, 16 do
	  local detail = turtle.getItemDetail(i)
	  if detail and detail.name:find("coal") then
		 turtle.select(i)
		 turtle.drop()
	  end
   end
end

local function returnToChest(distance)
   flipRotation()
   for i = 1, distance do turtle.forward() end
   dumpCoal()
   flipRotation()
   for i = 1, distance do turtle.forward() end
end

local mined = 0
while true do
   if turtle.detect() then turtle.dig() end
   if turtle.forward() then
	  mined = mined + 1
	  refuel()
	  if mined % stepsBetweenDrops == 0 then
		 returnToChest(mined)
	  end
   else
	  if not turtle.dig() then break end
   end
end
