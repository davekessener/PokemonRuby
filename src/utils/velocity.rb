module Pokemon
	module Utils
		class Velocity
			def initialize(speed)
				@speed = speed
				@left = speed - speed
			end

			def calculate(delta)
				d = (@speed * delta) + @left
				@left = d % 1000
				d / 1000
			end

			def dup
				Velocity.new(@speed)
			end

			def to_s
				@speed.to_s
			end
		end
	end
end

