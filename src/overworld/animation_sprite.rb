module Pokemon
	module Overworld
		class AnimationEntity < Entity::IEntity
			def initialize(a)
				super()
				@animation = a
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
				@animation.px
			end

			def py
				@animation.py
			end

			def corporal
				false
			end

			def model
				@animation.model
			end
		end
	end
end

