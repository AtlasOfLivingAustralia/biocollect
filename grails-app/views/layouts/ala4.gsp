
<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="description" content="">
    <meta name="author" content="">

    <title><g:layoutTitle/></title>

    <link href="//fonts.googleapis.com/css?family=Lato:700,900|Roboto:400,400i,500" rel="stylesheet">
    <link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.7.2/css/all.css" integrity="sha384-fnmOCqbTlWIlj8LyTjo7mOUStjsKC4pOpQbqyi7RrhN7udi9RwhKkMHpvLbHG9Sr" crossorigin="anonymous">

    <asset:stylesheet src="pivotal_core.css" />
    <asset:script type="text/javascript">
    </asset:script>
    <asset:javascript src="pivotal_core.js" />
    <script src="${grailsApplication.config.google.maps.url}" async defer></script>
</head>

<body class="home">

<div class="site" id="page">

    <g:render template="/layouts/menu"/>

    <g:layoutBody/>

    <footer class="site-footer" id="footer">

        <div class="footer-top">
            <div class="container">
                <div class="row align-items-center">
                    <div class="col-md-12 col-lg-6 align-center logo-column d-flex flex-column flex-md-row justify-content-center justify-content-lg-start align-items-center">
                        <img width="183" height="80" src="${asset.assetPath(src:"assets/img/logo.png")}" class="logo" alt="BioCollect" itemprop="logo">
                        <div class="account mt-3 mt-md-0">
                            <a href="#" class="btn btn-outline-white btn-sm" title="Register">Register</a>
                            <a href="#" class="btn btn-primary btn-sm" title="Login">Login</a>
                        </div>
                    </div>
                    <!--col end -->
                    <div class="col-md-12 col-lg-6 menu-column text-center text-lg-right">
                        <ul class="menu horizontal">
                            <li class="menu-item">
                                <a title="Search" href="#">Search</a>
                            </li>
                            <li class="menu-item">
                                <a title="All Records" href="#">All Records</a>
                            </li>
                            <li class="menu-item">
                                <a title="Sites" href="#">Sites</a>
                            </li>
                            <li class="menu-item">
                                <a title="New Project" href="#">New Project</a>
                            </li>
                            <li class="menu-item">
                                <a title="Help" href="#">Help</a>
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
                    <div class="col-md-6 content-column">
                        <h4>The ALA is made possible by contributions from its partners, is supported by NCRIS and hosted by
                        CSIRO</h4>
                        <div class="partner-logos homepage">
                            <img src="${asset.assetPath(src:"assets/img/logo1.png")}" alt="Logo1" />
                            <img src="${asset.assetPath(src:"assets/img/logo2.png")}" alt="Logo2" />
                            <img src="${asset.assetPath(src:"assets/img/logo3.png")}" alt="Logo3" />
                        </div>
                    </div>
                    <!--col end -->
                    <div class="col-md-6 content-column">
                        <h4>Acknowledgement of Traditional Owners and Country</h4>
                        <p>The Atlas of Living Australia acknowledges Australia’s Traditional Owners and pays respect to the past
                        and present Elders of the nation’s Aboriginal and Torres Strait Islander communities. We honour and
                        celebrate the spiritual, cultural and customary connections of Traditional Owners to country and the
                        biodiversity that forms part of that country.</p>
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
                <h5 class="modal-title">Project Search</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>

            <div class="modal-body">
                <p class="text-center pt-3 pb-3">Use the below form to search BioCollect projects.</p>
                <form method="get" id="searchform" action="/" role="search">
                    <label class="sr-only" for="s">Project Search</label>
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
