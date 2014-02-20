// A standalone CommonJS loader.
(function(root) {
  /**
   * Require the given path.
   *
   * @param {String} path
   * @return {Object} exports
   * @api public
   */
  var require = function(path, parent, orig) {
    var resolved = require.resolve(path);

    // lookup failed
    if (!resolved) {
      orig = orig || path;
      parent = parent || 'root';
      var err = new Error('Failed to require "' + orig + '" from "' + parent + '"');
      err.path = orig;
      err.parent = parent;
      err.require = true;
      throw err;
    }

    var module = require.modules[resolved];

    // perform real require()
    // by invoking the module's
    // registered function
    if (!module._resolving && !module.exports) {
      var mod = {};
      mod.exports = {};
      mod.client = mod.component = true;
      module._resolving = true;
      module.call(this, mod.exports, require.relative(resolved), mod);
      delete module._resolving;
      module.exports = mod.exports;
    }

    return module.exports;
  };

  /**
   * Registered modules.
   */

  require.modules = {};

  /**
   * Registered aliases.
   */

  require.aliases = {};

  /**
   * Resolve `path`.
   *
   * Lookup:
   *
   *   - PATH/index.js
   *   - PATH.js
   *   - PATH
   *
   * @param {String} path
   * @return {String} path or null
   * @api private
   */

  require.resolve = function(path) {
    if (path.charAt(0) === '/') path = path.slice(1);

    var paths = [
      path,
      path + '.js',
      path + '.json',
      path + '/index.js',
      path + '/index.json'
    ];

    for (var i = 0; i < paths.length; i++) {
      path = paths[i];
      if (require.modules.hasOwnProperty(path)) return path;
      if (require.aliases.hasOwnProperty(path)) return require.aliases[path];
    }
  };

  /**
   * Normalize `path` relative to the current path.
   *
   * @param {String} curr
   * @param {String} path
   * @return {String}
   * @api private
   */

  require.normalize = function(curr, path) {
    var segs = [];

    if ('.' != path.charAt(0)) return path;

    curr = curr.split('/');
    path = path.split('/');

    for (var i = 0; i < path.length; ++i) {
      if ('..' == path[i]) {
        curr.pop();
      } else if ('.' !== path[i] && '' !== path[i]) {
        segs.push(path[i]);
      }
    }

    return curr.concat(segs).join('/');
  };

  /**
   * Register module at `path` with callback `definition`.
   *
   * @param {String} path
   * @param {Function} definition
   * @api private
   */

  require.register = function(path, definition) {
    require.modules[path] = definition;
  };

  /**
   * Alias a module definition.
   *
   * @param {String} from
   * @param {String} to
   * @api private
   */

  require.alias = function(from, to) {
    if (!require.modules.hasOwnProperty(from)) {
      throw new Error('Failed to alias "' + from + '", it does not exist');
    }
    require.aliases[to] = from;
  };

  /**
   * Return a require function relative to the `parent` path.
   *
   * @param {String} parent
   * @return {Function}
   * @api private
   */

  require.relative = function(parent) {
    var p = require.normalize(parent, '..');

    /**
     * lastIndexOf helper.
     */

    function lastIndexOf(arr, obj) {
      var i = arr.length;
      while (i--) {
        if (arr[i] === obj) return i;
      }
      return -1;
    }

    /**
     * The relative require() itself.
     */

    var localRequire = function(path) {
      var resolved = localRequire.resolve(path);
      return require(resolved, parent, path);
    };

    /**
     * Resolve relative to the parent.
     */

    localRequire.resolve = function(path) {
      var c = path.charAt(0);
      if ('/' == c) return path.slice(1);
      if ('.' == c) return require.normalize(p, path);

      // resolve deps by returning
      // the dep in the nearest "deps"
      // directory
      var segs = parent.split('/');
      var i = lastIndexOf(segs, 'deps') + 1;
      if (!i) i = 0;
      path = segs.slice(0, i + 1).join('/') + '/deps/' + path;
      return path;
    };

    /**
     * Check if module is defined at `path`.
     */
    localRequire.exists = function(path) {
      return require.modules.hasOwnProperty(localRequire.resolve(path));
    };

    return localRequire;
  };

  // Do we already have require loader?
  root.require = (typeof root.require !== 'undefined') ? root.require : require;

})(this);
// Concat modules and export them as an app.
(function(root) {

  // All our modules will use global require.
  (function() {
    
    // index.coffee
    root.require.register('runnable/client/app/index.js', function(exports, require, module) {
    
      var components, layout, render;
      
      render = require('./modules/render');
      
      layout = require('./templates/layout');
      
      components = [];
      
      module.exports = function(opts) {
        var name, _i, _len;
        for (_i = 0, _len = components.length; _i < _len; _i++) {
          name = components[_i];
          require("./components/" + name);
        }
        $(opts.el).html(render(layout));
        return CodeMirror($('#editor').get(0), {
          'mode': 'javascript',
          'theme': 'github',
          'lineNumbers': true,
          'viewportMargin': +Infinity,
          'value': "// Require the Request library.\nvar req = require('request');\n\n// Search against FlyMine.\nreq({\n    'uri': 'http://www.flymine.org/query/service/search',\n    // For terms associated with \"micklem\".\n    'qs': { 'q': \"micklem\" }\n}, function(err, res) {\n    if (err) throw err;\n\n    // Just log it.\n    console.log(res.body);\n});"
        });
      };
      
    });

    // render.coffee
    root.require.register('runnable/client/app/modules/render.js', function(exports, require, module) {
    
      module.exports = function(template, ctx) {
        if (ctx == null) {
          ctx = {};
        }
        return can.view.mustache(template)(ctx);
      };
      
    });

    // layout.mustache
    root.require.register('runnable/client/app/templates/layout.js', function(exports, require, module) {
    
      module.exports = ["<div id=\"nav\">","    <ul>","        <li><a href=\"#\">Public scripts</a></li>","        <li><a href=\"#\">API Documentation</a></li>","        <li><a href=\"#\" class=\"icon user\">Login</a></li>","    </ul>","","    <a class=\"logo\" href=\"/\">InterMine Runnable</a>","</div>","","<div id=\"toolbar\">","    <div class=\"left\">","        <div class=\"toolbar\">","            <div class=\"actions\">","                <button disabled=\"disabled\" class=\"secondary\">Save</button>","                <button class=\"main\">Run</button>","            </div>","","            <h2 class=\"icon code\">Editor</h2>","        </div>","    </div>","    <div class=\"right\">","        <div class=\"toolbar\">","            <h2 class=\"icon eye\">Results</h2>","        </div>","    </div>","</div>","<div id=\"panes\">","    <div id=\"editor\" class=\"left\"></div>","    <div class=\"right\">","        <div id=\"results\">","            <p>The results of your script will show up here.</p>","        </div>","    </div>","</div>"].join("\n");
    });
  })();

  // Return the main app.
  var main = root.require("runnable/client/app/index.js");

  // AMD/RequireJS.
  if (typeof define !== 'undefined' && define.amd) {
  
    define("runnable", [ /* load deps ahead of time */ ], function () {
      return main;
    });
  
  }

  // CommonJS.
  else if (typeof module !== 'undefined' && module.exports) {
    module.exports = main;
  }

  // Globally exported.
  else {
  
    root["runnable"] = main;
  
  }

  // Alias our app.
  
  root.require.alias("runnable/client/app/index.js", "runnable/index.js");
  

})(this);