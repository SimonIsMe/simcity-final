# -*- encoding : utf-8 -*-

class Game

    attr_reader :width, :height, :map, :pollution, :demand, :money, :future, :demandI, :demandC, :demandR, :taxI, :taxC, :taxR, :population, :pollutionAverage, :builds, :people, :workPlace, :userID, :tips;
    attr_writer :taxI, :taxC, :taxR

	TIP_POLLUTION = "Zbyt duże zanieczyszczenie. Zrób coś z tym!"
	TIP_SCHOOL = "Brakuje szkół."
	TIP_WORK_PLACE = "Brakuje miejsc pracy."
	TIP_TAX_R = "Podatek mieszkalny jest za duży."
	TIP_TAX_C = "Obniż podatki strefy komercyjnej, aby zwiększyć popyt."
	TIP_TAX_I = "Podatek przemysłowy jest za duży."
	TIP_MONEY = "Świetna sytuacja finansowa!"

    #wymairy mapy
    @width = 20
    @height = 20
    
    #mapa
    @map = []
    
    #zanieczyszczenie
    @pollution = []
    
    #popyt
    @demand = []
    
    #obecny stan finansów
    @money = 0
    
    #stan pieniędzy w następnym okresie rozliczeniowym
    @future = 0
    
    #popyt na strefy: przemysłową, komenrcyjną, mieszkalną
    @demandI = 0
    @demandC = 0
    @demandR = 0
    
    #podatki na strefy
    @taxI = 9
    @taxC = 9
    @taxR = 9
    
    #liczba mieszkańców/miejsc pracy w danym obszarze
    @population = []
    
    #średnia populacji
    @pollutionAverage = 0;

    @builds = []
    
    #mieszkańców w sumie
    @people = 0
    
    #miejsc pracy w sumie
    @workPlace = 0

    #   dane użytkownika z Facebook'a
    @userID = 0
    
    #	podpowiedzi
    @tips = []

    def initialize (userID)
        @userID = userID;

        file = File.new("./status/" + userID.to_s + ".txt", "r")

        @width = file.gets.to_s.to_i
        @height = file.gets.to_s.to_i

        count = @width * @height;

        #   mapa
        @map = []
        line = file.gets;
		map = line.split("");
		map.each { |el|
			@map << el.to_i
		}
	
        #   zanieczyszczenie
        @pollution = []
        @pollutionAverage = 0;
        pollution = file.gets.split("");
        pollution.each { |el|
            @pollution << el.to_i
            @pollutionAverage += el.to_i
        }
        @pollutionAverage = @pollutionAverage / count


        #   popyt
        @demand = []
        demand = file.gets.split("");
        demand.each { |el|
            @demand << el.to_i
        }

        #   budżet
        @money = file.gets.to_f

        #   budżet w przyszłości
        @future = file.gets.to_f

        #  popyt na strefy
        @demandI = file.gets.to_i
        @demandC = file.gets.to_i
        @demandR = file.gets.to_i;

        #   budynki specjalne
        @builds = []
        count.times do
            @builds << file.gets.to_i
        end

        #   podatki
        @taxI = file.gets.to_f
        @taxC = file.gets.to_f
        @taxR = file.gets.to_f

        #   populacja
        @population = []
        count.times do
            @population << file.gets.to_i
        end

        file.close
        
        @tips = []

        countPeopleAndWorkPalces();
    end

    def countPeopleAndWorkPalces
		limit = @width * @height
		i = 0
        @people = 0
        @workPlace = 0
		limit.times do
			if (@map[i] == 2) then
                @people += @population[i]
            end
            if (@map[i] == 3 || @map[i] == 4) then
                @workPlace += @population[i]
            end
            i = i + 1
		end
    end

    def buildArea (x_from, y_from, x_to, y_to, areaType)
		#	liczę wysokość i szerokość prostokąta
        width = (x_from - x_to).abs
        height = (y_from - y_to).abs

		#	porzędkuję wilekości x, y, tak aby mniejsze były przy _from
        if (x_from > x_to) then
            buffor = x_from
            x_from = x_to
            x_to = buffor
        end
        if (y_from > y_to) then
            buffor = y_from
            y_from = y_to
            y_to = buffor
        end

        position_x = [];
        position_y = [];

		# liczba ograniczająca iteracje
        y_limit = y_to - y_from + 1
		y = y_from;

		y_limit.times do
			x_limit = x_to - x_from + 1
			x = x_from
			x_limit.times do
				position_x << x
				position_y << y
				x = x + 1
			end
			y = y + 1
		end

        i = 0
        position_x.each { |pos_x|
			position = pos_x + @width * position_y[i]
			@map[position] = areaType
			i = i + 1
        }

        @money = @money - (width + 1) * (height + 1) * 15;
        save();
    end

    def buildRoad (x_from, y_from, x_to, y_to)
        width = (x_from - x_to).abs
        height = (y_from - y_to).abs

        if (x_from < x_to) then
            x_tmp_from = x_from
            x_tmp_to = x_to
            x2 = x_from
        else
            x_tmp_from = x_to
            x_tmp_to = x_from
            x2 = x_to
        end

        if (y_from <= y_to) then
            y_tmp_from = y_from
            y_tmp_to = y_to
        else
            y_tmp_from = y_to
            y_tmp_to = y_from
        end

        position_x = []
        position_y = []

        if (width > height) then
            #leży
            limit = x_tmp_to - x_tmp_from + 1;
            x = x_tmp_from;
            limit.times do
				position_x << x
				position_y << y_from
				x = x + 1
            end

            limit = y_tmp_to - y_tmp_from + 1
            y = y_tmp_from
            limit.times do
				position_x << x_to
				position_y << y
				y = y + 1
            end
        else
            #  stoi lub kwadrat
            limit = x_tmp_to - x_tmp_from + 1
            x = x_tmp_to
            limit.times do
				position_x << x
				position_y << y_to
				x = x - 1
            end

            limit = y_tmp_to - y_tmp_from + 1
            y = y_tmp_to
            limit.times do
				position_x << x_from
                position_y << y
                y = y - 1
            end
        end

        i = 0
        position_x.each { |pos_x|
			position = pos_x + @width * position_y[i]
			if (@map[position] > 4) then
				# nie można wybudować drogi
				return false
			end
			i = i + 1
        }

        i = 0
        position_x.each { |pos_x|
			position = pos_x + @width * position_y[i]
			@map[position] = 1
			i = i + 1
        }

        # ilość obszarów, na których powstanie droga
        areas = width + height + 1;

        @money = @money - areas * 10;
        @future = @future - areas * 0.3;

        save();

        return true;
    end

    def remove(x, y)
        pos = x + @width * y;

        if (@map[pos] == 1) then
            #  usuwam drogę
            @map[pos] = 0;
        end

        if (@map[pos] == 5) then
            # usuwam budynek

            if (@builds[pos] == 1 || @builds[pos] == 6) then
                pos = x + @width * y;
                pos2 = pos + 1
                pos3 = x + @width * (y + 1)
                pos4 = pos3 + 1
            end

            if (@builds[pos] == 2 || @builds[pos] == 7) then
                pos = pos - 1
                pos2 = pos + 1
                pos3 = (x - 1) + @width * (y + 1)
                pos4 = pos3 + 1
            end

            if (@builds[pos] == 3 || @builds[pos] == 8) then
                pos = x + @width * (y - 1)
                pos2 = pos + 1
                pos3 = x + @width * y
                pos4 = pos3 + 1
            end

            if (@builds[pos] == 4 || @builds[pos] == 9) then
                pos = (x - 1) + @width * (y - 1)
                pos2 = pos + 1
                pos3 = (x - 1) + @width * y
                pos4 = pos3 + 1
            end

            @map[pos] = 0;
            @map[pos2] = 0;
            @map[pos3] = 0;
            @map[pos4] = 0;

            @builds[pos] = 0;
            @builds[pos2] = 0;
            @builds[pos3] = 0;
            @builds[pos4] = 0;
        end

        @map[pos] = 0;
        save();
    end

    #
    # Zwraca tablicę z kluaczmi sąsiadów danego pola
    #
    # @param int x
    #@param int y
    #@return int
    #
    def getNeighbour(x, y)
		q = []
        if (y > 0) then
            q[2] = x + @width * (y - 1)
        end
        if (x > 0) then
            q[4] = x - 1 + @width * y;
            if (y > 0) then
                q[1] = x - 1 + @width * (y - 1)
            end
            if (y < @height) then
                q[6] = x - 1 + @width * (y + 1)
            end
        end

        if (x < @width) then
            q[5] = x + 1 + @width * y
            if (y > 0) then
                q[3] = x + 1 + @width * (y - 1)
            end
            if (y < @height) then
                q[8] = x + 1 + @width * (y + 1)
            end
        end

        if (y < @height) then
            q[7] = x + @width * (y + 1)
        end

        toReturn = []

        i = 1;
        7.times do
			if (q[i] != null) then
				toReturn << q[i]
			end
			i = i + 1
        end

        return toReturn
    end

    def update()
        updateResidentalTax()
        updateCommercialTax()
        updateIndustryTax()

        updatePollution()

        updateResidentalDemand()
        updateCommercialDemand()
        updateIndustryDemand()

        updateResidentalPopulation()
        updateCommercialPopulation()
        updateIndustryPopulation()

        updateRandomReducePopulation()

        countPeopleAndWorkPalces()
        
        if (@money > 100000 && @future > 10000) then
			@tips << TIP_MONEY
        end

        save()
    end

    def updateRandomReducePopulation()
		i = 0;
		(@width * @height).times do
			if (@population[i] > 0) then
				if (rand(10) < 2) then
					@population[i] = @population[i] - 20
				end
			end
			i = i + 1
		end
    end

    def updatePollution()
		i = 0
		pollution = 0
    	(@width * @height).times do
			pollution += @pollution[i]
			if (@map[i] == 5 && @builds[i] == 1) then
				#elektrownia
				x = i % @width;
                y = (i - x) / @width;

                @pollution[getKey(x, y)] = 9
                @pollution[getKey(x, y+1)] = 9
                @pollution[getKey(x+1, y)] = 9
                @pollution[getKey(x+1, y+1)] = 9

                if (x > 0) then
                    @pollution[getKey(x-1, y)] = 4
                    @pollution[getKey(x-1, y+1)] = 4
                end

                if (x < @width) then
                    @pollution[getKey(x+2, y)] = 4
                    @pollution[getKey(x+2, y+1)] = 4
                end

                if (y > 0) then
                    @pollution[getKey(x, y-1)] = 4
                    @pollution[getKey(x+1, y-1)] = 4
                end

                @pollution[getKey(x, y+2)] = 4
                @pollution[getKey(x+1, y+2)] = 4
			elsif (@map[i] == 4) then
				#	strefa przemysłowa
				if @population[i] < 40 then
					@pollution[i] += 2
				elsif @population[i] < 80 then
					@pollution[i] += 4
				elsif @population[i] >= 80 then
					@pollution[i] += 5
				end
			elsif (@map[i] == 3) then
				#	strefa komenrcyjna
				if @population[i] < 40 then
					@pollution[i] += 0
				elsif @population[i] < 80 then
					@pollution[i] += 1
				elsif @population[i] >= 100 then
					@pollution[i] += 2
				end
			elsif (@map[i] == 2) then
				#	strefa mieszkalna
				if @population[i] > 40 then
					@pollution[i] += 1
					#@pollution[i] = 10
				end
			end
			
			if rand(10) < 5 then
				@pollution[i] -= 2;
			end
			
			
			if (@pollution[i] < 0) then
				@pollution[i] = 0
			end
			if (@pollution[i] > 9) then
				@pollution[i] = 9
			end
			
			i = i + 1
    	end
    	
    end

    def getKey(x, y)
		return y.to_i * @width + x.to_i
    end
    
    def updateResidentalDemand()
        people = 0
        workPlace = 0

        i = 0
        (@width * @height).times do
			if (@map[i] == 2) then
                people += @population[i];
            elsif (@map[i] == 3 || @map[i] == 4) then
                workPlace += @population[i];
            end
			i = i + 1
        end

        if (people == 0) then
            @demandR = 8;
        else
            countElementarySchools = 0;

            #  ile jest szkół?
            count = @width * @height;
            i = 0
            count.times do
				if @map[i] == 5 && @builds[i] == 6 then
					countElementarySchools += 1
				end
				i = i + 1
            end
            
            isGoodElementarySchool = people / 1000 < countElementarySchools;

			# odpowiedni podatek?
            maxTax = 10
            if (@taxR < 10) then
                @demandR = -0.2 * @taxR + 14
            else
                @demandR = -4 * @taxR + 6
                @tips<< TIP_TAX_R
            end

			#	odpowiednia liczba szkół?
            if (isGoodElementarySchool) then
                @demandR += 1
            else
                @demandR -= 9
                @tips<< TIP_SCHOOL
            end

			# odpowiednia liczba miejsc pracy?
			if  workPlace / people < 0.8 || (people > 100 && workPlace == 0) then
				@demandR -= 7
				@tips<< TIP_WORK_PLACE
			elsif workPlace / people > 1.2 then
				@demandR += 1
			else
				@demandR += 2
			end
            
        end

        if (@demandR > 10) then
            @demandR = 10;
        end
        if (@demandR < -10) then
            @demandR = -10;
        end
    end

	# liczy średnie zanieczyszczenie
	def getAverPollution()
		pollutionCount = 0;
		i = 0;		
		(@width * @height).times do
			pollutionCount += @pollution[i]
			i = i + 1
		end
		return pollutionCount / (@width * @height);
	end

    def updateCommercialDemand()
		#średnie zanieczyszczenie
		pollutionCount = getAverPollution();
		if (pollutionCount < 1) then
			@demandC =- 2
		elsif (pollutionCount < 3) then
			@demandC =- 5
			@tips << TIP_POLLUTION
		elsif (pollutionCount < 5) then
			@demandC =- 8
			@tips << TIP_POLLUTION
		elsif (pollutionCount < 9) then
			@demandC =- 12
			@tips << TIP_POLLUTION
		end
		
		# wielkość miasta (liczba mieszkańców)
		peopleCount = 0
		i = 0
		(@width * @height).times do
			if (@map[i] == 2) then
				peopleCount += @population[i]
			end
		end
		if (peopleCount < 1000) then
			@demandC =+ 2
		elsif (peopleCount < 5000) then
			@demandC =+ 4
		elsif (peopleCount < 10000) then
			@demandC =+ 6
		end
		
		#  określam maxymalny akceptowany podatek w zależności od liczby mieszkańców (rozmiarów miasta)
        if (people < 10000) then
            maxTax = 5
        elsif (people < 100000) then
            maxTax = 7
        elsif (people < 1000000) then
            maxTax = 9
        else 
			maxTax = 11
		end
        percent = @taxC / maxTax
        if percent > 1 then
			@tips<< TIP_TAX_C
        end
        @demandC = (10 - (percent * 5)).to_i
		
		# "zaokrąglanie"
		if (@demandC > 10) then
            @demandC = 10;
        end
        if (@demandC < -10) then
            @demandC = -10;
        end
    end

    def updateIndustryDemand()
        people = 0
        i = 0
        (@width * @height).times do
			if (@map[i] == 2) then
                people += @population[i];
            end
            i += 1
        end

		maxTax = 9;

        #  określam maxymalny akceptowany podatek w zależności od liczby mieszkańców (rozmiarów miasta)
        if (people < 10000) then
            maxTax = 9
        elsif (people < 100000) then
            maxTax = 10
        elsif (people < 1000000) then
            maxTax = 11
        end

        percent = @taxI / maxTax
		if percent > 1 then
			@tips << TIP_TAX_I
        end
        @demandI = (10 - (percent * 5)).to_i
    end

    def updateResidentalPopulation()
		i = 0
		(@width * @height).times do
            if (@map[i] == 2) then
				demand = @demandR
				if @demand[i] == 1 then
					# jest prąd
					demand =+ 4
				end
                if (demand > 0) then
					if rand(30) < demand then
						@population[i] += 20;
					end
                else
					if rand(10) < demand then
						@population[i] -= 20;
					end
                end
            end

            if (@population[i] > 100) then
                @population[i] = 100;
            end
            if (@population[i] < 0) then
                @population[i] = 0;
            end
            i = i + 1
        end
    end

    def updateCommercialPopulation()
        i = 0
		(@width * @height).times do
            if (@map[i] == 3) then
				demand = @demandC
				if @demand[i] == 1 then
					# jest prąd
					demand =+ 4
				end
                if (demand > 0) then
					if rand(10) < demand then
						@population[i] += 20;
					end
                else
					if rand(10) < 3 then
						@population[i] -= 20
                    end
                end

            end

            if (@population[i] > 100) then
                @population[i] = 100;
            end
            if (@population[i] < 0) then
                @population[i] = 0;
            end
            i = i + 1
        end
    end

    def updateIndustryPopulation()
        i = 0
		(@width * @height).times do
            if (@map[i] == 4) then
				demand = @demandI
				if @demand[i] == 1 then
					# jest prąd
					demand =+ 4
				end
                if (demand > 0) then
					if rand(10) < demand then
						@population[i] += 20;
					end
                else
					if rand(10) < 5 then
						@population[i] -= 20;
                    end
                end

            end

            if (@population[i] > 100) then
                @population[i] = 100;
            end
            if (@population[i] < 0) then
                @population[i] = 0;
            end
            i = i + 1
        end
    end

    def updateCommercialTax()
		i = 0
		(@width * @height).times do
			if (@map[i] == 3) then
                @money += @taxC * @population[i];
                @future += @taxC * @population[i];
            end
            i += 1
		end
    end

    def updateResidentalTax()
		i = 0
		(@width * @height).times do
			if (@map[i] == 4) then
                @money += @taxR * @population[i];
                @future += @taxR * @population[i];
            end
            i = i + 1
		end
    end

    def updateIndustryTax()
		i = 0
		(@width * @height).times do
			if (@map[i] == 4) then
                @money += @taxI * @population[i];
                @future += @taxI * @population[i];
            end
            i = i + 1
		end
    end

    def buildSpecial(x, y, type)
        key = x + y * @width;
        key2 = x + 1 + y * @width;
        key3 = x + (y+1) * @width;
        key4 = x + 1 + (y+1) * @width;

        if (@map[key] != 0 ||
            @map[key2] != 0 ||
            @map[key3] != 0 ||
            @map[key4] != 0) then
            return false;
		end

        @map[key] = 5;
        @map[key2] = 5;
        @map[key3] = 5;
        @map[key4] = 5;

        case type
            when 1 then
                #  elektrownia
                a1 = 1
                a2 = 2
                a3 = 3
                a4 = 4
            when 2 then
                #  szkoła podstawowa
                a1 = 6
                a2 = 7
                a3 = 8
                a4 = 9
        end

        @builds[key] = a1;
        @builds[key2] = a2;
        @builds[key3] = a3;
        @builds[key4] = a4;

        save();

        return true;
    end

    def save()
        File.open('./status/' + @userID.to_s + '.txt', 'w') { |out|
            out.write @width.to_s + "\n";
            out.write @height.to_s + "\n";

            count = @width * @height

            #  mapa
            map = ''
            i = 0;
            count.times do
                map += @map[i].to_s
                i = i + 1
            end
            out.write map + "\n"

            #zanieczyszczenia
            pollution = ''
            i = 0;
            count.times do
                pollution += @pollution[i].to_s
                i = i + 1
            end
            out.write pollution + "\n"

            #popyt
            demand = ''
            i = 0;
            count.times do
                demand += @demand[i].to_s
                i = i + 1
            end
            out.write demand + "\n"

            #  budżet
            out.write @money.to_s + "\n"

            #  budżet w przyszłości
            out.write @future.to_s + "\n"

            #  popyt na strefę przemysłową
            out.write @demandI.to_s + "\n"

            #  popyt na strefę komercyjną
            out.write @demandC.to_s + "\n"

            #  popyt na strefę mieszkalną
            out.write @demandR.to_s + "\n"

            #  budynki specjalne
            i = 0;
            count.times do
                out.write @builds[i].to_s + "\n"
                i = i + 1;
            end

            #  podatki
            out.write @taxI.to_s + "\n"
            out.write @taxC.to_s + "\n"
            out.write @taxR.to_s + "\n"
            
            print "|||" + @userID.to_s + "|||";

            #  liczba ludzi (mieszkańców lub miejsc pracy) w danym obszarze
            i = 0;
            count.times do
                out.write @population[i].to_s + "\n"
                i = i + 1
            end

            out.close
        }
    end

end
