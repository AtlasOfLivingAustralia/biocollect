<%@ page contentType="text/css;charset=UTF-8" %>
@import url(https://fonts.googleapis.com/css?family=Roboto:300,400,500,700,900);
body {
  background-color: ${bodybackgroundcolor}  !important;
  font-family: Roboto, Helvetica, "Helvetica Neue", Arial, sans-serif;
  padding-top: 0px;
  padding-bottom: 0px;
  color: ${bodytextcolor};
}

.margin-top-70 {
  margin-top: 70px;
}

/** copied from ala-styles bootstrap3 since bootstrap2 did not have this style **/
section#breadcrumb li + li::before {
  content: "\f105";
  font-family: FontAwesome;
  margin: 0 0.6em;
  height: 0.8em;
  opacity: 0.6;
}

section#breadcrumb {
  border-bottom: 1px solid ${breadcrumbbackgroundcolour};
  background-color: ${breadcrumbbackgroundcolour};
}

#main-content {
  /* Navbar */
  /* Home page */
  /* Responsive rules */
  /* Echo out a label for the example */
  /*image display size on project finder*/
}
#main-content h1, #main-content h2, #main-content h3, #main-content h4, #main-content h5 {
  font-family: Roboto, Helvetica, "Helvetica Neue", Arial, sans-serif;
  font-weight: 500;
}
#main-content .ftr-container .ftr-social {
  margin-bottom: 0px;
}
#main-content input, #main-content button,
#main-content select,
#main-content textarea {
  font-family: Roboto, Helvetica, "Helvetica Neue", Arial, sans-serif;
}
#main-content #breadcrumb {
  margin-top: 10px;
}
#main-content #main-content #searchInfoRow #customiseFacetsButton > .dropdown-menu {
  background-color: ${bodybackgroundcolor};
}
#main-content a {
  color: ${hrefcolor};
  text-decoration: none;
}
#main-content a:hover,
#main-content a:focus {
  color: ${hrefcolor};
}
#main-content .btn.btn-default {
  color: ${defaulttextcolor};
  background-color: ${defaultbackgroundcolor};
  background-image: linear-gradient(to bottom, ${defaultbackgroundcolor}, ${defaultbackgroundcolor});
  border-color: ${defaultbackgroundcolor} ${defaultbackgroundcolor} ${defaultbackgroundcolor} ${defaultbackgroundcolor};
}
#main-content .btn:hover,
#main-content .btn:focus,
#main-content .btn:active,
#main-content .btn.active,
#main-content .btn.disabled,
#main-content .btn[disabled],
#main-content .btn-default:hover,
#main-content .btn-default:focus,
#main-content .btn-default:active,
#main-content .btn-default.active,
#main-content .btn-default.disabled,
#main-content .btn-default[disabled] {
  color: ${defaultbtncoloractive};
  background-color: ${defaultbtnbackgroundcoloractive};
  background-position: center center;
}
#main-content .btn-primary {
  color: ${primarytextcolor};
  background-color: ${primarybackgroundcolor};
  background-image: linear-gradient(to bottom, ${primarybackgroundcolor}, ${primarybackgroundcolor});
  border-color: ${primarybackgroundcolor} ${primarybackgroundcolor} ${primarybackgroundcolor} ${primarybackgroundcolor};
}
#main-content .btn-primary:hover,
#main-content .btn-primary:focus,
#main-content .btn-primary:active,
#main-content .btn-primary.active,
#main-content .btn-primary.disabled,
#main-content .btn-primary[disabled] {
  color: #ffffff;
  background-color: ${primarybackgroundcolor};
}
#main-content .btn-primary:active,
#main-content .btn-primary.active {
  background-color: ${primarybackgroundcolor} 9 ;
}
#main-content .btn-danger:hover {
  color: white;
}
#main-content .btn-danger {
  color: white;
}
#main-content .btn-group .active {
  background-color: #ddd;
  color: black;
}
#main-content .bootstrap-switch .bootstrap-switch-handle-on.bootstrap-switch-success,
#main-content .bootstrap-switch .bootstrap-switch-handle-off.bootstrap-switch-success {
  background-color: ${primarycolor};
  background-image: linear-gradient(to bottom, ${primarycolor}, ${primarycolor});
  border-color: ${primarycolor} ${primarycolor} ${primarycolor} ${primarycolor};
}
#main-content .nav-tabs > .active > a, #main-content .nav-tabs > .active > a:hover, #main-content .nav-tabs > .active > a:focus {
  background-color: white;
}
#main-content .form-actions {
  border: 0px;
  background-color: inherit;
}
#main-content .nav {
  margin-top: 20px;
}
#main-content #content .nav-tabs > li.active > a {
  background-color: #ffffff;
}
#main-content .brand .headerLogo {
  height: 36px;
  padding-top: 10px;
  margin-top: -3px;
}
#main-content #mdbaLink .headerLogo {
  margin-top: -12px;
}
#main-content #mdbaHeadingText {
  display: inline-block;
  padding-top: 14px;
  padding-left: 5px;
}
#main-content #homeBanner {
  background-position: center;
  background-repeat: no-repeat;
  background-color: ${bannerbackgroundcolor};
  height: 240px;
  padding: 20px 40px;
  margin-top: 0px;
}
#main-content #bannerImg {
  max-height: 250px;
  display: block;
  margin-left: 25px;
}
#main-content .indexBuffer {
  margin-top: 50px;
}
#main-content .nav-well {
  display: block;
  width: 100%;
}
#main-content .homePageNav h4 {
  font-size: 20px;
  margin-bottom: 0;
}
#main-content .homePageNav h3 {
  font-size: 36px;
  margin-top: 0;
  margin-bottom: 5px;
  color: ${navtextcolor};
}
#main-content .homePageNav h3.condensed {
  font-size: 30px;
  letter-spacing: -1px;
  line-height: 35px;
}
#main-content .homePageNav .nav-well {
  min-height: 135px;
  background-color: ${navbackgroundcolor};
  border: 0px solid ${navbackgroundcolor};
  padding: 30px 15px;
  -webkit-border-radius: 10px;
  -moz-border-radius: 10px;
  border-radius: 10px;
  -webkit-box-shadow: inset 0 1px 1px rgba(0, 0, 0, 0.05);
  -moz-box-shadow: inset 0 1px 1px rgba(0, 0, 0, 0.05);
  box-shadow: inset 0 1px 1px rgba(0, 0, 0, 0.05);
}
#main-content .nav-well {
  min-height: 135px;
  background-color: ${wellbackgroundcolor};
  border: 0px solid ${wellbackgroundcolor};
  padding: 30px 15px;
  -webkit-border-radius: 10px;
  -moz-border-radius: 10px;
  border-radius: 10px;
  -webkit-box-shadow: inset 0 1px 1px rgba(0, 0, 0, 0.05);
  -moz-box-shadow: inset 0 1px 1px rgba(0, 0, 0, 0.05);
  box-shadow: inset 0 1px 1px rgba(0, 0, 0, 0.05);
}
#main-content .well {
  background-color: ${wellbackgroundcolor};
  border: 0px solid ${wellbackgroundcolor};
  -webkit-box-shadow: none;
  box-shadow: none;
  -moz-box-shadow: none;
}
#main-content #pt-selectors.well {
  background-color: ${facetbackgroundcolor};
  border: 0px solid ${facetbackgroundcolor};
}
#main-content #pt-table .tile {
  background-color: ${tilebackgroundcolor};
  border: 0px solid ${tilebackgroundcolor};
}
#main-content #quickSearchBox {
  margin-top: -46px;
  margin-bottom: 10px;
}
#main-content #quickSearchBox .input-append input {
  font-size: 20px;
  padding: 14px 20px 12px 25px;
  width: 200px;
  -webkit-border-radius: 25px 0 0 25px;
  -moz-border-radius: 25px 0 0 250px;
  border-radius: 25px 0 0 25px;
  height: 20px !important;
  line-height: normal;
}
#main-content #quickSearchBox .input-append .btn:last-child,
#main-content #quickSearchBox .input-append .btn-group:last-child > .dropdown-toggle {
  font-size: 20px;
  padding: 14px 12px 12px 10px;
  -webkit-border-radius: 0 25px 25px 0;
  -moz-border-radius: 25px 25px 0;
  border-radius: 0 25px 25px 0;
  line-height: 20px;
}
#main-content #customiseFacetsButton > .dropdown-menu,
#main-content #resultsReturned .dropdown-menu {
  background-color: ${bodybackgroundcolor};
}
#main-content .staticContent {
  margin-top: 30px;
  padding-left: 14px;
  padding-right: 14px;
}
#main-content .staticContent h2, #main-content .staticContent h3, #main-content .staticContent h4 {
  color: ${primarycolor};
}
#main-content .leaflet-container a {
  color: black;
}
@media (max-width: 979px) {
  #main-content .navbar-inverse .nav-collapse .nav > li > a,
#main-content .navbar-inverse .nav-collapse .dropdown-menu a {
    color: #efefef;
  }
  #main-content .navbar-inner ul li:not(:last-child), #main-content .navbar-inner ul li:last-child {
    border-right: none;
    margin: 8px;
    padding: 0px;
  }
}
@media (max-width: 767px) {
  #main-content #quickSearchBox .input-append input, #main-content #quickSearchBox .input-append .btn:last-child {
    height: 20px;
    padding: 4px 12px 2px 10px;
    min-height: 30px;
    box-sizing: inherit;
  }
}
#main-content #bannerHub {
  max-height: 350px;
  width: 100%;
  margin: 0 auto;
  overflow: hidden;
}
#main-content #bannerHubOuter {
  position: relative;
  min-height: 100px;
  max-height: 350px;
}
#main-content #bannerHubContainer {
  background-color: ${bannerbackgroundcolor};
  position: relative;
  padding-top: 25px;
}
#main-content #hubHomepageContent {
  padding-top: 20px;
}
#main-content #main-content.homepage {
  padding-top: 0px;
}
#main-content #main-content {
  min-height: 1000px;
}
#main-content #bannerHub .carousel-caption {
  position: absolute;
  right: 80px;
  bottom: auto;
  top: 80px;
  left: auto;
  width: 15%;
  min-height: 100px;
  max-height: 200px;
  background: ${insetbackgroundcolor};
  opacity: 0.75;
}
#main-content #bannerHub .carousel-caption h4, #main-content #bannerHub .carousel-caption p {
  color: ${insettextcolor};
}
#main-content #bannerHub .carousel-caption p {
  Font-size: x-large;
  Font-weight: bold;
  Line-height: 1.2em;
}
#main-content #bannerHub .carousel-inner .item img {
  width: 100%;
  height: 100%;
}
#main-content #bannerHubOuter .logo {
  left: 80px;
  top: -25px;
  max-width: 250px;
  max-height: 250px;
  position: absolute;
  z-index: 5;
}
#main-content #pt-search {
  Min-width: 150px;
  Max-width: 300px;
  Width: 20%;
  Padding: 5px;
}
#main-content #pt-search-link {
  Padding: 5px;
}
#main-content H1 {
  color: ${titletextcolor};
}
#main-content #headerBannerSpace {
  background-color: ${headerbannerspacebackgroundcolor};
}
#main-content .output-section {
  position: relative;
  margin: 15px 0;
  padding: 50px 15px 14px;
  background-color: #fff;
  border: 1px solid #ddd;
  box-sizing: border-box;
}
#main-content textarea {
  resize: none;
  height: auto;
}
#main-content .form-control, #main-content input.form-control, #main-content .input-append .add-on {
  padding: 4px 5px;
}
#main-content .full-width {
  width: 100%;
  box-sizing: border-box;
  -moz-box-sizing: border-box;
  -webkit-box-sizing: border-box;
}
#main-content input.full-width-input {
  width: 100%;
  height: 30px;
  box-sizing: border-box;
  -moz-box-sizing: border-box;
  -webkit-box-sizing: border-box;
}
#main-content .boxed-heading {
  position: relative;
  margin: 15px 0;
  padding: 50px 15px 14px;
  background-color: #fff;
  border: 1px solid #ddd;
  box-sizing: border-box;
}
#main-content .boxed-heading:after {
  content: attr(data-content);
  position: absolute;
  top: -1px;
  left: -1px;
  padding: 7px 15px;
  font-size: 125%;
  font-weight: 300;
  background-color: #ddd;
  border: 1px solid #ccc;
  color: inherit;
  line-height: 1;
}
#main-content .image-logo {
  max-width: 100%;
  max-height: 100%;
}
#main-content .tall {
  width: auto;
  height: 100%;
}
#main-content ​ .list-image-height {
  height: 120px;
}
#main-content #main-content {
  margin-top: 50px;
}
#main-content ul.quicklinks.breadcrumb {
  margin-top: 20px;
  margin-bottom: 20px;
}
#main-content .nav-pills > .active > a, #main-content .nav-pills > .active > a:hover, #main-content .nav-pills > .active > a:focus {
  color: #fff;
  background-color: #c44d34;
}
#main-content .dropzone {
  width: 205px;
  font-weight: 500;
  font-size: 20px;
  border: 1px solid #5F5D60;
  padding: 20px;
  box-sizing: border-box;
  -webkit-box-sizing: border-box;
  -moz-box-sizing: border-box;
  background-color: #f5f5f5;
}
#main-content .popover-content {
  color: ${bodytextcolor};
}

