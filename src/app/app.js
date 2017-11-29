top.Bus = new Vue();

function clone(ob){
    return JSON.parse(JSON.stringify(ob));
}
function gate(func, params){
    return Gate[func](params).then(function(last){ top.last = last; console.log(last); });
}

GateDemo = function(){
    /* Demo data (private) */
    var demoholders =
            [{"name": "Gerardo", "participation": 2800, "address": "0x8aac4851afc4079b712af706f41fffc0338e715e", "deposits": 1100},
             {"name": "Sebastián", "participation": 2800, "address": "0x1afc4079b716f41fffc0338e715e8aac4852af70", "deposits": 1000},
             {"name": "Satoshi", "participation": 4300, "address": "0x1f2af70ffc0338e715e8a6f4ac4851afc4079b71", "deposits": 3000}];

    /* Public Methods */
    var self = this;
    this.addHolder = function(holder) {
        console.log(JSON.stringify(holder));
        holder.deposits = 0;
        demoholders.push(holder);
        data = self.isInitialized();
        return new Promise(function(resolve, reject){ resolve(data); });
    };
    this.getHolder = function(index) {
        return demoholders[index];
    };
    this.holderCount = function() {
        return demoholders.length;
    };
    this.getHolders = function(index) {
        var holders = [];
        for (i = 0; i < Gate.holderCount(); i++) {
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

GateWeb3 = function(){
    /* Public Methods */
    var self = this;
    this.addHolder = function(holder) {
        console.log(JSON.stringify(holder));

        return App.contractInstance().then(function(c){
            c.addHolder(holder.name, holder.address, holder.participation);
            data = self.isInitialized();
        });

    };
    this.getHolder = function(index) {
        return App.contractInstance().then(function(c){
            return c.getHolder(index);
        });
    };
    this.holderCount = function() {
        return App.contractInstance().then(function(c){
            return c.holderCount();
        });
    };
    this.getHolders = function(index) {
        return self.holderCount().then(function(response) {
            var count = response.toNumber();
            var promises = [];
            var holders = [];
            for (i = 0; i < count; i++) {
                promises.push(Gate.getHolder(i));
            }
            return Promise.all(promises).then(function(values){
                var holders = [];
                for(i in values) {
                    holders.push({name: values[i][0], address: values[i][1], participation: values[i][2].toNumber()});
                }
                return holders;
            });
        });

    };
    this.isInitialized = function() {
        return App.contractInstance().then(function(c){
            return c.isInitialized();
        });
    };
    return this;
};

Consortium = function() {
    var self = this;

    this.web3Provider = null;
    this.contracts = {};

    this.consortiumInstance = 'uninitialized';

    this.initWeb3 = function() {
        // Is there is an injected web3 instance?
        if (typeof web3 !== 'undefined') {
        self.web3Provider = web3.currentProvider;
        } else {
        // If no injected web3 instance is detected, fallback to the TestRPC
        self.web3Provider = new Web3.providers.HttpProvider('http://localhost:8545');
        }
        web3 = new Web3(self.web3Provider);

        return self.initContract();
    }

    this.initContract = function() {

        return new Promise(function(resolve, reject){
            $.getJSON('Consortium.json', function(data) {
            // Get the necessary contract artifact file and instantiate it with truffle-contract
            var ConsortiumArtifact = data;
            self.contracts.Consortium = TruffleContract(ConsortiumArtifact);

            // Set the provider for our contract
            self.contracts.Consortium.setProvider(self.web3Provider);

            resolve(self.contractInstance());
            });
        });

    }

    this.contractInstance = function() {

        if(self.consortiumInstance == "uninitialized") {
            return self.contracts.Consortium.deployed().then(function(instance) {
                self.consortiumInstance = instance;
                return self.consortiumInstance;
            });
        } else {
            return new Promise(function(resolve, reject){resolve(self.consortiumInstance);});
        }

    }

    this.method = function(method, data) {
        return this.contractInstance().then(function(ins){ return ins[method](data); });
    }

    this.call = function(method, data) {
        return this.contractInstance().then(function(ins){ return ins[method].call(data); });
    }

    this.init = function() {
        return this.initWeb3().then(function(){ return self; });
    }

    return this;
};

(new Consortium()).init()
    .then(function(instance){ console.log("Contract instance: ", instance); top.App = instance; }).then(init);

function init() {

    console.log("top.App", top.App);

    // top.Gate = new GateDemo();
    top.Gate = new GateWeb3();

    var data = {
        holders: [],
        initialized: false
    };
    var retrieving = [
        Gate.getHolders().then(function(holders){data.holders = holders; console.log(JSON.stringify(holders));}),
        Gate.isInitialized().then(function(initialized){data.initialized = initialized})
    ];

    Promise.all( retrieving ).then(function(){ startInterface(data); });
}

function startInterface(data) {

    top.View = new Vue({
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
    View.active_tab = "propietarios";

    var init_vue = function(){
        var newholder = {"name": "", "participation": 0, "address": web3.eth.accounts[0]};
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
