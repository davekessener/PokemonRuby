module Pokemon
	module OverworldSprite
		class Container < Entity::Container
			attr_reader :movement
			attr_accessor :speed, :corporal, :moving
			attr_accessor :facing, :sprite, :type

			def initialize
				super(0, 0, 0, 0)
				@facing = :down
				@type = :entity
				@speed = Utils::WALKING_SPEED
				@movement = Movement.new(self)
				Renderer.new(self)
			end

			def corporal?
				@corporal
			end

			def moving?
				@moving
			end

			def sprite=(sprite)
				@sprite = sprite
				self.width = sprite.width
				self.height = sprite.height
			end

			def px
				self.x / Utils::TILE_SIZE
			end

			def py
				self.y / Utils::TILE_SIZE
			end

			def px=(v)
				@px = v
				self.x = @px * Utils::TILE_SIZE
			end

			def py=(v)
				@py = v
				self.y = @py * Utils::TILE_SIZE
			end
		end

		class Renderer < Component
			def draw
				if not object.queue.empty? and object.queue.first.renderer
					object.queue.first.renderer.draw(object)
				else
					object.sprite.draw([], 0.0, object.x, object.y, Utils::get_z(object.type))
				end
			end
		end

		class WalkRenderer
			attr_accessor :progress

			def draw(object)
				@progress ||= 0.0

				s = object.sprite
				if s
					l = Utils::TILE_SIZE 
					dx, dy = object.x % l, object.y % l
					d = dx.abs + dy.abs
					p = []

					p << object.facing
					p << ((object.moving? and d >= l / 4 and d < 3 * l / 4) ? 'walking' : 'standing')
					p << object.movement.steps % 2

					Gosu::translate((l - s.width) / 2, l * 3 / 4 - s.height) do
						s.draw(p, object.movement.progress, object.x, object.y, Utils::get_z(object.type))
					end
				end
			end
		end
		
		class Movement < Component
			attr_reader :steps

			def initialize(object)
				super(object)
				@steps = 1
			end

			def try_move(dir)
				if not object.moving?
					if dir != object.facing
						object.queue << TurnEvent.new(object, dir)
					else
						@steps += 1

						if $world.map.can_move?(object, dir)
							$world.map.exit_tile(object)
							object.queue << WalkEvent.new(object, dir) unless $world.map.on_move(object, dir)
						else
							object.queue << FailedWalkEvent.new(object, dir)
						end
					end
				end
			end
		end

		module Walker
			def enter
				object.moving = true
			end

			def exit
				object.moving = false
			end
		end

		class WalkEvent < Entity::Event
			include Walker

			def initialize(object, dir)
				super(object)
				object.facing = dir
				d = Utils::Directions[dir]
				@movement = Utils::Movement::Distance.new(d * Utils::TILE_SIZE, d * object.speed)
				self.renderer = WalkRenderer.new
			end

			def exit
				super
				$world.map.enter_tile(object)
			end

			def update(delta)
				d = @movement.calculate(delta)
				object.x += d.dx
				object.y += d.dy
				self.renderer.progress = @movement.progress
			end

			def done?
				@movement.done?
			end
		end

		class TurnEvent < Entity::DelayedCallbackEvent
			def initialize(object, dir)
				super(object, 50)
				object.facing = dir
			end
		end

		class FailedWalkEvent < Entity::DelayedCallbackEvent
			include Walker

			def initialize(object, dir)
				super(object, Utils::TILE_SIZE * 1000 / object.speed)
				object.facing = dir
			end
		end
	end
end

