require 'gosu'
require 'JSON'

require_relative 'vec'

module Pokemon
	module Utils
		TITLE = 'Yet Another Pokemon Clone'
		SCREEN_SIZE = [256, 144]
		SCREEN_SCALE = 3
		WINDOW_SIZE = SCREEN_SIZE.map { |i| SCREEN_SCALE * i }

		CHAR_SIZE = 8

		DATA_DIR = 'data'
		MEDIA_DIR = 'media'
		TILESET_DIR = 'tileset'
		TILEMAP_DIR = 'tilemap'
		SPRITE_DIR = 'sprite'
		MAP_DIR = 'map'
		BORDER_DIR = 'border'
		ANIMATION_DIR = 'animation'
		CHARSET_DIR = 'charset'
		LANG_DIR = 'lang'
		SAVE_DIR = 'saves'
		POKEMON_DIR = 'pkmn'
		TYPES_DIR = 'type'
		SPECIES_DIR = 'species'
		GAMEDATA_DIR = 'gamedata'

		Directions = [:left, :right, :up, :down]

		def self.scale_screen(&block)
			if block_given?
				Gosu::scale(Utils::SCREEN_SCALE, Utils::SCREEN_SCALE, &block)
			end
		end

		def self.layers
			@@layers ||= [:bottom, :top]
		end

		def self.direction(id)
			@@directions ||= {
				left: Vec2.new(-1, 0),
				right: Vec2.new(1, 0),
				up: Vec2.new(0, -1),
				down: Vec2.new(0, 1)
			}
			@@directions.fetch(id, Vec2.new(0, 0))
		end

		def self.get_direction(dx, dy)
			return :left if dx == -1 and dy == 0
			return :right if dx == 1 and dy == 0
			return :up if dx == 0 and dy == -1
			return :down if dx == 0 and dy == 1
			raise "not a valid direction! #{v}"
		end

		def self.opposite(dir)
			@@opposites ||= {
				left: :right,
				right: :left,
				up: :down,
				down: :up
			}
			@@opposites[dir]
		end

		def self.speed(id)
			@@speeds ||= {
				walking: 56,
				jumping: 64,
				running: 114
			}

			@@speeds.fetch(id, 16) * SCREEN_SCALE
		end

		def self.char_size
			CHAR_SIZE
		end

		def self.language
			'EN_US'
		end

		def self.absolute_path(*dirs)
			File.join($root_dir, *dirs)
		end

		def self.relative_path(path)
			path.gsub("#{$root_dir}/", '')
		end

		def self.load_json(*path)
			fn = Utils::absolute_path(*path)
			Logger::log("Loading JSON file '#{Utils::relative_path(fn)}'.")
			JSON.parse(File.read(fn))
		end

		def self.screen_width
			WINDOW_SIZE[0] #SCREEN_SIZE[0]
		end

		def self.screen_height
			WINDOW_SIZE[1] #SCREEN_SIZE[1]
		end

		def self.now
			Gosu::milliseconds
		end

		def self.get_z(id)
			@@zs ||= {background: 0, bottom: 1, entity: 10, top: 100, ui: 1000}
			@@zs.fetch(id, 1001)
		end

		def self.get_priority(id)
			@@priorities ||= {player: 1, world: 10, script: 50, ui: 100}
			@@priorities.fetch(id, 0)
		end

		def self.load_tiles(fn, w, h = w, retro = true)
			@@tilesets ||= {}

			unless @@tilesets[fn]
				img = Image::from_file(fn)
				cx, cy = img.width / w, img.height / h
				@@tilesets[fn] = [img.tiles(w, h), cx, cy]
			end

			@@tilesets[fn]
		end

		def self.backup(fn)
			i = Dir.glob(fn + "\.*\.bak").length
			Logger::log("Creating backup ##{i + 1} for '#{relative_path(fn)}'!")
			FileUtils.cp(fn, "#{fn}.#{i}.bak")
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

