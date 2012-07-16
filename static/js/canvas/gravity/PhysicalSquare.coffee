window.PhysicalSquare = (G) ->
  G.PhysicalSquare = class extends G.PhysicalBody
    constructor: (@position, @mass, @size, @index, @color) ->
      super @position, @mass, @size, 0.85

    update: ->
      G.applyGravity @, G.cursor
      if not G.cursor.isClicked.right and not G.cursor.isClicked.left
        @bounceOffLimits G.canvas.width, G.canvas.height, @mass*2
      @updatePosition()
      @decayVelocity G.CC_friction.values.current
      @draw G.ctx

    decayVelocity: (n) ->
      @velocity[0] -= @velocity[0] * n * @mass
      @velocity[1] -= @velocity[1] * n * @mass

    draw: (ctx) ->
      ctx.fillStyle = @color
      ctx.fillRect @position[0], @position[1], @size, @size

    bounceOffLimits: do ->
      bounce = (dimension) -> Math.abs dimension
      (width, height, offset) ->
        bounced = false
        if @position[0] > width - offset
          @velocity[0] = -bounce @velocity[0]
        else if @position[0] < 0 + offset
          @velocity[0] = bounce @velocity[0]

        if @position[1] > height - offset
          @velocity[1] = -bounce @velocity[1]
        else if @position[1] < 0 + offset
          @velocity[1] = bounce @velocity[1]
