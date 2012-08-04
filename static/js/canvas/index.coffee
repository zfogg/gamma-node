$gjs   = require "gamejs"
$mask  = require "gamejs/mask"
$draw  = require "gamejs/draw"
$v     = require "gamejs/utils/vectors"
$m     = require "gamejs/utils/matrix"

SpriteSheet = (require "js/canvas/SpriteSheet").SpriteSheet
Animation   = (require "js/canvas/Animation").Animation

$gjs.preload [
  "/images/spear.png",
  "/images/unit.png",
  "/images/canvas/MegaManSprites.png"
]

$gjs.setLogLevel 0

$gjs.Surface::rotate = (r) ->
    s        = @getSize()
    @_matrix = $m.translate @_matrix, s[0]/2, s[1]/2
    @_matrix = $m.rotate @_matrix, r
    @_matrix = $m.translate @_matrix, -s[0]/2, -s[1]/2

window.rectangleFromE = (e, canvas) ->
    new $gjs.Rect [e.offsetLeft, e.offsetTop], [($ e).width(), ($ e).height()]

$gjs.ready main = ->
    canvas        = $("#gjs-canvas")[0]
    display       = $gjs.display.setMode [($ "#main").width(), ($ "#main").height()]
    spear         = $gjs.image.load "/images/spear.png"
    unit          = $gjs.image.load "/images/unit.png"
    mUnit         = $mask.fromSurface unit
    mSpear        = $mask.fromSurface spear
    unitPosition  = [200, 350]
    spearPosition = [300, 300]
    font          = new $gjs.font.Font "20px monospace"

    collidables = for c in $ ".b2_staticBody"
        rectangleFromE c, canvas

    ss = new SpriteSheet "/images/canvas/MegaManSprites.png",
      width: 40, height: 40

    anim = new Animation ss,
        #spawning: [0, 0, 5]
        spawn:    [0, 4]
        #run:      [0, 2, 4]
        #fidget:   [0, 1, 3]
        #runGun:   [6, 2, 11]
        #fall:     [9, 4, 10]
        #climb:    [0, 3, 3]

    window.x = anim
    x.start "spawn"

    tick = (gameTime) ->
        $gjs.event.get().forEach (event) ->
            direction = {}
            direction[$gjs.event.K_UP]    = [0,  -1]
            direction[$gjs.event.K_DOWN]  = [0,   1]
            direction[$gjs.event.K_LEFT]  = [-1,  0]
            direction[$gjs.event.K_RIGHT] = [1,   0]

            if event.type is $gjs.event.KEY_DOWN
                d = direction[event.key]
                if d and d[0]
                    spear.rotate d[0]*Math.PI/8

            else if event.type is $gjs.event.MOUSE_MOTION
                spearPosition = $v.subtract event.pos, $v.divide spear.getSize(), 2

        x.update gameTime
        do draw = ->
            display.clear()
            display.blit x.image
            display.blit unit, unitPosition
            display.blit spear, spearPosition

            relativeOffset = $v.subtract spearPosition, unitPosition
            if mUnit.overlap mSpear, relativeOffset
                display.blit font.render("COLLISION", "#ff0000"), [200, 250]

        do collide = ->
            for c in collidables
                if c.collidePoint $v.add spearPosition, $v.divide spear.getSize(), 2
                    display.blit font.render("COLLISION", "#ff0000"), [200, 250]
                    $draw.rect display, "#ff00cc", c

    $gjs.time.fpsCallback tick, this, 30
