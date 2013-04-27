jQuery(function() {
    jQuery('.js-flipbook .js-gallery .js-gallery-link').on('click', function() {
        var id = jQuery(this).data('gallery-id');
        var gallery = jQuery(this).closest('.js-flipbook .js-gallery');
        var links = jQuery(this).closest('.js-flipbook .js-gallery-links');

        links.find('.js-gallery-link').removeClass('active');
        jQuery(this).addClass('active');

        gallery.find('.js-gallery-image').hide();
        gallery.find('.js-gallery-image[data-gallery-id="' + id + '"]').show();

        return false;
    });

    jQuery('.js-flipbook .js-flipbook-page').each(function() {
        var pageNumber = jQuery(this).data('page-number');
        jQuery(this).find('.js-gallery .js-gallery-image-link').colorbox({maxWidth: "900px", rel: "js-gallery-" + pageNumber});
    });
});