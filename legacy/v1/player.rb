module Pokemon
	class Player < GameObject
		attr_accessor :sprite

		def initialize
			super(0, 0, 0, 0)
			PlayerInput.new(self)
		end

		def x
			@sprite.x
		end

		def px
			@sprite.px
		end

		def y
			@sprite.y
		end

		def py
			@sprite.py
		end

		def width
			@sprite.width
		end

		def height
			@sprite.height
		end

		def can_move?
			@sprite.queue.empty?
		end
	end

	class PlayerInput < Component
		def initialize(object)
			super(object)
			@input = $input.create(:player)
			@input << self
			@input.active = true
		end

		def down(input, id)
			@@directions ||= [:left, :right, :up, :down]
			o = object.sprite
			if not o.moving? and object.can_move? and @@directions.include? id
				o.movement.try_move id
			end
		end

		def up(input, id)
		end
	end
end

