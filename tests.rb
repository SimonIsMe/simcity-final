load 'game.rb'

require 'test/unit'
require 'rack/test'

#ENV['RACK_ENV'] = 'test'

class HelloWorldTest < Test::Unit::TestCase
  include Rack::Test::Methods

	def init
		width = 20
		height = 20
	
		File.open('./status/0.txt', 'w') { |out|
			out.write width.to_s + "\n";
			out.write height.to_s + "\n";

			#  mapa
			map = ''
			count = width * height
			count.times do
				map = map + '0'
			end
			out.write map + "\n"

			#zanieczyszczenia
			out.write map + "\n"

			#popyt
			out.write map + "\n"

			#  budżet
			money = 100000;
			out.write money.to_s + "\n"

			#  budżet w przyszłości
			future = 100000;
			out.write future.to_s + "\n"

			#  popyt na strefę przemysłową
			out.write "8\n"

			#  popyt na strefę komercyjną
			out.write "8\n"

			#  popyt na strefę mieszkalną
			out.write "8\n"

			#  budynki specjalne
			count.times do
				out.write "0\n"
			end

			#  podatki
			out.write "9\n"
			out.write "9\n"
			out.write "9\n"

			#  liczba ludzi (mieszkańców lub miejsc pracy) w danym obszarze
			count.times do
				out.write "0\n"
			end

			out.close
		}
	end

	def test_create_area
		init()
		
		game = Game.new(0)
		game.buildArea(0,0, 10,4, 2)
		assert_equal game.map[(20*0 + 0)], 2
		assert_equal game.map[(20*0 + 19)], 0
		assert_equal game.map[(20*0 + 4)], 2
		assert_equal game.map[(20*3 + 4)], 2
	end

	def test_it_says_hello_to_a_person
		
	end
end
