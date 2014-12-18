package com.skooairs.dao.impl;

import java.util.Date;
import java.util.logging.Logger;

import javax.jdo.PersistenceManager;
import javax.jdo.Query;
import javax.jdo.Transaction;

import com.skooairs.entities.dto.PlayerDTO;


public class MainDAO {

	protected static final Logger log = Logger.getLogger(MainDAO.class.getName());
	
	//==================================================================================================//
	
	protected void persist(Object o) {
		PersistenceManager pm = PMF.getInstance().getPersistenceManager();
		Transaction tx = pm.currentTransaction();
		
		try {
			tx.begin();
			pm.makePersistent(o);
			tx.commit();
		} 
		finally {        
			if (tx.isActive()) 
				tx.rollback();
			
			pm.close();
		}
	}

	public PlayerDTO getPlayer(String uralysUID) {
		PersistenceManager pm = PMF.getInstance().getPersistenceManager();
		return pm.getObjectById(PlayerDTO.class, uralysUID);
	}

	public PlayerDTO getFacebookPlayer(String facebookUID)  {
		PersistenceManager pm = PMF.getInstance().getPersistenceManager();
		Query q = pm.newQuery("select from " + PlayerDTO.class.getName() + " where facebookUID == :fbUID");
		q.setUnique(true);
		
		PlayerDTO player = (PlayerDTO) q.execute(facebookUID);
		player.setLastLog(new Date().getTime());
		
		pm.close();
		
		return player;
	}

	//===========================================================//

}
