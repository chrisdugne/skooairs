package com.skooairs.dao.impl;

import javax.jdo.PersistenceManager;

import com.skooairs.dao.impl.PMF;
import com.skooairs.entities.dto.ServerDataDTO;


public class InitDAO extends MainDAO{

	//-----------------------------------------------------------------------------------//

	public void storePassword(String pwd) {
		PersistenceManager pm = PMF.getInstance().getPersistenceManager();
		ServerDataDTO data =  pm.getObjectById(ServerDataDTO.class, "serverData");
		
		data.setDataviewerPassword(pwd);
		
		pm.close();
	}

}