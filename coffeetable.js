(function() {
  /*
  
  # CoffeeTable v0.1.0
  
  A drop-in, CoffeeScript-fluent console for web pages.
  
  * [Demo + Instructions](http://code.alecperkins.net/coffeetable)
  * [GitHub repo](https://github.com/alecperkins/coffeetable)
  
  ## To use
  
  Load `coffeetable-min.js` into the page:
  `<script type="application/javascript" src="http://code.alecperkins.net/coffeetable/coffeetable-min.js"></script>`
  ...and the widget will automatically initialize.
  
  */  var $, $els, active, appendInstructions, bindEvents, buildAutosuggest, clearHistory, defaults, deferred, execute, history, history_index, init, keycode, loadFromStorage, loadPrevious, loadScript, loaded, loaded_scripts, preInit, renderAutosuggest, renderWidget, replayHistory, setSettings, settings, showing_multi_line, template, toggleMultiLine, _ref, _ref2;
  defaults = {
    autoload_coffee_script: true,
    autoload_jquery: true,
    coffeescript_js: 'http://code.alecperkins.net/coffeetable/lib/coffee_script-1.1.1-min.js',
    jquery_js: 'http://code.alecperkins.net/coffeetable/lib/jquery-1.6.2-min.js',
    local_storage: true,
    ls_key: 'coffee-table',
    clear_on_load: false,
    multi_line: false,
    indent: '    ',
    auto_suggest: true,
    widget_position: 'fixed',
    widget_top: '5px',
    widget_right: '5px',
    widget_id: "CoffeeTable-" + ((new Date()).getTime())
  };
    if (typeof console !== "undefined" && console !== null) {
    console;
  } else {
    console = {
      log: function() {},
      dir: function() {}
    };
  };
    if ((_ref = window.log) != null) {
    _ref;
  } else {
    window.log = function() {
      return console.log.apply(console, arguments);
    };
  };
    if ((_ref2 = window.dir) != null) {
    _ref2;
  } else {
    window.dir = function() {
      return console.dir.apply(console, arguments);
    };
  };
  keycode = {
    UP: 38,
    DOWN: 40,
    ENTER: 13,
    TAB: 9,
    BACKSPACE: 8
  };
  template = '<div id="__ID__"><style type="text/css">#__ID__{margin:0;padding:0;border:0;font-size:100%;font:inherit;vertical-align:baseline;-moz-box-shadow:0px 0px 4px #222222;-webkit-box-shadow:0px 0px 4px #222222;-o-box-shadow:0px 0px 4px #222222;box-shadow:0px 0px 4px #222222;background:rgba(255,255,255,0.93);padding:0;border:2px solid #fff;z-index:2147483647;font-size:12px;max-height:95%;max-width:900px}#__ID__ div,#__ID__ span,#__ID__ applet,#__ID__ object,#__ID__ iframe,#__ID__ h1,#__ID__ h2,#__ID__ h3,#__ID__ h4,#__ID__ h5,#__ID__ h6,#__ID__ p,#__ID__ blockquote,#__ID__ pre,#__ID__ a,#__ID__ abbr,#__ID__ acronym,#__ID__ address,#__ID__ big,#__ID__ cite,#__ID__ code,#__ID__ del,#__ID__ dfn,#__ID__ em,#__ID__ img,#__ID__ ins,#__ID__ kbd,#__ID__ q,#__ID__ s,#__ID__ samp,#__ID__ small,#__ID__ strike,#__ID__ strong,#__ID__ sub,#__ID__ sup,#__ID__ tt,#__ID__ var,#__ID__ b,#__ID__ u,#__ID__ i,#__ID__ center,#__ID__ dl,#__ID__ dt,#__ID__ dd,#__ID__ ol,#__ID__ ul,#__ID__ li,#__ID__ fieldset,#__ID__ form,#__ID__ label,#__ID__ legend,#__ID__ table,#__ID__ caption,#__ID__ tbody,#__ID__ tfoot,#__ID__ thead,#__ID__ tr,#__ID__ th,#__ID__ td,#__ID__ article,#__ID__ aside,#__ID__ canvas,#__ID__ details,#__ID__ embed,#__ID__ figure,#__ID__ figcaption,#__ID__ footer,#__ID__ header,#__ID__ hgroup,#__ID__ menu,#__ID__ nav,#__ID__ output,#__ID__ ruby,#__ID__ section,#__ID__ summary,#__ID__ time,#__ID__ mark,#__ID__ audio,#__ID__ video{margin:0;padding:0;border:0;font-size:100%;font:inherit;vertical-align:baseline}#__ID__ table{border-collapse:collapse;border-spacing:0}#__ID__ caption,#__ID__ th,#__ID__ td{text-align:left;font-weight:normal;vertical-align:middle}#__ID__ q,#__ID__ blockquote{quotes:none}#__ID__ q:before,#__ID__ q:after,#__ID__ blockquote:before,#__ID__ blockquote:after{content:"";content:none}#__ID__ a img{border:none}#__ID__ .toggle-widget{float:right;background:#fff;border:1px solid #ccc;color:#911;cursor:pointer}#__ID__ .toggle-widget:active,#__ID__ .toggle-widget.active{background:#911;color:#fff}#__ID__ .coffee-source{font-family:monospace;font-size:15px;min-width:400px;height:22px;margin:4px}#__ID__ .input{display:none}#__ID__ .history{margin:8px;padding:4px 4px 4px 16px;font-family:monospace;list-style-type:circle;overflow-y:scroll}#__ID__ .history li{padding:4px;cursor:pointer}#__ID__ .history li:hover{background-color:rgba(255,255,0,0.2);list-style-type:disc}#__ID__ .history li:active{background-color:rgba(255,255,0,0.8)}#__ID__ .history li.cs-error{color:orange}#__ID__ .history li.js-error{color:red}#__ID__ .history li.instructions{list-style-type:none;text-align:center}#__ID__ .history li.instructions:hover{background-color:#fff;cursor:default}#__ID__ .clear,#__ID__ .replay{padding:4px;text-align:center;cursor:pointer;float:left;color:#555;font-variant:small-caps;display:none}#__ID__ .clear:hover,#__ID__ .replay:hover{color:#911}#__ID__ a{padding:4px;text-align:center;cursor:pointer;float:right;color:#555;font-variant:small-caps}#__ID__ input{vertical-align:middle}#__ID__ p{padding:4px;margin:0;float:right;display:inline-block;width:80px;color:#555;font-variant:small-caps;display:none;text-align:right}#__ID__ .autosuggest{-moz-box-shadow:0px 0px 4px #222222;-webkit-box-shadow:0px 0px 4px #222222;-o-box-shadow:0px 0px 4px #222222;box-shadow:0px 0px 4px #222222;position:absolute;top:-2px;left:-260px;display:block;background:rgba(255,255,255,0.9);width:250px;overflow-y:scroll;font-family:monospace}#__ID__ .autosuggest li{padding:4px}#__ID__ .autosuggest li.heading{font-weight:bold;text-decoration:underline;list-style-type:none}#__ID__ .function{color:#292}#__ID__ .number{color:#229}#__ID__ .string{color:#922}#__ID__ .undefined{color:grey;font-style:italic}#__ID__ .object{color:#000}#__ID__ .boolean{color:#299}</style><button class="toggle-widget">CoffeeTable</button><span class="clear">clear</span><span class="replay">replay</span><a href="http://code.alecperkins.net/coffeetable/" target="_blank">?</a><p>multiline <input type="checkbox"></p><div class="input"><textarea class="coffee-source"></textarea><ul class="autosuggest"></ul><ul class="history"></ul></div></div>';
  $ = null;
  settings = null;
  $els = null;
  active = false;
  deferred = false;
  loaded = false;
  showing_multi_line = false;
  history_index = 0;
  loaded_scripts = {
    jquery_js: false,
    coffeescript_js: false
  };
  /*
  Track the input history with a list of objects like this...
  `
      {
        source: 'CoffeeScript code',
        result: 'result of eval'
      }
  `
  ...in order of entry by the user.
  */
  history = [];
  /*
  Loads settings, and initiates the rendering of the widget and loading of
  previous history from localStorage.
  */
  init = function(opts) {
    if (opts == null) {
      opts = {};
    }
    if (loaded_scripts.jquery_js && loaded_scripts.coffeescript_js) {
      $ = window.jQuery;
      template = template.replace(/__ID__/g, settings.widget_id);
      renderWidget();
      if (settings.local_storage) {
        loadFromStorage();
      }
      return loaded = true;
    }
  };
  /*
  Generate the auto-suggest list based on the object represented by the
  supplied text. Done by iterating over the objects loaded, starting with
  `window` and progressing through the subsequent properties.
  */
  buildAutosuggest = function(text, e) {
    var attribute, match_list, matches, to_match, token, tokens, value, working_items, _i, _len, _ref3, _ref4;
    if (e.which === keycode.BACKSPACE && text.length === 0 && $els.autosuggest_list.html().length !== 0) {
      return $els.autosuggest_list.html('');
    } else {
      tokens = text.split('.');
      working_items = [[window, 'window']];
      _ref3 = tokens.slice(0, tokens.length - 1);
      for (_i = 0, _len = _ref3.length; _i < _len; _i++) {
        token = _ref3[_i];
        token = token.replace('(', '').replace(')', '');
        if (token.length > 0) {
          working_items.push([working_items[working_items.length - 1][0][token], token]);
        }
      }
      match_list = [];
      to_match = new RegExp('^' + tokens[tokens.length - 1]);
      _ref4 = working_items[working_items.length - 1][0];
      for (attribute in _ref4) {
        value = _ref4[attribute];
        matches = to_match.exec(attribute);
        if ((matches != null ? matches.length : void 0) > 0) {
          match_list.push([attribute, typeof value]);
        }
      }
      match_list.sort();
      return renderAutosuggest(working_items, match_list);
    }
  };
  /*
  Build and show the ul for the auto-suggest matched items.
  */
  renderAutosuggest = function(working_items, match_list) {
    var html, item, list, _i, _j, _len, _len2;
    list = '';
    for (_i = 0, _len = working_items.length; _i < _len; _i++) {
      item = working_items[_i];
      list += item[1] + '.';
    }
    html = "<li class='current-object'>" + list + "</li>";
    for (_j = 0, _len2 = match_list.length; _j < _len2; _j++) {
      item = match_list[_j];
      html += "<li class='" + item[1] + "'>" + item[0] + "</li>";
    }
    return $els.autosuggest_list.html(html);
  };
  /*
  If localStorage is supported, try loading previous command history.
  Throws an error if called when localStorage is not supported.
  */
  loadFromStorage = function() {
    var entry_source, previous_data, _i, _len, _results;
    if (!(typeof localStorage !== "undefined" && localStorage !== null)) {
      throw 'localStorage not supported by this browser. History will not be persisted';
    } else {
      previous_data = localStorage.getItem(settings.ls_key);
      if (previous_data != null) {
        previous_data = JSON.parse(previous_data);
        _results = [];
        for (_i = 0, _len = previous_data.length; _i < _len; _i++) {
          entry_source = previous_data[_i];
          _results.push(execute(entry_source));
        }
        return _results;
      }
    }
  };
  /*
  Clear the display of the history and excute each item in the history.
  */
  replayHistory = function() {
    var entries_to_replay, entry, _i, _len, _results;
    entries_to_replay = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = history.length; _i < _len; _i++) {
        entry = history[_i];
        _results.push(entry.source);
      }
      return _results;
    })();
    history = [];
    $els.history_list.empty();
    history_index = 0;
    _results = [];
    for (_i = 0, _len = entries_to_replay.length; _i < _len; _i++) {
      entry = entries_to_replay[_i];
      _results.push(execute(entry));
    }
    return _results;
  };
  /*
  Compile and evaluate the specified CoffeeScript source string.
  */
  execute = function(source) {
    var compiled_js, cs_error, entry, entry_sources, error_output, js_error, new_li, result, this_result_index;
    if (source === 'localStorage.clear()') {
      return clearHistory();
    } else {
      if (history.length === 0) {
        $els.history_list.empty();
      }
      history_index = -1;
      error_output = null;
      cs_error = false;
      js_error = false;
      try {
        compiled_js = CoffeeScript.compile(source, {
          bare: true
        });
      } catch (error) {
        cs_error = true;
        error_output = error;
      }
      if (!(error_output != null)) {
        try {
          result = eval.call(window, compiled_js);
        } catch (eval_error) {
          js_error = true;
          error_output = eval_error;
        }
      }
      if (error_output != null) {
        result = error_output;
      }
      history.push({
        result: result,
        source: source
      });
      this_result_index = history.length - 1;
      new_li = $("<li class='" + (typeof result) + "'>" + this_result_index + ": " + result + "</li>");
      if (js_error) {
        new_li.addClass('js-error');
      } else if (cs_error) {
        new_li.addClass('cs-error');
      }
      new_li.click(function() {
        loadPrevious(false, this_result_index);
        return $els.textarea.focus();
      });
      new_li.prependTo($els.history_list);
      entry_sources = (function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = history.length; _i < _len; _i++) {
          entry = history[_i];
          _results.push(entry.source);
        }
        return _results;
      })();
      if (typeof localStorage !== "undefined" && localStorage !== null) {
        localStorage.setItem(settings.ls_key, JSON.stringify(entry_sources));
      }
      $els.clear_history.show();
      return $els.replay_history.show();
    }
  };
  /*
  Empty the history in memory, disk, and page.
  */
  clearHistory = function() {
    var autosuggest, autsuggest_query;
    $els.history_list.empty();
    history = [];
    if (typeof localStorage !== "undefined" && localStorage !== null) {
      localStorage.removeItem(settings.ls_key);
    }
    appendInstructions();
    autosuggest = [[window, 'window']];
    autsuggest_query = '';
    $els.clear_history.hide();
    return $els.replay_history.hide();
  };
  /*
  Show instructions for how to use the widget, depending on multi-line setting.
  */
  appendInstructions = function() {
    var instructions;
    if (history.length === 0) {
      if (settings.multi_line) {
        instructions = 'type CoffeeScript, press shift+enter';
      } else {
        instructions = 'type CoffeeScript, press enter';
      }
      return $els.history_list.html("<li class='instructions'>" + instructions + "</li>");
    }
  };
  /*
  Given a history index to load, set the current source input to that entry's
  source. Supports going either direction through the history; pass `true` for
  `forward` to move forward in the list.
  */
  loadPrevious = function(forward, target_index) {
    if (forward == null) {
      forward = false;
    }
    if (target_index != null) {
      history_index = target_index + 1;
    }
    if (history_index === -1 || history_index === 0) {
      history_index = history.length - 1;
    } else {
      if (forward) {
        history_index += 1;
      } else {
        history_index -= 1;
      }
    }
    if (history.length > 0) {
      $els.textarea.val(history[history_index].source);
      $els.textarea.selectionStart = 0;
      return $els.textarea.selectionEnd = 0;
    }
  };
  /*
  Switch between single-line and multi-line modes, disabling auto-suggest if in
  multi-line mode.
  */
  toggleMultiLine = function() {
    var new_height;
    showing_multi_line = !showing_multi_line;
    if (showing_multi_line) {
      new_height = '4em';
      $els.autosuggest_list.hide();
    } else {
      new_height = '';
      if (settings.auto_suggest) {
        $els.autosuggest_list.show();
      }
    }
    $els.textarea.css('height', new_height).focus();
    return appendInstructions();
  };
  /*
  Build and display the widget elements.
  */
  renderWidget = function() {
    var widget;
    widget = $(template);
    $els = {
      widget: widget,
      textarea: widget.find('textarea'),
      autosuggest_list: widget.find('ul.autosuggest'),
      history_list: widget.find('ul.history'),
      button: widget.find('button'),
      div: widget.find('div'),
      clear_history: widget.find('span.clear'),
      replay_history: widget.find('span.replay'),
      a: widget.find('a'),
      toggle_multiline: widget.find('input'),
      p: widget.find('p'),
      li: widget.find('li')
    };
    $els.widget.css({
      'position': "" + settings.widget_position,
      'top': "" + settings.widget_top,
      'right': "" + settings.widget_right
    });
    appendInstructions();
    bindEvents();
    return widget.appendTo('body');
  };
  /*
  Setup the various events for the control elements.
  */
  bindEvents = function() {
    $els.button.click(function() {
      active = !active;
      if (active) {
        $els.div.show();
        $els.p.show();
        $els.textarea.focus();
        return $els.button.addClass('active');
      } else {
        $els.div.hide();
        $els.p.hide();
        return $els.button.removeClass('active');
      }
    });
    $els.clear_history.click(function() {
      return clearHistory();
    });
    $els.replay_history.click(function() {
      $els.history_list.empty();
      return setTimeout(function() {
        return replayHistory();
      }, 100);
    });
    $els.toggle_multiline.click(function() {
      return toggleMultiLine();
    });
    $els.textarea.bind('keydown', function(e) {
      var end, entered_source, start;
      entered_source = $els.textarea.val();
      if (this.selectionStart === 0) {
        if (e.which === keycode.UP) {
          loadPrevious();
        } else if (e.which === keycode.DOWN) {
          loadPrevious(true);
        }
      }
      if (e.which === keycode.ENTER && (!settings.multi_line || e.shiftKey)) {
        e.preventDefault();
        if (entered_source !== '') {
          execute(entered_source);
          return $els.textarea.val('');
        }
      } else if (e.which === keycode.TAB) {
        e.preventDefault();
        start = this.selectionStart;
        end = this.selectionEnd;
        this.value = this.value.substring(0, start) + settings.indent + this.value.substring(start);
        this.selectionStart = start + settings.indent.length;
        return this.selectionEnd = start + settings.indent.length;
      }
    });
    $els.textarea.bind('keyup', function(e) {
      var entered_source;
      entered_source = $els.textarea.val();
      if (!settings.multi_line && settings.auto_suggest) {
        return buildAutosuggest(entered_source, e);
      }
    });
    if (settings.multi_line) {
      $els.toggle_multiline.click();
    }
    return $(window).resize(function() {
      var height, width;
      height = "" + (window.innerHeight - 140) + "px";
      width = "" + (window.innerWidth - 255) + "px";
      $els.autosuggest_list.css({
        'max-height': height,
        'max-width': width
      });
      return $els.history_list.css('max-height', height);
    });
  };
  window.CoffeeTable = {
    show: function() {
      $els.widget.show();
      return this;
    },
    hide: function() {
      $els.widget.hide();
      return this;
    },
    clear: function() {
      clearHistory();
      return this;
    },
    replay: function() {
      replayHistory();
      return this;
    },
    deferInit: function() {
      deferred = true;
      return this;
    },
    init: function(opts) {
      setSettings(opts);
      preInit();
      return this;
    }
  };
  /*
  Load the default settings and apply user overrides.
  */
  setSettings = function(opts) {
    var key, value, _results;
    settings = defaults;
    _results = [];
    for (key in opts) {
      value = opts[key];
      _results.push(settings[key] = value);
    }
    return _results;
  };
  /*
  Helper for loading external scripts.
  */
  loadScript = function(script_name) {
    var head, script;
    head = document.getElementsByTagName('head')[0];
    script = document.createElement('script');
    script.type = 'application/javascript';
    script.src = settings[script_name];
    script.async = true;
    script.onload = function() {
      loaded_scripts[script_name] = true;
      return init();
    };
    return head.appendChild(script);
  };
  /*
  Helper for prepping settings and checking if dependencies are loaded.
  */
  preInit = function() {
    var _ref3;
    if ($els != null) {
      if ((_ref3 = $els.widget) != null) {
        _ref3.remove();
      }
    }
    active = false;
    loaded_scripts.jquery_js = window.jQuery != null;
    loaded_scripts.coffeescript_js = window.CoffeeScript != null;
    if (!loaded_scripts.coffeescript_js) {
      if (!settings.autoload_coffee_script) {
        throw 'CoffeeTable requires coffee_script.js';
      } else {
        loadScript('coffeescript_js');
      }
    }
    if (!loaded_scripts.jquery_js) {
      if (!settings.autoload_jquery) {
        throw 'CoffeeTable requires jQuery';
      } else {
        loadScript('jquery_js');
      }
    }
    return init();
  };
  /*
  Automatically load dependencies and initialize the widget, unless deferred.
  */
  document.addEventListener('DOMContentLoaded', function() {
    document.removeEventListener('DOMContentLoaded', arguments.callee, false);
    if (!deferred && !loaded) {
      setSettings();
      return preInit();
    }
  }, false);
}).call(this);
