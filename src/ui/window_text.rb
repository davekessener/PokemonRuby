module Pokemon
	module UI
		class TextWindow < Window
			attr_reader :renderer, :charset

			def initialize(s, z, charset, border)
				super(0, Utils::SCREEN_SIZE[1] - 6 * charset.char_height, Utils::SCREEN_SIZE[0], 6 * charset.char_height, z, border)
				@charset = charset
				@controller = Action::Controller.new(self)

				paragraphs = s.split("\r").map { |p| p.split("\n") }
				paragraphs.reject &:empty?

				paragraphs.each_with_index do |p, j|
					s = p.size - 1
					p.each_with_index do |l, i|
						@controller << DisplayTextAction.new(self, l)
						unless i == 0 or i == s
							@controller << InputAction.new(self, [:A, :B]) << ScrollTextAction.new(self)
						end
					end
					@controller << (InputAction.new(self, [:A, :B]) { renderer.reset }) unless j == paragraphs.size - 1
				end

				@renderer = TextRenderer.new(self, 
					self.x + 3 * charset.char_width / 2, 
					self.y + 3 * charset.char_height / 2,
					2 * charset.char_height)
			end

			def done?
				@controller.empty?
			end

			def press(id)
				e = @controller.active
				e.accept id if e and e.respond_to? :accept
			end
		end

		class TextRenderer < Component
			attr_accessor :displace, :wait
			attr_reader :px, :py

			def initialize(object, px, py, h)
				super(object)
				@px, @py = px, py
				@char_height = h
				new_line
			end

			def new_line
				@old_line = @cur_line
				@cur_line = ''
				@displace = 0.0
				@old_line = nil if @old_line and @old_line.empty?
			end

			def <<(c)
				@cur_line += c
			end

			def draw
				y = @py

				if @old_line
					object.charset.draw(@old_line, @px, y, object.z + 1)
					y += @char_height
				end

				object.charset.draw(@cur_line, @px, y, object.z + 1)

				if @wait
					p = (Gosu::milliseconds / 1200) % 2
					object.charset.draw("\x02", object.x + object.width - 3 * object.charset.char_width, object.y + object.height - 3 * object.charset.char_height / 2 + p, object.z + 1)
				end
			end

			def reset
				@cur_line = nil
				new_line
			end
		end
	end
end

