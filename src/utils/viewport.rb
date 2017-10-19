module Pokemon
	module Utils
		class Viewport
			def initialize(x, y, w, h)
				@x, @y, @w, @h = x, y, w, h
				@rect = Rect.new(x, y, x + w, y + h)
			end

			def overlap?(object)
				@rect.overlap? Rect.new(object.x, object.y, object.x + object.width, object.y + object.height)
			end

			def upper_bound(l)
				[(@x + @w + l - 1) / l, (@y + @h + l - 1) / l]
			end

			def lower_bound(l)
				[@x / l, @y / l]
			end
		end
	end
end

