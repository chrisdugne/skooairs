package com.skooairs.services.impl;

import java.util.List;

import com.skooairs.domain.IPlayerManager;
import com.skooairs.entities.Board;
import com.skooairs.entities.Player;
import com.skooairs.services.IPlayerService;

public class PlayerService extends Service implements IPlayerService{

	//=========================================================================//
	
	private IPlayerManager playerManager;

	public PlayerService (IPlayerManager playerManager){
		this.playerManager = playerManager;
	}

	//=========================================================================//

	public boolean existFacebookPlayer(String facebookUID) {
		return playerManager.existFacebookPlayer(facebookUID);
	}

	public boolean createPlayer(String uralysUID) {
		return playerManager.createPlayer(uralysUID);
	}

	public Player getFacebookPlayer(String facebookUID) {
		return playerManager.getFacebookPlayer(facebookUID);
	}
	
	public Player getPlayer(String uralysUID) {
		return playerManager.getPlayer(uralysUID);
	}

	//=========================================================================//

	public void refreshLastLog(String uralysUID) {
		System.out.println("refreshLastLog " + uralysUID);
		playerManager.refreshLastLog(uralysUID);		
	}

	public void setTransactionMillis(String uralysUID, Long dateMillis) {
		playerManager.setTransactionMillis(uralysUID, dateMillis);
	}

	//==================================================================================================//

	public int getFriendPosition(String uralysUID) {		return -111;
	}

	public int getWorldPosition(String uralysUID) {
		return -111;
	}

	//==================================================================================================//

	public int getRecord(String uralysUID, int time, int colors) {
		return playerManager.getRecord(uralysUID, time, colors);
	}

	public void storeRecord(String uralysUID, String surname, int time, int colors, int points) {
		playerManager.storeRecord(uralysUID, surname, time, colors, points);
	}

	public List<Board> getBoard(String uralysUID, int time, int colors, List<String> friendUIDs) {
		return playerManager.getBoard(uralysUID, time, colors, friendUIDs);
	}

	public List<String> getFriendPlayerUIDs(List<String> facebookIds) {
		return playerManager.getFriendPlayerUIDs(facebookIds);
	}

}
