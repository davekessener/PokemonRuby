module Pokemon
module Overworld
	class Player < Entity::Base
		attr_reader :input, :name

		def initialize(input, data)
			super(data['x'], data['y'])
			@input = input
			@input << PlayerInput.new(self)
			@name = data['name']

			model.sprite = Sprite[data['sprite']]
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
end

end
