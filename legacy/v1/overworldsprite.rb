module Pokemon
	module OverworldSprite
		class Base < Entity::Base
			attr_reader :movement, :renderer
			attr_accessor :speed, :corporal, :moving
			attr_accessor :facing, :sprite, :type

			def initialize
				super(0, 0, 0, 0)
				@facing = :down
				@type = :entity
				@speed = Utils::WALKING_SPEED
				@movement = Movement.new(self)
				@renderer = Renderer.new(self)
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
			attr_accessor :default_renderer

			def [](id)
				(@default_renderer || Render[:default]).sub_renderer(id)
			end

			def draw
				if not object.queue.empty? and object.queue.first.renderer
					object.queue.first.renderer.draw(object)
				elsif @default_renderer
					@default_renderer.draw(object)
				else
					object.sprite.draw([], 0.0, object.x, object.y, Utils::get_z(object.type))
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
						object.queue << FailedWalkEvent.new(object, dir, 45)
					else
						@steps += 1

						if $world.map.can_move?(object, dir)
							$world.map.exit_tile(object)
							object.queue << WalkEvent.new(object, dir) unless $world.map.on_move(object, dir)
						else
							object.queue << FailedWalkEvent.new(object, dir, 500)
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

			def initialize(object, dir, distance = 1)
				super(object)
				object.facing = dir
				d = Utils::Directions[dir]
				@movement = Utils::Movement::Distance.new(d * Utils::TILE_SIZE * distance, d * object.speed)
				self.renderer = object.renderer[:walking]
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

		class FailedWalkEvent < Entity::DelayedCallbackEvent
			include Walker

			def initialize(object, dir, dur)
				super(object, dur)
				object.facing = dir
				self.renderer = object.renderer[:failed_walking]
			end

			def update(delta)
				super
				self.renderer.progress = progress
			end
		end

		class JumpEvent < WalkEvent
			def initialize(object, dir)
				super(object, dir, 2)
				self.renderer = object.renderer[:jumping]
			end
		end
	end
end

