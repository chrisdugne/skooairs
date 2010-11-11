package com.skooairs.entities;

public class Board {

	private String boardUID;
	
	private int time;
	private int colors;

	private String playerUID;
	private String surname;
	private int points;

	//-----------------------------------------------------------------------------------//

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

	public String getPlayerUID() {
		return playerUID;
	}

	public void setPlayerUID(String playerUID) {
		this.playerUID = playerUID;
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