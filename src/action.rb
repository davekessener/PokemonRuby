module Pokemon
	module Action
		class Base
			attr_reader :entity

			def initialize(entity)
				@entity = entity
			end

			def enter
			end

			def exit
			end

			def interrupt
			end

			def update(delta)
			end

			def done?
				true
			end
		end

		class Conditional < Base
			def initialize(entity, callback = nil, &cond)
				super(entity)
				@callback = callback
				@condition = cond
			end

			def exit
				@callback.call if @callback
			end

			def done?
				@done ||= (not @condition) or @condition.call
			end
		end

		class Timed < Base
			def initialize(entity, duration)
				super(entity)
				@timer = Utils::Movement::Timed.new(duration)
			end

			def update(delta)
				@timer.calculate(delta)
			end

			def done?
				@timer.done? || @done
			end

			def progress
				@timer.progress
			end
		end
	end
end

