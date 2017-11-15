module Pokemon
module Overworld
	module Render
		def self.set_render_gen(g)
			m = {
				2 => Gen2,
				3 => Gen3
			}[g]
			@@default_renderer ||= Base.new
			@@renderers = {
				default: @@default_renderer,
				tall_grass: m::TallGrass.new
			}
		end

		def self.[](id)
			@@renderers.fetch(id, @@default_renderer)
		end

		class Base
			def draw(model)
				model.sprite.centered do
					model.sprite.draw([model.facing, model.type], model.animation, model.progress, model.x, model.y - model.dz, model.z + model.dz)

					model.sprite.draw([:shadow, model.facing, model.type], model.animation, model.progress, model.x, model.y, model.z - 1) if model.dz > 0
				end if model.sprite
			end
		end

		module Gen2
			class TallGrass < Base
				def draw(model)
					super

					@@sprite ||= Sprite['tall_grass']

					@@sprite.draw([model.type], model.animation, model.progress, model.x, model.y, model.z + 1)
				end
			end
		end

		module Gen3
			class TallGrass < Base
				def draw(model)
					super

					@@sprite ||= Sprite['tall_grass']
					
					l = $world.tile_size
					dx, dy = model.entity.px, model.entity.py
					sx, sy = dx, dy
					sx += model.dx / model.dx.abs unless model.dx.zero?
					sy += model.dy / model.dy.abs unless model.dy.zero?

					if dx == sx and dy == sy
						@@sprite.draw([:default], 0, 0.0, dx * l, dy * l, model.z + 1)
					else
						if $world.meta_at(sx, sy) == :tall_grass and (model.facing == :left or model.facing == :right)
							@@sprite.draw([:default], 0, 0.0, sx * l, sy * l, model.z + 1)
						end

						@@sprite.draw([:entering], 0, 0.0, dx * l, dy * l, model.z - 1)
					end
				end
			end
		end
	end
end

end
