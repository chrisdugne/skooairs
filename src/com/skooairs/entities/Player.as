package com.skooairs.entities
{

[Bindable]
[RemoteClass(alias="com.skooairs.entities.Player")]
public class Player
{
	public function Player(){}



	public function get uralysUID():String {
		return _uralysUID;
	}

	public function set uralysUID(o:String):void {
		_uralysUID = o;
	}

	public function get surname():String {
		return _surname;
	}

	public function set surname(o:String):void {
		_surname = o;
	}

	public function get points():int {
		return _points;
	}

	public function set points(o:int):void {
		_points = o;
	}

	public function get lastLog():Number {
		return _lastLog;
	}

	public function set lastLog(o:Number):void {
		_lastLog = o;
	}
	
	public function get premium():Boolean {
		return _premium;
	}
	public function set premium(o:Boolean):void {
		_premium = o;
	}
	
	public function get facebookUID():String {
		return _facebookUID;
	}
	
	public function set facebookUID(o:String):void {
		_facebookUID = o;
	}
	
	public function get musicOn():Boolean {
		return _musicOn;
	}
	
	public function set musicOn(o:Boolean):void {
		_musicOn = o;
	}
	
	protected var _uralysUID:String;
	protected var _facebookUID:String;
	protected var _surname:String;
	protected var _premium:Boolean;
	protected var _points:int;
	protected var _musicOn:Boolean;
	protected var _lastLog:Number;

}
}

