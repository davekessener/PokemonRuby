module Pokemon
	module Text
		class Language
			include Utils::DynamicLoad

			def get(ids)
				t = @data
				ids.each do |id|
					break unless t.respond_to? :[]
					t = t[id]
				end

				t ? t.to_s : 'undefined'
			end

			private_class_method :new

			private

			def load_data(data)
				@data = data
			end

			def self.resource_path
				[Utils::DATA_DIR, Utils::LANG_DIR]
			end
		end

		def self.[](id)
			@@lang ||= Language[Utils::language]
			@@lang.get(id.to_s.split(/:/))
		end
	end
end

