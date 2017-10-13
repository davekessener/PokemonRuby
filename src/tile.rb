module Pokemon
	module Tile
		class Base
			attr_reader :name, :size

			def initialize(name, size, img)
				@name = name
				@size = size
				@image = img
			end

			def draw(x, y, z)
				@image.draw(x, y, z) if @image
			end
		end

		class Animation < Base
			def initialize(name, size, period, frames)
				super(name, size, nil)
				@period = period
				@frames = frames
			end

			def draw(x, y, z)
				@frames[(Gosu::milliseconds / @period) % @frames.size].draw(x, y, z)
			end
		end

		class Meta
			def interact
			end

			def on_move(object, dir)
				false
			end

			def can_enter_from(dir, meta)
				false
			end

			def enter(dir)
			end

			def exit(dir)
			end
		end

		class Floor < Meta
			attr_reader :level

			def initialize(l)
				@level = l
			end

			def can_enter_from(dir, meta)
				(not meta.respond_to? :level) || (meta.level - @level).abs <= 1
			end
		end

		class Water < Meta
		end

		class Ledge < Meta
			attr_reader :direction

			def initialize(d)
				@direction = d
			end

			def can_enter_from(dir, meta)
				dir == @direction
			end
		end

		class TallGrass < Meta
			def can_enter_from(dir, meta)
				true
			end
		end

		MetaData = {
			wall: Meta.new,
			floor: Floor.new(0),
			stairs: Floor.new(1),
			mountain: Floor.new(2),
			water: Water.new,
			ledge_left: Ledge.new(:left),
			ledge_right: Ledge.new(:right),
			ledge_down: Ledge.new(:down),
			tall_grass: TallGrass.new
		}
	end
end

