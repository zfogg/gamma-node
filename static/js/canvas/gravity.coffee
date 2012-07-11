# Dependencies: canvas-controls, canvas-tools

Gravity = (canvas) ->
  ctx                   = canvas.getContext "2d"

  gameTime              = 0
  squares               = []

  defaultGravity        = (C$.Math.randomBetween 4, 8) * Math.pow 10, -6
  defaultFriction       = (C$.Math.randomBetween 3, 7) * Math.pow 10, -4
  defaultDistance       = (C$.Math.randomBetween 4, 6)
  defaultCursorFriction = 1
  defaultCursorMass     = [500..2000].random()
  defaultCursorForce    = 0.65

  # An alias or two.
  V2                    = C$.Vector2

  class PhysicalBody
    constructor: (@position = V2::Zero(), @mass = 1, @size = 1, @restitution = 1, @velocity = V2::Zero()) ->

    updatePosition: ->
      @position.x += @velocity.x
      @position.y += @velocity.y

    applyForce: (acceleration) ->
      @velocity.x += 0.5 * acceleration.x * @mass
      @velocity.y += 0.5 * acceleration.y * @mass

  class Square extends PhysicalBody
    constructor: (@position, @mass, @size, @index, @color) ->
      super @position, @mass, @size, 0.85

    update: (gameTime) ->
      applyGravity @, cursor
      if not cursor.isClicked.right and not cursor.isClicked.left
        @bounceOffLimits canvas.width, canvas.height, @mass*2
      @updatePosition()
      @decayVelocity CC_friction.values.current
      @draw(ctx)

    decayVelocity: (n) ->
      @velocity.x -= @velocity.x * n * @mass
      @velocity.y -= @velocity.y * n * @mass

    draw: (ctx) ->
      ctx.fillStyle = @color
      ctx.fillRect @position.x, @position.y, @size, @size

    bounceOffLimits: do ->
      bounce = (dimension, coEf = 1) -> coEf * Math.abs dimension
      (width, height, offset) ->
        bounced = false
        if @position.x > width - offset
          @velocity.x = -bounce @velocity.x
        else if @position.x < 0 + offset
          @velocity.x = bounce @velocity.x

        if @position.y > height - offset
          @velocity.y = -bounce @velocity.y
        else if @position.y < 0 + offset
          @velocity.y = bounce @velocity.y

  class Cursor extends PhysicalBody
    constructor: ->
      @position        = V2::Zero()
      @trackedPosition = V2::Zero()
      @canvasCenter    = new V2 canvas.width / 2, canvas.height / 2

      ($ canvas).mousedown (e) => @toggleClicks e, true
      ($ "body").mouseup   (e) => @toggleClicks e, false
      ($ canvas).mousedown @mouseDown
      ($ "body").mouseup   @mouseUp
      ($ "canvas").mousemove C$.cursorUpdater @trackedPosition, canvas

      super

    isClicked:
      left:   false
      middle: false
      right:  false

    toggleClicks: (e, value) =>
      switch e.which
        when 1 then @isClicked.left   = value
        when 2 then @isClicked.middle = value
        when 3 then @isClicked.right  = value
      true

    mouseDown: =>
      if @isClicked.left
        @mass = CC_cursorMass.values.getFromControl()
        CC_friction.values.current =
          CC_friction.value / CC_friction.values.modifier * CC_cursorFriction.value

      else if @isClicked.right
        @mass = 0.25 * CC_cursorMass.values.getFromControl()
        CC_friction.values.current =
          0.2 * (CC_friction.value / CC_friction.values.modifier * CC_cursorFriction.value)

      true

    mouseUp: =>
      unless @isClicked.left
        squares.forEach (s) =>
          if 75 > C$.Math.distance s.position, @position
            s.applyForce forceTowards s.position, @position, CC_cursorForce.values.getFromControl()

        @mass = 0
        CC_friction.values.setFromControl()
        CC_gravity.values.setFromControl()

      @isClicked.left = @isClicked.middle = @isClicked.right = false
      true

    rightHeldDown: =>
      @position.x = @canvasCenter.x + (Math.sin gameTime / 14) * 124
      @position.y = @canvasCenter.y + (Math.cos gameTime / 14) * 124

    updatePosition: ->
      @position.x = @trackedPosition.x
      @position.y = @trackedPosition.y

    update: ->
      if @isClicked.right
        @rightHeldDown()
        @draw(ctx)
      else @updatePosition()

    draw: (ctx) ->
      ctx.beginPath()
      ctx.arc @position.x, @position.y, 10, 0, Math.PI*2, true
      ctx.closePath()
      ctx.fill()

  applyGravity = do ->
    attractionOfGravity = (b1, b2) ->
      d = C$.Math.direction b1.position, b2.position
      r = hypotenuse d.x, d.y

      if r isnt 0 and r > CC_distance.values.current
        g = gravity CC_gravity.values.current, b1.mass, b2.mass, r
        new V2 -d.x / r*g, -d.y / r*g
      else V2::Zero()

    gravity = (G, m1, m2, r) -> G*m1*m2 / r*r
    negateV2 = (v) -> new V2 -v.x, -v.y

    (body1, body2) ->
      f = attractionOfGravity body1, body2
      body1.applyForce f
      body2.applyForce negateV2 f

  forceTowards = (from, to, coEf = 1) ->
    d = C$.Math.direction from, to
    r = hypotenuse d.x, d.y
    new V2 -d.x/r * coEf, -d.y/r * coEf

  mapPairs = (f, set) ->
    i = set.length
    while j = --i
      while j--
        f set[i], set[j]
    return

  # Returns an n^2 grid of Squares, where n is the 'size' argument.
  constructSquares = do ->
    initPositions = (rows, columns) ->
      for n in [0...rows*columns]
        new V2 \
          (n / columns | 0) * canvas.width / columns,
          (n % rows) * canvas.height / rows

    newSquare = (p, i, size) ->
      new Square p, size*C$.Math.PHI/2, size, i, C$.color Math.random

    (rows, columns, size) ->
      for position, index in initPositions rows, columns
        newSquare position, index, (if size.call then size() else size)

  resetSquares = (gridSize) ->
    cursor.isClicked.left = true
    setTimeout (-> cursor.isClicked.left = false), 7000

    size = if [true, false].random()
    then -> (x*C$.Math.PHI for x in [3.25..4.75] by 0.125).random()
    else [3..6].random()
    constructSquares gridSize, gridSize, size

  # Canvas Controls
  controls          = new CanvasControls
  controlValueRange = lower: 10, upper: 100

  rangeInput = (name, defaultValue) ->
    cValObj = controls.controlValueObj defaultValue, controlValueRange
    control = controls.RangeInput \
      name, cValObj.default * cValObj.modifier,
      controlValueRange.lower, controlValueRange.upper, 3

    ($ control).blur controls.propertyUpdater cValObj, "current", cValObj.modifier
    cValObj.self = control
    control.values = cValObj
    control

  CC_gravity        = rangeInput "Gravitational Attraction",    defaultGravity
  CC_friction       = rangeInput "Atmospheric Friction",        defaultFriction
  CC_distance       = rangeInput "Gravity Deadzone Radius",     defaultDistance
  CC_cursorFriction = rangeInput "Cursor Friction Coefficient", defaultCursorFriction
  CC_cursorMass     = rangeInput "Cursor Body Mass",            defaultCursorMass
  CC_cursorForce    = rangeInput "Cursor Release Force",        defaultCursorForce

  CC_particleCount = controls.NumberInput "Rows of Squares", 16
  ($ CC_particleCount).blur controls.controlLimit (lower: 1, upper: 30)

  CC_resetButton = controls.ButtonInput "Reset Squares", "canvas-reset"
  ($ CC_resetButton).click (e) ->
    squares = resetSquares CC_particleCount.value

  CC_defaultButton = controls.ButtonInput "Default Values", "canvas-defaults"
  ($ CC_defaultButton).click ->
    x() for x in controls.resets

  # Init.
  hypotenuse = C$.Math.hypotenuseLookup 3, 0,
    ((Math.pow canvas.width, 2) + (Math.pow canvas.height, 2)) / Math.pow 10, 5
    Float64Array
  cursor     = new Cursor
  squares    = resetSquares 16

  do main = ->
    C$.clearCanvas canvas, ctx
    cursor.update()

    mapPairs applyGravity, squares
    square.update gameTime for square in squares

    gameTime++
    requestFrame main, canvas

$ ->
  canvas        = ($ "#canvas")[0]
  canvas.height = 480
  canvas.width  = 940

  if canvas.getContext
    Gravity canvas
