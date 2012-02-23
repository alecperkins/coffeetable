###

# CoffeeTable v0.2.0

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
    # Replay the history on load
    replay_on_load  : false

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

    # Alias log and dir for convenience.
    alias_log       : true
    alias_dir       : true
    
    # Adopt console.log and console.dir if they are not available in the
    # browser. This is useful in browsers like IE.
    adopt_log       : true
    adopt_dir       : true

# Keypress codes, for convenience.
keycode =
    UP          : 38
    DOWN        : 40
    ENTER       : 13
    TAB         : 9
    BACKSPACE   : 8
    ESCAPE      : 27

# Template for widget markup and style.
# `__ID__` will be replaced by the setting for widget_id. This ID is used for
# scoping the CSS rules to avoid conflicts with the existing page styles.
# See `src/template.html` and `src/style.sass` for the source files.
template = """
<div id="__ID__">
    <style type="text/css">
        #__ID__{margin:0;padding:0;border:0;font-size:100%;font:inherit;vertical-align:baseline;-webkit-box-shadow:0px 0px 4px #222;-moz-box-shadow:0px 0px 4px #222;box-shadow:0px 0px 4px #222;background:rgba(255,255,255,0.93);padding:0;border:2px solid #fff;z-index:2147483647;font-size:12px;font-family:Verdana,sans-serif;max-height:95%;max-width:900px;color:#000}#__ID__ div,#__ID__ span,#__ID__ applet,#__ID__ object,#__ID__ iframe,#__ID__ h1,#__ID__ h2,#__ID__ h3,#__ID__ h4,#__ID__ h5,#__ID__ h6,#__ID__ p,#__ID__ blockquote,#__ID__ pre,#__ID__ a,#__ID__ abbr,#__ID__ acronym,#__ID__ address,#__ID__ big,#__ID__ cite,#__ID__ code,#__ID__ del,#__ID__ dfn,#__ID__ em,#__ID__ img,#__ID__ ins,#__ID__ kbd,#__ID__ q,#__ID__ s,#__ID__ samp,#__ID__ small,#__ID__ strike,#__ID__ strong,#__ID__ sub,#__ID__ sup,#__ID__ tt,#__ID__ var,#__ID__ b,#__ID__ u,#__ID__ i,#__ID__ center,#__ID__ dl,#__ID__ dt,#__ID__ dd,#__ID__ ol,#__ID__ ul,#__ID__ li,#__ID__ fieldset,#__ID__ form,#__ID__ label,#__ID__ legend,#__ID__ table,#__ID__ caption,#__ID__ tbody,#__ID__ tfoot,#__ID__ thead,#__ID__ tr,#__ID__ th,#__ID__ td,#__ID__ article,#__ID__ aside,#__ID__ canvas,#__ID__ details,#__ID__ embed,#__ID__ figure,#__ID__ figcaption,#__ID__ footer,#__ID__ header,#__ID__ hgroup,#__ID__ menu,#__ID__ nav,#__ID__ output,#__ID__ ruby,#__ID__ section,#__ID__ summary,#__ID__ time,#__ID__ mark,#__ID__ audio,#__ID__ video{margin:0;padding:0;border:0;font-size:100%;font:inherit;vertical-align:baseline}#__ID__ table{border-collapse:collapse;border-spacing:0}#__ID__ caption,#__ID__ th,#__ID__ td{text-align:left;font-weight:normal;vertical-align:middle}#__ID__ q,#__ID__ blockquote{quotes:none}#__ID__ q:before,#__ID__ q:after,#__ID__ blockquote:before,#__ID__ blockquote:after{content:"";content:none}#__ID__ a img{border:none}#__ID__ *{visibility:visible;font-weight:500;-webkit-box-shadow:0px 0px 5px transparent;-moz-box-shadow:0px 0px 5px transparent;box-shadow:0px 0px 5px transparent;text-shadow:transparent 0px 0px 1px;-webkit-border-radius:0;-moz-border-radius:0;-ms-border-radius:0;-o-border-radius:0;border-radius:0;margin:0;padding:0;position:static}#__ID__ ul{text-align:left}#__ID__ .toggle-widget{float:right !important;background:#fff !important;border:1px solid #ccc !important;color:#911 !important;cursor:pointer !important;height:20px !important;width:78px !important;display:block !important;min-width:78px !important;min-height:20px !important;font-size:12px !important;line-height:1em !important;font-weight:500 !important}#__ID__ .toggle-widget:active,#__ID__ .toggle-widget.active{background:#911 !important;color:#fff !important}#__ID__ .coffee-source{font-family:monospace;font-size:15px;min-width:400px;height:22px;margin:4px}#__ID__ .input{display:none}#__ID__ .history{margin:8px;padding:4px;font-family:monospace;list-style-type:circle;overflow-y:scroll}#__ID__ .history li{padding:4px 1em 4px 4px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;position:relative}#__ID__ .history li:hover{list-style-type:disc}#__ID__ .history li.cs-error{color:orange}#__ID__ .history li.js-error{color:red}#__ID__ .history li.object span.result{cursor:pointer}#__ID__ .history li.property-value{list-style-type:none}#__ID__ .history li.property-value span.property{color:purple}#__ID__ .history li li{padding-left:3em}#__ID__ .history li button{cursor:pointer}#__ID__ .history li button.load{position:absolute;right:0;top:0;border:1px solid #ccc;padding:2px;background:#fff}#__ID__ .history li button.load:hover{background-color:rgba(255,255,0,0.2)}#__ID__ .history li button.load:active{background-color:rgba(255,255,0,0.8)}#__ID__ .history li button.expand{background:transparent;border:0;width:1em}#__ID__ .history li span.opened{display:none}#__ID__ .history li.open > button span.opened,#__ID__ .history li.open > span.value > button span.opened{display:inline}#__ID__ .history li.open > button span.closed,#__ID__ .history li.open > span.value > button span.closed{display:none}#__ID__ p.instructions{text-align:center}#__ID__ .clear,#__ID__ .replay{padding:4px;text-align:center;cursor:pointer;float:left;color:#555;font-variant:small-caps;display:none}#__ID__ .clear:hover,#__ID__ .replay:hover{color:#911}#__ID__ a{padding:4px;text-align:center;cursor:pointer;float:right;color:#555;font-variant:small-caps;text-decoration:none}#__ID__ input{vertical-align:middle}#__ID__ p.mode{padding:4px;margin:0;float:right;display:inline-block;width:80px;color:#555;font-variant:small-caps;display:none;text-align:right}#__ID__ .autosuggest{-webkit-box-shadow:0px 0px 4px #222;-moz-box-shadow:0px 0px 4px #222;box-shadow:0px 0px 4px #222;position:absolute;top:-2px;left:-260px;display:block;background:rgba(255,255,255,0.9);width:250px;overflow-y:scroll;font-family:monospace}#__ID__ .autosuggest li{padding:4px}#__ID__ .autosuggest li.heading{font-weight:bold;text-decoration:underline;list-style-type:none}#__ID__ .function{color:#292}#__ID__ .number{color:#229}#__ID__ .string{color:#922}#__ID__ .undefined{color:grey;font-style:italic}#__ID__ .object{color:#000}#__ID__ .boolean{color:#299}
    </style>
    <button class="toggle-widget">CoffeeTable</button>
    <span class="clear">clear</span><span class="replay">replay</span>
    <a href="http://code.alecperkins.net/coffeetable/" target="_blank">?</a>
    <p class="mode">multiline <input type="checkbox"></p>
    <div class="input">
        <textarea class="coffee-source"></textarea>
        <p class="instructions"></p>
        <ul class="autosuggest"></ul>
        <ul class="history"></ul>
    </div>
</div>
"""

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


        if settings.adopt_log
            console ?= {}
            console.log = (args...) ->
                ctLog(args...)

        if settings.adopt_dir
            console ?= {}
            console.dir = (args...) ->

        # Alias log and dir for shorter typing if log and dir aren't aready used.
        if settings.alias_log
            window.log ?= -> console.log arguments...
        if settings.alias_dir
            window.dir ?= -> console.dir arguments...

        # Apply the ID from settings to the template HTML and CSS.
        template = template.replace(/__ID__/g, settings.widget_id)
        renderWidget()

        # Load previous history if localStorage is enabled by settings.
        if settings.local_storage
            loadFromStorage()

        loaded = true
    return loaded

