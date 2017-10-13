module Pokemon
	module Entity
		class Container < GameObject
			attr_reader :queue, :controller

			def initialize(x, y, w, h)
				super(x, y, w, h)
				@queue = []
				@controller = Controller.new(self)
			end
		end

		class Event
			attr_reader :object

			def initialize(object)
				@object = object
			end

			def enter
			end

			def exit
			end

			def update(delta)
			end

			def done?
				true
			end
		end

		class OverworldSprite < Container
			attr_reader :movement
			attr_accessor :speed, :corporal, :moving, :facing, :sprite

			def initialize
				super(0, 0, 0, 0)
				@facing = :down
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

		class Controller < Component
			def update(delta)
				o = object.queue.first
				if o
					o.enter unless @cont
					@cont = true
					o.update(delta)
					if o.done?
						object.queue.shift
						o.exit
						@cont = false
					end
				end
			end
		end

		class Renderer < Component
			def draw
				s = object.sprite
				if s
					l = Utils::TILE_SIZE 
					dx, dy = object.x % l, object.y % l
					f = Utils::SpriteOffset[object.facing]

					if object.moving? and (dx.abs + dy.abs) < l / 2
						f += 1 + object.movement.steps % 2
					end

					Gosu::translate((l - s.width) / 2, l * 3 / 4 - s.height) do
						s.draw(f, object.x, object.y, Utils::get_z(:entity))
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

		class WalkEvent < Event
			include Walker

			def initialize(object, dir)
				super(object)
				object.facing = dir
				d = Utils::Directions[dir]
				@movement = Utils::MoveDistance.new(d * Utils::TILE_SIZE, d * object.speed)
			end

			def exit
				super
				$world.map.enter_tile(object)
			end

			def update(delta)
				d = @movement.calculate(delta)
				object.x += d.dx
				object.y += d.dy
			end

			def done?
				@movement.done?
			end
		end

		class DelayedCallbackEvent < Event
			def initialize(object, delay, &callback)
				super(object)
				@delay = delay
				@callback = callback
			end

			def update(delta)
				if @delay > 0
					@delay -= delta
					if @delay <= 0
						@callback.call if @callback
					end
				end
			end

			def done?
				@delay <= 0
			end
		end

		class TurnEvent < DelayedCallbackEvent
			def initialize(object, dir)
				super(object, 50)
				object.facing = dir
			end
		end

		class FailedWalkEvent < DelayedCallbackEvent
			include Walker

			def initialize(object, dir)
				super(object, Utils::TILE_SIZE * 1000 / object.speed)
				object.facing = dir
			end
		end
	end
end

