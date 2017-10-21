module Pokemon
	module UI
		class Border
			def initialize(id)
				@id = id
				fn = Utils::absolute_path(Utils::MEDIA_DIR, Utils::BORDER_DIR, "#{id}.png")
				Utils::Logger::log("Loading border '#{Utils::relative_path(fn)}'")
				@source = Gosu::Image.new(fn, {retro: true})
			end

			def draw(px, py, w, h, z)
				w, h = w / 2, h / 2
				@source.subimage(0, 0, w, h).draw(px, py, z)
				@source.subimage(@source.width - w, 0, w, h).draw(px + w, py, z)
				@source.subimage(0, @source.height - h, w, h).draw(px, py + h, z)
				@source.subimage(@source.width - w, @source.height - h, w, h).draw(px + w, py + h, z)
			end

			def self.[](id)
				@@borders ||= {}
				@@borders[id] = Border.new(id) unless @@borders[id]
				@@borders[id]
			end
		end
	end
end

