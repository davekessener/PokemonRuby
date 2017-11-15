module Pokemon
	module Utils
		module DynamicLoad
			attr_reader :id

			def initialize(id)
				@id = id
			end

			def self.included(base)
				base.extend ClassMethods
			end

			module ClassMethods
				def [](id)
					@loaded_entities ||= {}
					id = id.to_s if id.is_a? Symbol
					raise ArgumentError, "Invalid id '#{id}'!" if not id.is_a? String
					load_entity(id) unless @loaded_entities[id]
					@loaded_entities[id]
				end

				def load_entity(id)
					path = resource_path
					path.push(*(id + '.json').split(/:/))
					fn = Utils::absolute_path(*path)
					Logger::log("loading JSON resource #{id} from '#{Utils::relative_path(fn)}'!")
					data = JSON.parse(File.read(fn))
					@loaded_entities[id] = new(id)
					@loaded_entities[id].send :load_data, data
				end
			end
		end
	end
end

