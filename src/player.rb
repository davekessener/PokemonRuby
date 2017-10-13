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

		def y
			@sprite.y
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
		def update(delta)
			o = object.sprite
			if not o.moving? and object.can_move?
				if Gosu::button_down? Gosu::KB_UP
					o.movement.try_move :up
				elsif Gosu::button_down? Gosu::KB_DOWN
					o.movement.try_move :down
				elsif Gosu::button_down? Gosu::KB_LEFT
					o.movement.try_move :left
				elsif Gosu::button_down? Gosu::KB_RIGHT
					o.movement.try_move :right
				end
			end
		end
	end
end

