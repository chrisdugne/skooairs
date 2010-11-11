package com.skooairs.domain.impl;

import java.util.ArrayList;
import java.util.List;

import com.skooairs.dao.IPlayerDAO;
import com.skooairs.domain.IPlayerManager;
import com.skooairs.entities.Board;
import com.skooairs.entities.Player;
import com.skooairs.entities.dto.BoardDTO;
import com.skooairs.entities.dto.PlayerDTO;

public class PlayerManager implements IPlayerManager{
	
	//==================================================================================================//
	
	private IPlayerDAO playerDao;

	public PlayerManager (IPlayerDAO playerDao){
		this.playerDao = playerDao;
	}

	//==================================================================================================//

	public boolean existFacebookPlayer(String facebookUID) {
		return playerDao.existFacebookPlayer(facebookUID);
	}

	public boolean createPlayer(int type, String playerUID) {
		return playerDao.createPlayer(type, playerUID);
	}

	public Player getPlayer(String playerUID) {
		return convertPlayerDTO(playerDao.getPlayer(playerUID));
	}

	public Player getFacebookPlayer(String facebookUID) {
		return convertPlayerDTO(playerDao.getFacebookPlayer(facebookUID));
	}
	
	public boolean changeLanguage(String playerUID, int language) {
		return playerDao.changeLanguage(playerUID, language);
	}

	public boolean changeMusicOn(String playerUID, boolean musicOn) {
		return playerDao.changeMusicOn(playerUID, musicOn);
	}
	

	public void refreshLastLog(String playerUID) {
		playerDao.refreshLastLog(playerUID);
	}

	public void setTransactionMillis(String playerUID, Long dateMillis) {
		playerDao.setTransactionMillis(playerUID, dateMillis);
	}


	public int getRecord(String playerUID, int time, int colors) {
		return playerDao.getRecord(playerUID, time, colors);
	}
	
	public void storeRecord(String playerUID, String surname, int time, int colors, int points) {
		playerDao.storeRecord(playerUID, surname, time, colors, points);
	}

	public List<Board> getBoard(String playerUID, int time, int colors,	List<String> friendUIDs) {
		
		List<Board> boards = new ArrayList<Board>();
		
		List<BoardDTO> boardsDTO;
		
		if(friendUIDs == null){
			boardsDTO = playerDao.getBoard(time, colors);
		}
		else{
			boardsDTO = playerDao.getBoard(playerUID, time, colors, friendUIDs);			
		}
		
		for(BoardDTO boardDTO : boardsDTO){
			boards.add(convertBoardDTO(boardDTO));
		}
		
		return boards;
	}

	public List<String> getFriendPlayerUIDs(List<String> facebookIds) {
		return playerDao.getFriendPlayerUIDs(facebookIds);
	}
	//==================================================================================================//
	
	public static Player convertPlayerDTO(PlayerDTO playerDTO) {
		
		Player player = new Player();
		
		player.setPlayerUID(playerDTO.getPlayerUID());
		player.setSurname(playerDTO.getSurname());
		
		player.setFacebookUID(playerDTO.getFacebookUID());
		player.setEmail(playerDTO.getEmail());
		player.setPoints(playerDTO.getPoints());

		player.setLanguage(playerDTO.getLanguage());
		player.setMusicOn(playerDTO.getMusicOn());
		player.setLastLog(playerDTO.getLastLog());
		
		player.setPremium(playerDTO.getPremium());
		
		
		return player;
	}

	private Board convertBoardDTO(BoardDTO boardDTO) {
		Board board = new Board();
		
		board.setBoardUID(boardDTO.getBoardUID());
		board.setPlayerUID(boardDTO.getPlayerUID());
		board.setColors(boardDTO.getColors());
		board.setPoints(boardDTO.getPoints());
		board.setSurname(boardDTO.getSurname());
		board.setTime(boardDTO.getTime());
		
		return board;
	}

	
	
	
	
	
	
	
	
	

}
