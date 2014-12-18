package com.skooairs.entities;

public class Player {

	private String uralysUID;
	private String facebookUID;
	private String surname;

	private Long lastLog;
	private Boolean premium;
	private Integer points;
	private Boolean musicOn;

	//-----------------------------------------------------------------------------------//

	public String getUralysUID() {
		return uralysUID;
	}
	public void setUralysUID(String uralysUID) {
		this.uralysUID = uralysUID;
	}
	public String getFacebookUID() {
		return facebookUID;
	}
	public void setFacebookUID(String facebookUID) {
		this.facebookUID = facebookUID;
	}
	public Long getLastLog() {
		return lastLog;
	}
	public void setLastLog(Long lastLog) {
		this.lastLog = lastLog;
	}
	public Integer getPoints() {
		return points;
	}
	public void setPoints(Integer points) {
		this.points = points;
	}
	public Boolean getPremium() {
		return premium;
	}
	public void setPremium(Boolean premium) {
		this.premium = premium;
	}
	public String getSurname() {
		return surname;
	}
	public void setSurname(String surname) {
		this.surname = surname;
	}
	public Boolean getMusicOn() {
		return musicOn;
	}
	public void setMusicOn(Boolean musicOn) {
		this.musicOn = musicOn;
	}
	
}
