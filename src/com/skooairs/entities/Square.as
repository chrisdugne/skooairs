package com.skooairs.entities
{

/*
Square : il y en a 3 : next, waiting et current
status : CONSTRUCTOR (devient une Case) ou DESTRUCTOR (appel au SquareExploder pour gerer la destruction)
le Square est mis dans le data d'une Image de Square, laquelle est mise dans une Case si cette case est FULL
*/
[Bindable]
public class Square
{

	//-----------------------------------------------------------------------------------//

	protected var _color:int; 
	protected var _status:int; // CONSTRUCTOR ou DESTRUCTOR
	
	//-----------------------------------------------------------------------------------//

	public function Square(color:int, status:int){
		_color = color;
		_status = status;
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
	public function toString():String{
		var toString:String = "";

		toString += ("color : " + _color) + "\n";
		toString += ("status : " + _status) + "\n";

		return toString;
	}

	//-----------------------------------------------------------------------------------//



}
}

