
<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="description" content="">
    <meta name="author" content="">

    <title>BioCollect | ${hubConfig.title}</title>

    <link href="//fonts.googleapis.com/css?family=Lato:700,900|Roboto:400,400i,500" rel="stylesheet">
    <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.7.2/css/all.css" integrity="sha384-fnmOCqbTlWIlj8LyTjo7mOUStjsKC4pOpQbqyi7RrhN7udi9RwhKkMHpvLbHG9Sr" crossorigin="anonymous">

    <!-- Our Stylesheet-->
    <link href="${asset.assetPath(src:"assets/css/styles.css")}" rel="stylesheet" />

    <asset:stylesheet src="pivotal_core.css" />
    <asset:script type="text/javascript">
    </asset:script>
    <asset:javascript src="pivotal_core.js" />
    <script src="${grailsApplication.config.google.maps.url}" async defer></script>
</head>

<body class="button-hub">

<div class="site" id="page">


    <!-- ******************* The Navbar Area ******************* -->
    <div id="wrapper-navbar" itemscope="" itemtype="http://schema.org/WebSite">
        <a class="skip-link sr-only sr-only-focusable" href="#content">Skip to content</a>

        <nav class="navbar navbar-expand-lg navbar-dark navbar-alt">
            <div class="container">

                <!-- Your site title as branding in the menu -->
                <a href="/" class="custom-logo-link navbar-brand" rel="home" itemprop="url">
                ${hubConfig.title}
                </a> <!-- end custom logo -->

                <div class="outer-nav-wrapper">

                    <div class="main-nav-wrapper">
                        <button data-toggle="modal" data-target="#search-modal" class="search-trigger order-1 order-lg-3" title="search">
                            <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 22 22">
                                <defs>
                                    <style>
                                    .search-icon {
                                        fill: #fff;
                                        fill-rule: evenodd;
                                    }
                                    </style>
                                </defs>
                                <path class="search-icon" d="M1524.33,60v1.151a7.183,7.183,0,1,1-2.69.523,7.213,7.213,0,0,1,2.69-.523V60m0,0a8.333,8.333,0,1,0,7.72,5.217A8.323,8.323,0,0,0,1524.33,60h0Zm6.25,13.772-0.82.813,7.25,7.254a0.583,0.583,0,0,0,.82,0,0.583,0.583,0,0,0,0-.812l-7.25-7.254h0Zm-0.69-7.684,0.01,0c0-.006-0.01-0.012-0.01-0.018s-0.01-.015-0.01-0.024a6,6,0,0,0-7.75-3.3l-0.03.009-0.02.006v0a0.6,0.6,0,0,0-.29.293,0.585,0.585,0,0,0,.31.756,0.566,0.566,0,0,0,.41.01V63.83a4.858,4.858,0,0,1,6.32,2.688l0.01,0a0.559,0.559,0,0,0,.29.29,0.57,0.57,0,0,0,.75-0.305A0.534,0.534,0,0,0,1529.89,66.089Z"
                                      transform="translate(-1516 -60)"></path>
                            </svg>
                            Search</button>
                        <a href="#" class="account-mobile order-2 d-lg-none" title="My Account">
                            <svg xmlns="http://www.w3.org/2000/svg" width="25" height="25" viewBox="0 0 37 41">
                                <defs>
                                    <style>
                                    .account-icon {
                                        fill: #212121;
                                        fill-rule: evenodd;
                                    }
                                    </style>
                                </defs>
                                <path id="Account" class="account-icon" d="M614.5,107.1a11.549,11.549,0,1,0-11.459-11.549A11.516,11.516,0,0,0,614.5,107.1Zm0-21.288a9.739,9.739,0,1,1-9.664,9.739A9.711,9.711,0,0,1,614.5,85.81Zm9.621,23.452H604.874a8.927,8.927,0,0,0-8.881,8.949V125h37v-6.785A8.925,8.925,0,0,0,624.118,109.262Zm7.084,13.924H597.789v-4.975a7.12,7.12,0,0,1,7.085-7.139h19.244a7.119,7.119,0,0,1,7.084,7.139v4.975Z"
                                      transform="translate(-596 -84)"></path>
                            </svg>
                            Account</a>
                        <a href="javascript:" class="navbar-toggler order-3 order-lg-2" type="button" data-toggle="offcanvas"
                           data-target="#navbarNavDropdown" aria-controls="navbarNavDropdown" aria-expanded="false" aria-label="Toggle navigation">
                            <span class="navbar-toggler-icon"></span>
                        </a>


                        <!-- The Main Menu goes here -->
                        <div id="navbarNavDropdown" class="collapse navbar-collapse offcanvas-collapse">
                            <ul class="navbar-nav ml-auto">
                                <li itemscope="itemscope" itemtype="https://www.schema.org/SiteNavigationElement" class="menu-item nav-item">
                                    <a title="Home" href="#" class="nav-link">Home</a>
                                </li>
                                <li itemscope="itemscope" itemtype="https://www.schema.org/SiteNavigationElement" class="menu-item nav-item">
                                    <a title="Target Species" href="#" class="nav-link">Target Species</a>
                                </li>
                                <li itemscope="itemscope" itemtype="https://www.schema.org/SiteNavigationElement" class="menu-item nav-item">
                                    <a title="Data" href="#" class="nav-link">Data</a>
                                </li>
                                <li itemscope="itemscope" itemtype="https://www.schema.org/SiteNavigationElement" class="menu-item nav-item">
                                    <a href="#" class="btn btn-primary btn-sm nav-button" title="Login">Login</a>
                                </li>
                            </ul>
                        </div>
                    </div>

                </div>
            </div><!-- .container -->

        </nav><!-- .site-navigation -->

    </div><!-- #wrapper-navbar end -->
    <div class="wrapper" id="buttonHub">

        <main class="site-main" id="main" role="main">

            <article class="page">
