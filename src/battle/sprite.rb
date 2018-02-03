module Pokemon
module Battle
	class BattleSprite
		def initialize(id)
			fn_f = Utils::absolute_path(Utils::MEDIA_DIR, Utils::BATTLE_DIR, "front", "#{id}.png")
			fn_b = Utils::absolute_path(Utils::MEDIA_DIR, Utils::BATTLE_DIR, "back", "#{id}.png")
			@front = Gosu::Image.new(fn_f)
			@back = Gosu::Image.new(fn_b)
		end

		def self.[](id)
			@@sprites ||= {}
			@@sprites[id] = new(id) unless @@sprites[id]
			@@sprites[id]
		end

		private_class_method :new
	end
end
end

