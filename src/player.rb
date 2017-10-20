module Pokemon
	class Player < Entity::Base
		attr_reader :input

		def initialize(data)
			super(data['x'], data['y'])
			@input = ButtonBuffer.new($input.create(:player))
			PlayerInput.new(self)

			model.sprite = Sprite['gold']
			model.facing = data['facing'].to_sym
			self.corporal = true
		end
	end

	class ButtonBuffer < Input::Callback
		def initialize(input)
			input << self
			input.activate

			@buttons = []
		end

		def direction
			@buttons.find { |b| Utils::Directions.include? b }
		end

		def pressed
			@buttons.first
		end

		def down(input, id)
			up(input, id)
			@buttons.unshift id
			Utils::Logger::log("after down(:#{id}) is [#{@buttons.map {|e| ":#{e}"}.join(', ')}], dir = :#{direction}")
		end

		def up(input, id)
			@buttons.delete id if down? id
			Utils::Logger::log("after up(:#{id}) is [#{@buttons.map {|e| ":#{e}"}.join(', ')}], dir = :#{direction}")
		end

		def down?(id)
			@buttons.include? id
		end
	end

	class PlayerInput < Component
		def update(delta)
			unless object.controller.active?
				d = object.input.direction
				if d == object.model.facing
					object.controller.add(PlayerMoveAction.new(object, object.input.down?(:B) ? :running : :walking), :player)
				elsif d
					object.controller.add(FailedMoveAction.new(object, d, 25), :player)
				end
			end
		end
	end

	class PlayerMoveAction < Entity::Action
		def initialize(player, speed)
			super(player)
			@speed_id = speed
			@direction = Utils::direction(player.model.facing)
			@left = 0
		end

		def enter
			update_speed(@speed_id)
		end

		def exit
			entity.model.dx = 0
			entity.model.dy = 0
			entity.model.type = :standing
			entity.model.progress = 0.0
		end

		def interrupt
			self.exit
		end

		def update_speed(id)
			@speed_id = id
			@speed = Utils::Velocity.new(Utils::speed(@speed_id))
			entity.model.type = @speed_id
		end

		def update(delta)
			d = @speed.calculate(delta)
			dx, dy = *(@direction * d)
			l = $world.tile_size

			entity.model.dx += dx
			entity.model.dy += dy
			
			@left -= d
			if @left <= 0
				@left += l
				entity.model.animation += 1
			
				@done = true
				unless entity.controller.queued?
					dir = entity.input.direction
					if dir and dir != entity.model.facing
						entity.model.facing = dir
						entity.controller.override(PlayerMoveAction.new(entity, @speed_id))
						return
					end

					px, py = entity.px + @direction.dx, entity.py + @direction.dy
					dx, dy = *(@direction * l)

					entity.model.dx -= dx
					entity.model.dy -= dy
				
					if entity.input.down? entity.model.facing
						if $world.can_move_to(entity, px, py)
							$world.move_player(px, py)
							update_speed(entity.input.down?(:B) ? :running : :walking)
							@done = false
						else
							entity.controller.override(FailedMoveAction.new(entity, entity.model.facing, 600))
						end
					end
				end
			end

			entity.model.progress = (l - @left).to_f / l
		end

		def done?
			@done
		end
	end

	class FailedMoveAction < Entity::TimedAction
		def initialize(player, dir, duration)
			super(player, duration)
			@direction = dir
		end

		def enter
			entity.model.facing = @direction
			entity.model.type = :walking
		end

		def exit
			entity.model.type = :standing
		end

		def update(delta)
			super
			d = entity.input.direction 
			if d and d != entity.model.facing
				@done = true
			end
		end
	end
end

