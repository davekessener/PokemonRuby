module Pokemon
module Overworld
	module Entity
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

