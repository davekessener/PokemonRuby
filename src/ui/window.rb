module Pokemon
	module UI
		class Window < GameObject
			attr_reader :x, :y, :z
			attr_reader :width, :height

			def initialize(x, y, w, h, z, border)
				super()
				@x, @y, @z = x, y, z
				@width, @height = w, h
				BorderRenderer.new(self, border)
			end

			def done?
				true
			end

			def press(id)
			end
		end

		class BorderRenderer < Component
			def initialize(object, border)
				super(object)
				@border = border
			end

			def draw
				@border.draw(object.x, object.y, object.width, object.height, object.z)
			end
		end

	end
end

