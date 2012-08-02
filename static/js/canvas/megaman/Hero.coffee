window.Hero = (x, y) ->

  hero = Crafty.e("2D,
                   Canvas,
                   Box2D,
                   SpriteAnimation,
                   Keys,
                   b2_kinematicHMove,
                   SpriteHFlip,
                   standing")
    .attr(x: x, y: y)
    .SpriteHFlip('D', 'A')
    .animate("running", 0, 2, 4)
    .animate("standing", 0, 1, 3)
    .animate("runningGun", 6, 2, 11)

    .bind("EnterFrame", ->
      if 1 == [1..50].random()
        @animate "standing", 24

    ).box2d(
      shape: [
        [10, 4 ], [28, 4 ],
        [29, 35], [10, 35]
      ])

  sensor = Crafty.e("2D, Canvas, Box2D, Keys, b2_kinematicHMove")
    .attr(x: x+15, y: y+30, w: 10, h: 10)
    .box2d(
      bodyType: "kinematic"
    )

  hero.bind("KeyUp", (e) ->
    switch e.key
      when Crafty.keys['D']
        @animate "standing", 24
      when Crafty.keys['A']
        @animate "standing", 24
    ).bind("EnterFrame", (e) ->
      @position = hero.body.GetPosition()
      if @right
        @animate "running", 24
      if @left
        @animate "running", 24
    )

  [hero, sensor].map (e) ->
    e.Keys(
      W: "up"
      D: "right"
      S: "down"
      A: "left"
    ).b2_kinematicHMove('right', 'left')

    window.hero = hero
