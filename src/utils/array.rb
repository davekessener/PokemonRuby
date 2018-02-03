class FixedArray
	def initialize(n, &block)
		@array = Array.new(n)
		n.times { |i| @array[i] = block.call(i) } if block_given?
	end

	def resize(n)
		@array = Array.new(n) { |i| @array[i] }
	end

	def size
		@array.size
	end

	def [](i)
		raise if i < 0 or i >= size
		@array[i]
	end

	def []=(i, v)
		raise if i < 0 or i >= size
		@array[i] = v
	end

	def to_a
		@array.dup
	end

	alias_method :length, :size
end

