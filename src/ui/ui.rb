module Pokemon
	module UI
		class System < Input::Callback
			def initialize
				@pool = ObjectPool.new
				@windows = []
				@input = $input.create(:ui)

				@input << self
			end

			def update(delta)
				@pool.update(delta)
				
				if @active and @active.done?
					@active = nil
					@input.deactivate
				end
			end

			def draw
				@pool.draw
			end

			def active?
				@active
			end

			def close_all
				@windows.each { |w| w.remove! }
				@windows = []
			end

			def text_window(s, border = :default)
				set_active(TextWindow.new(s, Utils::get_z(:ui) + @windows.length, charset, Border[border]))
				@active
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
				@windows << @active
				@input.active = true
			end
		end
	end
end

