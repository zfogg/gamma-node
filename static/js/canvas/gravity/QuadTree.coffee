Gamma.namespace "Gravity", (G, top) ->
    Fn    = G.C$.Fn
    Math$ = G.C$.Math

    G.AABB = class
        constructor: (@center, @half) ->
            @_nw = G.vectors.get @center[0] - @half, @center[1] - @half
            @_ne = G.vectors.get @center[0] + @half, @center[1] - @half
            @_sw = G.vectors.get @center[0] - @half, @center[1] + @half
            @_se = G.vectors.get @center[0] + @half, @center[1] + @half

        destructor: ->
            for v in [@_nw, @_ne, @_sw, @_se]
                G.vectors.put v

        containsPoint: (p) ->
            (@_nw[0] <= p[0] <= @_se[0]) and
            (@_ne[1] <= p[1] <= @_sw[1])

        intersectsAABB: (aabb) ->
            @_nw[0] <= aabb._nw[0] and
            @_nw[1] <= aabb._nw[1] and
            @_se[0] >= aabb._se[0] and
            @_se[1] >= aabb._se[1]

        quadrents: ->
            q = @half/2
            [
                new G.AABB [@_nw[0] + q, @_nw[1] + q], q
                new G.AABB [@_ne[0] - q, @_ne[1] + q], q
                new G.AABB [@_sw[0] + q, @_sw[1] - q], q
                new G.AABB [@_se[0] - q, @_se[1] - q], q
            ]

    G.QuadTree = class
        #:: AABB -> @
        constructor: (@boundary, point_pointers, @RECUR_LIMIT) ->
            @pointps = []
            if point_pointers != null and point_pointers.length > 0
                @insert pp for pp in point_pointers

        #Always work with quadrents in this order.
        _nw: null, _ne: null, _sw: null, _se: null
        getQuadrents: ->
            qs = []
            for q in [@_nw, @_ne, @_sw, @_se]
                qs.push q if q
            qs
        setQuadrents: (nw, ne, sw, se) ->
            @_nw = @_new_QuadTree nw
            @_ne = @_new_QuadTree ne
            @_sw = @_new_QuadTree sw
            @_se = @_new_QuadTree se
            null

        _new_QuadTree: (corner) ->
            new (@getQT_T()) corner, null, @RECUR_LIMIT-1

        getQT_T: -> G.QuadTree
        QT_NODE_CAPACITY: 3

        #:: V2* -> bool
        insert: (pp) ->
            if not @boundary.containsPoint pp.position
                return false

            if @pointps.length < @QT_NODE_CAPACITY
                @pointps.push pp
                return true

            if @_nw == null
                @subdivide()

            return true in (q.insert pp for q in @getQuadrents())

        #:: void
        subdivide: ->
            if @RECUR_LIMIT > 0
                @setQuadrents.apply @, @boundary.quadrents()
            null

        #:: AABB -> [V2]
        queryRange: (range) ->
            pointsInRange = []

            if not @boundary.intersectsAABB range
                return pointsInRange

            for p in (@points.map (x) -> x.position)
                if range.containsPoint p
                    pointsInRange.push p

            if @_nw == null
                return pointsInRange

            for q in @quadrents
                Array::push.apply pointsInRange, q.queryRange range

            return pointsInRange

        map: (f, _acc=[]) ->
            _acc.push f @
            q.map f, _acc for q in @getQuadrents()
            _acc


    G.SquareTree = class extends G.QuadTree
        #Ensure that your colors are six hex digits.
        color: "#000000"
        getQT_T: -> G.SquareTree
        QT_NODE_CAPACITY: 4

        mass: 0
        theta: 8

        constructor: (@boundary, point_pointers, @RECUR_LIMIT) ->
            @barycenter = [
                @boundary._nw[0] - @boundary.half,
                @boundary._sw[1] - @boundary.half
            ]

            super @boundary, point_pointers, @RECUR_LIMIT

        updateMass: (m) -> @mass += m

        updateBarycenter: (p) ->
            sumx = 0; sumy = 0
            for pp in @pointps
                sumx += pp.position[0]
                sumy += pp.position[1]
            @barycenter[0] = (sumx + p[0])/(1+@pointps.length)
            @barycenter[1] = (sumy + p[1])/(1+@pointps.length)

        ratio: (p) ->
            (@boundary.half*2) / (G.distance @position, p.position)

        draw: (ctx) ->
            if @pointps.length > 0
                len = @pointps.length/@QT_NODE_CAPACITY
                delta = 1/@QT_NODE_CAPACITY
                v     = easeInOutCirc len, 0, delta, 1
                if v > 0
                    v *= @QT_NODE_CAPACITY
                    c = Gamma.RGBA.fromHex @color, v
                    if @RECUR_LIMIT % 2 == 0
                        @getQuadrents().map (x) ->
                            x.color = c

                    ctx.strokeStyle = c
                    ctx.fillStyle   = c

                    @_drawBoundary   ctx, v
                    @_drawBarycenter ctx, v
                    @_drawMass       ctx, v

        _drawBoundary: (ctx, v) ->
            ctx.lineWidth   = (1-v)*4
            ctx.strokeRect(
                @boundary.center[0]-@boundary.half,
                @boundary.center[1]-@boundary.half,
                @boundary.half*2,
                @boundary.half*2)

        _drawBarycenter: (ctx, v) ->
            ctx.beginPath()
            ctx.arc @barycenter[0], @barycenter[1], 4*v, 0, Math.PI*2, true
            ctx.closePath()
            ctx.stroke()

        _drawMass: (ctx, v) ->
            ctx.fillText((Math$.roundDigits @mass, 2),
                @boundary.center[0],
                @boundary.center[1])

        insert: (s) ->
            if @boundary.containsPoint s.position
                @color = s.color
                @updateBarycenter s.position
                @updateMass s.mass
            super s


    easeInOutCirc = (t, b, c, d) ->
        t /= d/2
        if t < 1
            return -c/2 * (Math.sqrt(1 - t*t) - 1) + b
        t -= 2
        return c/2 * (Math.sqrt(1 - t*t) + 1) + b
