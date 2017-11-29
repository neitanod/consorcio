top.Bus = new Vue();

function clone(ob){
    return JSON.parse(JSON.stringify(ob));
}

GateDemo = function(){
    /* Demo data (private) */
    var demoholders =
            [{"name": "Gerardo", "participation": 2800, "address": "a23124234fed", "deposits": 1100},
             {"name": "Sebastián", "participation": 2800, "address": "b23124234fed", "deposits": 1000},
             {"name": "Satoshi", "participation": 4300, "address": "c23124234fed", "deposits": 3000}];

    /* Public Methods */
    var self = this;
    this.addHolder = function(holder) {
        console.log(JSON.stringify(holder));
        holder.deposits = 0;
        demoholders.push(holder);
        data = self.isInitialized();
        return {then: function(cb){setTimeout(function(){cb(data)},0);}}
    };
    this.getHolder = function(index) {
        return demoholders[index];
    };
    this.getHolderCount = function() {
        return demoholders.length;
    };
    this.getHolders = function(index) {
        var holders = [];
        for (i = 0; i < Gate.getHolderCount(); i++) {
            holders.push(Gate.getHolder(i));
        }
        return holders;
    };
    this.isInitialized = function() {
        var total_participation = 0;
        for(i in demoholders) {
            total_participation += parseFloat(demoholders[i].participation);
        }
        console.log("Total participation:",total_participation);
        if(total_participation>=10000) return true;
        return false;
    };
    return this;
};

Gate = new GateDemo();

function init() {

    var data =
    {
        holders: Gate.getHolders(),
        initialized: Gate.isInitialized()
    };


    top.App = new Vue({
        el: '#app',
        data: {
            active_tab: '',
            initialized: data.initialized,
        },
        methods: {
            navigate: function(url) {
                this.active_tab = url;
            },
        },
        mounted: function() {
            var self = this;
        }
    });

    var propietarios_controller = function(params){
    App.active_tab = "propietarios";

    var init_vue = function(){
        var newholder = {"name": "", "participation": 0, "address": ""};
        var vue = new Vue(
            {
                el: "#propietarios-view",
                data: {
                    initialized: data.initialized,
                    adding: false,
                    holders: data.holders,
                    newholder: newholder
                },
                methods: {
                    add: function() {
                        var self=this;
                        Gate.addHolder(this.newholder).then((function(){var nh = self.newholder; return function(ret){
                            data.initialized = ret;
                            self.initialized = ret;
                            self.$forceUpdate();
                            // self.initialized = ret;
                            console.log(ret);
                            self.holders.push(clone(nh));
                        };})());
                        this.newholder = {"name": "", "participation": 0, "address": ""};
                        this.adding = false;
                    }
                }
            }
        );
    }

    init_vue();
    }

    var depositos_controller = function(params){

    var init_vue = function(){
        var vue = new Vue(
            {
            el: "#depositos-view",
            data: {
            },
            methods: {
            }
            }
        );
    }

    init_vue();
    }

    var gastos_controller = function(params){

    var init_vue = function(){
        var vue = new Vue(
            {
            el: "#gastos-view",
            data: {
            },
            methods: {
            }
            }
        );
    }

    init_vue();
    }

    var saldos_controller = function(params){

    var init_vue = function(){
        var vue = new Vue(
            {
            el: "#saldos-view",
            data: {
            },
            methods: {
            }
            }
        );
    }

    init_vue();
    }

    var proveedores_controller = function(params){

    var init_vue = function(){
        var vue = new Vue(
            {
            el: "#proveedores-view",
            data: {
            },
            methods: {
            }
            }
        );
    }

    init_vue();
    }


    top.router = new NeekoRouter(
        {
            'propietarios': propietarios_controller,
            'depositos': depositos_controller,
            'gastos': gastos_controller,
            'saldos': saldos_controller,
            'proveedores': proveedores_controller,
            'page': function(params){  $('.router-view').load('static/'+params[0]+'.html'); },
            'default': function(){ top.router.navigate_to('/home'); }
        },
    jQuery);

}

init(jQuery);
