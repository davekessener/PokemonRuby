module Pokemon
	module Utils
		class Logger
			class Severity
				attr_reader :name, :level

				def initialize(name, level)
					@name = name
					@level = level
				end

				def <(s)
					@level < s.level
				end

				def to_str
					@name
				end

				alias_method :to_s, :to_str

				def to_int
					@level
				end

				alias_method :to_i, :to_int
			end

			INFO = Severity.new('INFO', 0)
			WARNING = Severity.new('WARNING', 1)
			ERROR = Severity.new('ERROR', 2)
			CRITICAL = Severity.new('CRITICAL', 3)

			class << self
				def log(msg, severity = INFO)
					@logs ||= [[], [], [], []]
					@thresh ||= INFO
					@lengths ||= {}

					c = caller_locations(1,1)[0]
					path = c.path.gsub("#{$root_dir}/",'')
					o = [msg, path, c.lineno, c.label, Time.utc(*Time.now.to_a)]

					@logs[severity] << o
					set_length(:severity, severity.to_s.length)
					set_length(:path, path.length)
					set_length(:name, c.label.length)

					puts format(severity, *o) unless severity < @thresh
				end

				def threshold=(t)
					@thresh = t
				end

				def print_all
					if @logs
						@logs.each_with_index do |level, severity|
							level.each do |o|
								puts format(severity, *o)
							end
						end
					end
				end

				private

				def format(severity, msg, path, line, name, time)
					s_sev = "%#{@lengths[:severity]}s" % severity.to_s
					s_path = "%-#{@lengths[:path]}s" % path
					s_name = "%-#{@lengths[:name]}s" % name
					"#{time} [#{s_sev}] #{s_path}:#{'%3d' % line} in #{s_name} '#{msg}'"
				end

				def set_length(id, l)
					@lengths[id] = [@lengths[id] || 0, l].max
				end
			end
		end
	end
end

