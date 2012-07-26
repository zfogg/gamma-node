//= require ../canvas-tools

function Squares(canvas) {

    var ctx = canvas.getContext("2d"),
        gameTime = 0,
        canvas_center = {x:canvas.width/2, y:canvas.height/2},
        currentMotionFunction,
        squareRows = 0, squareColumns = 0,
        squares = [];

    function Square(x, y, size, index, color) {
        this.x = x, this.y = y;
        this.color = color, this.alpha = 1;
        this.size = size;
        this.index = index;

        this.update = function() {
            currentMotionFunction(this);
        };

        this.draw = function() {
            ctx.fillStyle = this.color;
            ctx.fillRect(this.x, this.y, this.size, this.size);
        };
    }

    function main() {
        C$.clearCanvas(canvas, ctx);

        squares.forEach(function(square) {
            square.update();
            square.draw();
        });

        gameTime++;
        window.requestFrame(main, canvas);
    }

    function constructSquares(rows, columns, size) {
        var array = new Array(),
            color = colorPatternGenerator(),
            positions = initPositions(rows, columns);

        positions.forEach(function(p, i){
           array[i] = new Square(p.x, p.y, size, i, color(i));
        });

        return array;
    }

    function initPositions(rows, columns) {
        var positions = [];
        for (var x = 0, i = 0; x < canvas.width; x += canvas.width / columns)
            for (var y = 0; y < canvas.height; y += canvas.height / rows, i++)
                positions[i] = {x:x, y:y};

        return positions;
    }

    function motionOverTime(motionExpression) {
        return function(point) {
            point.x += Math.sin(gameTime / motionExpression(point));
            point.y += Math.cos(gameTime / motionExpression(point));
        }
    }

    function randomExpressionClosure() {
        var expressions = motionExpressionGenerator();
        var n = Math.floor(C$.Math.randomBetween(0, expressions.length));
        return expressions[n];
    }

    function motionExpressionGenerator() {
        var expressions = [];
        expressions[expressions.length] = function ripple1() {
            gameTime = C$.Math.randomBetween(25000,75000);
            var xDenominator = C$.Math.randomBetween(5, 15);
            var yDenominator = C$.Math.randomBetween(5, 15);
            return function(square) {
                var point = {
                    x: square.x*Math.sin(gameTime/xDenominator),
                    y: square.y*Math.cos(gameTime/yDenominator)
                };
                return C$.Math.distance(point, canvas_center);
            };
        };

        expressions[expressions.length] = function ripple2() {
            gameTime = C$.Math.randomBetween(10, 1000);
            var denominator = C$.Math.randomBetween(1000, 4000);
            return function(square) {
                var point = {
                    x: square.x*Math.sin(gameTime/denominator),
                    y: square.y*Math.cos(gameTime/denominator)
                };
                return C$.Math.distance(point, canvas_center) / 100;
            };
        };

        expressions[expressions.length] = function brownian() {
            gameTime = Math.random() * 10000000;
            return function(square) {
                var point = {
                    x: square.x*Math.sin(gameTime/50),
                    y: square.y*Math.cos(gameTime/50)
                };
                return C$.Math.distance(point, canvas_center);
            };
        };

        expressions[expressions.length] = function helix() {
            gameTime = C$.Math.randomBetween(10000, 100000);

            var f = trigFunction(Math.random());
            var indexFromCorner = function(i) {return i*i;};

            return function(square) {
                return 2 * f(squares.length) * Math.log(indexFromCorner(square.index)) * squares.length * 0.00005;
            };
        };

        return expressions;
    }

    function colorPatternGenerator() {

        function patternGenerator() {
            function randomness() {
                var n = Math.random();
                return n > 0.5 ?  n * 10 : n * -10;
            }

            var r = randomness(),
                g = randomness(),
                b = randomness(),
                f = trigFunction(Math.random()),
                noise = randomness(),
                patternNumber = Math.floor(C$.Math.randomBetween(0, 3));

            return function(i) {
                switch (patternNumber) {
                    case 0: return f(i*f(noise)/r*b%i);
                    case 1: return f(i*f(noise)/g*r%i);
                    case 2: return f(i*f(noise)/b*g%i);
                }
            };
        }

        var specialNumbers = [Math.PI, Math.E, Math.SQRT2, Math.LOG2E];
        var specialNumber = specialNumbers[Math.floor(
            C$.Math.randomBetween(0, specialNumbers.length))] / C$.Math.randomBetween(5, 1000);
        var pattern1 = patternGenerator();
        var pattern2 = patternGenerator();
        var pattern3 = patternGenerator();

        function calculateColorByte(pattern, i) {
            return Math.floor(Math.abs(255*pattern(i)));
        }

        return function(i) {
            i *= specialNumber;
            var r = calculateColorByte(pattern1, i),
                g = calculateColorByte(pattern2, i),
                b = calculateColorByte(pattern3, i),
                a = 1;

            return "rgba("+r+","+g+","+b+","+"1)";
        };
    }

    function trigFunction(x) {
        var f = Math.random() > 0.5 ? Math.sin : Math.cos;
        return function(n) {
            return f(n*Math.sqrt(x));
        };
    }

    function resetSquares() {
        var expression = randomExpressionClosure()();
        currentMotionFunction = motionOverTime(expression);

        var x = determineRatio(canvas.width), y = determineRatio(canvas.height),
            coEf = Math.floor(C$.Math.randomBetween((x-1)*8, y*8)),
            squareRows = x*coEf;
            squareColumns = y*coEf;

        squares = constructSquares(squareRows, squareColumns, C$.Math.randomBetween(5, 25));
    }

    function determineRatio(n) {
        return n / Math.floor(canvas.width/canvas.height * 10) / 10;
    }

    resetSquares();
    canvas.onclick = resetSquares;
    setInterval(resetSquares, 15000);
    main();
}

window.onload = function() {
    var canvas = document.getElementById("canvas");
    canvas.height = 480;
    canvas.width  = 940;

    if (canvas.getContext){
        Squares(canvas);
    }
};
