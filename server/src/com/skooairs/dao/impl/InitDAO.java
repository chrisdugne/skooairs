package com.skooairs.dao.impl;

import javax.jdo.PersistenceManager;

import com.skooairs.dao.impl.PMF;
import com.skooairs.entities.dto.BoardDTO;
import com.skooairs.entities.dto.ServerDataDTO;
import com.skooairs.utils.Utils;


public class InitDAO extends MainDAO{

	//-----------------------------------------------------------------------------------//

	public void storePassword(String pwd) {
		PersistenceManager pm = PMF.getInstance().getPersistenceManager();
		ServerDataDTO data =  pm.getObjectById(ServerDataDTO.class, "serverData");
		
		data.setDataviewerPassword(pwd);
		
		pm.close();
	}

	public void generateBoards(int color, int time, String name, int points) {
		PersistenceManager pm = PMF.getInstance().getPersistenceManager();

		BoardDTO board =  new BoardDTO();
		board.setBoardUID("dummy_"+Utils.generateUID());
		board.setColors(color);
		board.setTime(time);
		board.setSurname(name);
		board.setPoints(points);

		pm.makePersistent(board);
		pm.close();
	}

}