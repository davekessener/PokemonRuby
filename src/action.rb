module Pokemon
	module Entity
		class Action
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

		class TimedAction < Action
			def initialize(entity, duration)
				super(entity)
				@timer = Utils::Movement::Timed.new(duration)
			end

			def update(delta)
				@timer.calculate(delta)
				entity.model.progress = @timer.progress
			end

			def done?
				@timer.done?
			end
		end

		class JumpAction < Action
			def initialize(entity, movement)
				super(entity)
				@movement = movement
			end

			def update(delta)
			end

			def done?
				@movement.done?
			end
		end
	end
end

