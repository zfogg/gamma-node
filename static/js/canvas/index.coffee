#= require canvas-tools
#= require canvas-controls

#= require ../libs/crafty
#= require ../libs/mousetrap.min

#= require ../libs/Box2dWeb-2.1.a.3
#= require ../libs/craftybox2d

#= require Game
#= require megaman/index


class MegaMan extends Game
  constructor: ->
    super()
    ($ ".b2_staticBody").each (i, e) =>
      rectangleFromE e, @canvas

    Crafty.sprite 40, "/images/canvas/MegaManSprites.png",
      megamanStand: [0, 1]

    hero = Hero 550, 280

    Crafty.bind "MouseDown", (e) ->
      console.log e
      if e.click == Crafty.mouseButtons['LEFT']
        Crafty.e("2D, Canvas, Box2D, SpriteAnimation")

  update: (gameTime) ->
    super gameTime

  draw: (ctx) ->
    super ctx

window.staticBodies = []
rectangleFromE = (e, canvas) ->
  p = $(canvas).offset()
  x = e.offsetLeft - p.left
  y = e.offsetTop  - p.top
  staticBodies.push Crafty.e("Box2D")
    .attr(x: x, y: y, w: ($ e).width(), h: ($ e).height())
    .box2d(bodyType: "static")

konamiCode = "up up down down left right left right a b a enter"
Mousetrap.bind konamiCode, ->
  Mousetrap.unbind konamiCode
  new MegaMan

Mousetrap.bind "1", ->
  Mousetrap.unbind "1"
  new MegaMan
