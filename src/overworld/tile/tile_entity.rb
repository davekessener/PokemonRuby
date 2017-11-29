module Pokemon
module Overworld
	class TileEntity
		attr_reader :meta
		attr_accessor :px, :py

		def initialize(px, py, meta, anims = [])
			@px, @py = px, py
			@layers = {}
			@meta = meta
			@animations = anims
		end

		def interact
			@meta.interact(@px, @py)
		end

		def trigger
			@meta.trigger(@px, @py)
		end

		def enter(entity)
			@animations.each { |a| a.enter(entity, @px, @py) }
		end

		def exit(entity)
			@animations.each { |a| a.exit(entity, @px, @py) }
		end

		def can_enter(entity, tile)
			@meta.can_enter(entity, @px, @py, tile)
		end

		def renderer
			@meta.renderer
		end

		def encounter_type
			@meta.encounter_type
		end

		def add(z, layer)
			@layers[z] = [] unless @layers[z]
			@layers[z] << layer
		end

		def update(delta)
			@animations.each { |a| a.update delta }
		end

		def draw(x, y)
			@layers.each do |z, layer|
				layer.each { |t| t.draw(x, y, z) }
			end
			@animations.each { |a| a.draw(x, y) }
		end
	end
end
end

#			def enter(entity)
#				if Utils::gen == 3
#					l = $world.tile_size
#					anim = Animation::Static.new('tall_grass', entity.px * l, entity.py * l, entity.model.z + 1)
#					@animations << AnimationEntity.new(anim)
#				end
#			end

