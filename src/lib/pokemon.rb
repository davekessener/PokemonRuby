module Pokemon
module Data
	class Pokemon
		attr_accessor :nickname, :species, :moves, :hp, :status

		def load(tag)
			@nickname = tag['nickname']
			@species = Species[tag['species'].to_sym]
			@moves = tag['moves'].map { |m| Move[m.to_sym] }
			@hp = tag['hp']
			@status = tag['status'].to_sym
		end
	end
end
end

