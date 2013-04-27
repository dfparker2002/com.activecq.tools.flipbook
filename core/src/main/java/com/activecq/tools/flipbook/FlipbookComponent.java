/*
 * Copyright 2013 david gonzalez.
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */
package com.activecq.tools.flipbook;

import com.activecq.api.ActiveComponent;
import com.day.cq.commons.jcr.JcrConstants;
import com.day.cq.search.PredicateGroup;
import com.day.cq.search.Query;
import com.day.cq.search.result.Hit;
import com.day.cq.search.result.SearchResult;
import com.day.cq.wcm.api.WCMMode;
import com.day.cq.wcm.api.components.Component;
import com.day.cq.wcm.api.components.Toolbar;
import org.apache.commons.collections.IteratorUtils;
import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.sling.api.SlingHttpServletRequest;
import org.apache.sling.api.resource.LoginException;
import org.apache.sling.api.resource.Resource;
import org.apache.sling.api.resource.ResourceUtil;
import org.apache.sling.api.resource.ValueMap;
import org.apache.tika.io.IOUtils;
import org.pegdown.PegDownProcessor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.jcr.Node;
import javax.jcr.RepositoryException;
import javax.jcr.Session;
import java.io.IOException;
import java.io.InputStream;
import java.util.*;

/**
 *
 * @author david
 */
public class FlipbookComponent extends ActiveComponent {
    private final Logger log = LoggerFactory.getLogger(this.getClass());

    private static final String COMPONENT_FLIPBOOK_NODE = "spec";
    private static final String PAGE_FLIPBOOK_NODE = "flipbook";

    private static final String[] README_NAMES = new String[] { "README.md", "SPEC.md", "README.html", "SPEC.html", "README.txt", "SPEC.txt", "README", "SPEC" };
    private static final String[] IMAGE_EXTENSIONS = new String[] { "png", "jpg", "gif", "jpeg" };
    private static final String[] PAGE_RESOURCE_SUPER_TYPES = new String[] {
            "foundation/components/page",
            "wcm/mobile/components/page",
            "mcm/components/newsletter/page"
    };

    private static final int MAX_RESULTS = 1000;
    private static final String HIDDEN_COMPONENT_GROUP = ".hidden";
    private List<String> paths;

    private List<Resource> cachedWidgetResources = new ArrayList<Resource>();

    public static enum DialogType { DIALOG, DESIGN_DIALOG };

    public FlipbookComponent(SlingHttpServletRequest request) throws RepositoryException, LoginException {
        super(request);
        this.Plugins.WCMMode.switchTo(WCMMode.DISABLED);
    }

    public Resource getFlipbookResource() {
        return this.getResource().getChild("./" + PAGE_FLIPBOOK_NODE);
    }

    public List<String> getPaths() {
        if(this.paths == null) {
            final String[] pathsArray = this.getPage().getProperties(PAGE_FLIPBOOK_NODE).get("paths", new String[]{"/apps"});
            this.paths = Arrays.asList(pathsArray);
        }

        return this.paths;
    }

    public boolean getShowHidden() {

        return this.getProperty("./" + PAGE_FLIPBOOK_NODE + "/showHidden", false);
    }

    public List<Resource> getPages() throws RepositoryException {
        List<Resource> pages = new ArrayList<Resource>();

        Map<String, String> map = new HashMap<String, String>();
        map.put("type", "cq:Component");

        map.put("orderby", "@jcr:title");
        map.put("orderby.sort", "asc");

        map.put("p.offset", "0");
        // Cowardly refusing to return more than 1000 results
        // If you have more than 10,000 components something is seriously wrong
        // with your design approach
        map.put("p.limit", String.valueOf(MAX_RESULTS));

        Query query = this.getQueryBuilder().createQuery(PredicateGroup.create(map),
                this.getResourceResolver().adaptTo(Session.class));
        SearchResult result = query.getResult();

        for (Hit hit : result.getHits()) {
            final ValueMap props = hit.getProperties();
            final String path = hit.getPath();
            boolean hide = true;

            for(final String validPathPrefix : this.getPaths()) {
                if(StringUtils.startsWith(path, validPathPrefix.concat("/"))) {
                    hide = false;
                }
            }

            if(!hide) {
                if(!this.getShowHidden()) {
                    hide = StringUtils.equals(props.get("componentGroup", HIDDEN_COMPONENT_GROUP), "");
                }
            }

            if(!hide) {
                hide = props.get("hideInFlipbook", false);
            }

            if(!hide) {
                pages.add(hit.getResource());
            }
        }

        return pages;
    }

    public List<ValueMap> getDialogFields(Resource resource, DialogType dialogType) throws RepositoryException {
        List<ValueMap> list = new ArrayList<ValueMap>();
        Component component = resource.adaptTo(Component.class);
        String path;

        if(DialogType.DIALOG.equals(dialogType)) {
            path = component.getDialogPath();
        } else {
            path = component.getDesignDialogPath();
        }

        if(StringUtils.isBlank(path)) {
            return list;
        }

        if(this.cachedWidgetResources.isEmpty()) {
            Map<String, String> map = new HashMap<String, String>();
            //map.put("path", path);
            map.put("type", "cq:Widget");

            map.put("1_property.property", "xtype");
            map.put("1_property.operation", "exists");

            map.put("2_property.property", "name");
            map.put("2_property.operation", "exists");

            map.put("3_property.property", "fieldLabel");
            map.put("3_property.operation", "exists");

            map.put("orderby", "@fieldLabel");
            map.put("orderby.sort", "asc");

            map.put("p.offset", "0");
            map.put("p.limit", String.valueOf(Integer.MAX_VALUE));

            Query query = this.getQueryBuilder().createQuery(PredicateGroup.create(map),
                    this.getResourceResolver().adaptTo(Session.class));

            for(Hit hit : query.getResult().getHits()) {
                this.cachedWidgetResources.add(hit.getResource());
            }
        }

        for (Resource cachedResource : this.cachedWidgetResources) {
            if(StringUtils.startsWith(cachedResource.getPath(), path)) {
                list.add(cachedResource.adaptTo(ValueMap.class));
            }
        }

        return list;
    }

