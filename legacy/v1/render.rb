module Pokemon
	module Render
		def self.[](id)
			@@default_renderer ||= Standing.new
			@@renderers ||= {
				default: @@default_renderer,
				tall_grass: TallGrass.new(:standing, @@default_renderer)
			}

			r = @@renderers[id]

			if not r
				Utils::Logger::log("unknown render factory '#{id}'!", Utils::Logger::WARNING)
				r = @@default_renderer
			end

			r
		end

		class Base
			attr_accessor :progress

			def sub_renderer(id)
				@@default_renderer ||= Standing.new
				@@default_subs ||= {
					standing: @@default_renderer,
					walking: Walking.new,
					jumping: Jumping.new,
					failed_walking: FailedWalking.new
				}

				@@default_subs.fetch(id, @@default_renderer)
			end
		end

		class Standing < Base
			def draw(object)
				s = object.sprite
				if s
					Gosu::translate(*Utils::center_object(s)) do
						s.draw([object.facing], 0.0, object.x, object.y, Utils::get_z(object.type))
					end
				end
			end
		end

		class Walking < Base
			def draw(object)
				@progress ||= 0.0

				s = object.sprite
				if s
					p = [object.facing, :walking, object.movement.steps % 2]

					Gosu::translate(*Utils::center_object(s)) do
						s.draw(p, @progress, object.x, object.y, Utils::get_z(object.type))
					end
				end
			end
		end

		class Jumping < Base
			def draw(object)
				@progress ||= 0.0
				@shadow ||= Sprite['shadow']

				s = object.sprite
				if s
					path = [object.facing, :walking, object.movement.steps % 2]
					n = (@progress * 2 * Utils::TILE_SIZE).to_i
					z = Utils::get_z(object.type)

					if not @trans or @old != n
						@trans = Jumping::translate(object.facing, @progress)
						@old = n
					end

					Gosu::translate(*Utils::center_object(s)) do
						@shadow.draw([], @progress, object.x, object.y, z - 1)

						Gosu::translate(@trans.dx, @trans.dy) do
							s.draw(path, @progress, object.x, object.y, z)
						end
					end
				end
			end

			def self.translate(dir, p)
				Utils::Directions[:up] * Utils::TILE_SIZE * 0.75 * Math.sin(p * Math::PI)
			end
		end

		class FailedWalking < Base
			def draw(object)
				@progress ||= 0.0

				s = object.sprite
				if s
					Gosu::translate(*Utils::center_object(s)) do
						p = [object.facing, @progress >= 0.7 ? 'standing' : 'walking', object.movement.steps % 2]
						s.draw(p, @progress, object.x, object.y, Utils::get_z(object.type))
					end
				end
			end
		end

		class TallGrass < Base
			def initialize(anim, parent)
				@animation = anim
				@parent = parent
			end

			def sub_renderer(id)
				@@renderers ||= {
					standing: TallGrass.new(:standing, Standing.new),
					walking: TallGrass.new(:walking, Walking.new),
					failed_walking: TallGrass.new(:standing, FailedWalking.new)
				}

				@@renderers.fetch(id, super(id))
			end

			def draw(object)
				@parent.draw(object)

				@progress ||= 0.0

				@parent.progress = @progress

				s = object.sprite
				if s
					@@sprite ||= Sprite['tall_grass']

					@@sprite.draw([@animation], @progress, object.x, object.y, Utils::get_z(object.type) + 1)
				end
			end
		end
	end
end

