module Pokemon
	module UI
		class DisplayTextAction < Action::Base
			def initialize(entity, text, speed = 30)
				super(entity)
				@text = text.split(//)
				@left = @speed = speed
			end

			def enter
				entity.renderer.new_line
			end

			def update(delta)
				while delta > @left
					delta -= @left
					@left = @speed
					entity.renderer << @text.shift
					break if done?
				end
				@left -= delta
			end

			def done?
				@text.empty?
			end
		end

		class ScrollTextAction < Action::Base
			def initialize(entity, speed = 100)
				super(entity)
				@speed = speed
				@current = 0
			end

			def update(delta)
				@current += delta
				if @current > @speed
					@done = true
				else
					entity.renderer.displace = @current / @speed.to_f
				end
			end

			def done?
				@done
			end
		end

		class InputAction < Action::Base
			def initialize(entity, keys, &block)
				super(entity)
				@keys = keys
				@callback = block if block_given?
			end

			def enter
				entity.renderer.wait = true
			end

			def exit
				entity.renderer.wait = false
			end

			def accept(id)
				if not @done and @keys.include? id
					@done = true
					@callback.call if @callback
				end
			end

			def done?
				@done
			end
		end
	end
end

