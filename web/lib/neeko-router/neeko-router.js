if(NeekoRouter == undefined){
  var NeekoRouter = function(controllers, $){

    var self = this;
    var params = [];
    var this_route = "";
    var prev_route = "";

    self.options = {
      'views_path': "views/"
    }

    self.view_container = $(".router-view");
    self.ignore_jump = false;

    $('.router-load-view').on('click',function(ev){
      ev.preventDefault();
      var old_v = top.location.hash;
      var new_v = $(this).attr('href');
      if(old_v != new_v){
        self.navigate_to(new_v);
      }
    });

    self.navigate_to = function(route){
      top.location.hash = route;
      return self;
    }

    self.navigate_back = function(fallback_route, jumps){
      if(jumps == undefined) jumps = 1;
      if(prev_route) {
        top.history.go(-jumps);
      } else {
        self.navigate_to(fallback_route);
      }
      return self;
    }

    self.dont_navigate_to = function(route){
      if(top.location.hash == route) return self;
      self.ignore_jump = true;
      top.location.hash = route;
      return self;
    }

    self.rebuild_route = function(param_no, param_val){
      var new_params = self.params.slice();
      new_params[param_no] = param_val;
      new_params.unshift(self.route_name);
      return '#/'+new_params.join('/');
    }

    self.load_route = function(route){
      prev_route = this_route;
      this_route = route;
      route = route.replace('#/','');
      self.params = route.split('/');
      self.route_name = route_name = self.params[0];
      self.params.shift();
      if(!self.ignore_jump){
        self.view_container.addClass('v-cloak');
        if(route_name != ''){
          self.view_container.load(self.options.views_path+route_name+".html",function(){
            if(controllers[route_name]) { controllers[route_name](self.params); } else { if(controllers['default']) controllers['default'](self.params); }
            self.view_container.removeClass("v-cloak");
          });
        } else {
          if(controllers['default']) controllers['default'](self.params);
        }
      }
      self.ignore_jump = false;
    }

    self.initialize_library = function(){
      // load current route
      $(function(){ self.load_route(top.location.hash); });
      // set global hook
      $(window).on('popstate', function(){ self.load_route(top.location.hash); });
    }

    self.initialize_library();
  };  // Router component end
}
