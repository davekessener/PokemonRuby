module Pokemon
module Overworld
	module Map
		class NPCController < Component
			def initialize(object, ai)
				super(object)
				@ai = ai
				@active = true

				@ai.start(object)
			end

			def freeze
				@active = false
			end

			def unfreeze
				@active = true
			end

			def update(delta)
				if @active
					@ai.update(object, delta)
				end
			end
		end

		module AI
			def self.[](value)
				@@classes ||= {
					'random' => Random
				}
				id, arg = *value.split(':')
				args = arg.split(',')
				Utils::Logger::log("Instantiating AI #{id} with #{args.length} arguments '#{args.join(', ')}'!")
				@@classes[id].new(*args)
			end

			class Base
				def start(object)
				end

				def update(object, delta)
				end
			end

			class Random < Base
				def initialize(leash, delay, frequency)
					@leash = leash.to_f
					@delay = @timer = delay.to_i
					@frequency = frequency.to_f
					@wandered = [0, 0]
				end

				def update(object, delta)
					unless object.controller.queued?
						@timer -= delta
						if @timer <= 0
							@timer = @delay
							if rand < @frequency
								tick(object)
							end
						end
					end
				end

				private

				def tick(object)
					dx, dy = 0, 0
					if rand < 0.5
						dx = calc(@wandered[0])
					else
						dy = calc(@wandered[1])
					end

					if $world.can_move? object, object.px + dx, object.py + dy
						object.controller << Overworld::Entity::WalkAction.new(object, Utils::get_direction(dx, dy))
						@wandered[0] += dx
						@wandered[1] += dy
					else
						tick(object)
					end
				end

				def calc(v)
					(rand < 0.5 + 0.5 * (v / @leash)) ? -1 : 1
				end
			end
		end
	end
end
end

