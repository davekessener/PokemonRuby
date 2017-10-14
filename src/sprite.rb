module Pokemon
	class Sprite
		include Utils::DynamicLoad

		attr_reader :width, :height

		def draw(path, p, x, y, z)
			f = @frames
			path.each { |id| f = f[id.to_s] }
			@source[f.frame(p)].draw(x, y, z)
		end

		private_class_method :new

		private

		class Frame
			attr_reader :default

			def initialize(data)
				if data['at']
					@frames = [ Frame::get_index(*data['at']) ]
				elsif data['frames']
					@frames = data['frames'].map do |frame|
						Frame::get_index(*frame['at'])
					end
				elsif data['group']
					@children = {}
					data['group'].each do |e|
						t = Frame.new(e)
						@default = t if e['default']
						@children[e['id']] = t
						e['alias'].each { |a| @children[a] = t } if e['alias']
					end
				elsif data['alternatives']
					@children = {}
					data['alternatives'].each_with_index do |alt, i|
						t = Frame.new(alt)
						@default = t if alt['default']
						@children[i.to_s] = t
					end
				end
				@default = self unless @default
			end

			def [](id)
				if @children[id]
					@children[id]
				else
					@default
				end
			end

			def frame(p)
				@frames[(p * @frames.size).to_i]
			end

			def self.get_index(x, y)
				x + y * 8 # TODO REMOVE FUCKING MAGIC CONSTANT!
			end
		end

		def load_data(data)
			fn = Utils::absolute_path(Utils::MEDIA_DIR, Utils::SPRITE_DIR, data['source'])
			Logger::log("Loading spritesheet for #{id} from #{Utils::relative_path(fn)}")
			@width = data['width']
			@height = data['height']
			@source = Gosu::Image.load_tiles(fn, @width, @height, {retro: true})
			@frames = Frame.new(data)
		end

		def self.resource_path
			[Utils::DATA_DIR, Utils::SPRITE_DIR]
		end

		def self.json_loader
			@@loader ||= Sprite::generator
		end

		def self.generator
			recurse = Utils::Enforcer::CompoundGenerator.new('frame', [:optional]) do
				strict

				string 'id', 'alphanumerical identifier' do
					constraint_not_empty
				end

				bool 'default', 'designates default path', [:optional]

				array 'at', 'frame index coordinates', [:optional] do
					constraint_size 2

					every_tag :int
				end

				array 'alias', 'alias identifiers', [:optional] do
					constraint_not_empty

					every_tag :string do
						constraint_not_empty
					end
				end

				array 'alternatives', 'list of frames to alternate between', [:optional] do
					constraint_not_empty

					every_tag :tag do
						array 'at', 'frame index coordinates' do
							constraint_size 2

							every_tag :int
						end
					end
				end
				
				array 'group', 'list of sub-frames', [:optional] do
					constraint_not_empty

					every_tag :tag
				end
			end

			recurse.content['group'].gen = recurse

			generator = Utils::Enforcer::generate 'sprite' do
				strict

				string 'source', 'path of source image' do
					constraint_not_empty
				end

				int 'width', 'frame width in pixels' do
					constraint_positive
				end

				int 'height', 'frame height in pixels' do
					constraint_positive
				end

				array 'group', 'root of frame tree' do
					constraint_not_empty

					every_tag :tag
				end
			end

			generator.content['group'].gen = recurse

			generator
		end
	end
end

