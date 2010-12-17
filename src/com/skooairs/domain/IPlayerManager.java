package com.skooairs.domain;

import java.util.List;

import com.skooairs.entities.Board;
import com.skooairs.entities.Player;

public interface IPlayerManager {

	public boolean existFacebookPlayer(String facebookUID);
	public Player createPlayer(String playerUID);
	
	public Player getPlayer(String uralysUID);
	public Player getFacebookPlayer(String facebookUID);
	public List<String> getFriendPlayerUIDs(List<String> facebookIds);

	public void refreshLastLog(String playerUID);
	
	public void setTransactionMillis(String playerUID, Long dateMillis);
	
	public int getRecord(String uralysUID, int time, int colors);
	public void storeRecord(String uralysUID, String surname, int time, int colors, int points);
	public List<Board> getBoard(String uralysUID, int time, int colors, List<String> friendUIDs);
	
	public boolean changeMusicOn(String uralysUID, boolean musicOn);
	
}
