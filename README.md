# CoffeeTable
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
will reinitialize it, using the specified options.

_Note: the replaying of history, either on widget reload or on demand, can be
dependent on the overall state of the page, and may not be idempotent._


## By

[Alec Perkins](http://alecperkins.net)

This is free and unencumbered software released into the public domain. See UNLICENSE for more information.
