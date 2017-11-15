module Pokemon
module Overworld
	module Entity
		class TurnAction < Action::Base
			def initialize(entity, dir)
				super(entity)
				@facing = dir
			end

			def enter
				entity.model.facing = @facing
			end
		end

		class WalkAction < Action::Base
			def initialize(entity, dir, speed = :walking)
				super(entity)
				@facing = dir
				@movement_type = speed
				@speed = Utils::Velocity.new(Utils::speed(@movement_type))
				@direction = Utils::direction(dir)
			end

			def enter
				entity.model.reset :dz, :progress
				entity.model.facing = @facing
				entity.model.type = @movement_type

				entity.px += @direction.dx
				entity.py += @direction.dy
				@left = $world.tile_size
				entity.model.dx = -@direction.dx * @left
				entity.model.dy = -@direction.dy * @left
			end

			def exit
				entity.model.reset :dx, :dy, :dz, :progress
				entity.model.type = :standing
			end

			def update(delta)
				d = @speed.calculate(delta)
				dx, dy = *(@direction * d)
				l = $world.tile_size 

				entity.model.dx += dx
				entity.model.dy += dy
				
				@left -= d
				@done = true if @left <= 0
				entity.model.progress = (l - @left).to_f / l
			end

			def done?
				@done
			end
		end

		class JumpAction < Action::Base
			def initialize(entity, px, py, h = 3 * $world.tile_size / 4, speed = Utils::speed(:jumping))
				super(entity)
				@px, @py, @h = px, py, h
				d = Utils::Vec2.new(px, py) - Utils::Vec2.new(entity.px, entity.py)
				v = Utils::Velocity.new((d / d.abs) * speed)
				Utils::Logger::log("jumping from (#{entity.px}, #{entity.py}) to (#{px}, #{py})")
				Utils::Logger::log("thats a distance of #{d} at a speed of #{v}!")
				@movement = Utils::Movement::Distance.new(d.abs * $world.tile_size, v)
			end

			def enter
				entity.model.reset(:dx, :dy, :dz, :progress)
				entity.model.animation += 1
			end

			def exit
				entity.model.reset(:dx, :dy, :dz, :progress)
				$world.move_entity(entity, @px, @py)
			end

			def update(delta)
				dx, dy = *@movement.calculate(delta)
				p = @movement.progress
				entity.model.dx += dx if dx
				entity.model.dy += dy if dy
				entity.model.dz = get_height(p)
				entity.model.progress = p
			end

			def done?
				@movement.done?
			end

			private

			def get_height(l)
				if !@tmp or @tmp != l
					@tmp, @last = l, (@h * Math.sin(l * Math::PI)).to_i
				end
				@last
			end
		end
	end
end
end

