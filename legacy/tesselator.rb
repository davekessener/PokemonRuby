require 'Matrix'
require 'gosu'

module Pokemon
	class Tesselator
		attr_accessor :z

		def initialize
			@stack = []
			@z = 0
			reset
		end

		def render
			@queue.each do |img, v, z, c|
				p0, p1, p2, p3 = *v
				img.draw_as_quad(
					p0[0], p0[1], c,
					p1[0], p1[1], c,
					p2[0], p2[1], c,
					p3[0], p3[1], c,
					z)
			end
			clear
		end

		def translate(dx, dy)
			@matrix *= Matrix[[1, 0, dx], [0, 1, dy], [0, 0, 1]]
		end

		def rotate(angle)
			s, c = Math::sin(angle), Math::cos(angle)
			@matrix *= Matrix[[c, -s, 0], [s, c, 0], [0, 0, 1]]
		end

		def push
			@stack.push @matrix
			self
		end

		def pop
			@matrix = @stack.pop
			self
		end

		def clear
			@queue = []
			self
		end

		def reset
			@matrix = Matrix.identity(3)
			clear
		end

		def draw_image(img, x, y, c = Gosu::Color::WHITE)
			a = [[x, y], [x + img.width, y], [x + img.width, y + img.height], [x, y + img.height]]
			a.map! do |px, py|
				m = @matrix * Matrix.column_vector([px, py, 1])
				v = m.column(0).to_a
				v.pop
				v
			end
			@queue << [img, a, @z, c] unless a.none? { |px, py| Utils::on_screen(px, py) }
			self
		end
	end
end

