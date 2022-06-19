local ITERATIONS = 8

local module = {}

function module.new(mass, force, damping, speed)
	local self = {
		Target = Vector3.new(),
		Position = Vector3.new(),
		Velocity = Vector3.new(),

		Mass = mass or 5,
		Force = force or 50,
		Damping    = damping or 4,
		Speed = speed  or 4,
	}

	function self.shove(_force)
		self.Velocity += _force
	end

	function self.update(dt)
		local scaledDeltaTime = math.min(dt, 1) * self.Speed / ITERATIONS

		for _ = 1, ITERATIONS do
			local iterationForce = self.Target - self.Position
			local acceleration = (iterationForce * self.Force) / self.Mass

			acceleration = acceleration - self.Velocity * self.Damping

			self.Velocity += acceleration * scaledDeltaTime
			self.Position += self.Velocity * scaledDeltaTime
		end

		return self.Position
	end
	return self
end

return module