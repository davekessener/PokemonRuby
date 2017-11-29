module Pokemon
module Overworld
	module Animator
		class Base
			def initialize(args = [])
			end

			def update(delta)
			end

			def draw(x, y)
			end

			def enter(entity, px, py)
			end

			def exit(entity, px, py)
			end
		end

		class TallGrass < Base
			def initialize(args)
				@name = 'tall_grass_' + args[0]
				@sprite = Sprite[@name]
				@animation = Animation::Static.new(@name, 0, 0, 0)
				@cooldown = 0
			end

			def enter(entity, px, py)
				l = $world.tile_size
				@model = entity.model
				@animation.model.tap do |m|
					m.x, m.y, m.z = px * l, py * l, @model.z
					m.z = @model.z - 1 if @model.facing == :up
				end
				$world.add_object AnimationSprite.new(@animation)
				@anim_active = true
			end

			def exit(entity, px, py)
				@anim_active = false
				if entity.model.facing == :left or entity.model.facing == :right
					@cooldown = 200 
				else
					@animation.model.z = @model.z - 1
				end
			end

			def update(delta)
				@cooldown -= delta
			end

			def draw(x, y)
				if @anim_active
					@sprite.draw([:default], 0, 0.0, x, y, @model.z - 1)
					unless @model.moving?
						@animation.model.z = @model.z + 1
					end
					if @animation.remove?
						@sprite.draw([:standing], 0, 0.0, x, y, @model.z + 1)
					end
				elsif @cooldown > 0
					@sprite.draw([:standing], 0, 0.0, x, y, @model.z + 1) if @animation.remove?
				end
			end
		end

		def self.[](id)
			@@animators ||= {
				tall_grass: TallGrass
			}

			@@animators[id]
		end
	end
end
end

