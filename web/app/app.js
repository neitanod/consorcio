top.Bus = new Vue();
top.app = new Vue({
  el: '#app',
  data: {
    active_tab: ''
  },
  methods: {
      navigate: function(url) {
           this.active_tab = url;
      }
  },
  mounted: function() {
      var self = this;
  }
});


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
        'depositos': depositos_controller,
        'gastos': gastos_controller,
        'saldos': saldos_controller,
        'proveedores': proveedores_controller,
        'page': function(params){  $('.router-view').load('static/'+params[0]+'.html'); },
        'default': function(){ top.router.navigate_to('/home'); }
      },
  jQuery);
