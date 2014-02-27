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
    root.require.register('runnable/client/components/editor.js', function(exports, require, module) {
    
      var cursor, db, editor, job, tabs;
      
      db = require('../models/db');
      
      job = require('../models/job');
      
      tabs = require('./tabs');
      
      editor = null;
      
      db.bind('language', function(obj, newVal) {
        return editor.setOption('mode', newVal);
      });
      
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
          '.btn.run click': function() {
            var src;
            if (!(src = editor.getValue())) {
              return;
            }
            job.submit({
              'src': editor.getValue(),
              'lang': editor.getOption('mode')
            });
            return tabs(1);
          },
          inserted: function(el) {
            editor = CodeMirror(el.find('.content').get(0), {
              'mode': db.attr('language'),
              'theme': 'github',
              'lineNumbers': true,
              'viewportMargin': Infinity,
              'showCursorWhenSelecting': true,
              'lineWrapping': true,
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

    // results.coffee
    root.require.register('runnable/client/components/results.js', function(exports, require, module) {
    
      var job;
      
      job = require('../models/job');
      
      module.exports = can.Component.extend({
        tag: 'app-results',
        template: require('../templates/results'),
        scope: function(obj, parent, el) {
          return {
            job: job
          };
        },
        helpers: {
          isEmpty: function(opts) {
            var out;
            if (!(out = job.attr('out'))) {
              return;
            }
            if (out.stdout.length + out.stderr.length) {
              return opts.inverse(this);
            } else {
              return opts.fn(this);
            }
          }
        }
      });
      
    });

    // select.coffee
    root.require.register('runnable/client/components/select.js', function(exports, require, module) {
    
      var current, db, expanded, languages, query;
      
      db = require('../models/db');
      
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
      
      current = new can.Map({});
      
      current.bind('key', function(ev, newVal, oldVal) {
        return db.attr('language', newVal);
      });
      
      languages.on('change', function(obj, property, evt, newVal) {
        var m;
        if (evt !== 'add' && evt !== 'set') {
          return;
        }
        if (!newVal) {
          return;
        }
        if (m = property.match(/^(\d+)\.active$/)) {
          return current.attr(languages.attr(parseInt(m[1])).attr(), true);
        }
      });
      
      module.exports = can.Component.extend({
        tag: 'app-select',
        template: require('../templates/select'),
        scope: function(obj, parent, el) {
          return {
            'languages': languages,
            'current': current,
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

    // tabs.coffee
    root.require.register('runnable/client/components/tabs.js', function(exports, require, module) {
    
      var active, job, tabs;
      
      job = require('../models/job');
      
      module.exports = active = can.compute(0);
      
      tabs = new can.List([
        {
          'label': 'Editor',
          'icon': 'code',
          'show': true
        }, {
          'label': 'Results',
          'fade': true,
          'icon': 'terminal',
          'show': false
        }, {
          'label': 'Discussion',
          'fade': true,
          'icon': 'comment',
          'show': true
        }
      ]);
      
      job.on('change', function() {
        return tabs.attr(1).attr('show', true);
      });
      
      job.on('status', function(evt, status) {
        var icon, out;
        icon = (function() {
          switch (false) {
            case status !== 'running':
              return 'spin6';
            case !((out = this.attr('out')) && out.stderr.length):
              return 'attention';
            default:
              return 'terminal';
          }
        }).call(this);
        return tabs.attr(1).attr('icon', icon);
      });
      
      can.Component.extend({
        tag: 'app-tabs',
        template: require('../templates/tabs'),
        scope: function(obj, parent, el) {
          return {
            tabs: tabs,
            "switch": function(item, el, evt) {
              return active(_.findIndex(tabs, item.attr()));
            }
          };
        },
        helpers: {
          isActive: function(idx, opts) {
            if (_.isFunction(idx)) {
              idx = idx();
            }
            if (idx === active()) {
              return opts.fn(this);
            } else {
              return opts.inverse(this);
            }
          }
        }
      });
      
    });

    // index.coffee
    root.require.register('runnable/client/index.js', function(exports, require, module) {
    
      var components, layout, render;
      
      render = require('./modules/render');
      
      layout = require('./templates/layout');
      
      components = ['tabs', 'editor', 'results', 'select'];
      
      module.exports = function(opts) {
        var el, name, _i, _len;
        for (_i = 0, _len = components.length; _i < _len; _i++) {
          name = components[_i];
          require("./components/" + name);
        }
        (el = $(opts.el)).html(render(layout));
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

    // db.coffee
    root.require.register('runnable/client/models/db.js', function(exports, require, module) {
    
      var DB, db, ls,
        __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };
      
      ls = window.localStorage;
      
      DB = can.Model.extend({
        dbName: md5("im-runnable-" + document.location.hostname),
        keys: null,
        init: function() {
          var item, key, _i, _len, _ref, _results;
          item = ls.getItem(this.dbName);
          if ((this.keys = (item && item.split(',')) || []).length) {
            _ref = this.keys;
            _results = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              key = _ref[_i];
              _results.push(this.attr(key, JSON.parse(ls.getItem("" + this.dbName + "-" + key))));
            }
            return _results;
          }
        }
      });
      
      module.exports = db = new DB({
        'language': 'javascript'
      });
      
      db.bind('change', function(ev, attr, how, newVal, oldVal) {
        switch (how) {
          case 'set':
            ls.setItem("" + this.dbName + "-" + attr, JSON.stringify(newVal));
            if (__indexOf.call(this.keys, attr) < 0) {
              this.keys.push(attr);
            }
            return ls.setItem(this.dbName, this.keys.join(','));
        }
      });
      
    });

    // job.coffee
    root.require.register('runnable/client/models/job.js', function(exports, require, module) {
    
      var job;
      
      module.exports = job = new can.Map({
        id: null,
        submit: function(obj) {
          var _this = this;
          return $.ajax({
            'url': '/api/v1/jobs.json',
            'type': 'post',
            'dataType': 'json',
            'contentType': 'application/json',
            'data': JSON.stringify(obj)
          }).then(function(_arg) {
            var data;
            data = _arg.data;
            return _this.attr('id', data.id);
          });
        },
        get: _.debounce(function(done) {
          var _this = this;
          return $.ajax({
            'url': "/api/v1/jobs/" + (this.attr('id')) + ".json",
            'type': 'get',
            'dataType': 'json',
            'contentType': 'application/json'
          }).then(function(_arg) {
            var data;
            data = _arg.data;
            _this.attr(data, false);
            if (_.isFunction(done)) {
              return done();
            }
          });
        }, 500),
        destroy: function(id) {
          return $.ajax({
            'url': "/api/v1/jobs/" + id + ".json",
            'type': 'delete',
            'dataType': 'json',
            'contentType': 'application/json'
          });
        }
      });
      
      job.bind('id', function(ev, newId, oldId) {
        var get;
        if (oldId) {
          job.destroy(oldId);
        }
        this.removeAttr('out');
        return (get = function() {
          if (job.attr('out')) {
            return;
          }
          if (newId !== job.attr('id')) {
            return;
          }
          return job.get(get);
        })();
      });
      
    });

    // languages.coffee
    root.require.register('runnable/client/models/languages.js', function(exports, require, module) {
    
      var Language, db, languages;
      
      db = require('./db');
      
      Language = can.Model.extend({
        'findAll': function() {
          return $.ajax({
            'url': '/api/v1/languages.json',
            'type': 'get',
            'dataType': 'json'
          });
        }
      }, {});
      
      module.exports = languages = new Language.List(Language.findAll());
      
      languages.on('add', function(obj, list) {
        var active, item, _i, _len, _results;
        active = db.attr('language');
        _results = [];
        for (_i = 0, _len = list.length; _i < _len; _i++) {
          item = list[_i];
          if (active === item.attr('key')) {
            item.attr('active', true);
          }
          _results.push(item.attr('show', true));
        }
        return _results;
      });
      
    });

    // render.coffee
    root.require.register('runnable/client/modules/render.js', function(exports, require, module) {
    
      module.exports = function(template, ctx) {
        if (ctx == null) {
          ctx = {};
        }
        return can.view.mustache(template)(ctx);
      };
      
    });

    // editor.mustache
    root.require.register('runnable/client/templates/editor.js', function(exports, require, module) {
    
      module.exports = ["<div id=\"editor\">","    <div class=\"header collapse row\">","        <div class=\"small-12 large-6 columns\">","            <a class=\"btn main run icon rocket\">Run</a>","            <a class=\"btn disabled\">Save</a>","        </div>","        <div class=\"small-12 large-6 columns\">","            <span class=\"icon lock right\"></span>","            <span class=\"icon cog right\"></span>","            <app-select class=\"right\"></app-select>","        </div>","    </div>","    <div class=\"collapse row\">","        <div class=\"small-12 columns\">","            <div class=\"content\"></div>","        </div>","    </div>","    <div class=\"collapse row\">","        <div class=\"small-12 columns\">","            <div class=\"footer\">","                Line: {{ cursor.line }} Col: {{ cursor.ch }}","            </div>","        </div>","    </div>","</div>"].join("\n");
    });

    // layout.mustache
    root.require.register('runnable/client/templates/layout.js', function(exports, require, module) {
    
      module.exports = ["<div id=\"nav\" class=\"row collapse\">","    <div class=\"small-12 large-8 push-2 columns title\">","        InterMine Runnable","    </div>","    <div class=\"small-12 large-2 columns\">","        <a class=\"btn dark right\">Log in</a>","    </div>","</div>","","<div id=\"sidebar\">","    <a class=\"home icon rocket\" href=\"/\">Home</a>","","    <ul>","        <li><a class=\"icon code\">New Script</a></li>","        <li><a class=\"icon clipboard\">Browse Scripts</a></li>","    </ul>","</div>","","<div id=\"content\">","    <div class=\"row\">","        <div class=\"intro small-12 columns\">","            <h1>Search a mine by keyword</h1>","            <p>Developed by the Micklem lab at the University of Cambridge, InterMine","                enables the creation of biological databases accessed by sophisticated","                web query tools. Parsers are provided for integrating data from many","                common biological data sources and formats, and there is a framework","                for adding your own data.</p>","        </div>","    </div>","","    <app-tabs></app-tabs>","</div>","","<div id=\"footer\">","    <div class=\"row\">","        <div class=\"small-12 columns\">","            <p>This is a beta version.</p>","            <ul>","                <li><a href=\"#\">Browse Scripts</a></li>","                <li><a href=\"#\">API Documentation</a></li>","                <li><a href=\"#\">Help</a></li>","            </ul>","        </div>","    </div>","</div>"].join("\n");
    });

    // results.mustache
    root.require.register('runnable/client/templates/results.js', function(exports, require, module) {
    
      module.exports = ["<article id=\"results\">","    {{ #isEmpty }}","    <div class=\"warning\">","        <h2>Your script has finished</h2>","        <span class=\"icon attention\"></span>","        <p>No data were logged into the terminal.</p>","    </div>","    {{ /isEmpty }}","","    {{ #job.out }}","        {{ #if stdout.length }}","            <div class=\"stdout\">","                <h2>Terminal output</h2>","            {{ #each stdout }}","                <pre>{{ . }}</pre>","            {{ /each }}","            </div>","        {{ /if }}","","        {{ #if stderr.length }}","            <div class=\"stderr\">","                <h2>Errors found</h2>","                <span class=\"icon attention\"></span>","            {{ #each stderr }}","                <pre>{{ . }}</pre>","            {{ /each }}","            </div>","        {{ /if }}","    {{ /job.out }}","</article>"].join("\n");
    });

    // select.mustache
    root.require.register('runnable/client/templates/select.js', function(exports, require, module) {
    
      module.exports = ["{{ #if languages.length }}","    <div class=\"select {{ #if expanded.value }}expanded{{ /if }}\">","        <div class=\"field\">","            <span class=\"circle\" style=\"background:{{ current.color }}\"></span>","","            {{ current.label }}","","            {{ #if expanded.value }}","                <div class=\"icon nub up-dir\"></div>","            {{ else }}","                <div class=\"icon nub down-dir\"></div>","            {{ /if }}","        </div>","        <div class=\"dropdown\">","            <div class=\"search\">","                <span class=\"icon search\"></span>","                <input class=\"input\" type=\"text\" autocomplete=\"off\" spellcheck=\"off\" value=\"{{ query.value }}\" />","            </div>","            <ul class=\"options\">","                {{ #languages }}","                    {{ #if show }}","                    <li can-click=\"select\" {{ #if active }}class=\"active\"{{ /if }}>","                        <span class=\"circle\" style=\"background:{{ color }}\"></span>","                        {{{ display label }}}","                    </li>","                    {{ /if }}","                {{ /languages }}","            </ul>","        </div>","    </div>","{{ /if }}"].join("\n");
    });

    // tabs.mustache
    root.require.register('runnable/client/templates/tabs.js', function(exports, require, module) {
    
      module.exports = ["<div class=\"row\">","    <div class=\"small-12 columns\">","        <ul class=\"tabs\">","            {{ #each tabs }}","            {{ #if show }}","            <li><a can-click=\"switch\" class=\"{{ #fade }}fade{{ /fade }} {{ #isActive @index }}active{{ /isActive }}\">","                <span class=\"wrapper\">","                    <span class=\"icon {{ icon }}\"></span>","                </span>","                {{ label }}","            </a></li>","            {{ /if }}","            {{ /each }}","        </ul>","    </div>","</div>","","<div class=\"row\">","    <div class=\"small-12 columns\">","        <div class=\"tab-content {{ #isActive 0 }}active{{ /isActive }}\">","            <app-editor></app-editor>","        </div>","        <div class=\"tab-content {{ #isActive 1 }}active{{ /isActive }}\">","            <app-results></app-results>","        </div>","        <div class=\"tab-content {{ #isActive 2 }}active{{ /isActive }}\">","            <article>","                <h2>Not implemented yet</h2>","","                <p>This place could contain people's comments on public scripts.</p>","            </article>","        </div>","    </div>","</div>"].join("\n");
    });
  })();

  // Return the main app.
  var main = root.require("runnable/client/index.js");

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
  
  root.require.alias("runnable/client/index.js", "runnable/index.js");
  

})(this);