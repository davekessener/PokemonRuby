module Pokemon
	module Utils
		module Movement
			class Base
				attr_reader :left

				def initialize(max, speed = Velocity.new(0))
					@speed = speed
					@max = @left = max
					@total = get_total(@speed, @max)
				end

				def calculate(delta)
					delta = update_delta(delta)
					r = update_result(@speed.calculate(delta))
					@left -= update_leftover(delta, r)
					@done = @left.zero?
					r
				end

				def progress
					(@max - @left).to_f / @max
				end

				def done?
					@done
				end

				def update_delta(delta)
					delta
				end

				def update_result(r)
					r
				end
			end

			class Distance < Base
				def update_result(r)
					(r > left) ? left : r
				end

				def update_leftover(delta, r)
					r
				end

				def get_total(speed, max)
					max
				end
			end

			class Timed
				def update_delta(delta)
					delta > left ? left : delta
				end

				def update_leftover(delta, r)
					delta
				end

				def get_total(speed, max)
					speed.dup.calculate(max).abs
				end
			end
		end
	end
end

