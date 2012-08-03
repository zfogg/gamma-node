ANIMATE_TIME = 24

window.Hero = (x, y) ->
  hero = Crafty.e(
    "2D, Canvas, Box2D, SpriteAnimation, Keys,
    b2_kinematicMove, SpriteHFlip, megamanStand")
    .attr(x: x, y: y, w: 40, h: 40)
    .spriteHFlip('D', 'A')
    .animate("spawning", 0, 0, 5)
    .animate("spawn", 0, 0, 7)
    .animate("run", 0, 2, 4)
    .animate("fidget", 0, 1, 3)
    .animate("runGun", 6, 2, 11)
    .animate("fall", 9, 4, 10)
    .animate("climb", 0, 3, 3)
    .box2d(shape: [
      [10, 4 ], [28, 4 ],
      [29, 35], [10, 35]
    ])

  REELS = ["spawning", "spawn", "climb", "run", "fall", "fidget"]

  window.sensor1 = Crafty.e(
    "2D, Canvas, Box2D, Keys, b2_kinematicMove")
    .attr(x: x+15, y: y+30, w: 10, h: 10)
    .box2d(bodyType: "kinematic")

  hero.bind("KeyUp", (e) ->
    ['W', 'D', 'S', 'A'].map (k) =>
      if e.key == Crafty.keys[k]
        @animate "fidget", ANIMATE_TIME

  ).bind("EnterFrame", (e) ->
    @position = hero.body.GetPosition()
    if @up
      @switchAnimation "fidget", "climb"
    if @right and !@down
      @switchAnimation "fidget", "run"
    if @down
      @switchAnimation "fidget", "fall"
    if @left  and !@down
      @switchAnimation "fidget", "run"

    do ->
      for reel in REELS
        return if hero.isPlaying reel
      hero.switchAnimation "", "fidget"
  )

  [hero, sensor1].map (e) ->
    e.keys W: "up", D: "right", S: "down", A: "left"
    e.b2_kinematicMove "up", "right", "down", "left", 0.08

  hero.switchAnimation = (fromReel, toReel, repeats=-1) ->
    if @isPlaying fromReel
      @stop()
    if not @isPlaying toReel
      @animate toReel, ANIMATE_TIME, repeats

  hero.animate "spawning", ANIMATE_TIME*1.5, 1
  window.hero = hero
