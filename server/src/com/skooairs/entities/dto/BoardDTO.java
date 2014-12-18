package com.skooairs.entities.dto;

import javax.jdo.annotations.Extension;
import javax.jdo.annotations.IdGeneratorStrategy;
import javax.jdo.annotations.IdentityType;
import javax.jdo.annotations.PersistenceCapable;
import javax.jdo.annotations.Persistent;
import javax.jdo.annotations.PrimaryKey;

@PersistenceCapable(identityType = IdentityType.APPLICATION)
public class BoardDTO {

	@PrimaryKey
    @Persistent(valueStrategy = IdGeneratorStrategy.IDENTITY)
    @Extension(vendorName="datanucleus", key="gae.encoded-pk", value="true")
	protected String key;
    
	@Persistent
    @Extension(vendorName="datanucleus", key="gae.pk-name", value="true")
	private String boardUID;
	
	@Persistent	private int time;
	@Persistent	private int colors;

	@Persistent	private String uralysUID;
	@Persistent	private String surname;
	@Persistent	private int points;

	//-----------------------------------------------------------------------------------//

	public String getKey() {
		return key;
	}

	public void setKey(String key) {
		this.key = key;
	}

	public String getBoardUID() {
		return boardUID;
	}

	public void setBoardUID(String boardUID) {
		this.boardUID = boardUID;
	}

	public int getTime() {
		return time;
	}

	public void setTime(int time) {
		this.time = time;
	}

	public int getColors() {
		return colors;
	}

	public void setColors(int colors) {
		this.colors = colors;
	}

	public String getUralysUID() {
		return uralysUID;
	}

	public void setUralysUID(String uralysUID) {
		this.uralysUID = uralysUID;
	}

	public int getPoints() {
		return points;
	}

	public void setPoints(int points) {
		this.points = points;
	}

	public String getSurname() {
		return surname;
	}

	public void setSurname(String surname) {
		this.surname = surname;
	}

}