module Pokemon
	class Player < Entity::Base
		attr_reader :input

		def initialize(data)
			super(data['x'], data['y'])
			@input = $input.create(:player)
			PlayerInput.new(self, @input)

			model.sprite = Sprite['gold']
			model.facing = data['facing'].to_sym
			self.corporal = true
		end
	end

	class PlayerInput < Component
		def initialize(object, input)
			super(object)
			@input = input
			
			@input.activate
		end

		def update(delta)
			unless object.controller.active?
				[:up, :down, :left, :right].each do |d|
					if @input.down? d
						if d == object.facing
							object.controller.add(PlayerMoveAction.new(object, @input.down?(:B) ? :running : :walking))
						else
							object.controller.add(PlayerTurnAction.new(object, d))
						end
					end
				end
			end
		end
	end

	class PlayerMoveAction < Entity::Action
		def initialize(player, speed)
			@player = player
			@speed_id = speed
			@direction = Utils::direction(player.model.facing)
			@speed = Utils::Velocity.new(Utils::speed(@speed_id))
			@left = 0
		end

		def enter
			@player.model.type = @speed_id
		end

		def exit
			@player.model.x = @player.px * $world.tile_size
			@player.model.y = @player.py * $world.tile_size
			@player.model.type = :standing
			@player.model.animation = 0
			@player.model.progress = 0.0
		end

		def interrupt
			self.exit
		end

		def update(delta)
			d = @speed.calculate(delta)
			dx, dy = *(@direction * d)
			l = $world.tile_size

			@player.model.x += dx
			@player.model.y += dy
			
			@left -= d
			if @left <= 0
				@left += l
				@player.model.animation += 1
			
				@done = true
				unless @player.controller.queued?
					px, py = @player.px + @direction.dx, @player.py + @direction.dy
				
					if @player.input.down? @player.model.facing
						if $world.can_move_to(@player, px, py)
							$world.move_player(px, py)
						else
							@player.controller.override(FailedMoveAction.new(@player))
						end
					end
				end
			end

			@player.model.progress = (l - @left).to_f / l
		end

		def done?
			@done
		end
	end

	class PlayerTurnAction < Entity::Action
		def initialize(player, facing)
			@player = player
			@facing = facing
		end

		def enter
			@player.model.facing = @facing
		end
	end

	class FailedMoveAction < Entity::Action
		def initialize(player)
		end
	end
end

