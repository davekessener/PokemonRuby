module Pokemon
	class Window < Gosu::Window
		def initialize
			super(*Utils::WINDOW_SIZE)
			$input = Input::System.new
#			$ui = UI::System.new

			@fps = 0
		end

		def needs_cursor?
			true
		end

		def update
			delta = calculate_delta

#			$ui.update(delta)
			@scene.update(delta)

			update_fps
		end

		def draw
			Utils::scale_screen do
#				$ui.draw
			end

			@scene.draw if @scene
		end

		def button_down(id)
			$input.down(Utils::button_id(id))
		end

		def button_up(id)
			$input.up(Utils::button_id(id))
		end

		def switch_scene(scene)
			@scene.exit if @scene
			@scene = scene
			@scene.enter
		end

		private
		
		def calculate_delta
			now = Utils::now
			delta = now - (@last || 0)
			@last = now
			delta
		end

		def update_fps
			fps = Gosu::fps
			if fps != @fps
				@fps = fps
				self.caption = "#{Utils::TITLE} [#{@fps} FPS]"
			end
		end
	end
end

