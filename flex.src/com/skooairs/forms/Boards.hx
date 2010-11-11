

import com.skooairs.core.Pager;
import com.skooairs.core.MusicPlayer;
import com.skooairs.utils.Utils;

import com.skooairs.constants.Session;
import com.skooairs.constants.Names;
import com.skooairs.constants.Numbers;
import com.skooairs.constants.Translations;

import com.skooairs.entities.Board;

import mx.rpc.events.ResultEvent;
import mx.rpc.events.FaultEvent;

import components.BoardLine;

	//-----------------------------------------------------------------------------------//

	[Bindable] private static var worldPosition:int;
	[Bindable] private static var friendPosition:int;

	//-----------------------------------------------------------------------------------//

	[Bindable] private var selectedTime:int = 2;
	[Bindable] private var selectedColors:int = 3;
	[Bindable] private var selectedGroup:int = 1;

	[Bindable] private var lock:Boolean = false;
			 
	//-----------------------------------------------------------------------------------//

	public function refresh():void{
		lock = true;
		
		playerWrapper.getBoard(Session.player.playerUID, selectedTime, selectedColors, selectedGroup == 2 ? Session.friendPlayerUIDs : null);
	}
	
	private function onGetBoard(event:ResultEvent):void{
		boardContainer.removeAllElements();
		
		for each(var board:Board in event.result){
			
			var boardLine:BoardLine = new BoardLine();
			boardLine.board = board;
			
			boardContainer.addElement(boardLine);
		}
		
		lock = false;
	}

	private function faultGetBoard(event:FaultEvent):void{
		trace(event.fault);
	}


