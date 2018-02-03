module Pokemon
module Battle
	class Nature
		Modifier = 0.15

		attr_reader :id

		def initialize(id, buf, red)
			@id, @buf, @red = id, buf, red
		end

		def modifier(stat)
			1.0 + (Modifier if stat == @buf).to_i - (Modifier if stat == @red).to_i
		end

		def self.[](id)
			@natures ||= [
				new(:hardy, :atk, :atk),
				new(:lonely, :atk, :def),
				new(:brave, :atk, :ini),
				new(:adamant, :atk, :spa),
				new(:naughty, :atk, :spd),
				new(:bold, :def, :atk),
				new(:docile, :def, :def),
				new(:relaxed, :def, :ini),
				new(:impish, :def, :spa),
				new(:lax, :def, :spd),
				new(:timid, :ini, :atk),
				new(:hasty, :ini, :def),
				new(:serious, :ini, :ini),
				new(:jolly, :ini, :spa),
				new(:naive, :ini, :spd),
				new(:modest, :spa, :atk),
				new(:mild, :spa, :def),
				new(:quiet, :spa, :ini),
				new(:bashful, :spa, :spa),
				new(:rash, :spa, :spd),
				new(:calm, :spd, :atk),
				new(:gentle, :spd, :def),
				new(:sassy, :spd, :ini),
				new(:careful, :spd, :spa),
				new(:quirky, :spd, :spd)
			].map { |n| [n.id, n] }.to_h
			@natures[id.to_sym] if id
		end

		private_class_method :new
	end
end
end

