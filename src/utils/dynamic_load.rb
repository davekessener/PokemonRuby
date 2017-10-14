module Pokemon
	module Utils
		module DynamicLoad
			attr_reader :id

			def initialize(id, data)
				@id = id
				load_data(data)
			end

			def self.included(base)
				base.extend ClassMethods
			end

			module ClassMethods
				def [](id)
					@loaded_entities ||= {}
					raise ArgumentError, "Invalid id '#{id}'!" if not id.is_a? String
					load_entity(id) unless @loaded_entities[id]
					@loaded_entities[id]
				end

				def load_entity(id)
					path = resource_path
					path << "#{id}.json"
					fn = Utils::absolute_path(*path)
					Logger::log("loading JSON resource '#{Utils::relative_path(fn)}'!")
					data = JSON.parse(File.read(fn))
					@loaded_entities[id] = new(id, data)
				end
			end
		end
	end
end

