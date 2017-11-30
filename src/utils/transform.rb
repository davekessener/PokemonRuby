module Pokemon
module Utils
	class Transform
		def initialize(o, id, &f)
			@object = o
			define_singleton_method id do |*args|
				f.call(*args)
			end
		end

		def respond_to_missing?(name, inc_private = false)
			@object.respond_to?(name, inc_private) or super
		end

		def method_missing(name, *args, &block)
			if @object.respond_to? name
				@object.send name, *args, &block
			else
				super
			end
		end
	end
end
end

