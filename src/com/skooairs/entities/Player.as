package com.skooairs.entities
{

[Bindable]
[RemoteClass(alias="com.skooairs.entities.Player")]
public class Player
{
	public function Player(){}



	public function get playerUID():String {
		return _playerUID;
	}

	public function set playerUID(o:String):void {
		_playerUID = o;
	}

	public function get surname():String {
		return _surname;
	}

	public function set surname(o:String):void {
		_surname = o;
	}

	public function get facebookUID():String {
		return _facebookUID;
	}

	public function set facebookUID(o:String):void {
		_facebookUID = o;
	}

	public function get email():String {
		return _email;
	}

	public function set email(o:String):void {
		_email = o;
	}
	public function get language():int {
		return _language;
	}

	public function set language(o:int):void {
		_language = o;
	}

	public function get musicOn():Boolean {
		return _musicOn;
	}

	public function set musicOn(o:Boolean):void {
		_musicOn = o;
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

	protected var _playerUID:String;
	protected var _surname:String;
	protected var _facebookUID:String;
	protected var _email:String;
	protected var _language:int;
	protected var _musicOn:Boolean;
	protected var _premium:Boolean;
	protected var _points:int;
	protected var _lastLog:Number;


	public function toString():String{
		var toString:String = "";

		toString += ("playerUID : " + _playerUID) + "\n";
		toString += ("surname : " + _surname) + "\n";
		toString += ("facebookUID : " + _facebookUID) + "\n";
		toString += ("email : " + _email) + "\n";
		toString += ("language : " + _language) + "\n";
		toString += ("musicOn : " + _musicOn) + "\n";
		toString += ("premium : " + _premium) + "\n";
		toString += ("points : " + _points) + "\n";
		toString += ("lastLog : " + _lastLog) + "\n";

		return toString;
	}




}
}

