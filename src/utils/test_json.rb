require_relative 'json_enforcer'

type = Pokemon::Utils::Enforcer::generate 'random etstfile' do
	strict

	int 'width', 'width of the bitmap', [:optional] do
		constraint_positive
	end
	
	string 'id', 'alphanumerical indentifier' do
		constraint_not_empty
	end
	
	array 'group', 'list of coordinates' do
		constraint_not_empty

		every_tag :tag do
			array 'at', 'coordinate' do
				constrain_size 2

				every_tag :int
			end
		end
	end
end

data = type.load('src/utils/test.json')

puts data.width?
puts data.id
puts data.group[0].at

