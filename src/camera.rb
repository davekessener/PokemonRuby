module Pokemon
	class Camera
		attr_accessor :following

		def initialize(object)
			@following = object
		end

		def offset
			if block_given?
				dx, dy = *calc_offset
				Gosu::translate(Utils::screen_width / 2 - dx, Utils::screen_height / 2 - dy) do
					yield Utils::Viewport.new(-dx, -dy, Utils::screen_width, Utils::screen_height)
				end
			end
		end

		private

		def calc_offset
			if @following
				[@following.x - @following.width / 2, @following.y - @following.height / 2]
			else
				[0, 0]
			end
		end
	end
end

