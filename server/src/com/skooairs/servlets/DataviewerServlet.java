package com.skooairs.servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.skooairs.dao.impl.UniversalDAO;
import com.skooairs.entities.dto.BoardDTO;
import com.skooairs.entities.dto.PlayerDTO;
import com.skooairs.entities.dto.TransactionDTO;
import com.skooairs.utils.Utils;


public class DataviewerServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;
	private String PASSWORD = "3bc7c708f8d865b506ffd1acde3b47f61af9445d";
	private String VERSION = "1.0.8";


	@SuppressWarnings({ "unchecked", "rawtypes" })
	public void doGet (HttpServletRequest req,
			HttpServletResponse res)
	throws ServletException, IOException
	{
		PrintWriter out = res.getWriter();

		if(!req.getRemoteHost().equals("127.0.0.1") && !req.getRequestURL().toString().startsWith("https")){
			out.println("<meta http-equiv=\"refresh\" content=\"0.1; URL=https://skooairs.appspot.com/dataviewer\"/>");	
			out.close();
			return;
		}
			

		if(!req.getRemoteHost().equals("127.0.0.1") && (req.getParameter("pwd")==null || !Utils.SHA1(req.getParameter("pwd")).equals(PASSWORD))){
			out.println("<html><body>");
			out.println("<center><span style=\"color:#009933\"><h2>Skooairs Dataviewer - "+VERSION+" (Off)</h2></center>");
			out.println("</body></html>");
			out.close();
			return;
		}
		
//		ApplicationContext appContext = WebApplicationContextUtils.getWebApplicationContext(getServletContext());
//		InitDAO initDao = (InitDAO) appContext.getBean("initDao");
//		initDao.createRio("324567");
//		initDao.createRio("3245674");
//		initDao.createRio("3245677");
//		initDao.createRio("3245679");
//		initDao.createRio("3245671");
//		initDao.createRio("32456123");
//		initDao.createRio("3245234");
//		initDao.createRio("327867");
//		initDao.createRio("324587967");
//		initDao.createRio("327897");
//		initDao.createRio("388724567");
//		initDao.createRio("39624567");

//		initDao.updateFools();

		UniversalDAO universalDao = UniversalDAO.getInstance();

		out.println("<html>" +
					"<head>" +
					"<SCRIPT TYPE=\"text/javascript\">" +
					"<!--" +
					"function dropdown(mySel)" +
					"{" +
					"var myWin, myVal;" +
					"myVal = mySel.options[mySel.selectedIndex].value;" +
					"if(myVal)" +
					"   {" +
					"   if(mySel.form.target)myWin = parent[mySel.form.target];" +
					"   else myWin = window;" +
					"   if (! myWin) return true;" +
					"   myWin.location = myVal;" +
					"   }" +
					"return false;" +
					"}" +

					"//-->" +
					"</SCRIPT>" +

					
					"<STYLE TYPE=\"text/css\">" +
					
					"tr.title" +
					"{" +
					"	font-weight: bold ;" +
					"	background: #c5d7ef ;" +
					"}" +
					"" +
					"tr" +
					"{" +
					"	padding: .25em 1.5em .5em .5em;" +
					"}" +
					"" +
					"td" +
					"{" +
					"	text-align: center;" +
					"}" +
					"</style>" +
					
					
					"" +
					"</head>" +
					"<body>");
		out.println("<center><span style=\"color:#009933\"><h2>Skooairs Dataviewer - "+VERSION+"</h2></center>");

		out.println("<hr>");
		out.println("<br>");
		
		String dropdown = "<FORM " +
				" METHOD=GET onSubmit=\"return dropdown(this.dto)\">" +
				" <SELECT NAME=\"dto\" onChange=\"this.form.submit()\">" +
				" <OPTION VALUE=\"___\">Choose a DTO..." +

				//-----------------------------------------------------------------------------------//				// - HERE : add a line for every new DTO
				
				" <OPTION VALUE=\"player\">PlayerDTO" +
				" <OPTION VALUE=\"board\">BoardDTO" +
				" <OPTION VALUE=\"transaction\">TransactionDTO" +
				
				//-----------------------------------------------------------------------------------//
								" </SELECT>" +
				" <INPUT TYPE=\"text\" name=\"pwd\" value=\""+req.getParameter("pwd")+"\"/>" +
				"</FORM>";
		out.println(dropdown);
		out.println("<br>");
		out.println("<input type=\"button\" value=\"Refresh\" onclick=\"window.location.reload();\">");
		out.println("<br>");
		
		
		//-----------------------------------------------------------------------------------//		// - edit
		
		if(req.getParameter("action") != null && req.getParameter("action").equals("edit")){
			Class selectedDTO = getDTOClass(req.getParameter("entity"));
			
			Object o = universalDao.getObjectDTO(req.getParameter("___uid"), selectedDTO);
			Field[] fields = o.getClass().getDeclaredFields();
			
			// [0] : key |  [1] : objectUID
			String idName = fields[1].getName();

			StringBuffer editTable = new StringBuffer();
			StringBuffer parametersToSave= new StringBuffer();

			editTable.append("<table>");
			
			for(Field field : fields){
				
				if(field.getName().startsWith("key") || field.getName().startsWith("jdo"))
					continue;
			
				if(field.getType().getName().equals("com.google.appengine.api.datastore.Text"))
					continue;
				
				if(field.getType().getName().equals("java.util.Date"))
					continue;
				
				try {
					field.setAccessible(true);
					editTable.append("<tr>");
					
					parametersToSave.append(field.getName() + "="+field.getName()+".value,");
					
					if(field.getName().equals(idName))
						editTable.append("<td><b>"+field.getName() + "</b> </td><td>" + field.get(o) + "</td>");
					else if(field.getType().getName().equals("java.lang.Boolean"))
						editTable.append("<td>"+field.getName() + "</td><td><select name="+field.getName()+"><option value=" + field.get(o) + ">"+ field.get(o) +"<option value=" + !(Boolean)field.get(o) + ">"+ !(Boolean)field.get(o) +"</td>");
					else if(field.getType().getName().equals("java.util.List"))
						editTable.append("<td>"+field.getName() + "</td><td><textarea style=\"width: 280px;\" rows=\""+((List)field.get(o)).size()+"\" name=\""+field.getName()+"\">" + field.get(o) + "</textarea></td>");
					else
						editTable.append("<td>"+field.getName() + "</td><td><input type=\"text\" name=\""+field.getName()+"\" value=\"" + field.get(o) + "\" /></td>");
					editTable.append("</tr>");
				} 
				catch (IllegalArgumentException e) {} 
				catch (IllegalAccessException e) {}
			}

			out.println("<form METHOD=GET onSubmit=\"document.window.href='/dataviewer?action=save&entity="+req.getParameter("entity")+"&uid="+req.getParameter("uid")+"'\">");
			out.println(editTable.toString());
			out.println("<input type=\"button\" value=\"Save\" onClick=\"this.form.submit();\"/>");
			out.println("<input type=\"hidden\" value=\""+req.getParameter("entity")+"\" name=\"entity\"/>");
			out.println("<input type=\"hidden\" value=\""+req.getParameter("___uid")+"\" name=\"___uid\"/>");
			out.println("<input type=\"hidden\" value=\""+req.getParameter("pwd")+"\" name=\"pwd\"/>");
			out.println("<input type=\"hidden\" value=\"save\" name=\"action\"/>");
			out.println("</form>");
		}
		
		//-----------------------------------------------------------------------------------//
		// - delete
		
		else if(req.getParameter("action") != null && req.getParameter("action").equals("delete")){
			Class selectedDTO = getDTOClass(req.getParameter("entity"));
			
			universalDao.delete(selectedDTO, req.getParameter("___uid"));
			out.println("<meta http-equiv=\"refresh\" content=\"0.1; URL=/dataviewer?pwd="+req.getParameter("pwd")+"&dto="+req.getParameter("entity")+"\">");	
		}
		
		//-----------------------------------------------------------------------------------//
		// - save the edition
		
		else if(req.getParameter("action") != null && req.getParameter("action").equals("save")){
			Class selectedDTO = getDTOClass(req.getParameter("entity"));
			Object instance = universalDao.getObjectDTO(req.getParameter("___uid"), selectedDTO);

			for(Field field : instance.getClass().getDeclaredFields()){

				if(field.getName().startsWith("key") || field.getName().startsWith("jdo"))
					continue;
				
				try {
					String value = req.getParameter(field.getName());

					if(value == null)
						continue;
					
					field.setAccessible(true);

					if(value.equals("null") || value.equals("") )
						value = null;
					
					if(value != null && value.startsWith("["))
						field.set(instance, createList(value));
					else if(field.getType().getName().equals("java.lang.Integer") || field.getType().getName().equals("int"))
						field.set(instance, value == null ? null : Integer.parseInt(value));
					else if(field.getType().getName().equals("java.lang.Boolean") || field.getType().getName().equals("boolean"))
						field.set(instance, value == null ? null : Boolean.parseBoolean(value));
					else if(field.getType().getName().equals("java.lang.Float") || field.getType().getName().equals("float"))
						field.set(instance, value == null ? null : Float.parseFloat(value));
					else if(field.getType().getName().equals("java.lang.Long") || field.getType().getName().equals("long"))
						field.set(instance, value == null ? null : Long.parseLong(value));
					else{
						// String
						field.set(instance, value);
					}
						
					
				} catch (SecurityException e) {
					e.printStackTrace();
					break;
				} catch (IllegalAccessException e) {
					e.printStackTrace();
					break;
				}
			}
			
			universalDao.update(instance, req.getParameter("___uid"));
			out.println("<meta http-equiv=\"refresh\" content=\"0.1; URL=/dataviewer?pwd="+req.getParameter("pwd")+"&dto="+req.getParameter("entity")+"\">");	
		}
		
		//-----------------------------------------------------------------------------------//		// - Display
		
		else if(req.getParameter("dto") != null && !req.getParameter("dto").equals("___")){

			Class selectedDTO = getDTOClass(req.getParameter("dto"));			
			int from = 1;
			int to = 100;
			
			if(req.getParameter("from") != null)
				from = Integer.parseInt(req.getParameter("from"));
			if(req.getParameter("to") != null)
				to = Integer.parseInt(req.getParameter("to"));
				
			List<Object> list = universalDao.getListDTO(selectedDTO, from, to);
			
			out.println("<br>");
			out.println("<br>");
			String table = " <table class=\"entities\" cellpadding=\"2\">" +
							"<tr class=\"title\"> ";
			
			table += "<td style=\"min-width:150px; background:#BCE954\"> Actions </td>";
			for(Field field : selectedDTO.getDeclaredFields()){
				if(field.getName().startsWith("key") || field.getName().startsWith("jdo"))
					continue;
				table += "<td> "+field.getName()+" </td>";
			}
			table += "</tr>";

			for(Object o : list){
				
				Field[] fields = o.getClass().getDeclaredFields();
				fields[1].setAccessible(true);
				String objectUID = "";
				
				try {
					objectUID = (String) fields[1].get(o);
				} catch (IllegalArgumentException e) {
					e.printStackTrace();
				} catch (IllegalAccessException e) {
					e.printStackTrace();
				}
				
				table += "<tr>";
				table += "<td>" +
				" <a href=\"/dataviewer?pwd="+req.getParameter("pwd")+"&entity="+req.getParameter("dto")+"&action=edit&___uid="+objectUID+"\">Edit</a>" +
				" &nbsp;&nbsp;&nbsp;" +
				" <a href=\"/dataviewer?pwd="+req.getParameter("pwd")+"&entity="+req.getParameter("dto")+"&action=delete&___uid="+objectUID+"\">Delete</a>" +
				" </td>";
				for(Field field : fields){
					if(field.getName().startsWith("key") || field.getName().startsWith("jdo"))
						continue;
					try {
						field.setAccessible(true);
						table += "<td> "+field.get(o)+" </td>";
					} catch (IllegalArgumentException e) {
						table += "<td> ___PROBLEM___ </td>";
						e.printStackTrace();
					} catch (IllegalAccessException e) {
						e.printStackTrace();
						table += "<td> ___PROBLEM___ </td>";
					}
				}
			
				table += "</tr>";
			}
			table += "</table>";
			
			out.println(table);
		}

		out.println("</body></html>");
		out.close();
	}


	/**
	 * convert [a,b,c,d]
	 * to List<String> {a,b,c,d}
	 */
	private List<String> createList(String s) {
		
		if(s.equals("[]"))
			return null;
		 
		List<String> list = new ArrayList<String>();
		
		//removing the '[' and ']'
		s = s.substring(1, s.length()-1);
		String[] values = s.split(",");
		
		for(String value : values){
			list.add(value.trim());
		}
		
		return list;
	}


	@SuppressWarnings({"rawtypes" })
	private Class getDTOClass(String dto) {
		
		//-----------------------------------------------------------------------------------//
		// - HERE : add a condition for every new DTO

		if(dto.equals("player"))
			return PlayerDTO.class;
		else if(dto.equals("board"))
			return BoardDTO.class;
		else if(dto.equals("transaction"))
			return TransactionDTO.class;
		
		//never
		return null;

		//-----------------------------------------------------------------------------------//
	}	
}