# ### ctLog
###
Log one or more values to the CoffeeTable widget. Used as the implementation of
`console.log` if `settings.adopt_log` is `true` and `console.log` isn't already
available.
###
ctLog = (args...) ->
    for arg in args
        do ->
            output = arg.toString().replace(/\'/g,"\\'").replace(/\"/g,'\\"')
            execute("'log: #{ output }'")
    return

# ### ctDir
###
Dir one or more values to the CoffeeTable widget. Used as the implementation of
`console.dir` if `settings.adopt_dir` is `true` and `console.dir` isn't already
available.
###
ctDir = (args...) ->
    return

# ### buildAutosuggest
###
Generate the auto-suggest list based on the object represented by the
supplied text. Done by iterating over the objects loaded, starting with
`window` and progressing through the subsequent properties.
###
buildAutosuggest = (text, e) ->
    # If the key is backspace and nothing is shown, or if the key is escape,
    # clear auto-suggest list.
    if e.which is keycode.ESCAPE or (e.which is keycode.BACKSPACE and text.length is 0 and $els.autosuggest_list.html().length isnt 0)
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

    # Resize for good measure
    resizeWidget()


# ### loadFromStorage
###
If localStorage is supported, try loading previous command history.
Throws an error if called when localStorage is not supported.
###
loadFromStorage = ->
    if not localStorage?
        throw 'localStorage not supported by this browser. History will not be persisted.'
    else
        # Get previous data
        previous_data = localStorage.getItem(settings.ls_key)
        if previous_data?
            # If data has been persisted, parse the string from localStorage
            # and execute each history item in order.
            previous_data = JSON.parse(previous_data)

            # Replay the previous entries, running as a dry-run if specified in
            # settings.
            execute(entry_source, not settings.replay_on_load) for entry_source in previous_data


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
Compile and evaluate the specified CoffeeScript source string. Optionally,
the execution can be a dry run and the source won't actually be executed.
###
execute = (source, dry_run=false) ->
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

        # If the source compiled cleanly, and not doing a dry run, try
        # evaluating the JavaScript in the global context.
        if not error_output? and not dry_run
            try
                result = eval.call(window, compiled_js)
            catch eval_error
                js_error = true
                error_output = eval_error
        # If doing a dry run, the result is just the compiled CoffeeScript.
        else if dry_run
            result = compiled_js

        # If there is an error, that becomes the result.
        if error_output?
            result = error_output

        # Add the source and corresponding result to the history.
        history.push
            result: result
            source: source
        
        # Prepare the list item for this history entry. The result is inserted
        # using jQuery's .text to ensure proper escaping.
        this_result_index = history.length - 1
        
        load_button = $('<button class="load">^</button>')
        clean_result = result.toString().replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;")
        new_li = $("""
            <li class='#{ typeof result }' title='#{ typeof result }: #{ clean_result }'>
                #{ this_result_index }:
                <span class='result'>#{ clean_result }</span>
            </li>
        """).append(load_button)

        # Results that are objects can be expanded, with their properties
        # enumerated in a list.
        if typeof result is 'object'
            # Each property that is an object gets an expand button, which
            # toggles between '+' if closed and '-' if open.
            expand_button_template = '<button class="expand"><span class="closed">+</span><span class="opened">-</span></button>'

            # Create an LI element for the given property and value.
            buildLI = (prop, val) ->
                return $("""
                    <li class='property-value' title='#{ typeof val }: #{ val }'>
                        <span class='property'>#{ prop }:</span>
                        <span class='value #{ typeof val }'>#{ val }</span>
                    </li>
                """)
            
            # List the properties of the given object, and append a UL with the
            # properties to the given element.
            assembleList = (obj, el) ->
                # Remove any existing ULs to avoid duplication. Yes, this is
                # redundant, but it keeps things simple.
                el.children('ul').remove()
                
                # Make and append the UL
                children_ul = $('<ul></ul>')
                el.append(children_ul)
                
                # Create a list of properties, then sort it so they can be
                # displayed in alphabetical order.
                prop_list = (prop for prop, val of obj)
                prop_list.sort()
                
                # Iterate over the sorted properties, building an LI and
                # appending it to the list.
                for prop in prop_list then do ->
                    p_name = prop
                    p_val = obj[prop]
                    child_li = buildLI(p_name, p_val)
                    children_ul.append(child_li)
                    
                    # If the property itself is an object, prepare it to be
                    # expandable as well.
                    # TODO: rework this whole system so it's more DRY.
                    if typeof p_val is 'object'
                        child_expand_button = $(expand_button_template)
                        child_li.children('span.value').prepend(child_expand_button)
                        child_expand_button.click (e) ->
                            e.stopPropagation()
                            if child_li.hasClass('open')
                                child_li.removeClass('open')
                                child_li.find('ul').remove()
                            else
                                child_li.addClass('open')
                                children_ul.show()
                                assembleList(p_val, child_li)
            
            # Create the expand button, append it to the LI, and setup the
            # events that toggle the opening and closing of property lists.
            expand_button = $(expand_button_template)
            new_li.children('span.result').before(expand_button)
            expand_button.click ->
                if new_li.hasClass('open')
                    new_li.removeClass('open')
                    new_li.find('ul').remove()
                else
                    new_li.addClass('open')
                    assembleList(result, new_li)


        # Set the appropriate classes if there were an error.
        if js_error
            new_li.addClass('js-error')
        else if cs_error
            new_li.addClass('cs-error')

        # When the history entry's load button is clicked, load the source for
        # that entry.
        load_button.click ->
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

    renderInstructions()

    # Reset the auto-suggest.
    autosuggest = [[window,'window']]
    autsuggest_query = ''

    # Hide the history controls.
    $els.clear_history.hide()
    $els.replay_history.hide()


# ### renderInstructions
###
Show instructions for how to use the widget, depending on multi-line setting.
###
renderInstructions = ->
    if history.length is 0
        if showing_multi_line
            instructions = 'type CoffeeScript, press <shift+enter>'
        else
            instructions = 'type CoffeeScript, press <enter>' 
        $els.instructions.text(instructions)


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
    renderInstructions()


# ### resizeWidget
###
Set the max-height and max-width of the widget and auto-suggest list to keep
it visible in the window. (Being absolutely positioned, it doesn't affect the
scrolling of the overall window.)
###
resizeWidget = ->
    height = "#{ window.innerHeight - 140 }px"
    width = "#{ window.innerWidth - 255 }px"
    $els.autosuggest_list.css
        'max-height'    : height
        'max-width'     : width
    $els.history_list.css('max-height',height)


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
        p                   : widget.find('p.mode')
        instructions        : widget.find('p.instructions')
        li                  : widget.find('li')

    # Apply these styles programmatically so they can be customized in settings.
    $els.widget.css
        'position'          : "#{ settings.widget_position }"
        'top'               : "#{ settings.widget_top }"
        'right'             : "#{ settings.widget_right }"

    renderInstructions()
    bindEvents()
    widget.appendTo('body')
    
    # Do resize of the widget to ensure the contained elements can scroll
    # correctly.
    resizeWidget()


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
        if e.which is keycode.ENTER and (not showing_multi_line or e.shiftKey)
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
        resizeWidget()

# ### unloadWidget
###
Remove the widget's element from the DOM and clear the `CoffeeTable` object.
###
unloadWidget = () ->
    $els.widget.remove()
    window.CoffeeTable = null
    delete window.CoffeeTable



# ## Export the API

# Reassign the API functions
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
        window.CoffeeTable?.unload() # Unload any previous widget
        setSettings(opts)
        preInit()
        return this
    unload: ->
        unloadWidget()
        return this
    active: ->
        return active
    log: (args...) ->
        ctLog(args...)
    dir: (args...) ->
        ctDir(args...)



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
    active = false

    # Check if jQuery and CoffeeScript have already been loaded.
    loaded_scripts.jquery_js = window.jQuery?
    loaded_scripts.coffeescript_js = window.CoffeeScript?

    # If the scripts haven't been loaded, load them, or throw an error if
    # loading is disabled in settings.
    if not loaded_scripts.coffeescript_js
        if not settings.autoload_coffee_script
            throw 'CoffeeTable requires coffee_script.js'
        else
            loadScript('coffeescript_js')
    if not loaded_scripts.jquery_js
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

