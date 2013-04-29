<%@page session="false" contentType="text/html; charset=utf-8" pageEncoding="UTF-8"
import="com.activecq.tools.flipbook.components.*,
        com.activecq.tools.quickimage.helpers.QuickImageHelper,
        com.day.cq.wcm.api.components.Component,
        com.day.cq.wcm.api.WCMMode,
        org.apache.sling.api.resource.*,
        org.apache.commons.lang.*,
        java.util.*"%><%
%><%@include file="/apps/vendors/activecq/tools/flipbook/global/global.jsp" %><%
%><% WCMMode.DISABLED.toRequest(slingRequest);
     final FlipbookService c = sling.getService(FlipbookService.class);
     final List<Resource> cachedWidgetResources = c.getWidgetResources(resource);
     int pageCount = 0;
     boolean first = true;

%><div class="js-flipbook flipbook"><%

%><cq:include script="pagination.jsp"/><%
%><cq:include script="printcover.jsp"/><%

%><% for(Resource fr : c.getPages(resource)) {
        final Component fc = fr.adaptTo(Component.class);
        final ValueMap fp = fr.adaptTo(ValueMap.class);

        final List<ValueMap> dialogFields = c.getDialogFields(fr, FlipbookService.DialogType.DIALOG, cachedWidgetResources);
        final List<ValueMap> designDialogFields = c.getDialogFields(fr, FlipbookService.DialogType.DESIGN_DIALOG, cachedWidgetResources);
        final Map<String, String> htmlAttrMap = fc.getHtmlTagAttributes();
        %><%
%><div class="js-flipbook-page flipbook-page clearfix <%= !first ? "hide" : "" %>" data-page-number="<%= pageCount %>">

    <%-- Begin Component Image --%>
    <div class="grid_4 js-gallery gallery">
        <% int gallerySize = c.getImagePaths(fc, resourceResolver).size(); %>
        <% if(gallerySize < 1) { %>
            <div class="image-placeholder">No image provided</div>
        <% } else { %>

           <%-- Gallery Links --%>
           <div class="gallery-links js-gallery-links">
               <% for(int i = 1; i <= gallerySize; i++) { %>
                    <a href="javascript:void(0);" data-gallery-id="<%= i %>" class="js-gallery-link gallery-link <%= i == 1 ? "active" : "" %>"><%= i %></a>
               <% } %>
           </div>

           <%-- Gallery Images --%>
           <div class="gallery-images"><%
               int count = 1;
               for(String path : c.getImagePaths(fc, resourceResolver)) {
               %>
                    <a href="<%= path %>" class="js-gallery-image-link">
                    <img src="<%= QuickImageHelper.getSrc(path, 298, 0) %>" width="298px" data-gallery-id="<%= count %>" class="js-gallery-image gallery-image js-gallery-<%= pageCount %>  <%= count > 1 ? " hide" : "" %>" />
                    </a>
                    <% count += 1; %>
               <% } %>
           </div>
        <% } %>

    </div>
    <%-- End Component Image --%>


    <%-- Begin Component Information --%>
    <div class="grid_8">
        <div class="overview">

            <%-- Begin Title --%>
            <div class="grid_8 alpha omega">
                <%-- Title --%>
                <h1><%= fp.get("jcr:title", fr.getName()) %></h1>
            </div>
            <%-- End Title --%>

            <%-- Begin Basic Information --%>
            <div class="grid_4 alpha">
                <ul>
                    <%-- Component Group --%>
                    <% if(StringUtils.isNotBlank(fc.getComponentGroup())) { %><li><label>Component Group:</label> <%= fc.getComponentGroup() %></li><% } %>

                    <%-- Icon --%>
                    <li><label>Icon:</label> <img src="<%= c.getIconPath(fc) %>" alt="Component Icon"/></li>

                    <%-- Has Dialog --%>
                    <li><label>Editable:</label> <%= c.yesNo(fc.isEditable()) %></li>

                    <%-- Has Design Dialog --%>
                    <li><label>Designable:</label> <%= c.yesNo(fc.isDesignable()) %></li>

                    <% if(fr.getChild("analytics") == null) { %>
                        <%-- No Analytics --%>
                        <li><label>Analytics Enabled:</label> <%= c.yesNo(false) %></li>
                    <% } %>
                </ul>

                <!-- Analytics-->
                <% if(fr.getChild("analytics") != null) { %>
                    <ul>
                        <%-- Has Analytics --%>
                        <li><label>Analytics Enabled:</label> <%= c.yesNo(true) %></li>

                        <%-- Analytics --%>
                        <li><label>Events:</label> <%= fr.getChild("analytics").adaptTo(ValueMap.class).get("cq:trackevents", "n/a") %></li>
                        <li><label>eVars:</label> <%= fr.getChild("analytics").adaptTo(ValueMap.class).get("cq:trackvars", "n/a") %></li>
                    </ul>
                <% } %>
            </div>

            <div class="grid_4 omega">
                <ul>
                    <%-- Is Template Implementation --%>
                    <% if(c.isPageImplementation(fc)) { %>
                    <li><label>Template Component:</label> Yes</li>
                    <% } %>

                    <%-- Template Content --%>
                    <li><label>Has Template Content:</label> <%= c.yesNo(StringUtils.isNotBlank(fc.getTemplatePath())) %></li>

                    <%-- Allowed Parents --%>
                    <li><label>Allowed Parents:</label> <%= Arrays.toString(fp.get("allowedParents", new String[]{})) %></li>

                    <%-- Allowed Children --%>
                    <li><label>Allowed Children:</label> <%= Arrays.toString(fp.get("allowedChildren", new String[]{})) %></li>
                </ul>
            </div>

            <div class="grid_8 alpha omega">
                <%-- Description --%>
                <% if(StringUtils.isNotBlank(fc.getDescription())) { %><p><%= fc.getDescription() %></p><% } %>

                <%-- Flipbook Extended Description --%>
                <% final String readme = c.getReadme(fc, resourceResolver); %>
                <% if(StringUtils.isNotBlank(readme)) { %>
                <div class="flipbook-description"><%= readme %></div>
                <% } %>
            </div>

        </div>

        <%-- End Basic Information --%>

        <%-- Begin Technical Details --%>
        <div class="js-technical-details technical-details">
            <div class="alpha grid_8 omega">
                <h5>Technical Details</h5>

                <dl>
                    <%-- Sling Resource Type --%>
                    <dd><label>Resource Type:</label> <%= fc.getResourceType() %></dd>

                    <%-- Sling Resource Super Type --%>
                    <% if(fc.getSuperComponent() != null) { %>
                    <dd><label>Resource Super Type:</label> <%= fc.getSuperComponent().getResourceType() %></dd>
                    <% } %>

                    <%-- No Decoration --%>
                    <dd><label>No Decoration:</label> <%= c.yesNo(fc.noDecoration()) %></dd>

                    <%-- Is Container --%>
                    <dd><label>Is Container:</label> <%= c.yesNo(fc.isContainer()) %></dd>

                    <%-- Cell Name --%>
                    <dd><label>Cell Name:</label> <%= fc.getCellName() %></dd>
                </dl>
            </div>

            <div class="alpha grid_4">
                <dl>
                    <%-- Html Tag --%>
                    <dt><h5>cq:htmlTag</h5></dt>

                    <%-- HTML Tag Classes --%>
                    <dd><label>HTML Tag:</label>
                    <% if(StringUtils.isNotBlank(htmlAttrMap.get("cq:tagName"))) { %>
                        <%= htmlAttrMap.get("cq:tagName") %></dd>
                    <% } else { %>
                        div
                    <% } %>
                    </dd>

                    <%-- HTML CSS Classes --%>
                    <dd><label>CSS Classes:</label>
                    <% if(StringUtils.isNotBlank(htmlAttrMap.get("class"))) { %>
                        <%= htmlAttrMap.get("class") %></dd>
                    <% } else { %>
                        <%= fc.getName() %>
                    <% } %>
                    </dd>

                    <%-- Edit Config --%>
                    <% if(fc.getEditConfig() != null) { %>

                        <dt><h5>cq:editConfig</h5></dt>

                        <%-- Dialog Mode --%>
                        <dd><label>Dialog Mode:</label> <%= fc.getEditConfig().getDialogMode() %></dd>

                        <%-- Empty Text --%>
                        <% if(StringUtils.isNotBlank(fc.getEditConfig().getEmptyText())) { %>
                        <dd><label>Empty Text:</label> <%= fc.getEditConfig().getEmptyText() %></dd>
                        <% } %>

                        <%-- Insert Behavior --%>
                        <% if(StringUtils.isNotBlank(fc.getEditConfig().getInsertBehavior())) { %>
                        <dd><label>Insert Behavior:</label> <%= fc.getEditConfig().getInsertBehavior() %></dd>
                        <% } %>

                        <%-- Layout --%>
                        <dd><label>Layout:</label> <%= fc.getEditConfig().getLayout().toString() %></dd>

                        <%-- Toolbar --%>
                        <% if(fc.getEditConfig().getToolbar() != null) { %>
                        <dd><label>Toolbar:</label> <%= Arrays.toString(c.getToolbarList(fc.getEditConfig().getToolbar()).toArray()) %></dd>
                        <% } %>

                        <%-- Is Deep Cancel --%>
                        <dd><label>Is Deep Cancel:</label> <%= c.yesNo(fc.getEditConfig().isDeepCancel()) %></dd>

                        <%-- Is Default --%>
                        <dd><label>Is Default:</label> <%= c.yesNo(fc.getEditConfig().isDefault()) %></dd>

                        <%-- Is Empty --%>
                        <dd><label>Is Empty:</label> <%= c.yesNo(fc.getEditConfig().isEmpty()) %></dd>

                        <%-- Is Orderable --%>
                        <dd><label>Is Orderable:</label> <%= c.yesNo(fc.getEditConfig().isOrderable()) %></dd>


                        <%-- Default View --%>
                        <% if(StringUtils.isNotBlank(fc.getDefaultView())) { %>
                        <dd><label>Default View:</label> <%= fc.getDefaultView() %></dd>
                        <% } %>

                        <%-- Available Actions --%>
                        <dd><label>Available Actions:</label> <%= Arrays.toString(fp.get("cq:editConfig/cq:actions", new String[]{"edit", "delete", "insert", "copymove"})) %></dd>


                        <%-- Dialog Mode --%>
                        <dd><label>Dialog Mode:</label> <%= fp.get("cq:editConfig/cq:dialogMode", "auto") %></dd>

                        <%-- Supports Inplace Editing --%>
                        <% if(fc.getEditConfig().getInplaceEditingConfig() != null) { %>
                            <dt><h5>cq:inplaceEditing</h5></dt>

                            <dd><label>Active:</label> <%= c.yesNo(fc.getEditConfig().getInplaceEditingConfig().isActive()) %></dd>
                            <dd><label>Inplace Editor:</label> <%= fc.getEditConfig().getInplaceEditingConfig().getEditorType() %></dd>
                            <dd><label>Config:</label> <%= fc.getEditConfig().getInplaceEditingConfig().getConfigPath() %></dd>
                        <% } %>



                        <%-- Drop Targets --%>
                        <% if(fc.getEditConfig().getDropTargets() != null &&
                                fc.getEditConfig().getDropTargets().size() > 0) { %>

                            <dt><h5>cq:dropTargets</h5></dt>

                            <% for(String key : fc.getEditConfig().getDropTargets().keySet()) { %>
                            <dd><label>Name:</label> <%= fc.getEditConfig().getDropTargets().get(key).getName() %></dd>
                            <dd><label>Id:</label> <%= fc.getEditConfig().getDropTargets().get(key).getId() %></dd>
                            <dd><label>Property Name:</label> <%= fc.getEditConfig().getDropTargets().get(key).getPropertyName() %></dd>
                            <dd><label>Accept:</label> <%= Arrays.toString(fc.getEditConfig().getDropTargets().get(key).getAccept()) %></dd>
                            <dd><label>Groups:</label> <%= Arrays.toString(fc.getEditConfig().getDropTargets().get(key).getGroups()) %></dd>
                            <dd><label>Parameters:</label> <%= fc.getEditConfig().getDropTargets().get(key).getParameters().toString() %></dd>
                            <% } %>
                        <% } %>


                        <%-- Form Parameters --%>
                        <% if(fc.getEditConfig().getFormParameters().size() > 0) { %>
                            <dt><h5>cq:formParameters</h5></dt>

                            <% for(String key : fc.getEditConfig().getFormParameters().keySet()) { %>
                            <dd><label><%= key  %>:</label> <%= fc.getEditConfig().getFormParameters().get(key) %></dd>
                            <% } %>
                        <% } %>

                    <% } %>

                </dl>
            </div>

            <%-- Begin Dialog/Design Dialig Fields --%>
            <div class="grid_4 omega">
                <%-- Begin Dialog Fields --%>
                <% if(dialogFields.size() > 0) { %>
                    <h5>Dialog <a class="button small-button" href="<%= fc.getDialogPath() %>.html" target="flipbook-dialog">view</a></h5>
                    <div class="list-collection">
                        <% for(ValueMap fields : dialogFields) { %>
                        <dl>
                            <%-- Label --%>
                            <dd><label>Label:</label> <%= fields.get("fieldLabel", "Label not set") %></dd>

                            <%-- Description --%>
                            <% if(StringUtils.isNotBlank(fields.get("fieldDescription", String.class))) { %>
                            <dd><label>Description:</label> <%= fields.get("fieldDescription", "Field Description not set") %></dd>
                            <% } %>

                            <%-- Name --%>
                            <dd><label>Name:</label> <%= fields.get("name", "Name not set") %></dd>

                            <%-- XType --%>
                            <dd><label>XType: </label> <%= fields.get("xtype", "Xtype not set") %></dd>

                            <%-- Type --%>
                            <% if(StringUtils.isNotBlank(fields.get("type", String.class))) { %>
                            <dd><label>Type: </label> <%= fields.get("type", "Type not set") %></dd>
                            <% } %>
                        </dl>
                        <% } %>
                    </div>
                <% } %>
                <%-- End Dialog Fields --%>

                <%-- Begin Design Dialog Fields --%>
                <% if(designDialogFields.size() > 0) { %>
                    <h5>Design Dialog <a class="button small-button" href="<%= fc.getDesignDialogPath() %>.html" target="flipbook-designdialog">view</a></h5>

                    <div class="list-collection">
                        <% for(ValueMap fields : designDialogFields) { %>
                            <dl>
                                <%-- Label --%>
                                <dd><label>Label:</label> <%= fields.get("fieldLabel", "Label not set") %></dd>

                                <%-- Description --%>
                                <% if(StringUtils.isNotBlank(fields.get("fieldDescription", ""))) { %>
                                <dd><label>Description:</label> <%= fields.get("fieldDescription", "") %></dd>
                                <% } %>

                                <%-- Name --%>
                                <dd><label>Name:</label> <%= fields.get("name", "Name not set") %></dd>

                                <%-- XType --%>
                                <dd><label>XType:</label> <%= fields.get("xtype", "Xtype not set") %></dd>

                                <%-- Type --%>
                                <% if(StringUtils.isNotBlank(fields.get("type", String.class))) { %>
                                <dd><label>Type: </label> <%= fields.get("type", "Type not set") %></dd>
                                <% } %>
                            </dl>
                        <% } // for %>
                    </div>
                 <% } %>
                <%-- End Design Dialog Fields --%>
            </div>
            <%-- End Dialog/Design Dialog Fields --%>

        </div>
        <%-- End Technical Details --%>

    </div>
    <%-- End Component Information --%>
</div>
<%
first = false;
pageCount++;
%>
<% } %><%
%>
</div>