package funkin.editors.ui;

import funkin.editors.ui.UIContextMenu.UIContextMenuCallback;
import openfl.ui.Mouse;
import funkin.editors.ui.UIContextMenu.UIContextMenuOption;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;

class UIState extends MusicBeatState {

    public var curContextMenu:UIContextMenu = null;

    public static var state(get, null):UIState;

    public var buttonHandler:Void->Void = null;
    public var hoveredSprite:UISprite = null;

    private var __rect:FlxRect;
    private var __mousePos:FlxPoint;

    private inline static function get_state()
        return FlxG.state is UIState ? cast FlxG.state : null;

    public override function create() {
        __rect = new FlxRect();
        __mousePos = FlxPoint.get();
        super.create();
    }

    public function updateButtonHandler(spr:UISprite, buttonHandler:Void->Void) {
        spr.__rect.x = spr.x;
        spr.__rect.y = spr.y;
        spr.__rect.width = spr.width;
        spr.__rect.height = spr.height;
        updateRectButtonHandler(spr, spr.__rect, buttonHandler);
    }

    public function updateRectButtonHandler(spr:UISprite, rect:FlxRect, buttonHandler:Void->Void) {
        
        
        for(camera in spr.__lastDrawCameras) {
			var pos = FlxG.mouse.getScreenPosition(camera, FlxPoint.get());
            __rect.x = rect.x;
            __rect.y = rect.y;
            __rect.width = rect.width;
            __rect.height = rect.height;
            
            __rect.x -= camera.scroll.x * spr.scrollFactor.x;
            __rect.y -= camera.scroll.y * spr.scrollFactor.y;
            
            if (((pos.x > __rect.x) && (pos.x < __rect.x + rect.width)) && ((pos.y > __rect.y) && (pos.y < __rect.y + __rect.height))) {
                spr.hoveredByChild = true;
                this.hoveredSprite = spr;
                this.buttonHandler = buttonHandler;
				pos.put();
                return;
            }
			pos.put();
        }
    }

    public override function tryUpdate(elapsed:Float) {
		FlxG.mouse.getScreenPosition(FlxG.camera, __mousePos);

        super.tryUpdate(elapsed);

        if (buttonHandler != null) {
            buttonHandler();
            buttonHandler = null;
        }

        if (hoveredSprite != null) {
            Mouse.cursor = hoveredSprite.cursor;
            hoveredSprite = null;
        } else {
            Mouse.cursor = ARROW;
        }
    }

    public override function destroy() {
        super.destroy();
        __mousePos.put();
    }

    public function openContextMenu(options:Array<UIContextMenuOption>, ?callback:UIContextMenuCallback, ?x:Float, ?y:Float) {
        var state = FlxG.state;
        while(state.subState != null)
            state = state.subState;

        state.persistentDraw = true;
        state.persistentUpdate = true;

        openSubState(curContextMenu = new UIContextMenu(options, callback, x.getDefault(__mousePos.x), y.getDefault(__mousePos.y)));
        return curContextMenu;
    }
}