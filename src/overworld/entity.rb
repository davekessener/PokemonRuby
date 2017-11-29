module Pokemon
module Overworld
	module Entity
		class IEntity < GameObject
			attr_accessor :px, :py

			def initialize(px = 0, py = 0)
				super()
				@px, @py = px, py
			end

			def corporal
				false
			end

			def interact
			end

			def trigger
			end

			def collide
				false
			end

			def model
				@model ||= IModel.new
			end
		end

		class Base < IEntity
			attr_accessor :model, :corporal
			attr_reader :renderer, :controller

			def initialize(x, y)
				super(x, y)
				@controller = Action::Controller.new(self)
				@model = BasicModel.new(self)
				@renderer = ModelRenderer.new(self)
			end
		end

		class ModelRenderer < Component
			def draw
				$world.renderer_at(object.px, object.py).draw(object.model) if object.model
			end
		end

		class IModel
			def x
				0
			end

			def y
				0
			end

			def z
				0
			end

			def width
				0
			end

			def height
				0
			end
		end

		class BasicModel < IModel
			attr_accessor :dx, :dy, :dz, :sprite
			attr_accessor :state, :type
			attr_accessor :progress
			attr_reader :facing, :animation, :entity
			attr_writer :z

			def initialize(entity)
				@entity = entity
				@dx, @dy, @dz = 0, 0, 0
				@z = Utils::get_z(:entity)
				@sprite = nil
				@facing = :down
				@state = :default
				@type = :standing
				@animation = 0
				@progress = 0.0
			end

			def moving?
				@dx != 0 or @dy != 0 or @dz != 0
			end

			def facing=(id)
				raise ArgumentError, "The only valid directions are #{Utils::Directions.join(', ')}!" unless Utils::Directions.include? id
				@facing = id
			end

			def animation=(a)
				@animation = a.abs
			end

			def reset(*vars)
				if vars.last.is_a? Hash
					vars.pop.each do |k,v|
						send "#{k}=", v
					end
				end
				vars.each do |v|
					send "#{v}=", 0
				end
			end

			def x
				@dx + @entity.px * $world.tile_size
			end

			def y
				@dy + @entity.py * $world.tile_size
			end

			def z
				@z + @entity.py
			end

			def width
				@sprite ? @sprite.width : 0
			end

			def height
				@sprite ? @sprite.height : 0
			end
		end
	end
end
end