#ala-header-bootstrap2 .navbar-default .navbar-nav > li > a {
  color: #555;
}
#ala-header-bootstrap2 .navbar-default .navbar-nav > li > a:hover {
  color: #111;
}

#biocollect-header body.nav-getinvolved {
  padding-top: 0px;
}
#biocollect-header nav#biocollectNav > ul {
  list-style-type: none;
  margin: 0;
  padding: 0;
  font-size: 0;
  text-align: left;
  background: #2b7b75;
}
#biocollect-header nav#biocollectNav.ecoScienceNav > ul, #biocollect-header nav#biocollectNav.ecoScienceNav > ul > li a, #biocollect-header nav#biocollectNav.ecoScienceNav ul#main > li > a.ala-link {
  color: #555;
  background: #94deff;
}
#biocollect-header nav#biocollectNav.ecoScienceNav > ul > li a + ul li a:hover, #biocollect-header nav#biocollectNav.ecoScienceNav > ul > li:hover > a {
  background: #64aac8;
}
#biocollect-header nav#biocollectNav.ecoScienceNav ul > li.active > a {
  background: #64aac8;
}
#biocollect-header nav#biocollectNav > ul > li {
  display: inline-block;
  position: relative;
}
#biocollect-header nav#biocollectNav > ul > li.more > a .fa {
  color: yellow;
}
#biocollect-header nav#biocollectNav > ul > li.hidden {
  display: none;
}
#biocollect-header nav#biocollectNav > ul > li > a {
  border-right: 1px dashed white;
}
#biocollect-header nav#biocollectNav > ul > li a {
  font-size: 1rem;
  display: block;
  background: #2b7b75;
  color: #FFF;
  text-align: center;
  text-decoration: none;
  padding: 10px 20px 5px 20px;
}
#biocollect-header nav#biocollectNav > ul > li a .fa {
  font-size: 20px;
  display: block;
  margin-bottom: 10px;
}
#biocollect-header nav#biocollectNav ul > li.active > a {
  background-color: #444d58;
}
#biocollect-header nav#biocollectNav > ul > li a + ul {
  display: none;
  position: absolute;
  top: 100%;
  right: 0;
  margin-right: 0;
  list-style-type: none;
}
#biocollect-header nav#biocollectNav > ul > li a + ul li {
  margin-top: 1px;
  position: relative;
  /*
  Input when focused hides the drop down menu. This was happening since bootstrap sets z-index=2 when an
  input field is focused.
  */
  z-index: 3;
}
#biocollect-header nav#biocollectNav > ul > li a + ul li a {
  padding-left: 16px;
  text-align: left;
  white-space: nowrap;
}
#biocollect-header nav#biocollectNav > ul > li a + ul li a .fa {
  display: inline-block;
  margin-right: 10px;
  margin-bottom: 0;
}
#biocollect-header nav#biocollectNav > ul > li a + ul li a:hover {
  background: #444d58;
}
#biocollect-header nav#biocollectNav > ul > li:hover > a {
  background: #444d58;
}
#biocollect-header nav#biocollectNav > ul > li:hover ul {
  display: block;
}
#biocollect-header nav#biocollectNav > ul > li.more > ul.more-ul > li > ul {
  display: block;
  position: relative;
}
#biocollect-header .ala-icon:before {
  content: url(https://www.ala.org.au/wp-content/themes/ala2011/images/favicon.ico);
}
#biocollect-header nav#biocollectNav ul#main > li > a.ala-link {
  padding-top: 25px, !important;
  padding-bottom: 10px, !important;
  color: white;
  font-size: large;
  border-right: 0px dashed #d1f5d6;
}
#biocollect-header nav#biocollectNav ul#main li a.ala-link:hover {
  color: #5f5d60;
  background: #2b7b75;
}
#biocollect-header .ala-header {
  background: url(https://www.ala.org.au/wp-content/themes/ala-wordpress-theme/img/species-by-location-phyllopteryx-taeniolatus.jpg) no-repeat center top;
  height: 225px;
  background-size: cover;
  background-position-y: -54px;
}
#biocollect-header .ala-header .input-append, #biocollect-header .ala-header-works .input-append, #biocollect-header .ala-header-ecoscience .input-append {
  margin-top: 75px;
}
#biocollect-header .ala-header-works {
  background: url(https://www.ala.org.au/wp-content/uploads/2015/07/Revegetation.jpg) no-repeat center top;
  height: 225px;
  background-size: cover;
  background-position-y: -54px;
}
#biocollect-header .ala-header-ecoscience {
  background: url(https://www.ala.org.au/wp-content/uploads/2015/07/ES-banner-4.jpg) no-repeat center top;
  height: 350px;
  background-size: cover;
  background-position-y: -90px;
}
#biocollect-header #biocollectlogo {
  background-color: white !important;
}
#biocollect-header #biocollectlogo > img {
  width: 193px;
}
#biocollect-header .acsa-image {
  content: url(ACSA_logo_white.png);
  height: 45px;
}
#biocollect-header nav#biocollectNav > ul > li#acsa-banner {
  display: inline-block;
}
#biocollect-header nav#biocollectNav .more li#acsa-banner {
  display: none;
}
#biocollect-header nav#biocollectNav > ul > li#acsa-banner a {
  border-right: 0px;
}
#biocollect-header nav#biocollectNav .more li#acsa-text {
  display: inline-block;
}
#biocollect-header nav#biocollectNav > ul > li#acsa-text {
  display: none;
}
#biocollect-header .acsa-icon {
  content: url(acsa_icon.png);
  height: 20px;
}
#biocollect-header .row-fluid {
  box-sizing: border-box;
  -moz-box-sizing: border-box;
  -webkit-box-sizing: border-box;
}

