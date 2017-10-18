module Pokemon
	module UI
		class System < Input::Callback
			def initialize
				@pool = Utils::ObjectPool.new
				@input = $input.create(:ui)

				@input << self
			end

			def update(delta)
				@pool.update(delta)
				
				if @active and @active.done?
					@active = nil
					@input.active = false
				end
			end

			def draw
				@pool.draw
			end

			def text_window(s)
				set_active(TextWindow.new(s, 1000, charset, border))
				@active
			end

			def border
				Border[:default]
			end

			def charset
				Charset[:default]
			end

			def down(input, id)
				@active.press(id) if @active
			end

			private

			def set_active(w)
				@active = w
				@pool << @active
				@input.active = true
			end
		end
	end
end

