module Pokemon
	class Camera
		attr_accessor :following

		def initialize(object)
			@following = object
		end

		def offset
			if block_given?
				dx, dy = *calc_offset
				w, h = Utils::screen_width / 2, Utils::screen_height / 2
				Gosu::translate(w - dx, h - dy) do
					yield Utils::Viewport.new(dx - w, dy - h, Utils::screen_width, Utils::screen_height)
				end
			end
		end

		private

		def calc_offset
			if @following
				[@following.x + @following.width / 2, @following.y + @following.height / 2]
			else
				[0, 0]
			end
		end
	end
end

