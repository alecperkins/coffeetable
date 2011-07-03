###
CoffeeTable

A drop-in workbench for experimentation.
http://github.com/alecperkins/coffeetable
###

default_settings =
    coffeescript_js : "https://raw.github.com/alecperkins/coffeetable/master/lib/coffee_script-1.1.1-min.js"
    style:
      position          : 'fixed'
      top               : '5px'
      right             : '5px'
    local_storage   : true
    ls_key          : 'coffee-table'
    multi_line      : false

# Trap calls to console.log and console.dir if the console doesn't exist.
# Lookin' at you, IE.
console ?=
    log: ->
    dir: ->

window.log = -> console.log arguments
window.dir = -> console.dir arguments

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
                'font-size'         : '12px'
                'max-height'        : '95%'
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
                'top'               : '0'
                'left'              : '-250px'
                'display'           : 'block'
                'background'        : 'rgba(255,255,255,0.8)'
                'box-shadow'        : '0px 0px 4px #222'
                'width'             : '200px'
                'max-height'        : '800px'
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

        loadCSJS()
        renderWidget()

        if settings.local_storage
            loadFromStorage()

    autocomplete_items = [[window,'window']]
    autocomplete_query = ''
    getAutocomplete = (e, text) ->
        # numbers: 48..57
        # letters: 65..90
        # space: 32
        # period: 190
        # (: 57 + shiftKey
        # ): 48 + shiftKey

        # in numbers
        push_token = pop_token = false
        character = null
        # console.log e.which
        if text.length is 0
            autocomplete_query = ''

        if e.which is 8 # backspace
            if autocomplete_query.length > 0
                autocomplete_query = autocomplete_query[0...autocomplete_query.length-1]
            else
                if autocomplete_items.length > 1
                    autocomplete_query = autocomplete_items.pop()[1]
                else
                    autocomplete_query = ''
                
            console.log 
        else
            if 65 <= e.which <= 90 or 48 <= e.which <= 57
                character = String.fromCharCode(e.which)
                if not e.shiftKey
                    character = character.toLowerCase()
                else
                    if e.which is 57
                        character = '('
                        pop_token = true
                    else if e.which is 48
                        character = ')'
                        pop_token = true
                    else if e.which is 52
                        character = '$'
            else if e.which is 190
                character = '.'
                push_token = true
            else if e.which is 32
                character = ' '
                pop_token = true
            else if e.which is 13   # enter
                pop_token = true
            
            if push_token or pop_token
                if autocomplete_query.length > 0
                    if push_token
                        autocomplete_items.push([autocomplete_items[autocomplete_items.length-1][autocomplete_query], autocomplete_query])
                    else
                        autocomplete_items = [[window,'window']]
                autocomplete_query = ''
            else if character?
                autocomplete_query += character
        
        console.log autocomplete_query

        match_list = []
        to_match = new RegExp('^' + autocomplete_query)
        for attribute, value of autocomplete_items[autocomplete_items.length-1][0]
            matches = to_match.exec(attribute)
            if matches?.length > 0
                match_list.push(attribute)
        
        match_list.sort()
        html = "<li style='font-weight:bold; text-decoration: underline; list-style-type: none'>#{ autocomplete_items[autocomplete_items.length-1][1] }</li>"
        html += "<li>#{ item }</li>" for item in match_list
        $els.CTAutocomplete.html(html)

        if e.which is 9 and match_list > 0 and autocomplete_query.length > 0
            console.log match_list[0].replace(autocomplete_query, '')
        



    loadFromStorage = ->
        previous_data = localStorage?.getItem('coffee-table')
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

        new_li = $("<li>#{ this_result_index }: <span>#{ result }</span></li>")
        new_li.css(styles.li)
        new_li.find('span').css(result_styles[typeof result])

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
        else
            new_height = styles.textarea.height
            instruction = 'type CoffeeScript, press enter'
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
            autocomplete    : widget.find('autocomplete')
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
            else if e.which is 9 #tab
                e.preventDefault()
                start = @selectionStart
                end = @selectionEnd
                @value = @value.substring(0,start) + "    " + @value.substring(start)
                @selectionStart = start + 4
                @selectionEnd = start + 4
            if not settings.multi_line
                getAutocomplete(e, entered_source)

        if settings.multi_line
            $els.input.click()
        widget.appendTo('body')

    loadCSJS = ->
        if not window.CoffeeScript?
            script_el = document.createElement('script')
            script_el.type ='application/javascript'
            script_el.src = default_settings.coffeescript_js
            $('head').append(script_el)
    
    show: ->
        $els.widget.show()
        return this
    
    hide: ->
        $els.widget.hide()
        return this

window.CoffeeTable = CoffeeTable

$(document).ready ->
    window.coffeetable_instance = new CoffeeTable(window.coffeetable_settings)