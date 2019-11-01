package;

import flixel.math.FlxPoint;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;

using flixel.util.FlxSpriteUtil;
using Math;
using zero.flixel.extensions.FlxPointExt;

class PlayState extends FlxState
{

	var rubber:Rubber;
	var ground:FlxSprite;

	override public function create():Void
	{
		super.create();

		ground = new FlxSprite(0, FlxG.height - 32);
		ground.makeGraphic(FlxG.width, 32);
		ground.immovable = true;
		add(ground);
		add(rubber = new Rubber());
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		FlxG.collide(ground, rubber);
	}
}

class Rubber extends FlxSprite
{

	static var climb_time:Float = 1;
	static var gravity:Float = 600;

	var climb_timer:Float = 0;
	var can_climb:Bool = true;
	var spin_amt:Float;
	var last_mouse_y:Float;

	public function new() {
		super(FlxG.width/2 - 64, FlxG.height/2);
		makeGraphic(64, 64, 0x00FFFFFF);
		this.drawCircle(-1, -1, 30);
		for (i in 0...16) {
			var p = FlxPoint.get(32, 32).place_on_circumference((360/16)*i, 28);
			this.drawCircle(p.x, p.y, 4);
		}
		for (i in 0...6) {
			var p = FlxPoint.get(32, 32).place_on_circumference((360/6)*i, 8);
			this.drawCircle(p.x, p.y, 4, 0xFF000000);
		}
		elasticity = 1;
	}

	override function update(elapsed:Float) {
		if (justTouched(FlxObject.FLOOR)) can_climb = true;
		if (FlxG.mouse.justPressed && can_climb) {
			climb_timer = climb_time;
			velocity.y = (velocity.y/2).max(-100);
			can_climb = false;
			last_mouse_y = FlxG.mouse.y;
		}
		if (FlxG.mouse.pressed && climb_timer > 0) {
			climb_timer -= elapsed;
			if (FlxG.mouse.y - last_mouse_y > 64) {
				climb_timer = 0;
				velocity.y = 800;
			}
		}
		if (FlxG.mouse.justReleased) climb_timer = 0;
		acceleration.y = climb_timer > 0 ? -gravity/4 : gravity;
		spin_amt = climb_timer > 0 ? 500 : 250;
		super.update(elapsed);
		angularVelocity += (spin_amt - angularVelocity) * 0.1;
		velocity.y = velocity.y.max(-500);
	}

}