module Pokemon
module Data
	class Species
		attr_reader :name, :types, :base_stats

		private_class_method :new

		private

		def load_data(data)
			@name = data['name']
			@types = data['types'].map { |t| Type[t.to_sym] }
			@base_stats = data['stats']
		end

		def self.resource_path
			[Utils::POKEMON_DIR, Utils::SPECIES_DIR]
		end
	end
end
end

