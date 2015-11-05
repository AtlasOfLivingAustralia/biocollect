/**
 * Created by Temi Varghese on 3/11/15.
 * modifying bootstrap to trigger event on changing toggle.
 */

jQuery.fn.button.Constructor.prototype.toggle = function () {
    var $parent = this.$element.closest('[data-toggle="buttons-radio"]')

    $parent && $parent
        .find('.active')
        .removeClass('active')

    this.$element.toggleClass('active')
    this.$element.trigger('statechange')
}