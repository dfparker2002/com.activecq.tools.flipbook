package com.activecq.tools.flipbook.components;

import com.day.cq.wcm.api.Page;
import com.day.cq.wcm.api.components.Component;
import com.day.cq.wcm.api.components.Toolbar;
import org.apache.sling.api.resource.Resource;
import org.apache.sling.api.resource.ResourceResolver;
import org.apache.sling.api.resource.ValueMap;

import javax.jcr.RepositoryException;
import java.util.List;

/**
 * User: david
 */
public interface FlipbookService {
    public final String COMPONENT_FLIPBOOK_NODE = "spec";
    public final String PAGE_FLIPBOOK_NODE = "flipbook";
    public final String[] README_NAMES = new String[]{"README.md", "SPEC.md", "README.html", "SPEC.html", "README.txt", "SPEC.txt", "README", "SPEC"};
    public final String[] IMAGE_EXTENSIONS = new String[]{"png", "jpg", "gif", "jpeg"};
    public final String[] PAGE_RESOURCE_SUPER_TYPES = new String[]{
            "foundation/components/page",
            "wcm/mobile/components/page",
            "mcm/components/newsletter/page"
    };
    public final int MAX_RESULTS = 10000;
    public final String HIDDEN_COMPONENT_GROUP = ".hidden";

    public Resource getFlipbookResource(final Resource resource);

    public List<String> getPaths(final Page page);

    public boolean getShowHidden(final ValueMap properties);

    public List<Resource> getPages(final Resource resource) throws RepositoryException;

    public List<Resource> getWidgetResources(final Resource resource) throws RepositoryException;

    public List<ValueMap> getDialogFields(final Resource resource, final DialogType dialogType, final List<Resource> cachedWidgetResources) throws RepositoryException;

    public String getReadme(final Component component, final ResourceResolver resourceResolver);

    public List<String> getImagePaths(final Component component, final ResourceResolver resourceResolver);

    public boolean isPageImplementation(final Component component);

    public String getIconPath(final Component component);

    public String yesNo(final boolean o);

    public String yesNo(final Object o);

    public List<String> getToolbarList(final Toolbar toolbar);

    public enum DialogType {DIALOG, DESIGN_DIALOG}
}
