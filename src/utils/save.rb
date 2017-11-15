module Pokemon
	module Utils
		class Save
			include DynamicLoad

			attr_reader :data

			private_class_method :new

			private

			def load_data(data)
				@data = data
				Text::globals[:player] = data['name']
				Text::globals[:rival] = data['rival']
			end

			def self.resource_path
				[SAVE_DIR]
			end
		end
	end
end