#custom-header .navbar {
  min-height: 58px;
  font-family: Roboto, Helvetica, "Helvetica Neue", Arial, sans-serif;
  border-bottom: 0px solid #fff;
}
#custom-header .navbar-inverse .navbar-inner {
  background-color: ${menubackgroundcolor};
  background-image: linear-gradient(to bottom, ${menubackgroundcolor}, ${menubackgroundcolor});
  background-repeat: repeat-x;
  border-color: ${menubackgroundcolor};
  filter: progid:DXImageTransform.Microsoft.gradient(startColorstr="#ff222222", endColorstr="#ff111111", GradientType=0);
}
#custom-header .navbar-inverse .contain-to-grid {
  min-height: 52px;
  padding-top: 5px;
}
#custom-header .navbar-inner ul.nav li {
  margin-top: 13px;
  font-size: 18px;
  min-height: 18px;
}
#custom-header .navbar-inner a.brand {
  color: white;
  padding: 0 0;
}
#custom-header .navbar-inner ul.nav > li > a {
  padding: 0 0 0 0;
}
#custom-header .navbar .brand {
  font-size: 18px;
  font-weight: normal;
  margin: 0 10px 0 10px;
}
#custom-header .brand .headerLogo {
  max-height: 32px;
}
#custom-header .navbar-inverse .nav > li.main-menu > a {
  color: ${menutextcolor};
}
#custom-header .navbar-inner ul li:not(:last-child) {
  border-right: 2px solid ${menutextcolor};
  margin-right: 14px;
  padding-right: 14px;
}

