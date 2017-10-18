module Pokemon
	module Utils
		class Vec2
			attr_accessor :dx, :dy

			def initialize(dx, dy)
				@dx, @dy = dx, dy
			end

			def *(s)
				Vec2.new(@dx * s, @dy * s)
			end

			def /(s)
				Vec2.new(@dx / s, @dy / s)
			end

			def +(v)
				Vec2.new(@dx + v.dx, @dy + v.dy)
			end

			def -(v)
				Vec2.new(@dx - v.dx, @dy - v.dy)
			end

			def abs
				Vec2.new(@dx.abs, @dy.abs)
			end
		end
	end
end

