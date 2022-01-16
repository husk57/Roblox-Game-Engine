local heightMapLibrary = require("heightMap")
local imageData = require("source")
local dimensions = require("dimensions")

local rChannel = heightMapLibrary.new(dimensions[1], dimensions[2])

for y=1,dimensions[2] do
  for x=1,dimensions[1] do
    if x==1 and y==1 then
      print(imageData[y][x][1])
    end
    heightMapLibrary:SetPixel(x,y,imageData[y][x][1])
  end
end