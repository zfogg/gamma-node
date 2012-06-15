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


window.Gamma = Gamma
