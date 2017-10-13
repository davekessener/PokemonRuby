require 'JSON'

module Pokemon
	module Utils
		TITLE = 'Yet Another Pokemon Clone'
		WINDOW_SIZE = [768, 432]
		SCREEN_SCALE = 3

		WALKING_SPEED = 48
		TILE_SIZE = 16

		DATA_DIR = 'data'
		MEDIA_DIR = 'media'
		TILESET_DIR = 'tileset'
		TILEMAP_DIR = 'tilemap'
		SPRITE_DIR = 'sprite'
		MAP_DIR = 'map'

		SpriteOffset = {
			down: 0,
			up: 8,
			left: 16,
			right: 24
		}

		def self.absolute_path(*dirs)
			File.join($root_dir, *dirs)
		end

		def self.relative_path(path)
			path.gsub("#{$root_dir}/", '')
		end

		def self.screen_width
			WINDOW_SIZE[0] / SCREEN_SCALE
		end

		def self.screen_height
			WINDOW_SIZE[1] / SCREEN_SCALE
		end

		def self.on_screen(x, y)
			x >= 0 and x < screen_width and y >= 0 and y < screen_height
		end

		def self.camera_offset(camera)
			return [screen_width / 2 - camera.x, screen_height / 2 - camera.y]
		end

		def self.get_z(id)
			@@zs ||= {background: 0, bottom: 1, entity: 10, top: 100}
			@@zs[id]
		end

		class Vec2
			attr_accessor :dx, :dy

			def initialize(dx, dy)
				@dx, @dy = dx, dy
			end

			def *(s)
				Vec2.new(@dx * s, @dy * s)
			end

			def /(s)
				Vec2.new(@dx / s, @dy / s)
			end

			def +(v)
				Vec2.new(@dx + v.dx, @dy + v.dy)
			end

			def -(v)
				Vec2.new(@dx - v.dx, @dy - v.dy)
			end

			def abs
				Vec2.new(@dx.abs, @dy.abs)
			end
		end

		Directions = {
			left: Vec2.new(-1, 0),
			right: Vec2.new(1, 0),
			up: Vec2.new(0, -1),
			down: Vec2.new(0, 1)
		}

		class Movement
			def calculate(delta)
				Vec2.new(0, 0)
			end

			def done?
				true
			end
		end

		class MoveDistance < Movement
			def initialize(v, s)
				@vec = v.abs
				@speed = s
				@leftover = Vec2.new(0, 0)
			end

			def calculate(delta)
				d = @speed * delta + @leftover
				@leftover = Vec2.new(d.dx % 1000, d.dy % 1000)
				d /= 1000
				d.dx = d.dx < 0 ? -@vec.dx : @vec.dx if d.dx.abs > @vec.dx
				d.dy = d.dy < 0 ? -@vec.dy : @vec.dy if d.dy.abs > @vec.dy
				@vec -= d.abs
				d
			end

			def done?
				@vec.dx == 0 and @vec.dy == 0
			end
		end

		module DynamicLoad
			attr_reader :id

			def initialize(id, data)
				@id = id
				load_data(data)
			end

			def self.included(base)
				base.extend ClassMethods
			end

			module ClassMethods
				def [](id)
					@loaded_entities ||= {}
					raise ArgumentError, "Invalid id '#{id}'!" if not id.is_a? String
					load_entity(id) unless @loaded_entities[id]
					@loaded_entities[id]
				end

				def load_entity(id)
					path = resource_path
					path << "#{id}.json"
					fn = Utils::absolute_path(*path)
					Logger::log("loading JSON resource '#{Utils::relative_path(fn)}'!")
					data = JSON.parse(File.read(fn))
					@loaded_entities[id] = new(id, data)
				end
			end
		end
	end
end

