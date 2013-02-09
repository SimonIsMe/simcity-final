
class Game 
    
    #wymairy mapy
    @width = 20;
    @height = 20;
    
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
    
    @builds = [];
    
    #mieszkańców w sumie
    @people = 0;
    
    #miejsc pracy w sumie
    @workPlace = 0;

    def initialize
#        $_SESSION['id'] = 1;

        file = File.new("./status/1.txt", "r")

        @width = file.gets.to_s.to_i
        @height = file.gets.to_s.to_i

        count = @width * @height;

        #   mapa
        @map = []
        map = file.gets.split("");
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

        countPeopleAndWorkPalces();
    end

    def countPeopleAndWorkPalces
		limit = @width * @height
		i = 0
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
        width = Math.abs(x_from - x_to)
        height = Math.abs(y_from - y_to)

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

        y_limit = y_to - y_from
		y = y_from;

		y_limit.times do
			x_limit = x_to - x_from
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
        width = Math.abs(x_from - x_to)
        height = Math.abs(y_from - y_to)

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
            limit = x_tmp_to - x_tmp_from;
            x = x_tmp_from;
            limit.times do
				position_x << x
				position_y << y_from
				x = x + 2
            end

            limit = y_tmp_to - y_tmp_from
            y = y_tmp_from
            limit.times do
				position_x << x_to
				position_y << y
				y = y + 1
            end
        else
            #  stoi lub kwadrat
            limit = x_tmp_to - x_tmp_from
            x = x_tmp_to
            limit.times do
				position_x << x
				position_y << y_to
				x = x - 1
            end

            limit = y_tmp_to - y_tmp_from
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

            if (@builds[pos] == 1) then
                pos = x + @width * y;
                pos2 = pos + 1
                pos3 = x + @width * (y + 1)
                pos4 = pos3 + 1
            end

            if (@builds[pos] == 2) then
                pos = pos - 1
                pos2 = pos + 1
                pos3 = (x - 1) + @width * (y + 1)
                pos4 = pos3 + 1
            end

            if (@builds[$pos] == 3) then
                pos = x + @width * (y - 1)
                pos2 = pos + 1
                pos3 = x + @width * y
                pos4 = pos3 + 1
            end

            if (@builds[$pos] == 4) then
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

        save()
    end

    def updateRandomReducePopulation()
		i = 0;
		(@width * @height).times do
			if (population[i] > 0) then
				if (Math.rand(0,10) < 10) then
					@population[i] = @population[i] - 20
				end
			end
			i = i + 1
		end
    end

    def updatePollution()
		i = 0
    	(@width * @height).times do
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

			end
			i = i + 1
    	end
    end

    def getKey(x, y)
		x_y_suma = x.to_i + y.to_i
        return (x_y_suma * @width)
    end

    #  TODO: sprawdzić
    def updateIndustryPollution()
