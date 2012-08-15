#=require "gravity"

Gamma.namespace "Gravity", (G, top) ->
    $ ->
        canvas        = ($ "#canvas")[0]
        canvas.height = ($ "#content").width()
        canvas.width  = ($ "#content").width()

        if canvas.getContext
            G.Gravity canvas
