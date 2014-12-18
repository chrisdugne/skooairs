package com.skooairs.entities
{

import mx.controls.Image;

/*
Case du plateau : vide ou pleine, elle a une couleur si elle est pleine.
*/
[Bindable]
public class Case
{

	//-----------------------------------------------------------------------------------//

	public static var EMPTY:int = 1; 
	public static var FULL:int = 2; 
	
	//-----------------------------------------------------------------------------------//

	protected var _color:int;
	protected var _status:int;
	protected var _x:int;
	protected var _y:int;

	protected var _image:Image;

	
	//-----------------------------------------------------------------------------------//

	public function Case(i:int, j:int){
		_status = EMPTY;
		_color = 0;
		_x = i;
		_y = j;
	}

	//-----------------------------------------------------------------------------------//
	
	public function fill(image:Image):void {
		_color = image.data.color;
		_image = image;
		_status = FULL;
	}
	
	//-----------------------------------------------------------------------------------//

	public function get color():int {
		return _color;
	}

	public function set color(o:int):void {
		_color = o;
	}

	public function get status():int {
		return _status;
	}

	public function set status(o:int):void {
		_status = o;
	}

	public function get image():Image {
		return _image;
	}

	public function set image(o:Image):void {
		_image = o;
	}
	
	public function get x():int {
		return _x;
	}

	public function set x(o:int):void {
		_x = o;
	}

	public function get y():int {
		return _y;
	}

	public function set y(o:int):void {
		_y = o;
	}

	
	public function toString():String{
		var toString:String = "";

		toString += ("color : " + _color) + "\n";
		toString += ("status : " + _status) + "\n";
		toString += ("x : " + _x) + "\n";
		toString += ("y : " + _y) + "\n";

		return toString;
	}

	//-----------------------------------------------------------------------------------//



}
}

