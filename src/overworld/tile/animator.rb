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
				super()
				@name = 'tall_grass_' + args[0]
				@sprite = Sprite[@name]
				@cooldown = 0
			end

			def enter(entity, px, py)
				l = $world.tile_size
				@model = entity.model
				@animation = Animation::Static.new(@name, px * l, py * l, @model.z)
				@animation.model.z -= 1 if @model.facing == :up
				$world.add_object AnimationSprite.new(@animation)
				@anim_active = true
			end

			def exit(entity, px, py)
				@anim_active = false
				if entity.model.facing == :left or entity.model.facing == :right
					@cooldown = 200 
				elsif @animation
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
						@animation.model.z = @model.z + 1 if @animation
					end
					if @animation.nil? or @animation.remove?
						@sprite.draw([:standing], 0, 0.0, x, y, @model.z + 1)
					end
				elsif @cooldown > 0
					@sprite.draw([:standing], 0, 0.0, x, y, @model.z + 1) if @animation.nil? or @animation.remove?
				end
			end
		end

		class Footsteps < Base
			def initialize(args)
				super()
				@animations = {}
				Utils::Directions.each { |d| @animations[d] = 'footsteps_sand_' + d.to_s }
			end

			def enter(entity, px, py)
				if @obj
					@obj.remove!
					@obj = nil
				end
			end

			def exit(entity, px, py)
				l = $world.tile_size
				a = Animation::Static.new(@animations[entity.model.facing], px * l, py * l, entity.model.z - 2)
				$world.add_object(@obj = AnimationSprite.new(a))
			end
		end

		class Looping < Base
			def initialize(id)
				super()
				@aid = id
			end

			def enter(entity, px, py)
				a = Animation::Static.new(@aid, 0, 0, 0, Animation::LoopingAnimator)
				Animation::Follower.new(a, Utils::Transform.new(entity.model, :z) { entity.model.z })
				$world.add_object(@animation = AnimationSprite.new(a))
			end

			def exit(entity, px, py)
				@animation.remove! if @animation
				@animation = nil
			end
		end

		class Beach < Looping
			def initialize(args)
				super('beach_particles')
			end
		end

		def self.[](id)
			@@animators ||= {
				tall_grass: TallGrass,
				footsteps: Footsteps,
				beach: Beach
			}

			@@animators[id]
		end
	end
end
end

