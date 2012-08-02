window.Game = class Game
  constructor: ->
    Crafty.init ($ "#main").width(), ($ "#main").height()
    Crafty.canvas.init()
    Crafty.box2D.init 0, 1, 32, true
    Crafty.box2D.showDebugInfo()


    @canvas = ($ "canvas")[0]
    @ctx = @canvas.getContext "2d"
    @time = (new Date).getTime()

    @main()

  main: (gameTime) =>
    now = (new Date).getTime()
    @update 1 / (now - @time)
    @time = now

    @draw @ctx

    requestFrame @main

  update: (gameTime) ->

  draw: (ctx) ->
