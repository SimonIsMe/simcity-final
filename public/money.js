Money = {
    current: 1000,
    forecast: 1000,
    init: function () {
        console.log('Money.init');
    },
    update: function () {
        $('#money_current').text(this.current + "$");
        $('#forecast').text(this.forecast + "$");
    }
}