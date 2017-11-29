module Pokemon
	module Overworld
		class AnimationSprite < Entity::IEntity
			def initialize(a)
				super()
				@animation = a

				@animation.reset
			end

			def update(delta)
				super
				@animation.update delta
			end

			def draw
				super
				@animation.draw
			end

			def px
				@animation.model.x / $world.tile_size
			end

			def py
				@animation.model.y / $world.tile_size
			end

			def corporal
				false
			end

			def model
				@animation.model
			end

			def remove?
				super or @animation.remove?
			end
		end
	end
end

