Gamma =
    replaceClass: (e, regex, c) ->
        e.className = e.className.replace regex, c

    toggleFullscreen: (speed="slow") ->
        ($ "#header").slideToggle speed
        ($ "#footer").slideToggle speed
        if (($ "#container").css "padding-top") == "0px"
            ($ "#container").css("padding-top", ($ "body").css("padding-bottom"))
            ($ "body").css("padding-bottom", "0px")
            Gamma.setSessionVars fullscreen: true
        else
            ($ "body").css("padding-bottom", ($ "#container").css("padding-top"))
            ($ "#container").css("padding-top", "0px")
            Gamma.setSessionVars fullscreen: false

    setSessionVars: (vars, successMsg=null, failMsg=null) ->
        $.ajax
            url: "/_set_session_vars"
            type: "POST"
            dataType: "json"
            contentType: "application/json; charset=UTF-8"
            data: JSON.stringify vars
            success: -> console.log successMsg if successMsg
            fail:    -> console.log failMsg    if failMsg

    RGBA:
        toArray: (s) ->
            vals = s.match /\.?\d+\.?\d*/g
            vals[i] = parseInt vals[i], 10 for i in [0..2]
            vals[3] = parseFloat vals[3]
            vals
        toString: (xs) ->
            "rgba(#{xs.join ','})"
        fromRGB: (rgb, alpha) ->
            "rgba(#{(rgb.match /\.?\d+\.?\d*/g).join ','},#{alpha})"
        fromHex: (hex, alpha) ->
            "rgba(#{(parseInt hex[i...i+2], 16 for i in [1...7] by 2).join ', '}, #{alpha})";

    namespace: (target, name, block) ->
        [target, name, block] = [(if typeof exports isnt 'undefined' then exports else window), arguments...] if arguments.length < 3
        top    = target
        target = target[item] or= {} for item in name.split '.'
        block target, top

    getParameterByName: (name) ->
        match = (RegExp "[?&]#{name}=([^&]*)").exec window.location.search
        match && decodeURIComponent match[1].replace /\+/g, ' '

window.Gamma = Gamma
