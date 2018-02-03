module Pokemon
module Overworld
	module Meta
		class Base
			def interact(px, py)
			end

			def trigger(px, py)
			end

			def can_enter(entity, px, py, tile)
				false
			end

			def renderer
				Render[:default]
			end

			def encounter_type
				nil
			end
		end

		class Floor < Base
			attr_reader :level

			def initialize(level)
				super()
				@level = level
			end

			def can_enter(entity, px, py, tile)
				(not tile.meta.respond_to? :level or (tile.meta.level - @level) <= 1)
			end

			def encounter_type
				:cave
			end
		end

		class Water < Base
			def interact(px, py)
			end

			def can_enter(entity, px, py, tile)
				tile.meta.is_a? Water
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

			def can_enter(entity, px, py, tile)
				entity.is_a? PlayerEntity and entity.model.facing == @direction
			end

			def trigger(px, py)
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
			def can_enter(entity, px, py, tile)
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
			@@meta_classes ||= {
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

			klass, args = *@@meta_classes.fetch(id, [Base, []])
			klass.new(*args)
		end
	end
end
end

