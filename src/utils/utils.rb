require 'gosu'
require 'JSON'

require_relative 'vec'

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

		Directions = {
			left: Vec2.new(-1, 0),
			right: Vec2.new(1, 0),
			up: Vec2.new(0, -1),
			down: Vec2.new(0, 1)
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

			if @@zs[id]
				@@zs[id]
			else
				101
			end
		end

		def self.load_tiles(fn, w, retro = true)
			@@tilesets ||= {}

			@@tilesets[fn] = Gosu::Image.load_tiles(fn, w, w, {retro: retro}) unless @@tilesets[fn]

			@@tilesets[fn]
		end
	end
end

