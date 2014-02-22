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
    
    // editor.coffee
    root.require.register('runnable/client/app/components/editor.js', function(exports, require, module) {
    
      var cursor, editor;
      
      editor = null;
      
      cursor = new can.Map({
        'line': 1,
        'ch': 1
      });
      
      module.exports = can.Component.extend({
        tag: 'app-editor',
        template: require('../templates/editor'),
        scope: function(obj, parent, el) {
          return {
            cursor: cursor
          };
        },
        events: {
          inserted: function(el) {
            editor = CodeMirror(el.find('.content').get(0), {
              'mode': 'javascript',
              'theme': 'github',
              'lineNumbers': true,
              'viewportMargin': +Infinity,
              'value': "// Require the Request library.\nvar req = require('request');\n\n// Search against FlyMine.\nreq({\n    'uri': 'http://www.flymine.org/query/service/search',\n    // For terms associated with \"micklem\".\n    'qs': { 'q': \"micklem\" }\n}, function(err, res) {\n    if (err) throw err;\n\n    // Just log it.\n    console.log(res.body);\n});"
            });
            return editor.on('cursorActivity', function(instance) {
              return cursor.attr(_.transform(editor.getCursor(), function(res, val, key) {
                return res[key] = val + 1;
              }), true);
            });
          }
        }
      });
      
    });

    // select.coffee
    root.require.register('runnable/client/app/components/select.js', function(exports, require, module) {
    
      var current, expanded, languages, query;
      
      languages = require('../models/languages');
      
      query = can.compute('');
      
      query.bind('change', function(ev, newVal, oldVal) {
        var lang, re, _i, _len, _results;
        if (!newVal.length) {
          return (function() {
            var _i, _len, _results;
            _results = [];
            for (_i = 0, _len = languages.length; _i < _len; _i++) {
              lang = languages[_i];
              _results.push(lang.attr('show', true));
            }
            return _results;
          })();
        }
        re = new RegExp("" + newVal + ".*", 'i');
        _results = [];
        for (_i = 0, _len = languages.length; _i < _len; _i++) {
          lang = languages[_i];
          _results.push(lang.attr('show', lang.attr('label').match(re)));
        }
        return _results;
      });
      
      expanded = can.compute(false);
      
      expanded.bind('change', function(ev, newVal, oldVal) {
        if (newVal != null) {
          return query('');
        }
      });
      
      current = can.compute('');
      
      languages.on('change', function(obj, property, evt, newVal) {
        var m;
        if (evt !== 'add' && evt !== 'set') {
          return;
        }
        if (m = property.match(/^(\d+)\.active$/)) {
          return current(languages.attr(parseInt(m[1])).attr().label);
        }
      });
      
      module.exports = can.Component.extend({
        tag: 'app-select',
        template: require('../templates/select'),
        scope: function(obj, parent, el) {
          return {
            'languages': languages,
            'current': {
              'value': current
            },
            'query': {
              'value': query
            },
            'expanded': {
              'value': expanded
            },
            'select': function(obj) {
              var key, label, lang, _i, _len, _ref;
              for (_i = 0, _len = languages.length; _i < _len; _i++) {
                lang = languages[_i];
                lang.attr('active', false);
              }
              _ref = obj.attr(), key = _ref.key, label = _ref.label;
              obj.attr('active', true);
              return expanded(false);
            }
          };
        },
        events: {
          '.field click': function(el, evt) {
            var b;
            expanded(b = !expanded());
            if (b) {
              return this.element.find('.search .input').focus();
            }
          },
          '.search .input keyup': function(el, evt) {
            switch (evt.which) {
              case 27:
                return expanded(false);
              default:
                return query(el.val().toLowerCase().replace(/[^a-z]*/g, ''));
            }
          },
          'inserted': function(el) {
            return $(document).on('click', function(evt) {
              if (!(el.is(evt.target) || el.has(evt.target).length)) {
                return expanded(false);
              }
            });
          }
        },
        helpers: {
          display: function(val, opts) {
            return val().replace(new RegExp("(" + (query()) + ")", 'ig'), "<span>$1</span>");
          }
        }
      });
      
    });

    // index.coffee
    root.require.register('runnable/client/app/index.js', function(exports, require, module) {
    
      var components, layout, render;
      
      render = require('./modules/render');
      
      layout = require('./templates/layout');
      
      components = ['editor', 'select'];
      
      module.exports = function(opts) {
        var name, _i, _len;
        for (_i = 0, _len = components.length; _i < _len; _i++) {
          name = components[_i];
          require("./components/" + name);
        }
        $(opts.el).html(render(layout));
        return (function() {
          var height, sidebar;
          height = $('#nav').outerHeight();
          sidebar = $('#sidebar');
          return $(document).on('scroll', function() {
            return sidebar.css('top', Math.max(-height, -$(window).scrollTop()));
          });
        })();
      };
      
    });

    // config.json
    root.require.register('runnable/client/app/models/config.js', function(exports, require, module) {
    
      module.exports = {
          "default_language": "node"
      };
    });

    // languages.coffee
    root.require.register('runnable/client/app/models/languages.js', function(exports, require, module) {
    
      var Language, config, languages;
      
      config = require('./config');
      
      Language = can.Model.extend({
        'findAll': function() {
          return $.ajax({
            'url': '/api/languages',
            'type': 'get',
            'dataType': 'json'
          });
        }
      }, {});
      
      module.exports = languages = new Language.List(Language.findAll());
      
      languages.on('add', function(obj, list) {
        var item, _i, _len, _results;
        _results = [];
        for (_i = 0, _len = list.length; _i < _len; _i++) {
          item = list[_i];
          if (config.default_language === item.attr('key')) {
            item.attr('active', true);
          }
          _results.push(item.attr('show', true));
        }
        return _results;
      });
      
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

    // editor.mustache
    root.require.register('runnable/client/app/templates/editor.js', function(exports, require, module) {
    
      module.exports = ["<div id=\"editor\">","    <div class=\"header collapse row\">","        <div class=\"small-12 large-6 columns\">","            <a class=\"btn main icon rocket\">Run</a>","            <a class=\"btn disabled\">Save</a>","        </div>","        <div class=\"small-12 large-6 columns\">","            <span class=\"icon lock right\"></span>","            <span class=\"icon cog right\"></span>","            <app-select class=\"right\"></app-select>","        </div>","    </div>","    <div class=\"collapse row\">","        <div class=\"small-12 columns\">","            <div class=\"content\"></div>","        </div>","    </div>","    <div class=\"collapse row\">","        <div class=\"small-12 columns\">","            <div class=\"footer\">","                Line: {{ cursor.line }} Col: {{ cursor.ch }}","            </div>","        </div>","    </div>","</div>"].join("\n");
    });

    // layout.mustache
    root.require.register('runnable/client/app/templates/layout.js', function(exports, require, module) {
    
      module.exports = ["<div id=\"nav\" class=\"row collapse\">","    <div class=\"small-12 large-8 push-2 columns title\">","        InterMine Runnable","    </div>","    <div class=\"small-12 large-2 columns\">","        <a class=\"btn dark right\">Log in</a>","    </div>","</div>","","<div id=\"sidebar\">","    <a class=\"home icon rocket\" href=\"/\">Home</a>","","    <ul>","        <li><a class=\"icon code\">New Script</a></li>","        <li><a class=\"icon clipboard\">Browse Scripts</a></li>","    </ul>","</div>","","<div id=\"content\">","    <div class=\"row\">","        <div class=\"intro small-12 columns\">","            <h1>Search a mine by keyword</h1>","            <p>Developed by the Micklem lab at the University of Cambridge, InterMine","                enables the creation of biological databases accessed by sophisticated","                web query tools. Parsers are provided for integrating data from many","                common biological data sources and formats, and there is a framework","                for adding your own data.</p>","        </div>","    </div>","","    <div class=\"row\">","        <div class=\"small-12 columns\">","            <ul class=\"tabs\">","                <li class=\"active\"><a class=\"icon code\">Editor</a></li>","                <li><a class=\"icon terminal\">Results</a></li>","                <li><a class=\"icon comment\">Discussion</a></li>","            </ul>","        </div>","    </div>","","    <div class=\"row\">","        <div class=\"small-12 columns\">","            <app-editor></app-editor>","        </div>","    </div>","</div>","","<div id=\"footer\">","    <div class=\"row\">","        <div class=\"small-12 columns\">","            <p>This is a beta version.</p>","            <ul>","                <li><a href=\"#\">Browse Scripts</a></li>","                <li><a href=\"#\">API Documentation</a></li>","                <li><a href=\"#\">Help</a></li>","            </ul>","        </div>","    </div>","</div>"].join("\n");
    });

    // select.mustache
    root.require.register('runnable/client/app/templates/select.js', function(exports, require, module) {
    
      module.exports = ["<div class=\"select {{ #if expanded.value }}expanded{{ /if }}\">","    <div class=\"field\">","        {{ #if languages.length }}","            <span>{{ current.value }}</span>","","            {{ #if expanded.value }}","                <div class=\"icon nub up-dir\"></div>","            {{ else }}","                <div class=\"icon nub down-dir\"></div>","            {{ /if }}","        {{ else }}","            <span class=\"icon spin6\"></span>","        {{ /if }}","    </div>","    <div class=\"dropdown\">","        <div class=\"search\">","            <span class=\"icon search\"></span>","            <input class=\"input\" type=\"text\" autocomplete=\"off\" spellcheck=\"off\" value=\"{{ query.value }}\" />","        </div>","        <ul class=\"options\">","            {{ #languages }}","                {{ #if show }}","                <li can-click=\"select\" {{ #if active }}class=\"active\"{{ /if }}>{{{ display label }}}</li>","                {{ /if }}","            {{ /languages }}","        </ul>","    </div>","</div>"].join("\n");
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