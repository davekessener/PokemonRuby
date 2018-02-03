class BinaryHeap
	def initialize
		@elements = [nil]
	end

	def <<(e)
		insert e if e
		self
	end

	def insert(e)
		@elements << e

		swim(@elements.length - 1)

		e
	end

	def remove
		return nil if empty?

		exchange(1, @elements.length - 1)

		@elements.pop.tap { sink(1) }
	end

	def peek
		@elements[1]
	end

	def empty?
		@elements.length <= 1
	end

	def to_a!
		[].tap do |a|
			a << remove until empty?
		end
	end

	private

	def sink(idx)
		l = @elements.length

		while true
			child = idx * 2

			break unless child < l

			child += 1 if child < l - 1 and @elements[child] < @elements[child + 1]

			break unless @elements[idx] < @elements[child]

			exchange(idx, child)

			idx = child
		end
	end

	def swim(idx)
		while idx > 1
			parent = idx / 2

			break unless @elements[parent] < @elements[idx]

			exchange(idx, parent)

			idx = parent
		end
	end

	def exchange(i0, i1)
		@elements[i0], @elements[i1] = @elements[i1], @elements[i0]
	end
end

