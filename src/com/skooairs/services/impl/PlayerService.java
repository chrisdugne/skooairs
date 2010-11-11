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

	public boolean createPlayer(int type, String playerUID) {
		return playerManager.createPlayer(type, playerUID);
	}

	public Player getFacebookPlayer(String facebookUID) {
		return playerManager.getFacebookPlayer(facebookUID);
	}
	
	public Player getPlayer(String playerUID) {
		return playerManager.getPlayer(playerUID);
	}

	public boolean changeLanguage(String playerUID, int language) {
		return playerManager.changeLanguage(playerUID, language);
	}

	//=========================================================================//

	public void refreshLastLog(String playerUID) {
		System.out.println("refreshLastLog " + playerUID);
		playerManager.refreshLastLog(playerUID);		
	}

	public void setTransactionMillis(String playerUID, Long dateMillis) {
		playerManager.setTransactionMillis(playerUID, dateMillis);
	}

	public boolean changeMusicOn(String playerUID, boolean musicOn) {
		return playerManager.changeMusicOn(playerUID, musicOn);
	}

	//==================================================================================================//


	public int getFriendPosition(String playerUID) {		return -111;
	}

	public int getWorldPosition(String playerUID) {
		return -111;
	}

	//==================================================================================================//

	public int getRecord(String playerUID, int time, int colors) {
		return playerManager.getRecord(playerUID, time, colors);
	}

	public void storeRecord(String playerUID, String surname, int time, int colors, int points) {
		playerManager.storeRecord(playerUID, surname, time, colors, points);
	}

	public List<Board> getBoard(String playerUID, int time, int colors, List<String> friendUIDs) {
		return playerManager.getBoard(playerUID, time, colors, friendUIDs);
	}

	public List<String> getFriendPlayerUIDs(List<String> facebookIds) {
		return playerManager.getFriendPlayerUIDs(facebookIds);
	}

}
