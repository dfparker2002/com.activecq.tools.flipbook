
jQuery(function() {
    var showAll = false;

    var current = jQuery('.js-flipbook-page').first();
    current.show();

    jQuery('.js-flipbook .js-next').on('click', function() {
        if(showAll) { return; }
        var next = current.next('.js-flipbook-page');
        if(next.length > 0) {
            current.hide();
            current = next.show();
        }
        return false;
    });

    jQuery('.js-flipbook .js-previous').on('click', function() {
        if(showAll) { return; }
        var previous = current.prev('.js-flipbook-page');
        if(previous.length > 0) {
            current.hide();
            current = previous.show();
        }
        return false;
    });

    jQuery('.js-flipbook .js-show-all').on('click', function() {
        showAll = true;
        jQuery('.js-flipbook-page').show();
        jQuery('.js-divider').show();
        jQuery('.js-show-all').hide();
        jQuery('.js-hide').show();

        jQuery('.js-previous').hide();
        jQuery('.js-next').hide();
        return false;
    });

    jQuery('.js-flipbook .js-hide').on('click', function() {
        if(!showAll) { return; }
        showAll = false;
        jQuery('.js-flipbook-page').hide();
        jQuery('.js-divider').hide();
        jQuery('.js-hide').hide();
        jQuery('.js-show-all').show();
        current.show();

        jQuery('.js-previous').show();
        jQuery('.js-next').show();
        return false;
    });


    jQuery('.js-flipbook .js-show-technical-details').on('click', function() {
        jQuery(this).hide();
        jQuery('.js-flipbook .js-hide-technical-details').show();
        jQuery('.js-flipbook .js-technical-details').show();

       return false;
    });

    jQuery('.js-flipbook .js-hide-technical-details').on('click', function() {
        jQuery(this).hide();
        jQuery('.js-flipbook .js-show-technical-details').show();
        jQuery('.js-flipbook .js-technical-details').hide();
        return false;
    });

});