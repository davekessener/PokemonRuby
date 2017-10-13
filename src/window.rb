module Pokemon
	class Window < Gosu::Window
		attr_reader :scene

		def initialize(scene)
			super(*Utils::WINDOW_SIZE)
			@scene = scene
			@fps = 0
		end

		def needs_cursor?
			true
		end

		def update
			delta = calculate_step

			@scene.update(delta)

			update_fps
		end

		def draw
			@scene.draw
		end

		private

		def calculate_step
			now = Gosu::milliseconds
			delta = (now - (@last || 0))
			@last = now
			delta
		end

		def update_fps
			fps = Gosu::fps
			if @fps != fps
				@fps = fps
				self.caption = "#{Utils::TITLE} [#{@fps} FPS]"
			end
		end
	end
end

