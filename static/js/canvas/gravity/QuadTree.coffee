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
            (@_nw[0] <= p[0] <= @_se[0]) && (@_ne[1] <= p[1] <= @_sw[1])

        intersectsAABB: (other) ->
            @_nw[0] <= other._nw[0] and
            @_nw[1] <= other._nw[1] and
            @_se[0] >= other._se[0] and
            @_se[1] >= other._se[1]

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
        constructor: (@boundary) ->

        #TODO
        #Add and removed squares to this as needed.
        pointPointers: []

        #Always work with quadrents in this order.
        _nw: null, _ne: null, _sw: null, _se: null
        getQuadrents: ->
            qs = []
            for q in [@_nw, @_ne, @_sw, @_se]
                qs.push q if q
            qs
        setQuadrents: (nw, ne, sw, se) ->
            [@_nw=new G.QuadTree nw, @_ne=new G.QuadTree ne,
             @_sw=new G.QuadTree sw, @_se=new G.QuadTree se]
            null

        QT_NODE_CAPACITY: 4

        #:: V2 -> bool
        insert: (p) ->
            if not @boundary.containsPoint p
                return false

            if @pointPointers.length < @QT_NODE_CAPACITY
                points.push p
                return true

            if @_nw != null
                subdivide()

            if Fn.any (@getQuadrents().map (q) -> q.insert p)
                return true

            return false

        #:: void
        subdivide: ->
            @setQuadrents.apply @, @boundary.quadrents()

        #:: AABB -> [V2]
        queryRange: (range, points) ->
            pointsInRange = []

            if not @boundary.intersectsAABB range
                return pointsInRange

            for p in (points.map (x) -> x.position)
                if range.containsPoint p
                    pointsInRange.push p

            if @_nw == null
                return pointsInRange

            for q in @getQuadrents()
                Array::push.apply pointsInRange, q.queryRange range

            return pointsInRange

        map: (f, _acc=[]) ->
            acc.push f @
            q.map f, _acc for q in @getQuadrents()
            _acc
