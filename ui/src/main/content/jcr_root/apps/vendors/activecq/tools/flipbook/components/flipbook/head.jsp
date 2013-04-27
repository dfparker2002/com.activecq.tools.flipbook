<%@include file="/apps/vendors/activecq/tools/flipbook/global/global.jsp" %><%
%><%@ page session="false" contentType="text/html; charset=utf-8" import="com.day.cq.commons.Externalizer"
%><%
    final Externalizer externalizer = resourceResolver.adaptTo(Externalizer.class);

    final String title         = currentPage.getTitle();
    final String canonicalURL  = externalizer.absoluteLink(slingRequest, "http", currentPage.getPath()) + ".html";

%><head>
    <meta charset="utf-8" />
    <title>Flipbook | <%= xssAPI.encodeForHTML(title) %></title>
    <link rel="canonical" href="<%= xssAPI.getValidHref(canonicalURL) %>" />

    <cq:include script="/libs/wcm/core/components/init/init.jsp"/>
    <cq:includeClientLib css="apps.vendors.activecq.tools.flipbook.all"/>

    <script>
        <%-- Adds a js class to the <html> element to create custom CSS rules if JS is enabled/disabled --%>
        document.documentElement.className+=' js';
        <%-- Makes HTML5 elements listen to CSS styling in IE6-8 (aka HTML5 Shiv) - this is using the IE conditional comments feature --%>
        /*@cc_on(function(){var e=['abbr','article','aside','audio','canvas','details','figcaption','figure','footer','header','hgroup','mark','meter','nav','output','progress','section','summary','time','video'];for (var i = e.length; i-- > 0;) document.createElement(e[i]);})();@*/
    </script>
</head>