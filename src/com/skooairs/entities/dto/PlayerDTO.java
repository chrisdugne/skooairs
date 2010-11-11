package com.skooairs.entities.dto;

import javax.jdo.annotations.Extension;
import javax.jdo.annotations.IdGeneratorStrategy;
import javax.jdo.annotations.IdentityType;
import javax.jdo.annotations.PersistenceCapable;
import javax.jdo.annotations.Persistent;
import javax.jdo.annotations.PrimaryKey;

@PersistenceCapable(identityType = IdentityType.APPLICATION)
public class PlayerDTO {


    @PrimaryKey
    @Persistent(valueStrategy = IdGeneratorStrategy.IDENTITY)
    @Extension(vendorName="datanucleus", key="gae.encoded-pk", value="true")	
    protected String key;

	@Persistent
    @Extension(vendorName="datanucleus", key="gae.pk-name", value="true")
	private String playerUID;

	@Persistent private String facebookUID;
	@Persistent private String email;
	@Persistent private String surname;
	@Persistent private Long lastLog;
	@Persistent private Long lastTransactionMillis;
	@Persistent private Integer language;
	@Persistent private Boolean musicOn;
	@Persistent private Boolean premium;
	@Persistent private Integer points;
	
	public String getKey() {
		return key;
	}
	public void setKey(String key) {
		this.key = key;
	}
	public String getPlayerUID() {
		return playerUID;
	}
	public void setPlayerUID(String playerUID) {
		this.playerUID = playerUID;
	}
	public Long getLastLog() {
		return lastLog;
	}
	public void setLastLog(Long lastLog) {
		this.lastLog = lastLog;
	}
	public Integer getLanguage() {
		return language;
	}
	public void setLanguage(Integer language) {
		this.language = language;
	}
	public Boolean getMusicOn() {
		return musicOn;
	}
	public void setMusicOn(Boolean musicOn) {
		this.musicOn = musicOn;
	}
	public Integer getPoints() {
		return points;
	}
	public void setPoints(Integer points) {
		this.points = points;
	}
	public Long getLastTransactionMillis() {
		return lastTransactionMillis;
	}
	public void setLastTransactionMillis(Long lastTransactionMillis) {
		this.lastTransactionMillis = lastTransactionMillis;
	}
	public Boolean getPremium() {
		return premium;
	}
	public void setPremium(Boolean premium) {
		this.premium = premium;
	}
	public String getFacebookUID() {
		return facebookUID;
	}
	public void setFacebookUID(String facebookUID) {
		this.facebookUID = facebookUID;
	}
	public String getEmail() {
		return email;
	}
	public void setEmail(String email) {
		this.email = email;
	}
	public String getSurname() {
		return surname;
	}
	public void setSurname(String surname) {
		this.surname = surname;
	}
	
	//-----------------------------------------------------------------------------------//
	
}