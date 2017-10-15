module Pokemon
	module Utils
		class Input
			def initialize
				@buttons = {}
				@pressed, @released = {}, {}
			end

			def down(id)
				@pressed[id] = true unless @buttons[id]
				@buttons[id] = true
			end

			def up(id)
				@released[id] = true if @buttons[id]
				@buttons[id] = false
			end

			def button_down?(id)
				@buttons[id]
			end

			def button_pressed?(id)
				r = @pressed[id]
				@pressed[id] = false
				r
			end

			def button_released?(id)
				r = @released[id]
				@released[id] = false
				r
			end

			def reset
				@buttons = {}
				@pressed, @released = {}, {}
			end
		end
	end
end