#        for ($i = 0; $i < @width * @height; $i++) {
#            if (@map[$i] == 4) {
#                $x = $i % @width;
#                $y = ($i - $x) / @height;
#                $around = @getNeighbour($x, $y);
#
#                switch (@population[$i])
#                {
#                    case 0:
#                        $pollution = 0;
#                        break;
#                    case 20:
#                        $pollution = 0.1;
#                        break;
#                    case 40:
#                        $pollution = 0.13;
#                        break;
#                    case 60:
#                        $pollution = 0.16;
#                        break;
#                    case 80:
#                        $pollution = 0.19;
#                        break;
#                    case 100:
#                        $pollution = 0.22;
#                        break;
#                }
#
#                foreach($around as $id) {
#                    @pollution[$id] += $pollution / 3;
#                }
#                @pollution[$i] += $pollution;
#            }
#        }
    end

    #  TODO
    def updateResidentalPollution()
		i = 0;
		(@width * @height).times do
			if (@map[i] == 2) then
				@pollution[i] += 0.01;
			end
			i = i + 1
		end

        i = 0;
		(@width * @height).times do
			@pollution[i] = @pollution[i].to_i;
			i = i + 1
		end
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

            #  czy jest szkoła postawowa?
            count = @width * @height;
            count.times do
				$countElementarySchools += 1
            end

            isGoodElementarySchool = people / 1000 < countElementarySchools;

            maxTax = 10
            if (@taxR < 10) then
                @demandR = -0.2 * @taxR + 10
            else
                @demandR = -4 * @taxR + 4
            end

            if (isGoodElementarySchool) then
                @demandR += 1
            else
                @demandR -= 2
            end

            if (workPlace / people > 1.2) then
                @demandR += 1
            elsif (workPlace / people < 0.5) then
                @demandR -= 16
            elsif (workPlace / people < 1) then
                @demandR -= 11
            end
        end

        @demandR = @demandR.to_i

        if (@demandR > 10) then
            @demandR = 10;
        end
        if (@demandR < -10) then
            @demandR = -10;
        end
    end

    def updateCommercialDemand()
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

        #  określam maxymalny akceptowany podatek w zależności od liczby mieszkańców (rozmiarów miasta)
        if (people < 10000) then
            maxTax = 9
        elsif (people < 100000) then
            maxTax = 10
        elsif (people < 1000000) then
            maxTax = 11
        end

        percent = @taxI / maxTax

        @demandI = (10 - (percent * 5)).to_i
    end

    def updateResidentalPopulation()
		i = 0
		(@width * @height).times do
            if (@map[i] == 2) then
                if (@demandR > 0) then
                    if (@demand[i] == 1) then
                        if (Math.rand(0, 10) < @demandR) then
                            @population[i] += 20;
                        end
                    else
                        if (Math.rand(0, 10) < (@demandR / 4)) then
                            @population[i] += 20
                        end
                    end
                else
                    @population[$i] -= 20;
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
        people = 0
        i = 0
        (@width * @height).times do
			if (@map[i] == 2) then
                people += @population[i];
            end
            i = i + 1
        end

        #  akceptowany maksymalny podatek
        maxTax = 8;
        if (people < 5000) then
            maxTax = 9
        elsif (people < 10000) then
            maxTax = 10
        elsif (people < 20000) then
			maxTax = 11
        end

        #  górny pułap losowania
        if (@taxC / maxTax < 0.1) then
            toRand = 5
        elsif (@taxC / maxTax < 0.4) then
            toRand = 4
        elsif (@taxC / maxTax < 0.7) then
            toRand = 3
        elsif (@taxC / maxTax < 0.8) then
            toRand = 2
        elsif (@taxC / maxTax < 0.9) then
            toRand = 1
        else
            toRand = 0
        end


        i = 0
        (@width * @height).times do
			if (@map[i] == 3) then
                if (@taxC < maxTax && @demand[i] == 1) then
                    if (Math.rand(0,10) < toRand) then
                        @population[i] += 20;
                    end
                else
                    @population[i] -= 20;
                end


                if (@population[i] > 100) then
                    @population[i] = 100
                end
                if (@population[i] < 0) then
                    @population[i] = 0
                end
            end
			i = i + 1
        end
    end

    def updateCommercialPollution()
		i = 0
		(@width * @height).times do
			if (@map[i] == 3) then
                if (Math.rand(0,10) < @population[i]) then
                    @pollution[i] += 1
                end
            end
            i = i + 1
		end
    end

    def updateIndustryPopulation()
        add = 0
        if (Math.round(0, 10) < Math.abs(@demandI)) then
            add = 20
        end

        i = 0
        (@width * @height).times do
			if (@map[i] == 4) then
                if (@demand[i] == 1 && @demandI > 0) then
                    if (Math.rand(0,10) < 4) then
                        @population[i] += add;
                    end
                else
                    @population[i] -= 20;
                end


                if (@population[i] > 100) then
                    @population[i] = 100
                end
                if (@population[i] < 0) then
                    @population[i] = 0;
                end
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

    def updateRoad()
		i = 0
        (@width * @height).times do
            if (@map[i] == 1) then
                @money -= 0.3;
                @future -= 0.3;

                #  aktualizuje zanieczyszczenie w danym kwadracie
                if(rand(0,100) < 40) then
                    @pollution[i] += 1;
                end

                x = i % @width;
                y = (i - x) / @width;
                around = getNeighbour(x, y)
                @demand[i] += 5;
                #foreach($around as $key) {
                #    //  zanieczyszczenie
                #    if(rand(0,100) < 20) {
                #        @pollution[$key] += 1;
                #    }
                #
                #    //  popyt
                #    @demand[$key] += 6;
                #}
            end
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

        File.open('./status/1.txt', 'w') { |out|
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
            out.write @demandI + "\n"

            #  popyt na strefę komercyjną
            out.write @demandC + "n"

            #  popyt na strefę mieszkalną
            out.write @demandR + "\n"

            #  budynki specjalne
            i = 0;
            count.times do
                out.write @builds[i] + "\n"
                i = i + 1;
            end

            #  podatki
            out.write @taxI + "\n"
            out.write @taxC + "\n"
            out.write @taxR + "\n"

            #  liczba ludzi (mieszkańców lub miejsc pracy) w danym obszarze
            i = 0;
            count.times do
                out.write @population[i] + "\n"
                i = i + 1
            end

            out.close
        }

    #    $f = fopen('./status/' . $_SESSION['id'] . '.txt', 'w');

    #    fwrite($f, @width . chr(10),  3);
    #    fwrite($f, @height . chr(10),  3);
    #    fwrite($f, implode(@map) . chr(10),  count(@map) + 1);
    #    fwrite($f, implode(@pollution) . chr(10),  count(@pollution) + 1);
    #    fwrite($f, implode(@demand) . chr(10),  count(@demand) + 1);
    #    fwrite($f, @money . chr(10), strlen(@money) + 1);
    #    fwrite($f, @future . chr(10), strlen(@future) + 1);

        #  popyt na strefy
    #    fwrite($f, @demandI . chr(10), strlen(@demandI) + 1);
    #    fwrite($f, @demandC . chr(10), strlen(@demandC) + 1);
    #    fwrite($f, @demandR . chr(10), strlen(@demandR) + 1);

        #  specjalne budynki
    #    $count = @width * @height;
    #    for($i = 0; $i < $count; $i++) {
    #        fwrite($f, @builds[$i] . chr(10), strlen(@builds[$i]) + 1);
    #    }

          #podatki
    #    fwrite($f, @taxI . chr(10), strlen(@taxI) + 1);
    #    fwrite($f, @taxC . chr(10), strlen(@taxC) + 1);
    #    fwrite($f, @taxR . chr(10), strlen(@taxR) + 1);

        #  populacja
    #    for($i = 0; $i < $count; $i++) {
    #        fwrite($f, @population[$i] . chr(10), strlen(@population[$i]) + 1);
    #    }

    #    fclose($f);
    end

end