<!--
                <div id="banner" class="page-banner" style="background-image: url('${asset.assetPath(src: "assets/img/banner.jpg")}');">
                </div>
-->
                <div id="banner" class="page-banner" style="background-image: url('https://ecodata.ala.org.au/uploads/2017-07/Feature_Graphic_-_1024_x_250_HR-01.png');">
                </div>


                <div id="titleBar">
                    <div class="container">
                        <div class="row d-flex title-row">
                            <div class="col-12 col-lg-auto flex-shrink-1 d-flex mb-4 mb-lg-0 justify-content-center justify-content-lg-end">
                                <div class="main-image">
                                    <img src="data:image/png;base64,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" alt="Australian Citizen Science Association"/>
                                </div>
                            </div>
                            <div class="col d-flex align-items-center justify-content-center justify-content-lg-end">
                                <a href="#" class="btn btn-lg btn-primary-dark" title="Getting Started"><i class="fas fa-info-circle"></i>
                                    Getting Started</a>
                                <a href="#" class="btn btn-lg btn-primary-dark" title="What is this?"><i
                                        class="far fa-question-circle"></i> What is this?</a>
                            </div>
                        </div>
                    </div>
                </div>

                <section class="text-center section-padding">
                    <div class="container">
                        <div class="row">
                            <div class="col-12 col-md-10 offset-0 offset-md-1">
                                <p>
                                    Citizen scientists and biocontrol end-users (including farmers, natural resource managers, community groups and others) play an important role in monitoring biocontrol agent releases, and recording field observations of agent occurrence. However, significant barriers can prevent biocontrol agent data being captured, shared and used. Maintaining and accessing long-term monitoring data is particularly problematic.
                                </p>
                                <p>
                                The Atlas of Living Australia (ALA) is a national on-line biodiversity database that has potential to address these barriers. The ALA contains tens of millions of user-submitted species occurrence records from field observations, collections and surveys. Data such as location coordinates, photographs, and species and host information, can be uploaded and later accessed in spreadsheets or species distribution maps.
                                </p>
                            </div>
                        </div>
                    </div>
                </section>

                <section id="buttonGrid">
                    <div class="container">
                        <div class="row d-flex">
                            <div class="col-12 col-md-6 col-lg-4 mb-4 d-flex">
                                <a href="#" class="btn btn-primary-dark btn-lg">
                                    <!-- <div class="image"><img src="${asset.assetPath(src:"assets/img/blog1.jpg")}" alt="Example Image"></div> -->
                                    <!-- <div class="image"><img src="https://ecodata.ala.org.au/uploads/2017-07/Feature_Graphic_-_1024_x_250_HR-01.png" alt="Example Image"></div>
                                    <div class="image"><img src="data:image/png;base64,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" alt="Example Image"></div>
                                    -->
                                    <span>Go to bioControl projects</span></a>
                            </div>
                            <div class="col-12 col-md-6 col-lg-4 mb-4 d-flex">
                                <a href="#" class="btn btn-primary-dark btn-lg">
                                    <!--
                                    <div class="image"><span class="fa fa-2x fa-suitcase"></span></div>
                                    -->
                                    <span>About the biocontrol</span>
                                </a>
                            </div>
                            <div class="col-12 col-md-6 col-lg-4 mb-4 d-flex">
                                <a href="#" class="btn btn-primary-dark btn-lg"><span>What is biocontrol?</span></a>
                            </div>
                            <div class="col-12 col-md-6 col-lg-4 mb-4 d-flex">
                                <a href="#" class="btn btn-primary-dark btn-lg"><span>Sharing and using data</span></a>
                            </div>
                            <div class="col-12 col-md-6 col-lg-4 mb-4 d-flex">
                                <a href="#" class="btn btn-primary-dark btn-lg"><span>Case studies</span></a>
                            </div>
                            <div class="col-12 col-md-6 col-lg-4 mb-4 d-flex">
                                <a href="#" class="btn btn-primary-dark btn-lg"><span>Further information</span></a>
                            </div>
                            <!--
                            <div class="col-12 col-md-6 col-lg-4 mb-4 d-flex">
                                <a href="#" class="btn btn-primary-dark btn-lg"><span>Again, a button <small>With a subheading</small></span></a>
                            </div>
                            <div class="col-12 col-md-6 col-lg-4 mb-4 d-flex">
                                <a href="#" class="btn btn-primary-dark btn-lg"><div class="image"><img src="${asset.assetPath(src:"assets/img/icons/example-icon.png")}" alt="Example Icon"></div>
                                    <span>This is another nice button <small>Could also have an icon</small></span></a>
                            </div>
                            <div class="col-12 col-md-6 col-lg-4 mb-4 d-flex">
                                <a href="#" class="btn btn-primary-dark btn-lg"><span>This is a button</span></a>
                            </div>
                            -->
                        </div>
                    </div>
                </section>

                <section class="text-center section-padding">
                    <div class="container">
                        <div class="row">
                            <div class="col-12 col-md-10 offset-0 offset-md-1">
                                <!--
                                <p></p>
                                -->
                            </div>
                        </div>
                    </div>
                </section>


            </article><!-- #article -->

        </main><!-- #main -->

    </div><!-- #full-width-page-wrapper --><footer class="site-footer footer-alt" id="footer">


    <div class="footer-top">
        <div class="container">
            <div class="row align-items-center">
                <div class="col-md-12 col-lg-8 align-center logo-column d-flex flex-column flex-md-row justify-content-center justify-content-lg-start align-items-center">
                    <h2>The Australian Biocontrol Hub</h2>
                    <div class="account mt-3 mt-md-0">
                        <a href="#" class="btn btn-primary btn-sm" title="Login">Login</a>
                        <ul class="social">
                            <li><a href="#" target="_blank" title="Facebook"><i class="fab fa-facebook-f"></i></a></li>
                            <li><a href="#" target="_blank" title="Twitter"><i class="fab fa-twitter"></i></a></li>
                        </ul>
                    </div>
                </div>
                <!--col end -->
                <div class="col-md-12 col-lg-4 menu-column text-center text-lg-right">
                    <ul class="menu horizontal">
                        <li class="menu-item">
                            <a title="Home" href="#">Home</a>
                        </li>
                        <li class="menu-item">
                            <a title="Target Species" href="#">Target Species</a>
                        </li>
                        <li class="menu-item">
                            <a title="Data" href="#">Data</a>
                        </li>
                    </ul>
                </div>
                <!--col end -->
            </div><!-- row end -->
        </div><!-- container end -->
    </div>

    <div class="footer-middle">
        <div class="container">
            <div class="row">
                <div class="col-md-4 col-lg-6">
                    <!-- Footer Menu goes here -->
                    <div class="footer-menu">
                        <ul class="menu menu-2-col">
                            <li class="menu-item menu-item-has-children">
                                <a title="Search &amp; Analyse" href="#">Search &amp; Analyse</a>
                                <ul class="sub-menu">
                                    <li class="menu-item">
                                        <a title="Search Occurrence Records" href="#">Search Occurrence Records</a>
                                    </li>
                                    <li class="menu-item">
                                        <a title="Search ALA Datasets" href="#">Search ALA Datasets</a>
                                    </li>
                                    <li class="menu-item">
                                        <a title="Spatial Portal" href="#">Spatial Portal</a>
                                    </li>
                                    <li class="menu-item">
                                        <a title="Download Data" href="#">Download Data</a>
                                    </li>
                                    <li class="menu-item">
                                        <a title="Search Species" href="#">Search Species</a>
                                    </li>
                                    <li class="menu-item">
                                        <a title="ALA Dashboard" href="#">ALA Dashboard</a>
                                    </li>
                                    <li class="menu-item">
                                        <a title="Explore Your Area" href="#">Explore Your Area</a>
                                    </li>
                                    <li class="menu-item">
                                        <a title="Browse Natural History Collections" href="#">Browse Natural History Collections</a>
                                    </li>
                                    <li class="menu-item">
                                        <a title="Explore Regions" href="#">Explore Regions</a>
                                    </li>
                                </ul>
                            </li>
                        </ul>
                    </div>
                </div>
                <!--col end -->
                <div class="col-md-4 col-lg-3">
                    <!-- Footer Menu goes here -->
                    <div class="footer-menu">
                        <ul class="menu">
                            <li class="menu-item menu-item-has-children">
                                <a title="Contribute" href="#">Contribute</a>
                                <ul class="sub-menu">
                                    <li class="menu-item">
                                        <a title="Record a sighting in the ALA" href="#">Record a sighting in the ALA</a>
                                    </li>
                                    <li class="menu-item">
                                        <a title="Submit a dataset to the ALA" href="#">Submit a dataset to the ALA</a>
                                    </li>
                                    <li class="menu-item">
                                        <a title="Digitise a record in the DigiVol" href="#">Digitise a record in the DigiVol</a>
                                    </li>
                                    <li class="menu-item">
                                        <a title="Mobile Apps" href="#">Mobile Apps</a>
                                    </li>
                                    <li class="menu-item">
                                        <a title="Join a Citizen Science Program" href="#">Join a Citizen Science Program</a>
                                    </li>
                                </ul>
                            </li>
                        </ul>
                    </div>
                </div>
                <!--col end -->
                <div class="col-md-4 col-lg-3">
                    <!-- Footer Menu goes here -->
                    <div class="footer-menu">
                        <ul class="menu">
                            <li class="menu-item menu-item-has-children">
                                <a title="About ALA" href="#">About ALA</a>
                                <ul class="sub-menu">
                                    <li class="menu-item">
                                        <a title="Who We Are" href="#">Who We Are</a>
                                    </li>
                                    <li class="menu-item">
                                        <a title="How to Work With Data" href="#">How to Work With Data</a>
                                    </li>
                                    <li class="menu-item">
                                        <a title="Indigenous Ecological Knowledge" href="#">Indigenous Ecological Knowledge</a>
                                    </li>
                                    <li class="menu-item">
                                        <a title="Contact Us" href="#">Contact Us</a>
                                    </li>
                                    <li class="menu-item">
                                        <a title="Feedback" href="#">Feedback</a>
                                    </li>
                                </ul>
                            </li>
                        </ul>
                    </div>
                </div>
                <!--col end -->
                <div class="col-md-12">
                    <!-- Footer Menu goes here -->
                    <div class="footer-menu-horizontal">
                        <ul class="menu horizontal">
                            <li class="menu-item">
                                <a title="Search" href="#">Blog</a>
                            </li>
                            <li class="menu-item">
                                <a title="Help" href="#">Help</a>
                            </li>
                            <li class="menu-item">
                                <a title="Sites &amp; Services" href="#">Sites &amp; Services</a>
                            </li>
                            <li class="menu-item">
                                <a title="Developer Tools &amp; Documentation" href="#">Developer Tools &amp; Documentation</a>
                            </li>
                        </ul>
                    </div>
                </div>
                <!--col end -->
            </div><!-- row end -->
        </div><!-- container end -->
    </div>

    <div class="footer-bottom">
        <div class="container">
            <div class="row">
                <div class="col-12 content-column text-center">
                    <h4>The ALA is made possible by contributions from its partners, is supported by NCRIS and hosted by CSIRO</h4>
                    <div class="partner-logos">
                        <img src="${asset.assetPath(src:"assets/img/logo1.png")}" alt="Logo1" />
                        <img src="${asset.assetPath(src:"assets/img/logo2.png")}" alt="Logo2" />
                        <img src="${asset.assetPath(src:"assets/img/logo3.png")}" alt="Logo3" />
                        <img src="${asset.assetPath(src:"assets/img/logo1.png")}" alt="Logo1" />
                        <img src="${asset.assetPath(src:"assets/img/logo2.png")}" alt="Logo2" />
                        <img src="${asset.assetPath(src:"assets/img/logo3.png")}" alt="Logo3" />
                        <img src="${asset.assetPath(src:"assets/img/logo1.png")}" alt="Logo1" />
                        <img src="${asset.assetPath(src:"assets/img/logo2.png")}" alt="Logo2" />
                        <img src="${asset.assetPath(src:"assets/img/logo3.png")}" alt="Logo3" />
                    </div>
                </div>
                <!--col end -->
            </div><!-- row end -->
        </div><!-- container end -->
    </div>

    <div class="footer-copyright">
        <div class="container">
            <div class="row">
                <div class="col-md-12 col-lg-7">
                    <p class="alert-text text-creativecommons">
                        This work is licensed under a <a href="https://creativecommons.org/licenses/by/3.0/au/">Creative
                    Commons Attribution 3.0 Australia License</a> <a rel="license"
                                                                     href="http://creativecommons.org/licenses/by/3.0/au/"><img
                                alt="Creative Commons License" style="border-width:0"
                                src="https://www.ala.org.au/wp-content/themes/ala-wordpress-theme/img/cc-by.png"></a>
                    </p>
                </div>
                <!--col end -->
                <div class="col-md-12 col-lg-5 text-lg-right">
                    <ul class="menu horizontal">
                        <li><a title="copyright" href="/copyright">Copyright</a></li>
                        <li><a title="Terms of Use" href="/terms">Terms of Use</a></li>
                        <li><a title="System Status" href="/status">System Status</a></li>
                    </ul>
                </div>
                <!--col end -->
            </div><!-- row end -->
        </div><!-- container end -->
    </div>

</footer><!-- wrapper end -->
</div>
<!-- </.site> -->

<div class="modal fade search-modal" id="search-modal" tabindex="-1" role="dialog" aria-labelledby="search-modal"
     aria-hidden="true" data-backdrop="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Site Search</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>

            <div class="modal-body">
                <p class="text-center pt-3 pb-3">Use the below form to search the website.</p>
                <form method="get" id="searchform" action="/" role="search">
                    <label class="sr-only" for="s">Search</label>
                    <div class="input-group">
                        <input class="field form-control" id="s" name="s" type="text" placeholder="Search …" value="">
                        <span class="input-group-append">
                            <input class="submit btn btn-primary" id="searchsubmit" name="submit" type="submit" value="Search">
                        </span>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

</body>

</html>