    public String getReadme(Component component) {
        String contents = "";

        final Resource cr = this.getResourceResolver().resolve(component.getPath());
        final Resource flipbook = cr.getChild(COMPONENT_FLIPBOOK_NODE);

        if(flipbook == null) {
            return contents;
        }

        Resource readme = null;

        for(String name : README_NAMES) {
            final Resource tmp = flipbook.getChild(name);

            if(tmp != null && ResourceUtil.isA(tmp, JcrConstants.NT_FILE)) {
                // Use the first README nt:file node found
                readme = tmp;
                break;
            }
        }

        try {
            if(readme != null) {
                final Node node = readme.adaptTo(Node.class);
                final Node jcrContent = node.getNode(JcrConstants.JCR_CONTENT);
                final InputStream content = jcrContent.getProperty(JcrConstants.JCR_DATA).getBinary().getStream();

                try {
                    contents = IOUtils.toString(content);
                } catch (IOException e) {
                    contents = "Could not read README";
                }

                /* Handle markdown */
                if(StringUtils.endsWith(readme.getName(), ".md")) {
                    contents = new PegDownProcessor().markdownToHtml(contents);
                } else if (StringUtils.endsWith(readme.getName(), ".txt")) {
                    // Wrap .txt with PRE tags
                    contents = "<pre>" + contents + "</pre>";
                }


            }
        } catch (RepositoryException ex) {
            contents = "Could not read README";
        } catch (NullPointerException ex) {
            contents = "Could not read README";
        }
        return StringUtils.stripToEmpty(contents);

    }

    public List<String> getImagePaths(Component component) {
        List<String> paths = new ArrayList<String>();

        final Resource cr = this.getResourceResolver().resolve(component.getPath());
        if(cr == null) {
            return paths;
        }

        final Resource flipbook = cr.getChild(COMPONENT_FLIPBOOK_NODE);
        if(flipbook == null) {
            return paths;
        }

        final List<Resource> children = IteratorUtils.toList(flipbook.listChildren());
        for(final Resource child : children) {
              if(ResourceUtil.isA(child, JcrConstants.NT_FILE)) {
                  for(final String ext : IMAGE_EXTENSIONS) {
                      if(StringUtils.endsWithIgnoreCase(child.getName(), ext)) {
                          paths.add(child.getPath());
                          break;
                      }
                  }
              }
        }

        return paths;
    }

    public boolean isPageImplementation(Component component) {
        Component superComponent = component.getSuperComponent();
        if (superComponent != null) {
            return this.isPageImplementation(superComponent);
        }

        return ArrayUtils.contains(PAGE_RESOURCE_SUPER_TYPES, component.getResourceType());
    }

    private String getImagePath(String parentPage, String imageName) {
        final Resource parent = this.getResourceResolver().resolve(parentPage);
        if(parent == null) { return null; }

        Resource imageResource = parent.getChild(imageName + ".png");
        if(imageResource == null) { return null; }

        return imageResource.getPath();
    }

    public String getIconPath(Component component) {
        final String DEFAULT_ICON_PATH = "/libs/cq/ui/widgets/themes/default/icons/16x16/components.png";

        if(!StringUtils.isBlank(component.getIconPath())) {
            return component.getIconPath();
        } else {
            return DEFAULT_ICON_PATH;
        }
    }

    public String yesNo(boolean o) {
        return yesNo(Boolean.valueOf(o));
    }

    public String yesNo(Object o) {
        final String YES = "Yes";
        final String NO = "No";

        if(o == null) {
            return NO;
        } else if(o instanceof String) {
            String tmp = (String) o;
            if(StringUtils.equalsIgnoreCase(tmp, "true") ||
                    StringUtils.endsWithIgnoreCase(tmp, "yes")) {
                return YES;
            } else {
                return NO;
            }
        } else if (o instanceof Boolean) {
            if(((Boolean) o).booleanValue()) {
                return YES;
            } else {
                return NO;
            }
        }

        return NO;
    }

    public List<String> getToolbarList(Toolbar toolbar) {
        List<String> list = new ArrayList<String>();

        Object[] objects = toolbar.toArray();

        for(Object obj : objects) {

            // Order matters because of subclassing
            if(obj instanceof Toolbar.Button) {
                list.add("Toolbar Button");
            } else if(obj instanceof Toolbar.Label) {
                list.add("Toolbar Label");
            } else if(obj instanceof Toolbar.Separator) {
                list.add("Toolbar Separator");
            } else if(obj instanceof Toolbar.Custom) {
                list.add("Toolbar Custom");
            } else if(obj instanceof com.day.cq.wcm.api.components.JcrToolbarItem) {
                list.add("Jcr Toolbar Item");
            } else if(obj instanceof Toolbar.Item) {
                list.add(obj.toString());
            } else {
                list.add(obj.toString());
            }
        }

        return list;
    }
}