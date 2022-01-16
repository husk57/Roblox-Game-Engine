--[[
    Heightmap.lua

    Copyright © 2021 Caravel Creations
    All Rights Reserved
--]]

local BYTES_PER_NUMBER = 4 -- Using bit32, so we can only access 4 bytes.

local Heightmap = {}
Heightmap.__index = Heightmap

--[[
    A constructor for an empty heightmap.

    @param pixelWidth (number)
    @param height (number)
--]]
function Heightmap.new(pixelWidth, pixelHeight)

    -- Calculate byte size 
    local self = {}
    self.packedWidth = math.ceil(pixelWidth / BYTES_PER_NUMBER)
    local dataCollection = {}
    for x=1,pixelWidth do
      for y=1,pixelHeight do
        dataCollection[#dataCollection+1] = 0
      end
    end 
    self.pixelWidth = pixelWidth
    self.pixelHeight = pixelHeight
    self.buffer = dataCollection

    setmetatable(self, Heightmap)


    return self
end

--[[
    Returns the byte value of the heightmap at the given position.

    @param x (number) The x-coordinate in terms of pixels
    @param y (number) the y-coordinate in terms of pixels

    @returns (number) An integer height value between [0,255]
--]]
function Heightmap:GetPixel(x, y)

    -- Get location of packed coordinates in linear array
    local packedX = math.floor(x / BYTES_PER_NUMBER)
    local offsetX = x % BYTES_PER_NUMBER

    -- Get position in array and retreive number
    local value = self.buffer[y*self.packedWidth + packedX + 1]
    return bit32.extract(value, offsetX*8, 8)

end

--[[
    Sets the byte value of the heightmap at the given position.

    @param x (number) The x-coordinate in terms of pixels
    @param y (number) the y-coordinate in terms of pixels
--]]
function Heightmap:SetPixel(x, y, byteValue)

    -- Get location of packed coordinates in linear array
    local packedX = math.floor(x / BYTES_PER_NUMBER)
    local offsetX = x % BYTES_PER_NUMBER
    local indexOf = y*self.packedWidth + packedX + 1

    -- Get position in array and retreive number
    local value = self.buffer[indexOf]
    self.buffer[indexOf] = bit32.replace(value, byteValue, offsetX*8, 8)

end


return Heightmap