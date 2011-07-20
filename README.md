# CoffeeTable, v0.1.1
A drop-in workbench for experimentation. CoffeeTable provides a CoffeeScript console on a page.

* [Demo](http://code.alecperkins.net/coffeetable/)
* [GitHub repo](https://github.com/alecperkins/coffeetable)



## Requires

* [jQuery](http://jquery.com/)
* [coffee_script.js](http://coffeescript.org) (loaded automatically if not already present)



## To use

Load `coffeetable-min.js` into the page:

    <script type="application/javascript" src="http://code.alecperkins.net/coffeetable/coffeetable-min.js"></script>

Click the "CoffeeTable" button in the top-right. Enter CoffeeScript code in the textarea, and press `enter` to execute it. The output will be listed below. For multiline input, check the "multiline" box, then use `shift`+`enter` instead to execute code. `log` and `dir` are shortcuts to the `console` functions. `this` is the `window` object. Everything happens in the global context.

If localStorage is supported, CoffeeTable uses it to persist the history, and then _replay_ it on load. Click on a history item to load the source that generated it. Also, you can indent 4 spaces using `tab`, and go through the history using the `up arrow`.

There is basic auto-suggest when in single-line mode that enumerates the properties of the currently 'completed' object.

### Bookmarklet

Add this to your bookmarks toolbar for a bookmarklet that will load CoffeeTable on any page.

    javascript:function ctl1(){var d=document,s=d.createElement('script'),b=d.body;if(!b)throw(0);s.setAttribute('src', 'http://code.alecperkins.net/coffeetable/coffeetable-min.js');s.onload=function(){CoffeeTable.init()};b.appendChild(s);}ctl1();void(0)


### Output color coding

* light-red : JavaScript eval error
* orange    : CoffeeScript parse error
* dark-red  : string
* green     : function
* turquoise : boolean
* blue      : number
* black     : object
* grey      : undefined


### API

To prevent automatic initialization, call `CoffeeTable.deferInit()` before the
DOM is ready.

If you want to initialize the widget before the document ready event, or after
`deferInit`, call `CoffeeTable.init(options)`, where options is an optional
hash of settings overrides. You can call `init` any time after CoffeeTable has
been loaded onto the page.

Only one widget can exist at a time. Calling `init` after the widget has loaded
will reinitialize it, using the specified options (see __Default settings__).

_Note: the replaying of history, either on widget reload or on demand, can be
dependent on the overall state of the page, and may not be idempotent._


### Default settings

    defaults =
        # Automatically load jQuery and CoffeeScript if not found in page
        autoload_coffee_script   : true
        autoload_jquery          : true
        # URLs of CoffeeScript and jQuery files to load 
        coffeescript_js : 'http://code.alecperkins.net/coffeetable/lib/coffee_script-1.1.1-min.js'
        jquery_js       : 'http://code.alecperkins.net/coffeetable/lib/jquery-1.6.2-min.js'

        # Persist the history using localStorage
        local_storage   : true
        # Key to persist data with in localStorage
        ls_key          : 'coffee-table'
        # Clear the history on load
        clear_on_load   : false

        # Default to multi-line mode
        multi_line      : false
        # Characters to use as indentation when TAB is pressed
        indent          : '    '
        # Enable auto-suggest panel
        auto_suggest    : true

        # Widget positioning on the screen (CSS values)
        widget_position : 'fixed'
        widget_top      : '5px'
        widget_right    : '5px'
        # ID attribute of widget div.

        # Defaults to including a timestamp for extra (excessive?) uniqueness
        widget_id       : "CoffeeTable-#{ (new Date()).getTime() }"



## By

[Alec Perkins](http://alecperkins.net)

This is free and unencumbered software released into the public domain. See UNLICENSE for more information.
