module Pokemon
	module Render
		def self.[](id)
			@@default_renderer ||= Base.new
			@@renderers ||= {
				default: @@default_renderer,
				tall_grass: TallGrass.new
			}
			@@renderers.fetch(id, @@default_renderer)
		end

		class Base
			def draw(model)
				model.sprite.centered do
					model.sprite.draw([model.facing, model.type], model.animation, model.progress, model.x, model.y - model.dz, model.z)

					model.sprite.draw([:shadow, model.facing, model.type], model.animation, model.progress, model.x, model.y, model.z - 1) if model.dz > 0
				end
			end
		end

		class TallGrass < Base
			def draw(model)
				super

				@@sprite ||= Sprite['tall_grass']

				@@sprite.draw([model.type], model.animation, model.progress, model.x, model.y, model.z + 1)
			end
		end
	end
end

