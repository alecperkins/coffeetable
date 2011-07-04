###
CoffeeTable

A drop-in, CoffeeScript-fluent console for web pages.

See https://github.com/alecperkins/coffeetable for more information, and
http://code.alecperkins.net/coffeetable for a working demo.
###

# Default widget settings.
default_settings =
    coffeescript_js : 'http://code.alecperkins.net/coffeetable/lib/coffee_script-1.1.1-min.js'
    style:
      position          : 'fixed'
      top               : '5px'
      right             : '5px'
    local_storage   : true
    ls_key          : 'coffee-table'
    multi_line      : false
    indent          : '    '
    auto_suggest    : true

# Trap calls to console.log and console.dir if the console doesn't exist.
# Lookin' at you, IE.
console ?=
    log: ->
    dir: ->

# Alias log and dir for shorter typing.
window.log = -> console.log arguments...
window.dir = -> console.dir arguments...

# Use $ even if jQuery is in no-conflict mode
$ = window.jQuery

class CoffeeTable
    settings = null
    $els = null
    styles = null
    result_styles = null
    template = ''

    active = false

    history_index = 0

    history =
        source: []
        result: []

    constructor: (opts={}) ->

        settings = default_settings
        for k, v of opts
            settings[k] = v

        # Applying the styles using JS until scoped="scoped" works
        styles =
            widget:
                'position'          : "#{ settings.style.position }"
                'top'               : "#{ settings.style.top }"
                'right'             : "#{ settings.style.right }"
                'background'        : 'rgba(255,255,255,0.9)'
                'padding'           : '0'
                'border'            : '2px solid white'
                'z-index'           : '9999999'
                'box-shadow'        : '0px 0px 4px #222'
                '-moz-box-shadow'   : '0px 0px 4px #222'
                '-webkit-box-shadow'   : '0px 0px 4px #222'
                'font-size'         : '12px'
                'max-height'        : '95%'
                'max-width'         : '900px'
            button:
                'float'             : 'right'
                'background'        : 'white'
                'border'            : '1px solid #ccc'
                'color'             : '#991111'
                'cursor'            : 'pointer'
            button_active:  
                'background'        : '#991111'
                'color'             : 'white'
            textarea:   
                'font-family'       : 'monospace'
                'font-size'         : '15px'
                'min-width'         : '400px'
                'height'            : '22px'
                'margin'            : '4px'
            div:
                'display'           : 'none'
            CTHistory:
                'margin'            : '8px'
                'padding'           : '4px 4px 4px 16px'
                'font-family'       : 'monospace'
                'list-style-type'   : 'circle'
                'overflow-y'        : 'scroll'
                'max-height'        : "#{ window.innerHeight - 140 }px"
            li:
                'padding'           : '4px 4px 4px 4px'
                'cursor'            : 'pointer'
            span:
                'padding'           : '4px'
                'text-align'        : 'center'
                'cursor'            : 'pointer'
                'float'             : 'left'
                'color'             : '#555'
                'font-variant'      : 'small-caps'
                'display'           : 'none'
            a:
                'padding'           : '4px'
                'text-align'        : 'center'
                'cursor'            : 'pointer'
                'float'             : 'right'
                'color'             : '#555'
                'font-variant'      : 'small-caps'
            input:
                'vertical-align'    : 'middle'
            p:
                'padding'           : '4px'
                'margin'            : '0'
                'float'             : 'right'
                'display'           : 'inline-block'
                'width'             : '80px'
                'color'             : '#555'
                'font-variant'      : 'small-caps'
                'display'           : 'none'
                'text-align'        : 'right'
            CTAutocomplete:
                'position'          : 'absolute'
                'top'               : '-14px'
                'left'              : '-300px'
                'display'           : 'block'
                'background'        : 'rgba(255,255,255,0.9)'
                'box-shadow'        : '0px 0px 4px #222'
                '-moz-box-shadow'   : '0px 0px 4px #222'
                '-webkit-box-shadow'   : '0px 0px 4px #222'
                'width'             : '250px'
                'max-height'        : "#{ window.innerHeight - 140 }px"
                'overflow-y'        : 'scroll'


        result_styles =
            'function' :
                'color'           : '#229922'
            'number':
                'color'           : '#222299'
            'string':
                'color'           : '#992222'
            'undefined':
                'color'           : 'grey'
                'font-style'      : 'italic'
            'object': {}
            'boolean':
                'color'           : '#229999'

        template = "
            <div>
                <button>CoffeeTable</button>
                <span>clear</span>
                <a href='https://github.com/alecperkins/coffeetable' target='_blank'>?</a>
                <p>multiline <input type='checkbox'></p>
                <div>
                    <textarea></textarea>
                    <ul class='CTAutocomplete'></ul>
                    <ul class='CTHistory'></ul>
                </div>
            </div>
        "

        renderWidget()

        if settings.local_storage
            loadFromStorage()

    window.onresize = ->
        height = "#{ window.innerHeight - 140 }px"
        $els.CTAutocomplete.css('max-height',height)
        $els.CTHistory.css('max-height',height)

    getAutocomplete = (text, e) ->
        if e.which is 8 and text.length is 0 and $els.CTAutocomplete.html().length isnt 0
            $els.CTAutocomplete.html('')
        else
            tokens = text.split('.')
            working_items = [[window, 'window']]
            for token in tokens[0...tokens.length-1]
                token = token.replace('(','').replace(')','')
                if token.length > 0
                    working_items.push([working_items[working_items.length-1][0][token], token])

            match_list = []
            to_match = new RegExp('^' + tokens[tokens.length-1])
            for attribute, value of working_items[working_items.length-1][0]
                matches = to_match.exec(attribute)
                if matches?.length > 0
                    match_list.push([attribute, typeof value])
            match_list.sort()

            list = ''
            list += item[1] + '.' for item in working_items
            html = "<li style='font-weight:bold; text-decoration: underline; list-style-type: none'>#{ list }</li>"
            html += "<li style='color:#{ result_styles[item[1]].color }'>#{ item[0] }</li>" for item in match_list
            $els.CTAutocomplete.html(html)



    loadFromStorage = ->
        previous_data = localStorage?.getItem(settings.ls_key)
        if previous_data?
            previous_data = JSON.parse(previous_data)
            
            # sloppy way to wait for coffeescript.js
            execHistory = ->
                if CoffeeScript?
                    execute(item) for item in previous_data
                else
                    setTimeout ->
                        execHistory()
                    , 500
            execHistory()

    execute = (source) ->
        if source is 'localStorage.clear()'
            clearHistory()
        else
            if history.source.length is 0
                $els.CTHistory.empty()
            history_index = -1
            history.source.push(source)

            error_output = null
            cs_error = false
            js_error = false

            try
                js = CoffeeScript.compile(source, { bare: on })
            catch error
                cs_error = true
                error_output = error
            
            if not error_output?
                try
                    result = eval(js)
                catch eval_error
                    js_error = true
                    error_output = eval_error

            if error_output?
                result = error_output

            history.result.push(result)
            this_result_index = history.source.length - 1

            new_li = $("<li>#{ this_result_index }: <span class='CTResultName'>#{ result }</span><span class='CTResultLoad'>src</span></li>")
            new_li.css(styles.li)
            new_li.find('span.CTResultName').css(result_styles[typeof result])

            if cs_error
                new_li.css('color','orange')
            else if js_error
                new_li.css('color','red')
            
            new_li.hover ->
                new_li.css
                    background          : 'rgba(255,255,0,0.2)'
                    'list-style-type'   : 'disc'
            , ->
                new_li.css
                    'background'        : ''
                    'list-style-type'   : ''
            
            new_li.click ->
                loadPrevious(false, this_result_index)
                $els.textarea.focus()
            new_li.mousedown ->
                new_li.css('background': 'rgba(255,255,0,0.8)')
            new_li.mouseup ->
                new_li.css('background': 'rgba(255,255,0,0.2)')

            new_li.prependTo($els.CTHistory)
            $els.span.show()
            localStorage?.setItem(settings.ls_key, JSON.stringify(history.source))


    clearHistory = ->
        $els.CTHistory.empty()
        history.source = []
        history.result = []
        localStorage?.removeItem(settings.ls_key)
        $els.span.hide()
        appendInstructions()
        autocomplete_items = [[window,'window']]
        autocomplete_query = ''

    appendInstructions = ->
        instructions = $('<li>type CoffeeScript, press enter</li>')
        instructions.css
            'list-style-type'   : 'none'
            'text-align'        : 'center'
        instructions.appendTo($els.CTHistory)


    loadPrevious = (forward=false, target_index) ->
        if target_index?
            history_index = target_index + 1 

        if history_index is -1
            history_index = history.source.length-1
        else
            if forward
                history_index += 1
            else
                history_index -= 1
        if history.source.length > 1
            $els.textarea.val(history.source[history_index])
            $els.textarea.selectionStart = 0
            $els.textarea.selectionEnd = 0

    toggleMultiLine = ->
        settings.multi_line = not settings.multi_line
        if settings.multi_line
            new_height = '4em'
            instruction = 'type CoffeeScript, press shift+enter'
            $els.CTAutocomplete.hide()
        else
            new_height = styles.textarea.height
            instruction = 'type CoffeeScript, press enter'
            if settings.auto_suggest
                $els.CTAutocomplete.show()
        $els.textarea.css('height',new_height).focus()
        if history.source.length is 0
            $els.CTHistory.find('li').text(instruction)

    renderWidget = ->
        widget = $(template)

        $els =
            widget          : widget
            textarea        : widget.find('textarea')
            CTAutocomplete  : widget.find('ul.CTAutocomplete')
            CTHistory       : widget.find('ul.CTHistory')
            button          : widget.find('button')
            div             : widget.find('div')
            span            : widget.find('span')
            a               : widget.find('a')
            input           : widget.find('input')
            p               : widget.find('p')
            li              : widget.find('li')
        for el_name, el of $els
            el.css(styles[el_name]) 
        appendInstructions()
        $els.button.click ->
            if active
                $els.button.css(styles.button)
                $els.div.hide()
                $els.p.hide()
            else
                $els.button.css(styles.button_active)
                $els.div.show()
                $els.p.show()
                $els.textarea.focus()
            active = not active

        $els.span.click ->
            clearHistory()
        $els.span.hover ->
            $els.span.css('color', '#991111')
        , ->
            $els.span.css('color', styles.span.color)

        $els.input.click ->
            toggleMultiLine()

        $els.textarea.bind 'keydown', (e) ->
            entered_source = $els.textarea.val()
            if @selectionStart is 0
                if e.which is 38 # up arrow
                    loadPrevious()
                else if e.which is 40 # down arrow
                    loadPrevious(true)
            if e.which is 13 and (not settings.multi_line or e.shiftKey) # enter key
                e.preventDefault()
                if entered_source isnt ''
                    execute(entered_source)
                    $els.textarea.val('')
            else if e.which is 9
                # tab, insert an indent when tab is pressed
                e.preventDefault()
                start = @selectionStart
                end = @selectionEnd
                @value = @value.substring(0,start) + settings.indent + @value.substring(start)
                @selectionStart = start + 4
                @selectionEnd = start + 4
            
        $els.textarea.bind 'keyup', (e) ->
            entered_source = $els.textarea.val()
            if not settings.multi_line and settings.auto_suggest
                getAutocomplete(entered_source, e)

        if settings.multi_line
            $els.input.click()
        widget.appendTo('body')

    show: ->
        $els.widget.show()
        return this
    
    hide: ->
        $els.widget.hide()
        return this
    
    clear: ->
        clearHistory()
        return this

init = ->
    window.coffeetable_instance = new CoffeeTable(window.coffeetable_settings)

$(document).ready ->
    window.CoffeeTable = CoffeeTable
    if not window.CoffeeScript?
        script_el = document.createElement('script')
        script_el.type ='application/javascript'
        script_el.src = default_settings.coffeescript_js
        $(script_el).bind 'load', (e) ->
            init()
        $('head').append(script_el)
    else
        init()
