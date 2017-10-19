module Pokemon
	module Velocity
		def initialize(speed)
			@speed = speed * 1000
			@left = speed - speed
		end

		def calculate(delta)
			d = (@speed * delta) + @left
			@left = d % 1000
			d / 1000
		end
	end
end

