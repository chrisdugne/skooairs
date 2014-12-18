package com.skooairs.entities
{

/*
Line : represente une ligne de case (au moins 2), 
	statut verticale ou horizontale
*/
[Bindable]
public class Line
{

	//-----------------------------------------------------------------------------------//

	public static var VERTICAL:int = 1; 
	public static var HORIZONTAL:int = 2; 
	
	//-----------------------------------------------------------------------------------//

	protected var _xFrom:int;
	protected var _yFrom:int;
	protected var _xTo:int;
	protected var _yTo:int;
	protected var _status:int;  // VERTICAL/HORIZONTAL
	
	//-----------------------------------------------------------------------------------//

	public function Line(xFrom:int, yFrom:int, xTo:int, yTo:int, status:int){
		_xFrom = xFrom;
		_yFrom = yFrom;
		_xTo = xTo;
		_yTo = yTo;
		_status = status;
	}

	//-----------------------------------------------------------------------------------//
	

	public function get xFrom():int {
		return _xFrom;
	}

	public function set xFrom(o:int):void {
		_xFrom = o;
	}

	public function get yFrom():int {
		return _yFrom;
	}

	public function set yFrom(o:int):void {
		_yFrom = o;
	}

	public function get xTo():int {
		return _xTo;
	}

	public function set xTo(o:int):void {
		_xTo = o;
	}

	public function get yTo():int {
		return _yTo;
	}

	public function set yTo(o:int):void {
		_yTo = o;
	}

	public function get status():int {
		return _status;
	}

	public function set status(o:int):void {
		_status = o;
	}
	
	public function toString():String{
		var toString:String = "";

		toString += ("xFrom : " + _xFrom) + "\n";
		toString += ("yFrom : " + _yFrom) + "\n";
		toString += ("xTo : " + _xTo) + "\n";
		toString += ("yTo : " + _yTo) + "\n";
		toString += ("status : " + _status) + "\n";

		return toString;
	}


	//-----------------------------------------------------------------------------------//



}
}

