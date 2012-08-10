Gamma =
    replaceClass: (e, regex, c) ->
        e.className = e.className.replace regex, c

    toggleNav: ->
        ($ "#header").slideToggle "slow"
        ($ "#footer").slideToggle "slow"
        if (($ "#container").css "padding-top") == "0px"
            ($ "#container").css("padding-top", "60px")
        else
            ($ "#container").css("padding-top", "0px")

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

window.Gamma = Gamma
