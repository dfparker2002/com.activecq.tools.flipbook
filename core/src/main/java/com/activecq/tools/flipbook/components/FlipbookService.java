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
    public Resource getFlipbookResource(final Resource resource);

    public List<String> getPaths(final Page page);

    public boolean getShowHidden(final ValueMap properties);

    public List<Resource> getPages(final Resource resource) throws RepositoryException;

    public List<ValueMap> getDialogFields(Resource resource, DialogType dialogType) throws RepositoryException;

    public String getReadme(final Component component, final ResourceResolver resourceResolver);

    public List<String> getImagePaths(final Component component, final ResourceResolver resourceResolver);

    public boolean isPageImplementation(Component component);

    public String getIconPath(Component component);

    public String yesNo(boolean o);

    public String yesNo(Object o);

    public List<String> getToolbarList(Toolbar toolbar);

    public enum DialogType {DIALOG, DESIGN_DIALOG}
}
