require 'gosu'
require 'JSON'

require_relative 'vec'

module Pokemon
	module Utils
		TITLE = 'Yet Another Pokemon Clone'
		SCREEN_SIZE = [256, 144]
		SCREEN_SCALE = 3
		WINDOW_SIZE = SCREEN_SIZE.map { |i| SCREEN_SCALE * i }

		WALKING_SPEED = 56
		TILE_SIZE = 16
		CHAR_SIZE = 8

		DATA_DIR = 'data'
		MEDIA_DIR = 'media'
		TILESET_DIR = 'tileset'
		TILEMAP_DIR = 'tilemap'
		SPRITE_DIR = 'sprite'
		MAP_DIR = 'map'
		BORDER_DIR = 'border'
		CHARSET_DIR = 'charset'
		SAVE_DIR = 'saves'

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

		def self.center_object(object)
			[(TILE_SIZE - object.width) / 2, TILE_SIZE * 3 / 4 - object.height]
		end

		def self.get_z(id)
			@@zs ||= {background: 0, bottom: 1, entity: 10, top: 100}
			@@zs.fetch(id, 101)
		end

		def self.get_priority(id)
			@@priorities ||= {player: 1, world: 10, ui: 100}
			@@priorities.fetch(id, 0)
		end

		def self.load_tiles(fn, w, retro = true)
			@@tilesets ||= {}

			@@tilesets[fn] = Gosu::Image.load_tiles(fn, w, w, {retro: retro}) unless @@tilesets[fn]

			@@tilesets[fn]
		end

		def self.button_id(id)
			@@button_ids ||= {
				Gosu::KB_A => :left,
				Gosu::KB_D => :right,
				Gosu::KB_W => :up,
				Gosu::KB_S => :down,
				Gosu::KB_L => :A,
				Gosu::KB_P => :B,
				Gosu::KB_RETURN => :start,
				Gosu::KB_BACKSPACE => :select
			}

			@@button_ids.fetch(id, :unknown)
		end
	end
end

