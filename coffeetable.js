(function() {
  /*
  CoffeeTable
  
  A drop-in workbench for experimentation.
  http://github.com/alecperkins/coffeetable
  */  var CoffeeTable, default_settings;
  default_settings = {
    coffeescript_js: "https://raw.github.com/alecperkins/coffeetable/master/lib/coffee_script-1.1.1-min.js",
    style: {
      position: 'fixed',
      top: '5px',
      right: '5px'
    },
    local_storage: true,
    ls_key: 'coffee-table',
    multi_line: false
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
    return console.log(arguments);
  };
  window.dir = function() {
    return console.dir(arguments);
  };
  CoffeeTable = (function() {
    var $els, active, appendInstructions, autocomplete_items, autocomplete_query, clearHistory, execute, getAutocomplete, history, history_index, loadCSJS, loadFromStorage, loadPrevious, renderWidget, result_styles, settings, styles, template, toggleMultiLine;
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
          'font-size': '12px',
          'max-height': '95%'
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
          'overflow-y': 'scroll'
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
          'top': '0',
          'left': '-250px',
          'display': 'block',
          'background': 'rgba(255,255,255,0.8)',
          'box-shadow': '0px 0px 4px #222',
          'width': '200px',
          'max-height': '800px',
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
      loadCSJS();
      renderWidget();
      if (settings.local_storage) {
        loadFromStorage();
      }
    }
    autocomplete_items = [[window, 'window']];
    autocomplete_query = '';
    getAutocomplete = function(e, text) {
      var attribute, character, html, item, match_list, matches, pop_token, push_token, to_match, value, _i, _len, _ref, _ref2, _ref3;
      push_token = pop_token = false;
      character = null;
      if (text.length === 0) {
        autocomplete_query = '';
      }
      if (e.which === 8) {
        if (autocomplete_query.length > 0) {
          autocomplete_query = autocomplete_query.slice(0, autocomplete_query.length - 1);
        } else {
          if (autocomplete_items.length > 1) {
            autocomplete_query = autocomplete_items.pop()[1];
          } else {
            autocomplete_query = '';
          }
        }
        console.log;
      } else {
        if ((65 <= (_ref = e.which) && _ref <= 90) || (48 <= (_ref2 = e.which) && _ref2 <= 57)) {
          character = String.fromCharCode(e.which);
          if (!e.shiftKey) {
            character = character.toLowerCase();
          } else {
            if (e.which === 57) {
              character = '(';
              pop_token = true;
            } else if (e.which === 48) {
              character = ')';
              pop_token = true;
            } else if (e.which === 52) {
              character = '$';
            }
          }
        } else if (e.which === 190) {
          character = '.';
          push_token = true;
        } else if (e.which === 32) {
          character = ' ';
          pop_token = true;
        } else if (e.which === 13) {
          pop_token = true;
        }
        if (push_token || pop_token) {
          if (autocomplete_query.length > 0) {
            if (push_token) {
              autocomplete_items.push([autocomplete_items[autocomplete_items.length - 1][autocomplete_query], autocomplete_query]);
            } else {
              autocomplete_items = [[window, 'window']];
            }
          }
          autocomplete_query = '';
        } else if (character != null) {
          autocomplete_query += character;
        }
      }
      console.log(autocomplete_query);
      match_list = [];
      to_match = new RegExp('^' + autocomplete_query);
      _ref3 = autocomplete_items[autocomplete_items.length - 1][0];
      for (attribute in _ref3) {
        value = _ref3[attribute];
        matches = to_match.exec(attribute);
        if ((matches != null ? matches.length : void 0) > 0) {
          match_list.push(attribute);
        }
      }
      match_list.sort();
      html = "<li style='font-weight:bold; text-decoration: underline; list-style-type: none'>" + autocomplete_items[autocomplete_items.length - 1][1] + "</li>";
      for (_i = 0, _len = match_list.length; _i < _len; _i++) {
        item = match_list[_i];
        html += "<li>" + item + "</li>";
      }
      $els.CTAutocomplete.html(html);
      if (e.which === 9 && match_list > 0 && autocomplete_query.length > 0) {
        return console.log(match_list[0].replace(autocomplete_query, ''));
      }
    };
    loadFromStorage = function() {
      var execHistory, previous_data;
      previous_data = typeof localStorage !== "undefined" && localStorage !== null ? localStorage.getItem('coffee-table') : void 0;
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
      new_li = $("<li>" + this_result_index + ": <span>" + result + "</span></li>");
      new_li.css(styles.li);
      new_li.find('span').css(result_styles[typeof result]);
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
    };
    clearHistory = function() {
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
      } else {
        new_height = styles.textarea.height;
        instruction = 'type CoffeeScript, press enter';
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
        li: widget.find('li'),
        autocomplete: widget.find('autocomplete')
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
            $els.textarea.val('');
          }
        } else if (e.which === 9) {
          e.preventDefault();
          start = this.selectionStart;
          end = this.selectionEnd;
          this.value = this.value.substring(0, start) + "    " + this.value.substring(start);
          this.selectionStart = start + 4;
          this.selectionEnd = start + 4;
        }
        if (!settings.multi_line) {
          return getAutocomplete(e, entered_source);
        }
      });
      if (settings.multi_line) {
        $els.input.click();
      }
      return widget.appendTo('body');
    };
    loadCSJS = function() {
      var script_el;
      if (!(window.CoffeeScript != null)) {
        script_el = document.createElement('script');
        script_el.type = 'application/javascript';
        script_el.src = default_settings.coffeescript_js;
        return $('head').append(script_el);
      }
    };
    CoffeeTable.prototype.show = function() {
      $els.widget.show();
      return this;
    };
    CoffeeTable.prototype.hide = function() {
      $els.widget.hide();
      return this;
    };
    return CoffeeTable;
  })();
  window.CoffeeTable = CoffeeTable;
  $(document).ready(function() {
    return window.coffeetable_instance = new CoffeeTable(window.coffeetable_settings);
  });
}).call(this);
