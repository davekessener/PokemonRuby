module Pokemon
	module UI
		class TextWindow < Window
			attr_reader :renderer, :charset

			def initialize(s, z, charset, border)
				sw, sh = Utils::SCREEN_SIZE[0], Utils::SCREEN_SIZE[1]
				h = 0

				if Utils::gen == 2
					h = 6 * charset.char_height
				else
					h = 3 * charset.char_height
				end
					
				super(0, sh - h, sw, h, z, border)

				@charset = charset
				@controller = Action::Controller.new(self)

				paragraphs = s.split("\n\n").map { |p| p.split("\n") }
				paragraphs.reject &:empty?

				paragraphs.each_with_index do |p, j|
					s = p.size - 1
					p.each_with_index do |l, i|
						@controller.add(DisplayTextAction.new(self, l), :ui)
						unless i == 0 or i == s
							@controller.add(InputAction.new(self, [:A, :B]), :ui)
							@controller.add(ScrollTextAction.new(self), :ui)
						end
					end
					@controller.add(InputAction.new(self, [:A, :B]) { renderer.reset }, :ui) unless j == paragraphs.size - 1
				end

				if Utils::gen == 2
					@renderer = TextRenderer.new(self,
						self.x + 3 * charset.char_height / 2,
						self.y + 3 * charset.char_height / 2,
						2 * charset.char_height)
				elsif Utils::gen == 3
					@renderer = TextRenderer.new(self, 
						self.x + border.offset[:x],
						self.y + border.offset[:y],
						charset.char_height)
				end
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
			attr_accessor :displace, :wait, :color
			attr_reader :px, :py

			def initialize(object, px, py, h)
				super(object)
				@px, @py = px, py
				@char_height = h
				@color = 0
				new_line
			end

			def new_line
				@old_line = @cur_line
				@cur_line = []
				@displace = 0.0
				@old_line = nil if @old_line and @old_line.empty?
			end

			def <<(ch)
				@cur_line << [ch, @color]
			end

			def draw
				y = @py

				if @old_line
					object.charset.draw(@old_line, @px, y, object.z + 1)
					y += @char_height
				end

				x = object.charset.draw(@cur_line, @px, y, object.z + 1)

				if @wait
					p = (((Gosu::milliseconds / 125) % 5) - 2).abs
					object.charset.draw([['^', 4]], x + 1, y - p, object.z + 1)
				end
			end

			def reset
				@cur_line = nil
				new_line
			end
		end
	end
end

