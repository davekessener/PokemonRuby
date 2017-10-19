module Pokemon
	module TileEntity
		class Base
			def initialize
				@layers = {}
				@animations = []
			end

			def interact
			end

			def enter(dir)
			end

			def exit(dir)
			end

			def trigger(entity)
			end

			def can_enter(entity)
				false
			end

			def renderer
				Render[:default]
			end

			def encounter_type
				nil
			end

			def add(z, layer)
				@layers[z] = [] unless @layers[z]
				@layers[z] << layer
			end

			def update(delta)
				@animations.each { |a| a.update(delta) }
				@animations.reject! &:done?
			end

			def draw(x, y)
				@layers.each do |z, layer|
					layer.each { |t| t.draw(x, y, z) }
				end
				@animations.each { |a| a.draw(x, y) }
			end
		end

		class Floor < Base
			attr_reader :level

			def initialize(level)
				super()
				@level = level
			end

			def can_enter(entity)
				src = $world.map.get_tile(entity.px, entity.py)
				(not src.respond_to? :level or (src.level - @level) <= 1)
			end

			def encounter_type
				:cave
			end
		end

		class Water < Base
			def can_enter(entity)
				entity.model.state == :surf
			end

			def encounter_type
				:surfing
			end
		end

		class Ledge < Base
			attr_reader :direction

			def initialize(dir)
				super()
				@direction = dir
			end

			def can_enter(entity)
				entity.facing == @direction
			end

			def trigger(entity)
				entity.controller.override(JumpAction.new(entity, @direction))
			end
		end

		class TallGrass < Base
			def can_enter(entity)
				true
			end

			def renderer
				Render[:tall_grass]
			end

			def encounter_type
				:tall_grass
			end
		end

		def self.[](id)
			@@te_classes ||= {
				wall: [Base, []],
				floor: [Floor, [0]],
				stairs: [Floor, [1]],
				mountain: [Floor, [2]],
				water: [Water, []],
				ledge_left: [Ledge, [:left]],
				ledge_right: [Ledge, [:right]],
				ledge_down: [Ledge, [:down]],
				tall_grass: [TallGrass, []]
			}

			klass, args = *@@te_classes.fetch(id, [Base, []])
			klass.new(*args)
		end
	end
end

