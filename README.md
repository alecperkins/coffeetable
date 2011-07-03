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

Click the "CoffeeTable" button in the top-right. Enter CoffeeScript code in the textarea, and press `enter` to execute it. The output will be listed below. For multiline input, check the "multiline" box, then use `shift`+`enter` instead to execute code. `log` and `dir` are shortcuts to the `console` functions. `this` is the `window` object. Use `@foo = bar` to make a variable global. It will then be accessible in subsequent entries. If localStorage is supported, CoffeeTable uses it to persist the history, and then replay it on load. Click on a history item to load the source that generated it. Also, you can indent 4 spaces using `tab`, and go through the history using the `up arrow`.
    
### Output color coding

* light-red : JavaScript eval error
* orange    : CoffeeScript parse error
* dark-red  : string
* green     : function
* turquoise : boolean
* blue      : number
* black     : object
* grey      : undefined
