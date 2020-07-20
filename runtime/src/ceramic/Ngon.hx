package ceramic;

using ceramic.Extensions;

@editable({ implicitSize: true })
class Ngon extends Mesh {

    @editable({ slider: [3, 100] })
    public var sides(default,set):Int = 32;
    inline function set_sides(sides:Int):Int {
        if (this.sides == sides) return sides;
        this.sides = sides;
        contentDirty = true;
        return sides;
    }

    @editable({ slider: [0, 999] })
    public var radius(default,set):Float = 50;
    function set_radius(radius:Float):Float {
        if (this.radius == radius) return radius;
        this.radius = radius;
        contentDirty = true;
        return radius;
    }

    public function new() {

        super();

        anchor(0.5, 0.5);

    }

    override function computeContent() {

        var count:Int = sides;

        width = radius * 2;
        height = radius * 2;

        vertices.setArrayLength(0);
        indices.setArrayLength(0);

        vertices.push(radius);
        vertices.push(radius);

        var sidesOverTwoPi:Float = Math.PI * 2 / count;

        for (i in 0...count) {

            var _x = radius * Math.cos(sidesOverTwoPi * i);
            var _y = radius * Math.sin(sidesOverTwoPi * i);

            vertices.push(radius + _x);
            vertices.push(radius + _y);

            indices.push(0);
            indices.push(i + 1);
            if (i < count - 1) indices.push(i + 2);
            else indices.push(1);

        }

        contentDirty = false;

    }

#if editor

/// Editor

    public static function editorSetupEntity(entityData:editor.model.EditorEntityData) {

        entityData.props.set('anchorX', 0.5);
        entityData.props.set('anchorY', 0.5);
        entityData.props.set('sides', 32);
        entityData.props.set('radius', 50);

    }

#end

}
