module Pokemon
module Save
	def self.previews
		@@previews ||= load_previews
	end

	def self.set_empty(t)
		@@newgame_template = t
	end

	private

	class PlayerData
		attr_accessor :name, :sprite
		attr_accessor :spawn, :spawn_map, :spawn_facing

		def initialize(data)
			@name = data['name']
			@sprite = data['sprite']
			@spawn_map = data['map']
			@spawn = data['at']
			@spawn_facing = data['facing'].to_sym
		end

		def update
			@spawn_map = $world.map.id
			$world.player.tap do |p|
				@spawn = [p.px, p.py]
				@spawn_facing = p.model.facing
			end
		end

		def save
			update

			{
				name: @name,
				sprite: @sprite,
				map: @spawn_map,
				at: @spawn,
				facing: @spawn_facing
			}
		end
	end

	class SaveFile
		attr_reader :id, :player_data
		attr_accessor :enabled

		def initialize(fn)
			Utils::backup(fn)
			@filename = fn
			@id = fn.gsub(/\.json$/, '').split(/\//).last.to_sym
			@data = JSON.parse(File.read(fn))
			Utils::Logger::log("Loading save file #{@id} from '#{Utils::relative_path(fn)}'.")
			load_data
			@enabled = true
		end

		def save
			if @enabled
				File.open(@filename, 'w') do |f|
					f.write(JSON.pretty_generate({
						player: @player_data.save,
						globals: Text::globals
					}))
				end

				Utils::Logger::log("Saved file #{@id}.")
			end
		end

		def load
			@globals.each do |k,v|
				Text::globals[k] = v
			end

			$savefile = self

			$world.load self
		end

		private

		def load_data
			@player_data = PlayerData.new(@data['player'])
			@globals = @data['globals'].map { |k,v| [k.to_sym, v] }.to_h
		end
	end

	def self.load_previews
		Dir.glob(File.join($root_dir, 'saves/*.json')).map do |file|
			SaveFile.new(file)
		end.map { |f| [f.id, f] }.to_h
	end
end
end