/* custom footer */
#custom-footer {
  background-color: ${footerbackgroundcolor};
  color: #efefef;
  margin-top: 50px;
  padding-top: 20px;
  padding-bottom: 25px;
  font-size: 16px;
}
#custom-footer .container {
  padding: 0 20px;
}
#custom-footer .nav {
  margin: 18px 0 20px 0;
  font-size: 18px;
  height: 18px;
}
#custom-footer ul.nav > li {
  float: left;
}
#custom-footer .navbar-inverse .nav > li > a {
  float: none;
  padding: 0;
  color: ${footertextcolor};
  text-decoration: none;
}
#custom-footer .navbar-inverse .nav > li > a:hover {
  text-decoration: underline;
}
#custom-footer .navbar-inverse ul li:not(:last-child) {
  border-right: 2px solid ${footertextcolor};
  margin-right: 14px;
  padding-right: 14px;
}
#custom-footer .navbar-inverse .brand {
  color: ${footertextcolor};
  padding: 0;
}
#custom-footer #smlinks {
  margin-top: 5px;
}
#custom-footer #smlinks a {
  color: ${socialtextcolor};
  text-decoration: none;
  margin-right: 5px;
}
@media (max-width: 979px) {
  #custom-footer .nav {
    font-size: 15px;
  }
}
#custom-footer #alaHeadingText {
  display: inline-block;
  margin-left: 5px;
  margin-top: 4px;
  line-height: 1.1em;
}
#custom-footer #alaLink .headerLogo {
  margin-top: -27px;
}
#custom-footer #poweredBy {
  font-size: 11px;
  display: block;
}
#custom-footer #alaBy {
  font-size: 16px;
}
#custom-footer .brand .headerLogo {
  height: 36px;
  padding-top: 10px;
  margin-top: -3px;
}