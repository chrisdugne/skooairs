

import com.skooairs.entities.Board;

	//-----------------------------------------------------------------------------------//
	[Bindable]	public function get board():Board {
		return _board;
	}

	public function set board(o:Board):void {
		_board = o;
	}

	protected var _board:Board;

	//-----------------------------------------------------------------------------------//
