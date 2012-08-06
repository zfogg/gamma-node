Gamma =
    replaceClass: (e, regex, c) ->
        e.className = e.className.replace regex, c

    RGBA:
        toArray: (s) ->
            vals = s.match /\.?\d+\.?\d*/g
            vals[i] = parseInt vals[i], 10 for i in [0..2]
            vals[3] = parseFloat vals[3]
            vals
        toString: (xs) ->
            "rgba(#{xs.join ','})"

    namespace: (target, name, block) ->
        [target, name, block] = [(if typeof exports isnt 'undefined' then exports else window), arguments...] if arguments.length < 3
        top    = target
        target = target[item] or= {} for item in name.split '.'
        block target, top

window.Gamma = Gamma
