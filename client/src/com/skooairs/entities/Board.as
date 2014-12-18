package com.skooairs.entities
{

[Bindable]
[RemoteClass(alias="com.skooairs.entities.Board")]
public class Board
{
	public function Board(){}


	public function get boardUID():String {
		return _boardUID;
	}

	public function set boardUID(o:String):void {
		_boardUID = o;
	}

	public function get time():int {
		return _time;
	}

	public function set time(o:int):void {
		_time = o;
	}

	public function get colors():int {
		return _colors;
	}

	public function set colors(o:int):void {
		_colors = o;
	}

	public function get playerUID():String {
		return _playerUID;
	}

	public function set playerUID(o:String):void {
		_playerUID = o;
	}

	public function get points():int {
		return _points;
	}

	public function set points(o:int):void {
		_points = o;
	}
	
	public function get surname():String {
		return _surname;
	}

	public function set surname(o:String):void {
		_surname = o;
	}

	protected var _boardUID:String;
	protected var _time:int;
	protected var _colors:int;
	protected var _playerUID:String;
	protected var _surname:String;
	protected var _points:int;

	public function toString():String{
		var toString:String = "";

		toString += ("boardUID : " + _boardUID) + "\n";
		toString += ("time : " + _time) + "\n";
		toString += ("colors : " + _colors) + "\n";
		toString += ("playerUID : " + _playerUID) + "\n";
		toString += ("surname : " + _surname) + "\n";
		toString += ("points : " + _points) + "\n";

		return toString;
	}

	
}
}