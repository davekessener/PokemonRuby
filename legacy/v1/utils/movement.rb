module Pokemon
	module Utils
		module Movement
			class Base
				def calculate(delta)
					Vec2.new(0, 0)
				end

				def progress
					1.0
				end

				def done?
					true
				end
			end

			class Distance < Base
				def initialize(v, s)
					@vec = v.abs
					@speed = s
					@leftover = Vec2.new(0, 0)
					@distance = @vec.dx + @vec.dy
					@covered = Vec2.new(0, 0)
				end

				def progress
					(@covered.dx + @covered.dy).to_f / @distance
				end

				def calculate(delta)
					d = @speed * delta + @leftover
					@leftover = Vec2.new(d.dx % 1000, d.dy % 1000)
					d /= 1000
					d.dx = d.dx < 0 ? -@vec.dx : @vec.dx if d.dx.abs > @vec.dx
					d.dy = d.dy < 0 ? -@vec.dy : @vec.dy if d.dy.abs > @vec.dy
					@vec -= d.abs
					@covered += d.abs
					d
				end

				def done?
					@vec.dx == 0 and @vec.dy == 0
				end
			end
		end
	end
end

