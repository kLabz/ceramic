package ceramic.macros;

import haxe.Json;
import haxe.io.Path;
import haxe.macro.Context;
import haxe.macro.Expr;

using StringTools;

class AppMacro {

    static var computedInfo:Dynamic;

    static public function getComputedInfo(rawInfo:String):Dynamic {

        if (AppMacro.computedInfo == null) AppMacro.computedInfo = computeInfo(rawInfo);
        return AppMacro.computedInfo;

    }

    macro static public function build():Array<Field> {

        #if ceramic_debug_macro
        trace(Context.getLocalClass() + ' -> BEGIN AppMacro.build()');
        #end

        var fields = Context.getBuildFields();

        var data = getComputedInfo(Context.definedValue('app_info'));

        // Load collection types from ceramic.yml
        for (key in Reflect.fields(data.collections)) {
            var val:Dynamic = Reflect.field(data.collections, key);
            if (Std.isOfType(val, String)) {
                Context.getType(val);
            }
            else {
                for (k in Reflect.fields(val)) {
                    var v:Dynamic = Reflect.field(val, k);
                    if (v.type == null) v.type = 'ceramic.CollectionEntry';
                    Context.getType(v.type);
                }
            }
        }

        var expr = Context.makeExpr(data, Context.currentPos());

        fields.push({
            pos: Context.currentPos(),
            name: 'info',
            kind: FVar(null, expr),
            access: [APublic],
            doc: 'App info extracted from `ceramic.yml`',
            meta: [{
                name: ':dox',
                params: [macro hide],
                pos: Context.currentPos()
            }]
        });

        #if ceramic_debug_macro
        trace(Context.getLocalClass() + ' -> END AppMacro.build()');
        #end

        return fields;

    }

    static function computeInfo(rawInfo:String):Dynamic {

        var data:Dynamic = {};

        if (rawInfo != null) {
            // AppMacro.rawInfo can be null when running stuff like "go to definition" from compiler
            data = convertArrays(Json.parse(Json.parse(rawInfo)));
        }

        // Add required info
        if (data.collections == null) data.collections = {};

        return data;

    }

    static function convertArrays(data:Dynamic):Dynamic {

        var newData:Dynamic = {};

        for (key in Reflect.fields(data)) {

            var val:Dynamic = Reflect.field(data, key);

            if (Std.isOfType(val, Array)) {
                var items:Dynamic = {};
                var list:Array<Dynamic> = val;
                var i = 0;
                for (item in list) {
                    Reflect.setField(items, 'item$i', item);
                    i++;
                }
                Reflect.setField(newData, key, items);
            }
            else if (val == null || Std.isOfType(val, String) || Std.isOfType(val, Int) || Std.isOfType(val, Float) || Std.isOfType(val, Bool)) {
                Reflect.setField(newData, key, val);
            }
            else {
                Reflect.setField(newData, key, convertArrays(val));
            }

        }

        return newData;

    }

}
