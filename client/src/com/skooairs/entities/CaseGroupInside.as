package com.skooairs.entities
{

/*
CaseGroupInside : un CaseGroup, mais utilise pour connaitre les 'boomers' : cases qui sont coincees dans un encadrement.
*/
[Bindable]
public class CaseGroupInside extends CaseGroup
{

	public static var FREE:int = 1;
	public static var TO_EXPLODE:int = 2;
	
	//-----------------------------------------------------------------------------------//

	protected var _status:int = TO_EXPLODE; 
	
	//-----------------------------------------------------------------------------------//

	public function CaseGroupInside(){
		_cases = [];
		placement = [[],[],[],[],[],[],[],[],[]];
	}

	//-----------------------------------------------------------------------------------//

	public function get status():int {
		return _status;
	}

	public function set status(o:int):void {
		_status = o;
	}

}
}

