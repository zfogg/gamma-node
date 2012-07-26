//= require ../canvas-tools

function Grid() {

    var ctx = canvas.getContext("2d"),
        gameTime = 0,
        items = new Array(100),
        positions = new Array(items.length);

    var gradient = ctx.createRadialGradient(canvas.width / 2, canvas.height / 2, 99, canvas.width / 2, canvas.height, 60);
    gradient.addColorStop(0, randomColor());
    gradient.addColorStop(0.5, randomColor());
    gradient.addColorStop(1, randomColor());
    ctx.strokeStyle = gradient;

    function trigFunction(x) {
        this.x = x;
        f = Math.random() > 0.5 ? Math.sin : Math.cos;
        return function(n) {
            return f(n*Math.sqrt(x));
        };
    }

    var mod = 1;
    var f1 = trigFunction(Math.random());
    var f2 = trigFunction(Math.random());
    var f3 = trigFunction(Math.random());

    function main() {
        clearCanvas();

        mod += Math.sin(mod);
        //gradient.addColorStop(Math.abs(f1(gameTime*mod)), randomColor());
        //gradient.addColorStop(Math.abs(f2(gameTime*mod)), randomColor());
        //gradient.addColorStop(Math.abs(f3(gameTime*mod)), randomColor());
        
        drawGrid(//canvas.width/2, canvas.height/2
            Math.abs(Math.ceil(Math.sin(gameTime*0.01)*(canvas.width/2) )),
            Math.abs(Math.ceil(Math.cos(gameTime*0.01)*(canvas.height/2) ))
        );
        items.forEach(function(item) {
            item.update(gameTime);
            item.draw();
        });

        gameTime++;
    }

    function drawGrid(rows, columns) {
        var positions = initPositions(rows, columns).filter(function(p) {
            return !p.x || !p.y;
        });

        ctx.beginPath();
        positions.forEach(function(p, i) {
            switch (p.x < p.y) {
                case true:
                    ctx.moveTo(p.x, p.y);
                    ctx.lineTo(canvas.width, p.y);
                    break;
                case false:
                    ctx.moveTo(p.x, p.y);
                    ctx.lineTo(p.x, canvas.height);
                    break;
            }
        });
        ctx.stroke();
    }
    
    function initPositions(rows, columns) {
        var positions = new Array();
        for (var x = 0, i = 0; x <= canvas.width; x += canvas.width / columns)
            for (var y = 0; y <= canvas.height; y += canvas.height / rows, i++)
                positions[i] = {x:x, y:y};

        return positions;
    }

    function randomColor() {
        return '#'+('00000'+(Math.random()*16777216<<0).toString(16)).substr(-6);
    }

    function clearCanvas() {
        ctx.clearRect(0, 0, canvas.width, canvas.height);
    }

    setInterval(main, 30);
}

window.onload = function() {
    var canvas = document.getElementById("canvas");
    canvas.height = 480;
    canvas.width  = 940;

    if (canvas.getContext) {
        Grid();
    }
};
