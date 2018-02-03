class Object
	def try
		yield self unless nil? or not block_given?
		self
	end
end

