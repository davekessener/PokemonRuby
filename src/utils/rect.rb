module Pokemon
	module Utils
		class Rect
			attr_reader :x0, :y0, :x1, :y1

			def initialize(x0, y0, x1, y1)
				@x0, @y0 = [x0, x1].min, [y0, y1].min
				@x1, @y1 = [x0, x1].max, [y0, y1].max
			end

			def width
				@x1 - @x0
			end

			def height
				@y1 - @y0
			end

			def overlap?(r)
				return false if x0 >= r.x1 or r.x0 >= x1
				return false if y0 >= r.y1 or r.y0 >= y1
				true
			end
		end
	end
end

