module Pokemon
module Overworld
	module TileEntity
		class Base
			def initialize
				@layers = {}
				@animations = ObjectPool.new
			end

			def interact
			end

			def trigger
			end

			def enter(entity)
			end

			def exit(entity)
			end

			def can_enter(entity, tile)
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
				@animations.update delta
			end

			def draw(x, y)
				@layers.each do |z, layer|
					layer.each { |t| t.draw(x, y, z) }
				end
				@animations.draw
			end
		end

		class Floor < Base
			attr_reader :level

			def initialize(level)
				super()
				@level = level
			end

			def can_enter(entity, tile)
				(not tile.respond_to? :level or (tile.level - @level) <= 1)
			end

			def encounter_type
				:cave
			end
		end

		class Water < Base
			def interact
			end

			def can_enter(entity, tile)
				tile == self
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

			def can_enter(entity, tile)
				entity.is_a? Player and entity.model.facing == @direction
			end

			def trigger
				player = $world.player
				d = Utils::direction(@direction)
				px, py = player.px + d.dx, player.py + d.dy
				player.px -= d.dx
				player.py -= d.dy
				player.model.facing = @direction
				player.controller.override(Entity::JumpAction.new(player, px, py))
			end
		end

		class TallGrass < Base
			def can_enter(entity, tile)
				true
			end

			def renderer
				Render[:tall_grass]
			end

			def encounter_type
				:tall_grass
			end

			def enter(entity)
				if Utils::gen == 3
					l = $world.tile_size
					anim = Animation::Static.new('tall_grass', entity.px * l, entity.py * l, entity.model.z + 1)
					@animations << AnimationEntity.new(anim)
				end
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

end
