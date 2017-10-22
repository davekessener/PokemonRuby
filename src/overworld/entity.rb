module Pokemon
module Overworld
	module Entity
		class Base < GameObject
			attr_accessor :px, :py
			attr_accessor :model, :corporal
			attr_reader :renderer, :controller

			def initialize(x, y)
				super()
				@px, @py = x, y
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

		class BasicModel
			attr_accessor :dx, :dy, :dz, :z, :sprite
			attr_accessor :state, :type, :animation
			attr_accessor :progress
			attr_reader :facing

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

			def facing=(id)
				raise ArgumentError, "The only valid directions are #{Utils::Directions.join(', ')}!" unless Utils::Directions.include? id
				@facing = id
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

