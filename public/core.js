Core = {
    apiAddress: Address.api,
    imgAddress: Address.img,
    map: [0, 0, 0, 0, 0, 0, 0, 0, 0],
    pollution: [],
    demand: [],
    population: [],
    builds: [],
    isPower: [],
    demandI: 0,
    demandC: 0,
    demandR: 0,
    taxI: 0,
    taxC: 0,
    taxR: 0,
    mapWidth: 20,
    mapHeight: 20,
    people: 0,
    workPlace: 0,
    init: function() {
        Core.map = new Array(Core.mapHeight * Core.mapWidth);
        for(i = 0; i < Core.mapHeight * Core.mapWidth; i++) {
            Core.map[i] = 0;
            Core.builds[i] = 0;
            Core.isPower[i] = false;
        }
        Core.start();
        setInterval("Core.update()", 10000);
    },
    start: function() {
        Core.send('start', {}, function (data) {
            Core.mapWidth = data.width;
            Core.mapHeight = data.height;
            
            Core.map = data.map;
            Core.pollution = data.pollution;
            Core.demand = data.demand;
            Core.population = data.population;
            Core.builds = data.builds;
            Core.isPower = data.demand;
            
            Core.people = data.people;
            Core.workPlace = data.workPlace;
            
            Board.generateMap();
            Board.generatePollutionMap();
            Board.generateDemandMap();
            
            Core.demandI = data.demandI;
            Core.demandC = data.demandC;
            Core.demandR = data.demandR;
            
            Core.taxI = data.taxI;
            Core.taxC = data.taxC;
            Core.taxR = data.taxR;
            
            Core.updateDemandGraph();
            Core.updateTaxes();
            
            Money.forecast = data.future;
            Money.current = data.money;
            Money.update();
        })
    },
    updateTaxes: function() {
        $('input[name="taxI"]').val(Core.taxI);
        $('input[name="taxR"]').val(Core.taxR);
        $('input[name="taxC"]').val(Core.taxC);
    },
    changeTax: function() {
        Core.taxI = $('input[name="taxI"]').val();
        Core.taxR = $('input[name="taxR"]').val();
        Core.taxC = $('input[name="taxC"]').val();
        Core.send('tax', {
            'taxI': Core.taxI,
            'taxC': Core.taxC,
            'taxR': Core.taxR
        }, function () {
            
        })
    },
    update: function() {
        Core.send('update', {}, function(data){
            Core.pollution = data.pollution;
            Board.generatePollutionMap();

            Core.demand = data.demand;
            Board.generateDemandMap();
            
            Core.population = data.population;
            Core.demandI = data.demandI;
            Core.demandC = data.demandC;
            Core.demandR = data.demandR;
            
            Core.people = data.people;
            Core.workPlace = data.workPlace;
            
            Board.generateMap();
            Core.updateDemandGraph();
            
            Money.current = data.money;
            Money.forecast = data.future;
            Money.update();
            
            $('#tips').html('');
            $.each(data.tips, function(id, tip) {
				$('#tips').prepend("<li>" + tip + "</li>")
			})
        });
    },
    updateDemandGraph: function() {
        $('#industry').css('height', (Core.demandI + 10) * 5);
        $('#industry').css('marginTop', 100 - (Core.demandI + 10) * 5);
        
        $('#commercial').css('height', (Core.demandC + 10) * 5);
        $('#commercial').css('marginTop', 100 - (Core.demandC + 10) * 5);
        
        $('#residental').css('height', (Core.demandR + 10) * 5);
        $('#residental').css('marginTop', 100 - (Core.demandR + 10) * 5);
        
        $('#people').text(Core.people);
        $('#workPlace').text(Core.workPlace);
    },
    send: function(uri, data, callbackSuccess) {
        
        if (callbackSuccess == undefined) {
            callbackSuccess = function(data) {}
        }
        
        $.ajax({
            url: Core.apiAddress + uri,
            data: data,
            type: 'POST',
            dataType: 'json',
            success: callbackSuccess,
            error: function(data) {
//                Core.onErrorConnection();
            }
        });
    },
    onErrorConnection: function() {
        console.log("Błąd połączenia z serwerem");
        $('#lock').show();
        $('#lockStatement').text("Błąd połączenia z serwerem");
        $('#lockStatement').show();
    },
    unlockScreen: function() {
        $('#lock').hide();
        $('#lockStatement').hide();
    }
}


$(document).ready(function(){
    Core.init();
    Board.init();
    Money.init();
});
