package com.skooairs.entities.dto;

import javax.jdo.annotations.Extension;
import javax.jdo.annotations.IdGeneratorStrategy;
import javax.jdo.annotations.IdentityType;
import javax.jdo.annotations.PersistenceCapable;
import javax.jdo.annotations.Persistent;
import javax.jdo.annotations.PrimaryKey;

@PersistenceCapable(identityType = IdentityType.APPLICATION)
public class TransactionDTO {

	@PrimaryKey
    @Persistent(valueStrategy = IdGeneratorStrategy.IDENTITY)
    @Extension(vendorName="datanucleus", key="gae.encoded-pk", value="true")
	protected String key;
    
	@Persistent
    @Extension(vendorName="datanucleus", key="gae.pk-name", value="true")
	private String transactionUID;
	
	@Persistent	private Long transactionMillis;
	@Persistent	private String playerUID;
	@Persistent	private int paymentType;
	@Persistent	private String app;

	//-----------------------------------------------------------------------------------//

	public String getKey() {
		return key;
	}

	public void setKey(String key) {
		this.key = key;
	}

	public String getTransactionUID() {
		return transactionUID;
	}

	public void setTransactionUID(String transactionUID) {
		this.transactionUID = transactionUID;
	}

	public Long getTransactionMillis() {
		return transactionMillis;
	}

	public void setTransactionMillis(Long transactionMillis) {
		this.transactionMillis = transactionMillis;
	}

	public String getPlayerUID() {
		return playerUID;
	}

	public void setPlayerUID(String foolUID) {
		this.playerUID = foolUID;
	}

	public int getPaymentType() {
		return paymentType;
	}

	public void setPaymentType(int paymentType) {
		this.paymentType = paymentType;
	}

	public String getApp() {
		return app;
	}

	public void setApp(String app) {
		this.app = app;
	}

}
