// Generated by CoffeeScript 1.12.7
(function() {
  var APIManager, BaseObject, MarkOn,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  window.classes = {};

  window.libraries = {};

  window.myuri = "/";

  window.mobilecheck = function() {
    if (navigator.userAgent.match(/Android/i) || navigator.userAgent.match(/webOS/i) || navigator.userAgent.match(/iPhone/i) || navigator.userAgent.match(/iPad/i) || navigator.userAgent.match(/iPod/i) || navigator.userAgent.match(/BlackBerry/i) || navigator.userAgent.match(/Windows Phone/i)) {
      return true;
    }
    return false;
  };

  window.makeclass = function(n, o) {
    return window.classes[n] = o;
  };

  window.require = function(lib) {
    return new Promise(function(r, e) {
      if (window.libraries[lib]) {
        return r();
      }
      return $.getScript(window.myuri + lib).done(function(d) {
        window.libraries[lib] = true;
        return r();
      }).fail(function(m, s) {
        return e(m, s);
      });
    });
  };

  BaseObject = (function() {
    function BaseObject(name) {
      this.name = name;
    }

    BaseObject.prototype.ready = function() {
      var me;
      me = this;
      return new Promise(function(r, e) {
        return me.resolveDep().then(function() {
          return r();
        })["catch"](function(m, s) {
          return e(m, s);
        });
      });
    };

    BaseObject.prototype.resolveDep = function() {
      var me;
      me = this;
      return new Promise(function(r, e) {
        var dep, fn;
        dep = window.classes[me.name].dependencies;
        if (!dep) {
          r();
        }
        fn = function(l, i) {
          if (i >= dep.length) {
            return r();
          }
          return require(l[i]).then(function() {
            return fn(l, i + 1);
          })["catch"](function(m, s) {
            return e(m, s);
          });
        };
        return fn(dep, 0);
      });
    };

    return BaseObject;

  })();

  makeclass("BaseObject", BaseObject);

  APIManager = (function(superClass) {
    extend(APIManager, superClass);

    function APIManager() {
      APIManager.__super__.constructor.call(this, "APIManager");
    }

    APIManager.prototype.init = function(cname) {
      console.log(cname);
      return this.ready().then(function() {
        if (mobilecheck()) {
          mobileConsole.init();
        }
        if (!cname || cname === "") {
          return;
        }
        if (!window.classes[cname]) {
          return console.error("Cannot find class ", cname);
        }
        return (new window.classes[cname]).init();
      })["catch"](function(m, s) {
        return console.error(m, s);
      });
    };

    return APIManager;

  })(window.classes.BaseObject);

  APIManager.dependencies = ["/assets/scripts/mobile_console.js"];

  makeclass("APIManager", APIManager);

  MarkOn = (function(superClass) {
    extend(MarkOn, superClass);

    function MarkOn() {
      MarkOn.__super__.constructor.call(this, "MarkOn");
    }

    MarkOn.prototype.init = function() {
      var me;
      me = this;
      return this.ready().then(function() {
        return me.editor = new SimpleMDE({
          element: $("#editor")[0]
        });
      })["catch"](function(m, s) {
        return console.error(m, s);
      });
    };

    return MarkOn;

  })(window.classes.BaseObject);

  MarkOn.dependencies = ["/rst/gscripts/mde/simplemde.min.js"];

  makeclass("MarkOn", MarkOn);

}).call(this);
