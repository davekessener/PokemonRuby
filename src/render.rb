module Pokemon
	module Render
		def self.[](id)
			@@renderer ||= Base.new
		end

		class Base
			def draw(model)
				model.sprite.centered do
					model.sprite.draw([model.facing, model.type], model.animation, model.progress, model.x, model.y, model.z)
				end
			end
		end
	end
end

