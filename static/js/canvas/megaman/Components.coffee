Crafty.c "b2_kinematicHMove",
  _move: (x, y) ->
    p = @body.GetPosition()
    @body.SetPosition new b2Vec2 p.x+x, p.y+y
  b2_kinematicHMove: (r, l, move$) ->
    @bind "EnterFrame", (e) ->
      if @[r]
        @_move 0.1, 0
      if @[l]
        @_move -0.1, 0

Crafty.c "SpriteHFlip",
  SpriteHFlip: (l, r) ->
    @bind "KeyDown", (e) ->
      if e.key == Crafty.keys[r]
        @flip()
      if e.key == Crafty.keys[l]
        @unflip()

Crafty.c "Keys",
  Keys: (keys) ->
    @bind "KeyDown", (e) ->
      for k,v of keys
        if e.key == Crafty.keys[k]
          @[v] = true
    @bind "KeyUp", (e) ->
      for k,v of keys
        if e.key == Crafty.keys[k]
          @[v] = false
