<%@include file="/apps/vendors/activecq/tools/flipbook/global/global.jsp" %><%
%><%@ page session="false" contentType="text/html; charset=utf-8" %><%
    final String className = component.getProperties().get("className", "");
%>
<!--[if IE 7 ]> <body class="ie7 <%= xssAPI.encodeForHTMLAttr(className) %>"> <![endif]-->
<!--[if IE 8 ]> <body class="ie8 <%= xssAPI.encodeForHTMLAttr(className) %>"> <![endif]-->
<!--[if IE 9 ]> <body class="ie9 <%= xssAPI.encodeForHTMLAttr(className) %>"> <![endif]-->
<!--[if (gt IE 9)|!(IE)]><!--> <body class="<%= xssAPI.encodeForHTMLAttr(className) %>"> <!--<![endif]-->
    <div id="main" class="page-main container_12">
        <cq:include script="main.jsp"/>
    </div>

    <cq:includeClientLib js="apps.vendors.activecq.tools.flipbook.all"/>
    <cq:include path="timing" resourceType="foundation/components/timing"/>
</body>