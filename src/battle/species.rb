module Pokemon
module Battle
	class Species
		attr_reader :id, :types, :stats

		def initialize(data)
			@id = data['id'].to_sym
			@types = data['types'].map { |t| Type[t] }
			@abilities = data['abilities'].map { |t, a| [t.to_sym, a.to_sym] }.to_h
			@stats = data['stats'].map { |k, v| [k.to_sym, v] }.to_h
		end

		def ability(id)
			@abilities.fetch(id, @abilities[:primary])
		end

		def self.[](id)
			unless @species
				@species = {}
				Utils::load_json(Utils::DATA_DIR, Utils::GAMEDATA_DIR, 'species.json').each do |species|
					o = new(species)
					@species[o.id] = o
				end
			end
			@species[id.to_sym] if id
		end

		private_class_method :new
	end
end
end

