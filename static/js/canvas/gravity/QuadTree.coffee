Gamma.namespace "Gravity", (G, top) ->
    Fn = G.C$.Fn

    G.AABB = exports.AABB = class
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


    G.QuadTree = exports.class = class
        #:: AABB -> @
        constructor: (@boundary, point_pointers, @RECUR_LIMIT) ->
            @pointps = []
            if ($.isArray point_pointers) and point_pointers.length > 0
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
            new G.QuadTree corner, null, @RECUR_LIMIT-1

        QT_NODE_CAPACITY: 4
        color: "#000000"

        #:: V2 -> bool
        insert: (pp) ->
            if not @boundary.containsPoint pp.position
                return false

            if @pointps.length < @QT_NODE_CAPACITY
                @color = pp.color #FIXME
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

            for q in @getQuadrents()
                Array::push.apply pointsInRange, q.queryRange range

            return pointsInRange

        map: (f, _acc=[]) ->
            _acc.push f @
            q.map f, _acc for q in @getQuadrents()
            _acc

        draw: (ctx) ->
            opacity = 0.25+(@getQuadrents().length/@QT_NODE_CAPACITY)
            if @RECUR_LIMIT % 2 == 0
                @getQuadrents().map (x) =>
                    x.color = Gamma.RGBA.fromHex @color, opacity

            ctx.strokeStyle = Gamma.RGBA.fromHex @color, opacity
            ctx.lineWidth   = @RECUR_LIMIT/4
            ctx.strokeRect(
                @boundary.center[0]-@boundary.half,
                @boundary.center[1]-@boundary.half,
                @boundary.half*2,
                @boundary.half*2)
