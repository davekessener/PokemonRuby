module Pokemon
	module Text
		def self.globals
			@@globals ||= {}
		end

		class Evaluator < BasicObject
			def method_missing(name)
				g = ::Pokemon::Text::globals
				if g[name.to_sym]
					g[name.to_sym].to_s
				else
					super
				end
			end

			def player
				$world.player.data.name
			end
		end

		class Language
			include Utils::DynamicLoad

			def get(ids)
				t = @data
				ids.each do |id|
					break unless t.respond_to? :[]
					t = t[id]
				end

				if t
					Utils::Logger::log("String primitive '#{ids.join(':')}' is '#{t}'.")
					(Evaluator.new.instance_eval "\"#{t.gsub(/\\/, '^')}\"").gsub(/\^/, '\\')
				else
					'undefined'
				end
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

