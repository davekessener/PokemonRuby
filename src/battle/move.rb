module Pokemon
module Battle
	class Move
		attr_reader :id, :power, :accuracy, :category
		attr_reader :types, :priority, :tags, :effects

		def initialize(data)
			@id = data['id'].to_sym
			@power = data['power']
			@accuracy = data['accuracy'] / 100.0
			@category = data['category'].to_sym
			@types = data['types'].map { |t| Type[t] }
			@priority = data['priority']
			@effects = (data['effects'] || [])
			@tags = data['tags'].map { |t| t.to_sym }
			@action = data['handler']

			@effects = @effects.map { |eid| Object::const_get(eid).new(self) }
			@action = @action.nil? ? MoveAction : Object::const_get(@action)
		end

		def self.[](id)
			unless @moves
				@moves = {}
				Utils::load_json(Utils::DATA_DIR, Utils::GAMEDATA_DIR, 'moves.json').each do |move|
					o = new(move)
					@moves[o.id] = o
				end
			end
			@moves[id.to_sym] if id
		end

		private_class_method :new
	end
end
end

