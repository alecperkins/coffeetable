(function() {
  /*
  CoffeeTable
  
  A drop-in, CoffeeScript-fluent console for web pages.
  
  See https://github.com/alecperkins/coffeetable for more information, and
  http://code.alecperkins.net/coffeetable for a working demo.
  */  var $, CoffeeTable, default_settings, init;
  default_settings = {
    coffeescript_js: 'http://code.alecperkins.net/coffeetable/lib/coffee_script-1.1.1-min.js',
    style: {
      position: 'fixed',
      top: '5px',
      right: '5px'
    },
    local_storage: true,
    ls_key: 'coffee-table',
    multi_line: false,
    indent: '    ',
    auto_suggest: true
  };
    if (typeof console !== "undefined" && console !== null) {
    console;
  } else {
    console = {
      log: function() {},
      dir: function() {}
    };
  };
  window.log = function() {
    return console.log.apply(console, arguments);
  };
  window.dir = function() {
    return console.dir.apply(console, arguments);
  };
  $ = window.jQuery;
  CoffeeTable = (function() {
    var $els, active, appendInstructions, clearHistory, execute, getAutocomplete, history, history_index, loadFromStorage, loadPrevious, renderWidget, result_styles, settings, styles, template, toggleMultiLine;
    settings = null;
    $els = null;
    styles = null;
    result_styles = null;
    template = '';
    active = false;
    history_index = 0;
    history = {
      source: [],
      result: []
    };
    function CoffeeTable(opts) {
      var k, v;
      if (opts == null) {
        opts = {};
      }
      settings = default_settings;
      for (k in opts) {
        v = opts[k];
        settings[k] = v;
      }
      styles = {
        widget: {
          'position': "" + settings.style.position,
          'top': "" + settings.style.top,
          'right': "" + settings.style.right,
          'background': 'rgba(255,255,255,0.9)',
          'padding': '0',
          'border': '2px solid white',
          'z-index': '9999999',
          'box-shadow': '0px 0px 4px #222',
          '-moz-box-shadow': '0px 0px 4px #222',
          '-webkit-box-shadow': '0px 0px 4px #222',
          'font-size': '12px',
          'max-height': '95%',
          'max-width': '900px'
        },
        button: {
          'float': 'right',
          'background': 'white',
          'border': '1px solid #ccc',
          'color': '#991111',
          'cursor': 'pointer'
        },
        button_active: {
          'background': '#991111',
          'color': 'white'
        },
        textarea: {
          'font-family': 'monospace',
          'font-size': '15px',
          'min-width': '400px',
          'height': '22px',
          'margin': '4px'
        },
        div: {
          'display': 'none'
        },
        CTHistory: {
          'margin': '8px',
          'padding': '4px 4px 4px 16px',
          'font-family': 'monospace',
          'list-style-type': 'circle',
          'overflow-y': 'scroll',
          'max-height': "" + (window.innerHeight - 140) + "px"
        },
        li: {
          'padding': '4px 4px 4px 4px',
          'cursor': 'pointer'
        },
        span: {
          'padding': '4px',
          'text-align': 'center',
          'cursor': 'pointer',
          'float': 'left',
          'color': '#555',
          'font-variant': 'small-caps',
          'display': 'none'
        },
        a: {
          'padding': '4px',
          'text-align': 'center',
          'cursor': 'pointer',
          'float': 'right',
          'color': '#555',
          'font-variant': 'small-caps'
        },
        input: {
          'vertical-align': 'middle'
        },
        p: {
          'padding': '4px',
          'margin': '0',
          'float': 'right',
          'display': 'inline-block',
          'width': '80px',
          'color': '#555',
          'font-variant': 'small-caps',
          'display': 'none',
          'text-align': 'right'
        },
        CTAutocomplete: {
          'position': 'absolute',
          'top': '-14px',
          'left': '-300px',
          'display': 'block',
          'background': 'rgba(255,255,255,0.9)',
          'box-shadow': '0px 0px 4px #222',
          '-moz-box-shadow': '0px 0px 4px #222',
          '-webkit-box-shadow': '0px 0px 4px #222',
          'width': '250px',
          'max-height': "" + (window.innerHeight - 140) + "px",
          'overflow-y': 'scroll'
        }
      };
      result_styles = {
        'function': {
          'color': '#229922'
        },
        'number': {
          'color': '#222299'
        },
        'string': {
          'color': '#992222'
        },
        'undefined': {
          'color': 'grey',
          'font-style': 'italic'
        },
        'object': {},
        'boolean': {
          'color': '#229999'
        }
      };
      template = "            <div>                <button>CoffeeTable</button>                <span>clear</span>                <a href='https://github.com/alecperkins/coffeetable' target='_blank'>?</a>                <p>multiline <input type='checkbox'></p>                <div>                    <textarea></textarea>                    <ul class='CTAutocomplete'></ul>                    <ul class='CTHistory'></ul>                </div>            </div>        ";
      renderWidget();
      if (settings.local_storage) {
        loadFromStorage();
      }
    }
    window.onresize = function() {
      var height;
      height = "" + (window.innerHeight - 140) + "px";
      $els.CTAutocomplete.css('max-height', height);
      return $els.CTHistory.css('max-height', height);
    };
    getAutocomplete = function(text, e) {
      var attribute, html, item, list, match_list, matches, to_match, token, tokens, value, working_items, _i, _j, _k, _len, _len2, _len3, _ref, _ref2;
      if (e.which === 8 && text.length === 0 && $els.CTAutocomplete.html().length !== 0) {
        return $els.CTAutocomplete.html('');
      } else {
        tokens = text.split('.');
        working_items = [[window, 'window']];
        _ref = tokens.slice(0, tokens.length - 1);
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          token = _ref[_i];
          token = token.replace('(', '').replace(')', '');
          if (token.length > 0) {
            working_items.push([working_items[working_items.length - 1][0][token], token]);
          }
        }
        match_list = [];
        to_match = new RegExp('^' + tokens[tokens.length - 1]);
        _ref2 = working_items[working_items.length - 1][0];
        for (attribute in _ref2) {
          value = _ref2[attribute];
          matches = to_match.exec(attribute);
          if ((matches != null ? matches.length : void 0) > 0) {
            match_list.push([attribute, typeof value]);
          }
        }
        match_list.sort();
        list = '';
        for (_j = 0, _len2 = working_items.length; _j < _len2; _j++) {
          item = working_items[_j];
          list += item[1] + '.';
        }
        html = "<li style='font-weight:bold; text-decoration: underline; list-style-type: none'>" + list + "</li>";
        for (_k = 0, _len3 = match_list.length; _k < _len3; _k++) {
          item = match_list[_k];
          html += "<li style='color:" + result_styles[item[1]].color + "'>" + item[0] + "</li>";
        }
        return $els.CTAutocomplete.html(html);
      }
    };
    loadFromStorage = function() {
      var execHistory, previous_data;
      previous_data = typeof localStorage !== "undefined" && localStorage !== null ? localStorage.getItem(settings.ls_key) : void 0;
      if (previous_data != null) {
        previous_data = JSON.parse(previous_data);
        execHistory = function() {
          var item, _i, _len, _results;
          if (typeof CoffeeScript !== "undefined" && CoffeeScript !== null) {
            _results = [];
            for (_i = 0, _len = previous_data.length; _i < _len; _i++) {
              item = previous_data[_i];
              _results.push(execute(item));
            }
            return _results;
          } else {
            return setTimeout(function() {
              return execHistory();
            }, 500);
          }
        };
        return execHistory();
      }
    };
    execute = function(source) {
      var cs_error, error_output, js, js_error, new_li, result, this_result_index;
      if (source === 'localStorage.clear()') {
        return clearHistory();
      } else {
        if (history.source.length === 0) {
          $els.CTHistory.empty();
        }
        history_index = -1;
        history.source.push(source);
        error_output = null;
        cs_error = false;
        js_error = false;
        try {
          js = CoffeeScript.compile(source, {
            bare: true
          });
        } catch (error) {
          cs_error = true;
          error_output = error;
        }
        if (!(error_output != null)) {
          try {
            result = eval(js);
          } catch (eval_error) {
            js_error = true;
            error_output = eval_error;
          }
        }
        if (error_output != null) {
          result = error_output;
        }
        history.result.push(result);
        this_result_index = history.source.length - 1;
        new_li = $("<li>" + this_result_index + ": <span class='CTResultName'>" + result + "</span><span class='CTResultLoad'>src</span></li>");
        new_li.css(styles.li);
        new_li.find('span.CTResultName').css(result_styles[typeof result]);
        if (cs_error) {
          new_li.css('color', 'orange');
        } else if (js_error) {
          new_li.css('color', 'red');
        }
        new_li.hover(function() {
          return new_li.css({
            background: 'rgba(255,255,0,0.2)',
            'list-style-type': 'disc'
          });
        }, function() {
          return new_li.css({
            'background': '',
            'list-style-type': ''
          });
        });
        new_li.click(function() {
          loadPrevious(false, this_result_index);
          return $els.textarea.focus();
        });
        new_li.mousedown(function() {
          return new_li.css({
            'background': 'rgba(255,255,0,0.8)'
          });
        });
        new_li.mouseup(function() {
          return new_li.css({
            'background': 'rgba(255,255,0,0.2)'
          });
        });
        new_li.prependTo($els.CTHistory);
        $els.span.show();
        return typeof localStorage !== "undefined" && localStorage !== null ? localStorage.setItem(settings.ls_key, JSON.stringify(history.source)) : void 0;
      }
    };
    clearHistory = function() {
      var autocomplete_items, autocomplete_query;
      $els.CTHistory.empty();
      history.source = [];
      history.result = [];
      if (typeof localStorage !== "undefined" && localStorage !== null) {
        localStorage.removeItem(settings.ls_key);
      }
      $els.span.hide();
      appendInstructions();
      autocomplete_items = [[window, 'window']];
      return autocomplete_query = '';
    };
    appendInstructions = function() {
      var instructions;
      instructions = $('<li>type CoffeeScript, press enter</li>');
      instructions.css({
        'list-style-type': 'none',
        'text-align': 'center'
      });
      return instructions.appendTo($els.CTHistory);
    };
    loadPrevious = function(forward, target_index) {
      if (forward == null) {
        forward = false;
      }
      if (target_index != null) {
        history_index = target_index + 1;
      }
      if (history_index === -1) {
        history_index = history.source.length - 1;
      } else {
        if (forward) {
          history_index += 1;
        } else {
          history_index -= 1;
        }
      }
      if (history.source.length > 1) {
        $els.textarea.val(history.source[history_index]);
        $els.textarea.selectionStart = 0;
        return $els.textarea.selectionEnd = 0;
      }
    };
    toggleMultiLine = function() {
      var instruction, new_height;
      settings.multi_line = !settings.multi_line;
      if (settings.multi_line) {
        new_height = '4em';
        instruction = 'type CoffeeScript, press shift+enter';
        $els.CTAutocomplete.hide();
      } else {
        new_height = styles.textarea.height;
        instruction = 'type CoffeeScript, press enter';
        if (settings.auto_suggest) {
          $els.CTAutocomplete.show();
        }
      }
      $els.textarea.css('height', new_height).focus();
      if (history.source.length === 0) {
        return $els.CTHistory.find('li').text(instruction);
      }
    };
    renderWidget = function() {
      var el, el_name, widget;
      widget = $(template);
      $els = {
        widget: widget,
        textarea: widget.find('textarea'),
        CTAutocomplete: widget.find('ul.CTAutocomplete'),
        CTHistory: widget.find('ul.CTHistory'),
        button: widget.find('button'),
        div: widget.find('div'),
        span: widget.find('span'),
        a: widget.find('a'),
        input: widget.find('input'),
        p: widget.find('p'),
        li: widget.find('li')
      };
      for (el_name in $els) {
        el = $els[el_name];
        el.css(styles[el_name]);
      }
      appendInstructions();
      $els.button.click(function() {
        if (active) {
          $els.button.css(styles.button);
          $els.div.hide();
          $els.p.hide();
        } else {
          $els.button.css(styles.button_active);
          $els.div.show();
          $els.p.show();
          $els.textarea.focus();
        }
        return active = !active;
      });
      $els.span.click(function() {
        return clearHistory();
      });
      $els.span.hover(function() {
        return $els.span.css('color', '#991111');
      }, function() {
        return $els.span.css('color', styles.span.color);
      });
      $els.input.click(function() {
        return toggleMultiLine();
      });
      $els.textarea.bind('keydown', function(e) {
        var end, entered_source, start;
        entered_source = $els.textarea.val();
        if (this.selectionStart === 0) {
          if (e.which === 38) {
            loadPrevious();
          } else if (e.which === 40) {
            loadPrevious(true);
          }
        }
        if (e.which === 13 && (!settings.multi_line || e.shiftKey)) {
          e.preventDefault();
          if (entered_source !== '') {
            execute(entered_source);
            return $els.textarea.val('');
          }
        } else if (e.which === 9) {
          e.preventDefault();
          start = this.selectionStart;
          end = this.selectionEnd;
          this.value = this.value.substring(0, start) + settings.indent + this.value.substring(start);
          this.selectionStart = start + 4;
          return this.selectionEnd = start + 4;
        }
      });
      $els.textarea.bind('keyup', function(e) {
        var entered_source;
        entered_source = $els.textarea.val();
        if (!settings.multi_line && settings.auto_suggest) {
          return getAutocomplete(entered_source, e);
        }
      });
      if (settings.multi_line) {
        $els.input.click();
      }
      return widget.appendTo('body');
    };
    CoffeeTable.prototype.show = function() {
      $els.widget.show();
      return this;
    };
    CoffeeTable.prototype.hide = function() {
      $els.widget.hide();
      return this;
    };
    CoffeeTable.prototype.clear = function() {
      clearHistory();
      return this;
    };
    return CoffeeTable;
  })();
  init = function() {
    return window.coffeetable_instance = new CoffeeTable(window.coffeetable_settings);
  };
  $(document).ready(function() {
    var script_el;
    window.CoffeeTable = CoffeeTable;
    if (!(window.CoffeeScript != null)) {
      script_el = document.createElement('script');
      script_el.type = 'application/javascript';
      script_el.src = default_settings.coffeescript_js;
      $(script_el).bind('load', function(e) {
        return init();
      });
      return $('head').append(script_el);
    } else {
      return init();
    }
  });
}).call(this);
