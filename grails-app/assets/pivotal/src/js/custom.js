($ => {
  $(document).ready(($) => {

    /**
     * Mobile (off-canvas) menu
     */
    $('[data-toggle="offcanvas"]').on('click', function () {
      $('.site').toggleClass('offcanvas-open');
    });


    /**
     * Hero Banner
     */
    $('.hero-slider').each((index, el) => {
      $(el).addClass(`hero-slide-${index}`);

      new Swiper(`.hero-slide-${index}`, {
        loop: true,
        slidesPerView: 1,
        spaceBetween: 0,
        speed: 1000,
        autoplay: {
          delay: 5000,
          disableOnInteraction: false
        },
        preventClicks: false,
        effect: 'fade',
        preloadImages: false,
        lazy: {
          loadPrevNext: true,
        },
        navigation: false,
        pagination: {
          el: '.swiper-pagination',
          type: 'bullets',
          clickable: true,
        },
      });
    });

    /**
     * Post Sliders
     */

    const postSlider = [];

    $('.post-slider').each((index, el) => {
      $(el).addClass(`post-slider-${index}`);

      const delay = Math.floor((Math.random() * 500) + 6000);

      postSlider[index] = new Swiper(`.post-slider-${index}`, {
        loop: true,
        slidesPerView: 1,
        spaceBetween: 20,
        speed: 1000,
        autoplay: {
          delay: delay,
          disableOnInteraction: true
        },
        preventClicks: false,
        preloadImages: false,
        lazy: {
          loadPrevNext: true,
        },
        navigation: false,
        pagination: false,
      });
    });

    $(".post-slider").hover(function () {
      this.swiper.autoplay.stop();
    }, function () {
      this.swiper.autoplay.start();
    });


    /**
     * Tooltips
     */
    $('[data-toggle="tooltip"]').tooltip();


    //Count up to data-count num
    $('[data-count]').each(function () {
      const $this = $(this),
          countTo = $this.attr('data-count');

      $this.html('0');

      $({countNum: $this.text()}).animate({
            countNum: countTo
          },

          {

            duration: 4000,
            easing: 'linear',
            step: function () {
              const countNumFloor = Math.floor(this.countNum);
              $this.text(countNumFloor.toLocaleString());
            },
            complete: function () {
              $this.text(this.countNum.toLocaleString());
            }

          });
    });

    const datepicker = $('.input-daterange');

    if (datepicker.length) {

      const dateFormat = "dd/mm/yy",
          from = $("#start")
              .datepicker({
                changeMonth: true,
                numberOfMonths: 1,
                dateFormat: dateFormat
              })
              .on("change", function () {
                to.datepicker("option", "minDate", getDate(this));
              }),
          to = $("#end").datepicker({
            defaultDate: "+1w",
            changeMonth: true,
            numberOfMonths: 1,
            dateFormat: dateFormat
          })
              .on("change", function () {
                from.datepicker("option", "maxDate", getDate(this));
              });

      function getDate(element) {
        let date;
        try {
          date = $.datepicker.parseDate(dateFormat, element.value);
        } catch (error) {
          date = null;
        }

        return date;
      }

    }
    //End datepicker section


    const closeFilters = () => {
      if ($(window).outerWidth() < 576) {
        $('.expander').collapse('hide');
      }
    };

    closeFilters();

    $(window).on('resize', function () {
      closeFilters();
    });

  });

})(jQuery);
