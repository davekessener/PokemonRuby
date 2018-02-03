module Pokemon
module Data
	class Move
		include Utils::DynamicLoad

		attr_reader :name, :category, :power, :accuracy
		attr_reader :priority, :pps, :modifiers

		private_class_method :new

		private

		def load_data(data)
			@name = data['name']
			@category = data['category'].to_sym
			@power = data['power']
			@accuracy = data['accuracy']
			@pps = data['pp']
			@modifiers = data['modifiers'].map(&:to_sym)
		end

		def self.resource_path
			[Utils::POKEMON_DIR, Utils::MOVE_DIR]
		end
	end
end
end

