###

# CoffeeTable v0.1.0

A drop-in, CoffeeScript-fluent console for web pages.

* [Demo + Instructions](http://code.alecperkins.net/coffeetable)
* [GitHub repo](https://github.com/alecperkins/coffeetable)

## To use

Load `coffeetable-min.js` into the page:
`<script type="application/javascript" src="http://code.alecperkins.net/coffeetable/coffeetable-min.js"></script>`
...and the widget will automatically initialize.

###



# ## Settings and prep

# Default widget settings.
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


# Trap calls to console.log and console.dir if the console doesn't exist.
# Lookin' at you, IE.
console ?=
    log: ->
    dir: ->

# Alias log and dir for shorter typing if log and dir aren't aready used.
window.log ?= -> console.log arguments...
window.dir ?= -> console.dir arguments...

# Keypress codes, for convenience.
keycode =
    UP          : 38
    DOWN        : 40
    ENTER       : 13
    TAB         : 9
    BACKSPACE   : 8

# Template for widget markup and style.
# `__ID__` will be replaced by the setting for widget_id. This ID is used for
# scoping the CSS rules to avoid conflicts with the existing page styles.
# See `resources/template.html` and `resources/style.sass` for the source files.
template = '<div id="__ID__"><style type="text/css">#__ID__{margin:0;padding:0;border:0;font-size:100%;font:inherit;vertical-align:baseline;-moz-box-shadow:0px 0px 4px #222222;-webkit-box-shadow:0px 0px 4px #222222;-o-box-shadow:0px 0px 4px #222222;box-shadow:0px 0px 4px #222222;background:rgba(255,255,255,0.93);padding:0;border:2px solid #fff;z-index:2147483647;font-size:12px;max-height:95%;max-width:900px}#__ID__ div,#__ID__ span,#__ID__ applet,#__ID__ object,#__ID__ iframe,#__ID__ h1,#__ID__ h2,#__ID__ h3,#__ID__ h4,#__ID__ h5,#__ID__ h6,#__ID__ p,#__ID__ blockquote,#__ID__ pre,#__ID__ a,#__ID__ abbr,#__ID__ acronym,#__ID__ address,#__ID__ big,#__ID__ cite,#__ID__ code,#__ID__ del,#__ID__ dfn,#__ID__ em,#__ID__ img,#__ID__ ins,#__ID__ kbd,#__ID__ q,#__ID__ s,#__ID__ samp,#__ID__ small,#__ID__ strike,#__ID__ strong,#__ID__ sub,#__ID__ sup,#__ID__ tt,#__ID__ var,#__ID__ b,#__ID__ u,#__ID__ i,#__ID__ center,#__ID__ dl,#__ID__ dt,#__ID__ dd,#__ID__ ol,#__ID__ ul,#__ID__ li,#__ID__ fieldset,#__ID__ form,#__ID__ label,#__ID__ legend,#__ID__ table,#__ID__ caption,#__ID__ tbody,#__ID__ tfoot,#__ID__ thead,#__ID__ tr,#__ID__ th,#__ID__ td,#__ID__ article,#__ID__ aside,#__ID__ canvas,#__ID__ details,#__ID__ embed,#__ID__ figure,#__ID__ figcaption,#__ID__ footer,#__ID__ header,#__ID__ hgroup,#__ID__ menu,#__ID__ nav,#__ID__ output,#__ID__ ruby,#__ID__ section,#__ID__ summary,#__ID__ time,#__ID__ mark,#__ID__ audio,#__ID__ video{margin:0;padding:0;border:0;font-size:100%;font:inherit;vertical-align:baseline}#__ID__ table{border-collapse:collapse;border-spacing:0}#__ID__ caption,#__ID__ th,#__ID__ td{text-align:left;font-weight:normal;vertical-align:middle}#__ID__ q,#__ID__ blockquote{quotes:none}#__ID__ q:before,#__ID__ q:after,#__ID__ blockquote:before,#__ID__ blockquote:after{content:"";content:none}#__ID__ a img{border:none}#__ID__ .toggle-widget{float:right;background:#fff;border:1px solid #ccc;color:#911;cursor:pointer}#__ID__ .toggle-widget:active,#__ID__ .toggle-widget.active{background:#911;color:#fff}#__ID__ .coffee-source{font-family:monospace;font-size:15px;min-width:400px;height:22px;margin:4px}#__ID__ .input{display:none}#__ID__ .history{margin:8px;padding:4px 4px 4px 16px;font-family:monospace;list-style-type:circle;overflow-y:scroll}#__ID__ .history li{padding:4px;cursor:pointer}#__ID__ .history li:hover{background-color:rgba(255,255,0,0.2);list-style-type:disc}#__ID__ .history li:active{background-color:rgba(255,255,0,0.8)}#__ID__ .history li.cs-error{color:orange}#__ID__ .history li.js-error{color:red}#__ID__ .history li.instructions{list-style-type:none;text-align:center}#__ID__ .history li.instructions:hover{background-color:#fff;cursor:default}#__ID__ .clear,#__ID__ .replay{padding:4px;text-align:center;cursor:pointer;float:left;color:#555;font-variant:small-caps;display:none}#__ID__ .clear:hover,#__ID__ .replay:hover{color:#911}#__ID__ a{padding:4px;text-align:center;cursor:pointer;float:right;color:#555;font-variant:small-caps}#__ID__ input{vertical-align:middle}#__ID__ p{padding:4px;margin:0;float:right;display:inline-block;width:80px;color:#555;font-variant:small-caps;display:none;text-align:right}#__ID__ .autosuggest{-moz-box-shadow:0px 0px 4px #222222;-webkit-box-shadow:0px 0px 4px #222222;-o-box-shadow:0px 0px 4px #222222;box-shadow:0px 0px 4px #222222;position:absolute;top:-2px;left:-260px;display:block;background:rgba(255,255,255,0.9);width:250px;overflow-y:scroll;font-family:monospace}#__ID__ .autosuggest li{padding:4px}#__ID__ .autosuggest li.heading{font-weight:bold;text-decoration:underline;list-style-type:none}#__ID__ .function{color:#292}#__ID__ .number{color:#229}#__ID__ .string{color:#922}#__ID__ .undefined{color:grey;font-style:italic}#__ID__ .object{color:#000}#__ID__ .boolean{color:#299}</style><button class="toggle-widget">CoffeeTable</button><span class="clear">clear</span><span class="replay">replay</span><a href="http://code.alecperkins.net/coffeetable/" target="_blank">?</a><p>multiline <input type="checkbox"></p><div class="input"><textarea class="coffee-source"></textarea><ul class="autosuggest"></ul><ul class="history"></ul></div></div>'

# Initialize variables so they're visible to all internal functions.
$           = null
settings    = null
$els        = null

# State variables
active              = false
deferred            = false
loaded              = false
showing_multi_line  = false
history_index       = 0
loaded_scripts =
    jquery_js       : false
    coffeescript_js : false


###
Track the input history with a list of objects like this...
`
    {
      source: 'CoffeeScript code',
      result: 'result of eval'
    }
`
...in order of entry by the user.
###
history = []


# ## Main functions

# ### init
###
Loads settings, and initiates the rendering of the widget and loading of
previous history from localStorage.
###
init = (opts={}) ->
    if loaded_scripts.jquery_js and loaded_scripts.coffeescript_js
        # Use $ even if jQuery is in no-conflict mode
        $ = window.jQuery

        # Apply the ID from settings to the template HTML and CSS.
        template = template.replace(/__ID__/g, settings.widget_id)
        renderWidget()

        # Load previous history if enabled by settings.
        if settings.local_storage
            loadFromStorage()

        loaded = true


# ### buildAutosuggest
###
Generate the auto-suggest list based on the object represented by the
supplied text. Done by iterating over the objects loaded, starting with
`window` and progressing through the subsequent properties.
###
buildAutosuggest = (text, e) ->
    # If the key is backspace and nothing is shown, clear auto-suggest list.
    if e.which is keycode.BACKSPACE and text.length is 0 and $els.autosuggest_list.html().length isnt 0
        $els.autosuggest_list.html('')
    else
        # Rudimentary parsing by splitting on the `.` delimiter and using the
        # tokens as keys against each subsequent object.
        tokens = text.split('.')

        # Start with the 'window' object...
        working_items = [[window, 'window']]

        # ...and iterate over the tokens, throwing out `(` and `)` from
        # function calls, and pushing the objects and keys onto the
        # working_items list.
        for token in tokens[0...tokens.length-1]
            token = token.replace('(','').replace(')','')
            if token.length > 0
                working_items.push([working_items[working_items.length-1][0][token], token])

        # Set up the matching pattern to match the last token entered.
        match_list = []
        to_match = new RegExp('^' + tokens[tokens.length-1])

        # Iterate over the properties of the latest working_item, running the
        # matching pattern against the name of each one, building a list of
        # the properties that match.
        for attribute, value of working_items[working_items.length-1][0]
            matches = to_match.exec(attribute)
            if matches?.length > 0
                # Push the name and type of property (for color coding)
                match_list.push([attribute, typeof value])

        # Sort the auto-suggest matches in ascending alphabetical order
        match_list.sort()
        
        # Display the list of matches
        renderAutosuggest(working_items, match_list)


# ### renderAutosuggest
###
Build and show the ul for the auto-suggest matched items.
###
renderAutosuggest = (working_items, match_list) ->
    list = ''

    # Add the full 'path' of the object currently being matched against.
    list += item[1] + '.' for item in working_items
    html = "<li class='current-object'>#{ list }</li>"

    # Add each item matched, with a class based on the type for color coding.
    html += "<li class='#{ item[1] }'>#{ item[0] }</li>" for item in match_list

    # Show the complete list.
    $els.autosuggest_list.html(html)


# ### loadFromStorage
###
If localStorage is supported, try loading previous command history.
Throws an error if called when localStorage is not supported.
###
loadFromStorage = ->
    if not localStorage?
        throw 'localStorage not supported by this browser. History will not be persisted'
    else
        # Get previous data
        previous_data = localStorage.getItem(settings.ls_key)
        if previous_data?
            # If data has been persisted, parse the string from localStorage
            # and execute each history item in order.
            previous_data = JSON.parse(previous_data)
            execute(entry_source) for entry_source in previous_data


# ### replayHistory
###
Clear the display of the history and excute each item in the history.
###
replayHistory = ->
    # Build the list of commands to replay.
    entries_to_replay = (entry.source for entry in history)

    # Clear the current history.
    history = []
    $els.history_list.empty()
    history_index = 0

    # Execute the previous entries. 
    execute(entry) for entry in entries_to_replay


# ### execute
###
Compile and evaluate the specified CoffeeScript source string.
###
execute = (source) ->
    # If the command is to clear localStorage, just clear the history instead.
    # Otherwise, the localStorage will be cleared, but the history remains in
    # memory and would be replaced into localStorage, negating the command.
    if source is 'localStorage.clear()'
        clearHistory()
    else
        # Clear the displayed history list if history is empty.
        if history.length is 0
            $els.history_list.empty()
        
        # Reset the index for the history's arrow-navigation.
        history_index = -1

        error_output = null
        cs_error = false
        js_error = false

        # Attempt to compile the CoffeeScript source, using `bare: on` so that
        # it's not wrapped in a closure and the output can be captured.
        try
            compiled_js = CoffeeScript.compile(source, { bare: on })
        catch error
            cs_error = true
            error_output = error

        # If the source compiled cleanly, try evaluating the JavaScript in the
        # global context.
        if not error_output?
            try
                result = eval.call(window, compiled_js)
            catch eval_error
                js_error = true
                error_output = eval_error

        # If there is an error, that becomes the result.
        if error_output?
            result = error_output

        # Add the source and corresponding result to the history.
        history.push
            result: result
            source: source
        
        # Prepare the list item for this history entry.
        this_result_index = history.length - 1
        new_li = $("<li class='#{ typeof result }'>#{ this_result_index }: #{ result }</li>")

        # Set the appropriate classes if there were an error.
        if js_error
            new_li.addClass('js-error')
        else if cs_error
            new_li.addClass('cs-error')

        # When the history entry is clicked, load the source for that entry.
        new_li.click ->
            loadPrevious(false, this_result_index)
            $els.textarea.focus()

        # Add the history entry to the history list
        new_li.prependTo($els.history_list)

        # If localStorage is supported, save the current history to the key
        # specified by settings.
        entry_sources = (entry.source for entry in history)
        localStorage?.setItem(settings.ls_key, JSON.stringify(entry_sources))

        $els.clear_history.show()
        $els.replay_history.show()


# ### clearHistory
###
Empty the history in memory, disk, and page.
###
clearHistory = ->
    # Clear the displayed history.
    $els.history_list.empty()
    
    # Clear the in-memory history.
    history = []
    
    # Clear the history persisted in localStorage, if any.
    localStorage?.removeItem(settings.ls_key)

    appendInstructions()

    # Reset the auto-suggest.
    autosuggest = [[window,'window']]
    autsuggest_query = ''

    # Hide the history controls.
    $els.clear_history.hide()
    $els.replay_history.hide()


# ### appendInstructions
###
Show instructions for how to use the widget, depending on multi-line setting.
###
appendInstructions = ->
    if history.length is 0
        if settings.multi_line
            instructions = 'type CoffeeScript, press shift+enter'
        else
            instructions = 'type CoffeeScript, press enter' 
        $els.history_list.html("<li class='instructions'>#{ instructions }</li>")


# ### loadPrevious
###
Given a history index to load, set the current source input to that entry's
source. Supports going either direction through the history; pass `true` for
`forward` to move forward in the list.
###
loadPrevious = (forward=false, target_index) ->
    if target_index?
        history_index = target_index + 1 

    # Currently not "inside" the history, so start at the most recent entry.
    if history_index is -1 or history_index is 0
        history_index = history.length - 1
    else
        if forward
            history_index += 1
        else
            history_index -= 1
    
    # If the selected index is "inside" the history list (eg -1), load the
    # entry at that index.
    if history.length > 0
        $els.textarea.val(history[history_index].source)
        # Keep the cursor at the start of the textarea, so the user can
        # continue to step through using the arrows.
        $els.textarea.selectionStart = 0
        $els.textarea.selectionEnd = 0


# ### toggleMultiline
###
Switch between single-line and multi-line modes, disabling auto-suggest if in
multi-line mode.
###
toggleMultiLine = ->
    showing_multi_line = not showing_multi_line

    # Set height to larger and hide auto-suggest...
    if showing_multi_line
        new_height = '4em'
        $els.autosuggest_list.hide()
    # ...or reset height and show auto-suggest, if enabled.
    else
        new_height = ''
        if settings.auto_suggest
            $els.autosuggest_list.show()

    $els.textarea.css('height',new_height).focus()
    appendInstructions()


# ### renderWidget
###
Build and display the widget elements.
###
renderWidget = ->
    # Load the template into a jQuery object.
    widget = $(template)

    # Capture all the elements for later reference.
    $els =
        widget              : widget
        textarea            : widget.find('textarea')
        autosuggest_list    : widget.find('ul.autosuggest')
        history_list        : widget.find('ul.history')
        button              : widget.find('button')
        div                 : widget.find('div')
        clear_history       : widget.find('span.clear')
        replay_history      : widget.find('span.replay')
        a                   : widget.find('a')
        toggle_multiline    : widget.find('input')
        p                   : widget.find('p')
        li                  : widget.find('li')

    # Apply these styles programmatically so they can be customized in settings.
    $els.widget.css
        'position'          : "#{ settings.widget_position }"
        'top'               : "#{ settings.widget_top }"
        'right'             : "#{ settings.widget_right }"

    appendInstructions()
    bindEvents()
    widget.appendTo('body')


# ### bindEvents
###
Setup the various events for the control elements.
###
bindEvents = ->
    # Toggle the main edit elements of the widget.
    $els.button.click ->
        active = not active
        if active
            $els.div.show()
            $els.p.show()
            $els.textarea.focus()
            $els.button.addClass('active')
        else
            $els.div.hide()
            $els.p.hide()
            $els.button.removeClass('active')

    # Clear history on demand.
    $els.clear_history.click ->
        clearHistory()
    
    # Replay history on demand.
    $els.replay_history.click ->
        # Empty the list now and replay after a slight delay, so there is a
        # visual indication that something happened.
        $els.history_list.empty()
        setTimeout ->
            replayHistory()
        , 100

    # Toggle multi-line mode on demand.
    $els.toggle_multiline.click ->
        toggleMultiLine()

    # Bind main textarea events to keydown for quicker responsiveness.
    $els.textarea.bind 'keydown', (e) ->
        entered_source = $els.textarea.val()

        # If the cursor is at the start of the textarea and the up or down
        # arrows are pressed, step through the history.
        if @selectionStart is 0
            if e.which is keycode.UP
                loadPrevious()
            else if e.which is keycode.DOWN
                loadPrevious(true)

        # If enter was pressed and in single-line mode or the shift key was
        # pressed, and the source isn't blank, execute it and clear the input.
        if e.which is keycode.ENTER and (not settings.multi_line or e.shiftKey)
            e.preventDefault()
            if entered_source isnt ''
                execute(entered_source)
                $els.textarea.val('')

        # Treat tab the way a text-editor should.
        else if e.which is keycode.TAB
            # Prevent the textarea losing focus.
            e.preventDefault()

            # Insert the specified indent characters at cursor location.
            start = @selectionStart
            end = @selectionEnd
            @value = @value.substring(0,start) + settings.indent + @value.substring(start)
            @selectionStart = start + settings.indent.length
            @selectionEnd = start + settings.indent.length

    # Bind auto-suggest to keyup for better overall performance.
    $els.textarea.bind 'keyup', (e) ->
        entered_source = $els.textarea.val()
        # Only run auto-suggest if enabled and widget is in single-line mode.
        if not settings.multi_line and settings.auto_suggest
            buildAutosuggest(entered_source, e)

    # Set the initial multi-line state based on the settings.
    if settings.multi_line
        $els.toggle_multiline.click()

    # Keep the auto-suggest and history lists within the window.
    $(window).resize ->
        height = "#{ window.innerHeight - 140 }px"
        width = "#{ window.innerWidth - 255 }px"
        $els.autosuggest_list.css
            'max-height'    : height
            'max-width'     : width
        $els.history_list.css('max-height',height)



# ## Export the API

window.CoffeeTable =
    show: ->
        $els.widget.show()
        return this
    hide: ->
        $els.widget.hide()
        return this
    clear: ->
        clearHistory()
        return this
    replay: ->
        replayHistory()
        return this
    deferInit: ->
        deferred = true
        return this
    init: (opts) ->
        setSettings(opts)
        preInit()
        return this



# ## Loading

# ### setSettings
###
Load the default settings and apply user overrides.
###
setSettings = (opts) ->
    settings = defaults
    for key, value of opts
        settings[key] = value


# ### loadScript
###
Helper for loading external scripts.
###
loadScript = (script_name) ->
    # Do all the traversing and manipulation directly, since jQuery may not
    # be available yet.
    head = document.getElementsByTagName('head')[0]
    script = document.createElement('script')
    script.type = 'application/javascript'
    script.src = settings[script_name]
    script.async = true
    script.onload = ->
        loaded_scripts[script_name] = true
        init()
    head.appendChild(script)


# ### preInit
###
Helper for prepping settings and checking if dependencies are loaded.
###
preInit = ->
    # Remove any previous widget.
    $els?.widget?.remove()
    active = false

    # Check if jQuery and CoffeeScript have already been loaded.
    loaded_scripts.jquery_js = window.jQuery?
    loaded_scripts.coffeescript_js = window.CoffeeScript?

    # If the scripts haven't been loaded, load them, or throw an error if
    # loading is disabled in settings.
    if not loaded_scripts.jquery_js
        if not settings.autoload_coffee_script
            throw 'CoffeeTable requires coffee_script.js'
        else
            loadScript('coffeescript_js')
    if not loaded_scripts.coffeescript_js
        if not settings.autoload_jquery
            throw 'CoffeeTable requires jQuery'
        else
            loadScript('jquery_js')

    # Try init here (in case the scripts are already loaded).
    init()


# ### DOM ready event
###
Automatically load dependencies and initialize the widget, unless deferred.
###
document.addEventListener('DOMContentLoaded', ->
    document.removeEventListener('DOMContentLoaded', arguments.callee, false)
    if not deferred and not loaded
        setSettings()
        preInit()
, false)

