module Pokemon
	module UI
		class Window < GameObject
			def initialize(x, y, w, h, border = :default)
				super(x * Utils::TILE_SIZE, y * Utils::TILE_SIZE, w * Utils::TILE_SIZE, h * Utils::TILE_SIZE)
				@border = Border[border]
				@px, @py, @pw, @ph = x, y, h, w
			end

			def draw
				@border.draw(@px, @py, @pw, @ph)
			end
		end

		class TextWindow < Window
		end
	end
end

