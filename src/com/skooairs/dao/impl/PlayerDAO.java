package com.skooairs.dao.impl;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import javax.jdo.PersistenceManager;
import javax.jdo.Query;

import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.skooairs.dao.IPlayerDAO;
import com.skooairs.entities.dto.BoardDTO;
import com.skooairs.entities.dto.PlayerDTO;
import com.skooairs.entities.dto.TransactionDTO;
import com.skooairs.utils.Utils;


public class PlayerDAO extends MainDAO implements IPlayerDAO{
	
	public boolean existFacebookPlayer(String facebookUID) {
		return getFacebookPlayer(facebookUID) != null;
	}

	public PlayerDTO createPlayer(String uralysUID) {
		
		PlayerDTO player = new PlayerDTO();
		Key key = KeyFactory.createKey(PlayerDTO.class.getSimpleName(), uralysUID);
		
		player.setKey(KeyFactory.keyToString(key));
		player.setUralysUID(uralysUID);
		player.setFacebookUID("NO");

		player.setPremium(false);
		player.setPoints(0);
		
		player.setSurname("New Player");
		player.setMusicOn(true);
		
		player.setLastLog(new Date().getTime());

		persist(player);
		
		return player;
	}
	
	public PlayerDTO getPlayer(String uralysUID) {
		return super.getPlayer(uralysUID);
	}

	@SuppressWarnings("unchecked")
	public List<String> getFriendPlayerUIDs(List<String> facebookIds) {
		
		PersistenceManager pm = PMF.getInstance().getPersistenceManager();
		Query q = pm.newQuery("select from " + PlayerDTO.class.getName() + " where :keys.contains(facebookUID)");
		
		List<PlayerDTO> players;
		
		try{
			players = (List<PlayerDTO>) q.execute(facebookIds);
			System.out.println("friendsplayers found");
			if(players != null){
				System.out.println(players.size() + " players");
			}
			else{
				System.out.println("players == null : " + players == null);
				return null;
			}
			
		}
		catch(Exception e){
			e.printStackTrace();
			players = new ArrayList<PlayerDTO>();
		}
		
		List<String> uralysUIDs = new ArrayList<String>();
		
		for(PlayerDTO _p : players)
			uralysUIDs.add(_p.getUralysUID());

		return uralysUIDs;
	}
	
		

	/**
	 * NOT USED IN SKOOAIRS : lastLog is refreshed when calling MainDAO.getFacebookUser() 
	 */
	public void refreshLastLog(String uralysUID) {
		PersistenceManager pm = PMF.getInstance().getPersistenceManager();
		PlayerDTO player =  pm.getObjectById(PlayerDTO.class, uralysUID);
		
		player.setLastLog(new Date().getTime());
		
		pm.close();
		
	}

	public void setPremium(String uralysUID, Long transactionMillis) {		
		PersistenceManager pm = PMF.getInstance().getPersistenceManager();
		PlayerDTO player =  pm.getObjectById(PlayerDTO.class, uralysUID);
		
		player.setPremium(true);
		pm.close();
		
		TransactionDTO transaction = new TransactionDTO();
		String transactionUID = Utils.generateUID();
		Key key = KeyFactory.createKey(TransactionDTO.class.getSimpleName(), transactionUID);
		
		transaction.setKey(KeyFactory.keyToString(key));
		transaction.setTransactionUID(transactionUID);
		transaction.setUralysUID(uralysUID);
		transaction.setTransactionMillis(transactionMillis);
		
		persist(transaction);
	}

	public void setTransactionMillis(String uralysUID, Long dateMillis) {
		PersistenceManager pm = PMF.getInstance().getPersistenceManager();
		PlayerDTO player =  pm.getObjectById(PlayerDTO.class, uralysUID);
		
		player.setLastTransactionMillis(dateMillis);
		
		pm.close();
	}


	public int getRecord(String uralysUID, int time, int colors) {
		PersistenceManager pm = PMF.getInstance().getPersistenceManager();
		Query q = pm.newQuery("select from " + BoardDTO.class.getName() + " where uralysUID == :fbUID " +
																			"&& time == :time " +
																			"&& colors == :colors");
		q.setUnique(true);
		
		BoardDTO boardEntry = (BoardDTO) q.execute(uralysUID, time, colors);
		
		if(boardEntry == null)
			return 0;
		else
			return boardEntry.getPoints();
	}

	
	public void storeRecord(String uralysUID, String surname, int time, int colors, int points) {
		PersistenceManager pm = PMF.getInstance().getPersistenceManager();
		Query q = pm.newQuery("select from " + BoardDTO.class.getName() + " where uralysUID == :fbUID " +
																			"&& time == :time " +
																			"&& colors == :colors");
		q.setUnique(true);
		
		BoardDTO boardEntry = (BoardDTO) q.execute(uralysUID, time, colors);
		
		if(boardEntry == null){
			boardEntry = new BoardDTO();
			String boardUID = Utils.generateUID();
			Key key = KeyFactory.createKey(BoardDTO.class.getSimpleName(), boardUID);
			
			boardEntry.setKey(KeyFactory.keyToString(key));
			boardEntry.setBoardUID(boardUID);
			boardEntry.setUralysUID(uralysUID);
			boardEntry.setTime(time);
			boardEntry.setColors(colors);
			boardEntry.setPoints(points);
			boardEntry.setSurname(surname);
			
			pm.makePersistent(boardEntry);
		}
		else{
			boardEntry.setPoints(points);
		}


		PlayerDTO player =  pm.getObjectById(PlayerDTO.class, uralysUID);
		player.setSurname(surname);

		pm.close();
	}

	@SuppressWarnings("unchecked")
	public List<BoardDTO> getBoard(int time, int colors) {
		
		PersistenceManager pm = PMF.getInstance().getPersistenceManager();
		Query q = pm.newQuery("select from " + BoardDTO.class.getName() + " where time == :time " +
																			"&& colors == :colors");
		
		q.setOrdering("points descending");
		q.setRange(0,100);
		
		return (List<BoardDTO>) q.execute(time, colors);
		
	}

	@SuppressWarnings("unchecked")
	public List<BoardDTO> getBoard(String uralysUID, int time, int colors, List<String> friendUIDs) {
		
		
		PersistenceManager pm = PMF.getInstance().getPersistenceManager();
		Query q = pm.newQuery("select from " + BoardDTO.class.getName() + " where :keys.contains(uralysUID) " +
																			"&& time == :time " +
																			"&& colors == :colors");
		q.setOrdering("points descending");
		q.setRange(0,100);
		
		
		List<String> uids = new ArrayList<String>();
		uids.addAll(friendUIDs);
		uids.add(uralysUID);
		
		try{
			return (List<BoardDTO>) q.execute(uids, time, colors);
		}catch(Exception e){

			System.out.println("-----------------------------------");
			System.out.println("problem with getBoard for friends");
			System.out.println("friendUIDs size : " + friendUIDs.size());
			System.out.println("-----------------------------------");
			e.printStackTrace();
			return new ArrayList<BoardDTO>();
		}
		
	}

	public boolean changeMusicOn(String playerUID, boolean musicOn) {
		PersistenceManager pm = PMF.getInstance().getPersistenceManager();
		PlayerDTO player =  pm.getObjectById(PlayerDTO.class, playerUID);
		
		player.setMusicOn(musicOn);
		
		pm.close();
		return true;
	}
}
