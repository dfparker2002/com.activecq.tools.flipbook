<%@page session="false" contentType="text/html; charset=utf-8" pageEncoding="UTF-8"
        import="java.util.Date, java.text.SimpleDateFormat,com.activecq.tools.flipbook.FlipbookComponent"%>
<%@include file="/apps/vendors/activecq/tools/flipbook/global/global.jsp" %><%

FlipbookComponent c = new FlipbookComponent(slingRequest);

SimpleDateFormat dateFormat = new SimpleDateFormat("MMMMM d, yyyy");
SimpleDateFormat timeFormat = new SimpleDateFormat("hh:mm aaa");

%><div class="print-cover">
      <h1>Component Flipbook</h1>
      <h2><%= currentPage.getTitle() %></h2>
      <h3><%= dateFormat.format(new Date()) %> at <%= timeFormat.format(new Date()) %></h3>

      <p>
      <strong>Reporting on:</strong>
      <br/>
      <%
      for(String path : c.getPaths()) {
      %><%= path %><br/><%
      }
      %></p>

</div>