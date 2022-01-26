local texture = {}
texture.__index = texture

function texture.new(imageSource)
	local meta = {}
	meta.data = require(imageSource)
	meta.width = #meta.data[1]
	meta.height = #meta.data
	
	return setmetatable(meta, texture)
end

function texture:sample(offset)
	local x = math.clamp(math.round(offset.X*self.width), 1, self.width)
	local y = math.clamp(math.round(offset.Y*self.height), 1, self.height)
	local tab = self.data[y][x]
	return Vector3.new(tab[1]/255, tab[2]/255, tab[3]/255)
end

return texture
