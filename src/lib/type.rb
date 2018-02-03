module Pokemon
module Data
	class Type
		include Utils::DynamicLoad

		attr_reader :name

		def effectiveness_on(type)
			@table.fetch(type, 1.0)
		end

		private_class_method :new

		private

		def load_data(data)
			@name = data['name']
			@table = {}

			[weak: 0.5, stronk: 2.0, immune: 0.0].each do |t, m|
				@table[data[t.to_s].to_sym] = m
			end
		end

		def self.resource_path
			[Utils::POKEMON_DIR, Utils::TYPES_DIR]
		end
	end
end
end

