module Pokemon
	class Player < Entity::Base
		attr_reader :input

		def initialize(input, data)
			super(data['x'], data['y'])
			@input = input
			@input << PlayerInput.new(self)

			model.sprite = Sprite['gold']
			model.facing = data['facing'].to_sym
			self.corporal = true
		end

		def direction
			@input.buttons.find { |b| Utils::Directions.include? b }
		end
	end

	class PlayerInput < Component
		def update(delta)
			unless object.controller.active?
				d = object.direction
				if d == object.model.facing
					object.controller.add(PlayerMoveAction.new(object, object.input.down?(:B) ? :running : :walking), :player)
				elsif d
					object.controller.add(FailedMoveAction.new(object, d, 25), :player)
				end
			end
		end

		def down(input, id)
			if id == :A
				object.controller.add(PlayerInteractAction.new(object), :script)
			elsif id == :start
			end
		end
	end

	class PlayerInteractAction < Entity::Action
		def enter
			entity.controller.clear
			dx, dy = *Utils::direction(entity.model.facing)
			$world.player_interact(entity.px + dx, entity.py + dy)
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
			entity.model.reset(:dx, :dy, :dz, :progress)
			entity.model.type = :standing
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
					dir = entity.direction
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
			d = entity.direction 
			if d and d != entity.model.facing
				@done = true
			end
		end
	end
end

