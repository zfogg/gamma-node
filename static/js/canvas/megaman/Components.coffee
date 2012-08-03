Crafty.c "b2_kinematicMove",
  _move: (x, y) ->
    p = @body.GetPosition()
    @body.SetPosition new b2Vec2 p.x+x, p.y+y
  b2_kinematicMove: (u, r, d, l, f) ->
    @bind "EnterFrame", (e) ->
      if @[u]
        @_move 0, -f
      if @[r]
        @_move f, 0
      if @[d]
        @_move 0, f
      if @[l]
        @_move -f, 0

Crafty.c "SpriteHFlip",
  spriteHFlip: (l, r) ->
    @bind "KeyDown", (e) ->
      if e.key == Crafty.keys[r]
        @flip()
      if e.key == Crafty.keys[l]
        @unflip()

Crafty.c "Keys",
  keys: (keys) ->
    @bind "KeyDown", (e) ->
      for k,v of keys
        if e.key == Crafty.keys[k]
          @[v] = true
    @bind "KeyUp", (e) ->
      for k,v of keys
        if e.key == Crafty.keys[k]
          @[v] = false
