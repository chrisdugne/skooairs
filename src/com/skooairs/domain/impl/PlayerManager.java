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

	public Player createPlayer(String uralysUID) {
		return convertPlayerDTO(playerDao.createPlayer(uralysUID));
	}

	public Player getPlayer(String uralysUID) {
		System.out.println("domain.getPlayer " + uralysUID);
		return convertPlayerDTO(playerDao.getPlayer(uralysUID));
	}

	public Player getFacebookPlayer(String facebookUID) {
		return convertPlayerDTO(playerDao.getFacebookPlayer(facebookUID));
	}
	
	public void refreshLastLog(String uralysUID) {
		playerDao.refreshLastLog(uralysUID);
	}

	public void setTransactionMillis(String uralysUID, Long dateMillis) {
		playerDao.setTransactionMillis(uralysUID, dateMillis);
	}


	public int getRecord(String uralysUID, int time, int colors) {
		return playerDao.getRecord(uralysUID, time, colors);
	}
	
	public void storeRecord(String uralysUID, String surname, int time, int colors, int points) {
		playerDao.storeRecord(uralysUID, surname, time, colors, points);
	}

	public List<Board> getBoard(String uralysUID, int time, int colors,	List<String> friendUIDs) {
		
		List<Board> boards = new ArrayList<Board>();
		
		List<BoardDTO> boardsDTO;
		
		if(friendUIDs == null){
			boardsDTO = playerDao.getBoard(time, colors);
		}
		else{
			boardsDTO = playerDao.getBoard(uralysUID, time, colors, friendUIDs);			
		}
		
		for(BoardDTO boardDTO : boardsDTO){
			boards.add(convertBoardDTO(boardDTO));
		}
		
		return boards;
	}

	public List<String> getFriendPlayerUIDs(List<String> facebookIds) {
		try{
			return playerDao.getFriendPlayerUIDs(facebookIds);
		}
		catch(Exception e){
			e.printStackTrace();
			return null;
		}
	}

	public boolean changeMusicOn(String uralysUID, boolean musicOn) {
		return playerDao.changeMusicOn(uralysUID, musicOn);
	}
	
	//==================================================================================================//
	
	public static Player convertPlayerDTO(PlayerDTO playerDTO) {
		
		Player player = new Player();
		
		player.setUralysUID(playerDTO.getUralysUID());
		player.setFacebookUID(playerDTO.getFacebookUID());
		player.setSurname(playerDTO.getSurname());
		
		player.setPoints(playerDTO.getPoints());
		player.setLastLog(playerDTO.getLastLog());
		player.setPremium(playerDTO.getPremium());
		player.setMusicOn(playerDTO.getMusicOn());
		
		return player;
	}

	private Board convertBoardDTO(BoardDTO boardDTO) {
		Board board = new Board();
		
		board.setBoardUID(boardDTO.getBoardUID());
		board.setPlayerUID(boardDTO.getUralysUID());
		board.setColors(boardDTO.getColors());
		board.setPoints(boardDTO.getPoints());
		board.setSurname(boardDTO.getSurname());
		board.setTime(boardDTO.getTime());
		
		return board;
	}

	
	
	
	
	
	
	
	
	

}
