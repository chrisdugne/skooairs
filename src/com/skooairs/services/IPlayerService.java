package com.skooairs.services;

import java.util.List;

import com.skooairs.entities.Board;
import com.skooairs.entities.Player;

public interface IPlayerService {

	public void refreshLastLog(String uralysUID);
	public void setTransactionMillis(String uralysUID, Long dateMillis);

	public boolean existFacebookPlayer(String facebookUID);
	public Player createPlayer(String uralysUID);
	
	public Player getPlayer(String uralysUID);
	public Player getFacebookPlayer(String facebookUID);
	public List<String> getFriendPlayerUIDs(List<String> facebookIds);

	//==================================================================================================//
	
	public boolean changeMusicOn(String uralysUID, boolean musicOn);

	//==================================================================================================//

	public int getFriendPosition(String uralysUID);
	public int getWorldPosition(String uralysUID);

	//==================================================================================================//
	
	public int getRecord(String uralysUID, int time, int colors);
	public void storeRecord(String uralysUID, String surname, int time, int colors, int points);
	
	//==================================================================================================//

	public List<Board> getBoard(String uralysUID, int time, int colors, List<String> friendUIDs);
}
