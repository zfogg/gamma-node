window.Hero = (x, y) ->
  hero = Crafty.e("2D, Canvas, Box2D, SpriteAnimation, standing")
    .attr(x: x, y: y)

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
      ]

    ).bind("KeyDown", (e) ->
      if e.key == Crafty.keys['W']
        @up = true
      if e.key == Crafty.keys['D']
        @unflip()
        @right = true
      if e.key == Crafty.keys['S']
        @down = true
      if e.key == Crafty.keys['A']
        @flip()
        @left = true
    ).bind("KeyUp", (e) ->
      if e.key == Crafty.keys['W']
        @up = false
      if e.key == Crafty.keys['D']
        @animate "standing", 24
        @right = false
      if e.key == Crafty.keys['S']
        @down = false
      if e.key == Crafty.keys['A']
        @animate "standing", 24
        @left = false

    ).bind("EnterFrame", (e) ->
      @position = hero.body.GetPosition()
      if @up
        console.log
      if @right
        @move 0.1, 0
        @animate "running", 24
      if @down
        console.log
      if @left
        @move -0.1, 0
        @animate "running", 24
    )
    window.hero = hero

    hero.move = (x, y) ->
      p = hero.body.GetPosition()
      hero.body.SetPosition new b2Vec2 p.x+x, p.y+y

    hero.applyForce = (x, y) ->
      @body.ApplyForce (new b2Vec2 x, y), (new b2Vec2 0, 0)
    hero.applyImpulse = (x, y) ->
      @body.ApplyImpulse (new b2Vec2 x, y), (new b2Vec2 0, 0)
