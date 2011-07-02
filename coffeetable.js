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
  window.log = function() {
    return console.log(arguments);
  };
  window.dir = function() {
    return console.dir(arguments);
  };
  CoffeeTable = (function() {
    var $els, active, clearHistory, execute, history, history_index, loadCSJS, loadFromStorage, loadPrevious, renderWidget, result_styles, settings, styles, template, toggleMultiLine;
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
          'max-height': '95%',
          'overflow-y': 'scroll'
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
        ul: {
          'margin': '8px',
          'padding': '4px 4px 4px 16px',
          'font-family': 'monospace'
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
          'color': '#ccc',
          'font-variant': 'small-caps',
          'display': 'none'
        },
        a: {
          'padding': '4px',
          'text-align': 'center',
          'cursor': 'pointer',
          'float': 'right',
          'color': '#ccc',
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
          'color': '#ccc',
          'font-variant': 'small-caps',
          'display': 'none',
          'text-align': 'right'
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
      template = "            <div>                <button>CoffeeTable</button>                <span>clear</span>                <a href='https://github.com/alecperkins/coffeetable' target='_blank'>?</a>                <p>multiline <input type='checkbox'></p>                <div>                    <textarea></textarea>                    <ul></ul>                </div>            </div>        ";
      loadCSJS();
      renderWidget();
      if (settings.local_storage) {
        loadFromStorage();
      }
    }
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
        return loadPrevious(false, this_result_index);
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
      new_li.prependTo($els.ul);
      $els.span.show();
      return typeof localStorage !== "undefined" && localStorage !== null ? localStorage.setItem(settings.ls_key, JSON.stringify(history.source)) : void 0;
    };
    clearHistory = function() {
      $els.ul.empty();
      history.source = [];
      history.result = [];
      if (typeof localStorage !== "undefined" && localStorage !== null) {
        localStorage.removeItem(settings.ls_key);
      }
      return $els.span.hide();
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
      var new_height;
      console.log('toggle multi');
      settings.multi_line = !settings.multi_line;
      new_height = settings.multi_line ? '4em' : styles.textarea.height;
      return $els.textarea.css('height', new_height).focus();
    };
    renderWidget = function() {
      var el, el_name, widget;
      widget = $(template);
      $els = {
        widget: widget,
        textarea: widget.find('textarea'),
        ul: widget.find('ul'),
        button: widget.find('button'),
        div: widget.find('div'),
        span: widget.find('span'),
        a: widget.find('a'),
        input: widget.find('input'),
        p: widget.find('p')
      };
      for (el_name in $els) {
        el = $els[el_name];
        el.css(styles[el_name]);
      }
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
            console.log(history_index);
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
          this.value = this.value.substring(0, start) + "    " + this.value.substring(start);
          this.selectionStart = start + 4;
          return this.selectionEnd = start + 4;
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
