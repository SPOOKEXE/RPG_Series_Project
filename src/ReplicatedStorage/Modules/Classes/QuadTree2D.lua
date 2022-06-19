
-- // Point // --
local Point = { ClassName = 'Point' }
Point.__index = Point

function Point.New(Properties)

	local self = {
		x = 0,
		y = 0,
	}

	if typeof(Properties) == 'table' then
		for k,v in pairs(Properties) do
			self[k] = v
		end
	end

	setmetatable(self, Point)
	return self

end

function Point:Show( yLevel )
	local A = Instance.new('Attachment')
	A.WorldPosition = Vector3.new( self.x, yLevel, self.y )
	A.Visible = true
	A.Parent = workspace.Terrain
	return A
end

-- // Rectangle // --
local Rectangle = { ClassName = 'Rectangle' }
Rectangle.__index = Rectangle
function Rectangle.New( Properties )

	local self = {
		x = 0,
		y = 0,
		width = 0,
		height = 0,

		customColor = false,
	}

	if typeof(Properties) == 'table' then
		for k,v in pairs(Properties) do
			self[k] = v
		end
	end

	setmetatable(self, Rectangle)

	return self

end

function Rectangle:Intersects( _rectangle )

	return not (
		(_rectangle.x - _rectangle.width > self.x + self.width) or 
		(_rectangle.x + _rectangle.width < self.x - self.width)  or
		(_rectangle.y - _rectangle.height > self.y + self.height) or
		(_rectangle.y + _rectangle.height < self.y - self.height)
	)

end

function Rectangle:Contains(_point)
	return
		(_point.x <= self.x + self.width)  and
		(_point.x >= self.x - self.width)  and
		(_point.y <= self.y + self.height) and
		(_point.y >= self.y - self.height)
end

function Rectangle:Show( yLevel )

	local locations = {
		Vector3.new(self.x + self.width, yLevel, self.y + self.height),
		Vector3.new(self.x - self.width, yLevel, self.y + self.height),
		Vector3.new(self.x - self.width, yLevel, self.y - self.height),
		Vector3.new(self.x + self.width, yLevel, self.y - self.height),
	}

	local instances = {}
	for i, v in ipairs(locations) do
		local A = Instance.new('Attachment')
		A.Name = i
		A.WorldPosition = v
		A.Visible = true
		A.Parent = workspace.Terrain
		table.insert(instances, A)
	end

	local col = ColorSequence.new(Color3.new(1,1,1))

	local lastAttachment = instances[#instances]
	for _, attachment in ipairs(instances) do
		if lastAttachment then
			local b = Instance.new('Beam')
			b.Color = self.customColor or col
			b.FaceCamera = true
			b.Attachment0 = attachment
			b.Attachment1 = lastAttachment
			b.LightEmission = 1
			b.LightInfluence = 0
			b.Width0 = 0.5
			b.Width1 = 0.5
			b.Parent = workspace.Terrain
		end
		lastAttachment = attachment
	end

	return instances

end

-- // QuadTree // --
local quadTreeCapacity = 4

local QuadTree = {}
QuadTree.__index = QuadTree
function QuadTree.New( Properties )

	local b = Instance.new('BindableEvent')
	b.Name = tick()
	b.Parent = script

	local self = {
		boundary = Rectangle.New(),

		capacity = quadTreeCapacity,
		points = {},

		divide = false,
		northeast = nil,
		northwest = nil,
		southeast = nil,
		southwest = nil,

		update = b
	}

	if typeof(Properties) == 'table' then
		for k,v in pairs(Properties) do
			self[k] = v
		end
	end

	setmetatable(self, QuadTree)
	return self

end

function QuadTree:Subdivide()

	local x = self.boundary.x
	local y = self.boundary.y
	local w = self.boundary.width
	local h = self.boundary.height

	self.northeast = QuadTree.New({
		boundary = Rectangle.New({
			x = x + w/2,
			y = y - h/2,
			width = w/2,
			height = h/2,
		}),
		capacity = self.capacity,
	})

	self.northwest = QuadTree.New({
		boundary = Rectangle.New({
			x = x - w/2,
			y = y - h/2,
			width = w/2,
			height = h/2,
		}),
		capacity = self.capacity,
	})

	self.southeast = QuadTree.New({
		boundary = Rectangle.New({
			x = x + w/2,
			y = y + h/2,
			width = w/2,
			height = h/2,
		}),
		capacity = self.capacity,
	})

	self.southwest = QuadTree.New({
		boundary = Rectangle.New({
			x = x - w/2,
			y = y + h/2,
			width = w/2,
			height = h/2,
		}),
		capacity = self.capacity,
	})

	self.divide = true

end

function QuadTree:Insert( _shape )

	if not self.boundary:Contains( _shape ) then
		return false
	end

	if #self.points < self.capacity then
		table.insert(self.points, _shape)
		return true
	end

	if not self.divide then
		self:Subdivide()
	end

	if self.northeast:Insert(_shape) then
		return true
	elseif self.northwest:Insert(_shape) then
		return true
	elseif self.southeast:Insert(_shape) then
		return true
	elseif self.southwest:Insert(_shape) then
		return true
	end

end

function QuadTree:Query(_range, found_points)
	if not _range:Intersects(self.boundary) then
		return
	else
		for _, p in ipairs(self.points) do
			if (p.ClassName == 'Point' and _range:Contains(p)) or (p.ClassName == 'Rectangle' and _range:Intersects(p)) then
				table.insert(found_points, p)
			end
		end
		if self.divide then
			self.northwest:Query(_range, found_points)
			self.northeast:Query(_range, found_points)
			self.southwest:Query(_range, found_points)
			self.southeast:Query(_range, found_points)
		end
	end
	return found_points
end

function QuadTree:Show( yLevel )

	yLevel = (yLevel or 20)

	local instances = { }
	table.insert(instances, self.boundary:Show(yLevel))
	for _, point in ipairs( self.points ) do
		table.insert(instances, point:Show(yLevel))
	end
	if self.divide then
		table.insert(instances, self.northeast:Show(yLevel))
		table.insert(instances, self.northwest:Show(yLevel))
		table.insert(instances, self.southeast:Show(yLevel))
		table.insert(instances, self.southwest:Show(yLevel))
	end

	return instances

end

return {Rectangle = Rectangle, Point = Point, QuadTree = QuadTree}
