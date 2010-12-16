package com.skooairs.dao;

import java.util.List;

import com.skooairs.entities.dto.BoardDTO;
import com.skooairs.entities.dto.PlayerDTO;

public interface IPlayerDAO {

	public boolean existFacebookPlayer(String playerUID);
	public boolean createPlayer(String playerUID);
	
	public PlayerDTO getPlayer(String uralysUID);
	public PlayerDTO getFacebookPlayer(String facebookUID);
	
	public void refreshLastLog(String playerUID);
	
	public void setTransactionMillis(String playerUID, Long dateMillis);

	public int getRecord(String playerUID, int time, int colors);
	public void storeRecord(String playerUID, String surname, int time, int colors, int points);
	
	public List<BoardDTO> getBoard(String playerUID, int time, int colors, List<String> friendUIDs);
	public List<BoardDTO> getBoard(int time, int colors);
	public List<String> getFriendPlayerUIDs(List<String> facebookIds);

}
