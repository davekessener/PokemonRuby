class Object
	def to_o(*opts)
		setters, recurse = opts.include?(:setters), opts.include?(:recurse)

		type = setters ? :attr_accessor : :attr_reader

		Object.new.tap do |o|
			c = self
			c = c.to_h if not c.is_a? Hash and c.respond_to? :to_h
			c.each do |k,v|
				t = type

				if v.is_a? Hash and recurse
					v = v.to_o(**opts)
					t = :attr_reader
				end

				o.singleton_class.class_eval do
					send t, k
				end

				o.instance_variable_set :"@#{k}", v
			end
		end
	end
end

