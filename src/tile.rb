module Pokemon
	module Tile
		class Static
			def initialize(img)
				@image = img
			end

			def draw(x, y, z)
				@image.draw(x, y, z) if @image
			end
		end

		class Animation
			def initialize(frames, period)
				@frames = frames
				@period = period
			end

			def draw(x, y, z)
				@frames[(Utils::now / @period) % @frames.size].draw(x, y, z) if @frames
			end
		end
	end
end

