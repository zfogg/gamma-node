#= require ../canvas-tools

Squares = (canvas) ->

  G = # Globals object; need to refactor this out.
    currentMotionFunction: undefined
    squareRows: 0
    squareColumns: 0
    squares: []
    gameTime: 0
    canvas_center:
      x: canvas.width / 2
      y: canvas.height / 2


  class Square
    constructor: (@x, @y, @size, @index, @color) ->
      @alpha = 1

    update: ->
      G.currentMotionFunction this

    draw: ->
      ctx.fillStyle = @color
      ctx.fillRect @x, @y, @size, @size

  main = ->
    C$.clearCanvas canvas, ctx
    for square in G.squares
      square.update()
      square.draw()

    G.gameTime++
    window.requestFrame main, canvas

  constructSquares = (rows, columns, size) ->
    squares = new Array()
    color = colorPatternGenerator()
    positions = initPositions(rows, columns)
    positions.forEach (p, i) ->
      squares[i] = new Square(p.x, p.y, size, i, color(i))

    squares

  initPositions = (rows, columns) ->
    positions = []
    i = 0

    x = 0
    while x < canvas.width
      y = 0
      while y < canvas.height
        positions[i++] = x: x, y: y
        y += canvas.height / rows
      x += canvas.width / columns

    positions

  motionOverTime = (motionExpression) ->
    (point) ->
      point.x += Math.sin(G.gameTime / motionExpression(point))
      point.y += Math.cos(G.gameTime / motionExpression(point))

  randomExpressionClosure = ->
    expressions = motionExpressionGenerator()
    n = Math.floor(C$.Math.randomBetween(0, expressions.length))
    expressions[n]

  motionExpressionGenerator = ->
    expressions = []

    expressions[expressions.length] = ripple1 = ->
      G.gameTime = C$.Math.randomBetween(25000, 75000)
      xDenominator = C$.Math.randomBetween(5, 15)
      yDenominator = C$.Math.randomBetween(5, 15)
      (square) ->
        point =
          x: square.x * Math.sin(G.gameTime / xDenominator)
          y: square.y * Math.cos(G.gameTime / yDenominator)

        C$.Math.distance point, G.canvas_center

    expressions[expressions.length] = ripple2 = ->
      G.gameTime = C$.Math.randomBetween(10, 1000)
      denominator = C$.Math.randomBetween(1000, 4000)
      (square) ->
        point =
          x: square.x * Math.sin(G.gameTime / denominator)
          y: square.y * Math.cos(G.gameTime / denominator)

        C$.Math.distance(point, G.canvas_center) / 100

    expressions[expressions.length] = brownian = ->
      G.gameTime = Math.random() * 10000000
      (square) ->
        point =
          x: square.x * Math.sin(G.gameTime / 50)
          y: square.y * Math.cos(G.gameTime / 50)

        C$.Math.distance point, G.canvas_center

    expressions[expressions.length] = helix = ->
      G.gameTime = C$.Math.randomBetween(10000, 100000)
      f = trigFunction Math.random()
      indexFromCorner = (i) -> i*i
      (square) ->
        2 * (f G.squares.length) * Math.log(indexFromCorner square.index) * G.squares.length * 0.00005

    expressions

  colorPatternGenerator = ->

    patternGenerator = ->
      random    = -> [-1,1].random()*Math.random()*[10..100].random()
      [r, g, b] = [random(), random(), random()]
      noise     = random()
      f         = trigFunction Math.random()
      pattern   = [0,1,2].random()

      (i) ->
        switch pattern
          when 0
            f i * (f noise) / r * b % i
          when 1
            f i * (f noise) / g * r % i
          when 2
            f i * (f noise) / b * g % i

    calculateColorByte = (pattern, i) ->
      Math.floor Math.abs(255 * pattern(i))

    pattern1 = patternGenerator()
    pattern2 = patternGenerator()
    pattern3 = patternGenerator()

    p = [Math.PI, Math.E, Math.SQRT2, Math.LOG2E, C$.Math.PHI].random()
    q = p/[50..750].random()
    (i) ->
      r = (calculateColorByte pattern1, i*q)
      g = (calculateColorByte pattern2, i*q)
      b = (calculateColorByte pattern3, i*q)
      a = 1
      Gamma.RGBA.toString [r, g, b, 1]

  trigFunction = (x) ->
    f = [Math.sin, Math.cos, Math.tan].random()
    (n) -> f n * Math.sqrt x

  resetSquares = ->
    expression = randomExpressionClosure()()
    G.currentMotionFunction = motionOverTime expression
    x = determineRatio(canvas.width)
    y = determineRatio(canvas.height)
    coEf = Math.floor(C$.Math.randomBetween (x - 1) * 8, y * 8)
    G.squareRows = x * coEf
    G.squareColumns = y * coEf
    G.squares = constructSquares G.squareRows, G.squareColumns, (C$.Math.randomBetween 5, 25)

  determineRatio = (n) ->
    n / Math.floor(canvas.width / canvas.height * 10) / 10

  ctx = canvas.getContext("2d")

  canvas.onclick = resetSquares
  setInterval resetSquares, 15000
  resetSquares()
  main()

$ ->
  canvas = document.getElementById("canvas")
  canvas.height = 480
  canvas.width = 940
  Squares canvas  if canvas.getContext
