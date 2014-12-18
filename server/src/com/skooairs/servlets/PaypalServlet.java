package com.skooairs.servlets;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.context.ApplicationContext;
import org.springframework.web.context.support.WebApplicationContextUtils;

import com.skooairs.dao.impl.PlayerDAO;

public class PaypalServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;
	

	public void doGet (HttpServletRequest req,
			HttpServletResponse res)
	throws ServletException, IOException
	{

		ApplicationContext appContext = WebApplicationContextUtils.getWebApplicationContext(getServletContext());
		PlayerDAO playerDao = (PlayerDAO) appContext.getBean("playerDao");
		
		String custom = req.getParameter("custom");
		String[] params = custom.split("___");
		
		String playerUID = params[0];
		Long lastTransactionMillis = Long.parseLong(params[1]);
		
		System.out.println("-----------------------");
		System.out.println("PaypalServlet");
		System.out.println("playerUID : " + playerUID);
		System.out.println("lastTransactionMillis : " + lastTransactionMillis);
		System.out.println("-----------------------");
		
		playerDao.setPremium(playerUID, lastTransactionMillis);
		
		res.getWriter().println("<meta http-equiv=\"refresh\" content=\"0.1; URL=http://skooairs.uralys.com/\">");
	}
}

