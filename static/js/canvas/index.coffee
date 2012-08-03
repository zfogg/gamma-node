###
Demonstrates pixel perfect collision detection utilizing image masks.
gamejs.mask.fromSurface is used to create two pixel masks
that do the actual collision detection.
###

gamejs = require("gamejs")
mask   = require("gamejs/mask")
$v     = require("gamejs/utils/vectors")

gamejs.preload ["/images/spear.png", "/images/unit.png"]

main = ->
  # create image masks from surface
  display       = gamejs.display.setMode [($ "#main").width(), ($ "#main").height()]
  spear         = gamejs.image.load "/images/spear.png"
  unit          = gamejs.image.load "/images/unit.png"
  mUnit         = mask.fromSurface unit
  mSpear        = mask.fromSurface spear
  unitPosition  = [20, 350]
  spearPosition = [6, 300]
  font          = new gamejs.font.Font "20px monospace"

  tick = ->
    # event handling
    gamejs.event.get().forEach (event) ->
      direction = {}
      direction[gamejs.event.K_UP]    = [0,  -1]
      direction[gamejs.event.K_DOWN]  = [0,   1]
      direction[gamejs.event.K_LEFT]  = [-1,  0]
      direction[gamejs.event.K_RIGHT] = [1,   0]

      if event.type is gamejs.event.KEY_DOWN
        if direction[event.key]
          spearPosition = $v.add spearPosition, $v.multiply direction[event.key], 10
      else if event.type is gamejs.event.MOUSE_MOTION
        if display.rect.collidePoint event.pos
          spearPosition = $v.subtract event.pos, $v.divide spear.getSize(), 2

    # draw
    display.clear()
    display.blit unit, unitPosition
    display.blit spear, spearPosition

    # collision
    # the relative offset is automatically calculated by
    # the higher-level gamejs.sprite.collideMask(spriteA, spriteB)
    relativeOffset = $v.subtract spearPosition, unitPosition
    if mUnit.overlap(mSpear, relativeOffset)
      display.blit font.render("COLLISION", "#ff0000"), [200, 250]

  gamejs.time.fpsCallback tick, this, 30

gamejs.ready main
