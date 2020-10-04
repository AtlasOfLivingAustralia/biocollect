
<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="description" content="">
    <meta name="author" content="">

    <title><g:message code="g.biocollect"/></title>

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

    <!-- ******************* The Navbar Area ******************* -->
    <div id="wrapper-navbar" itemscope="" itemtype="http://schema.org/WebSite">
        <a class="skip-link sr-only sr-only-focusable" href="#content">Skip to content</a>

        <nav class="navbar navbar-expand-lg navbar-dark">
            <div class="container">

                <!-- Your site title as branding in the menu -->
                <a href="/" class="custom-logo-link navbar-brand" rel="home" itemprop="url">
                    <!--
                    <asset:image src="assets/img/logo.png"/>
                    -->
                    <img width="183" height="80" src="${asset.assetPath(src:"assets/img/logo.png")}" class="logo light-logo" alt="BioCollect" itemprop="logo">
                    <img width="183" height="80" src="${asset.assetPath(src:"assets/img/logo-dark.png")}" class="logo dark-logo" alt="BioCollect" itemprop="logo">
                </a> <!-- end custom logo -->

                <div class="outer-nav-wrapper">
                    <div class="top-bar d-flex">
                        <ul class="social">
                            <li><a href="#" target="_blank" title="Facebook"><i class="fab fa-facebook-f"></i></a></li>
                            <li><a href="#" target="_blank" title="Twitter"><i class="fab fa-twitter"></i></a></li>
                            <li><a href="#" target="_blank" title="LinkedIn"><i class="fab fa-linkedin-in"></i></a></li>
                        </ul>
                        <a href="#" class="btn btn-link btn-sm d-none d-lg-inline-block" title="Blog">Blog</a>
                        <a href="#" class="btn btn-link btn-sm d-none d-lg-inline-block" title="Contact Us">Contact Us</a>
                        <div class="account d-none d-lg-block">
                            <a href="#" class="btn btn-outline-white btn-sm" title="Register">Register</a>
                            <a href="#" class="btn btn-primary btn-sm" title="Login">Login</a>
                        </div>
                        <a href="https://www.ala.org.au/" class="ala d-none d-lg-inline-block" target="_blank" title="Atlas of Living Australia">
                            <svg xmlns="http://www.w3.org/2000/svg" width="25px" height="30px" viewBox="0 0 100.24 88.18"><defs><style>.ala{fill:#f26649;}</style></defs><path class="ala" d="M51.05.34a7.19,7.19,0,0,0-4.68,9l4.78,15.06L45.69,34.94l-14.22-1-22-7.21A7.2,7.2,0,0,0,5,40.41l11,3.59-4.76,4.13A7.19,7.19,0,0,0,20.61,59L32.54,48.62l11.89.84,2.11,6.65-17.7,4.14a7.19,7.19,0,1,0,3.28,14l20.05-4.68L60,84.35a7.19,7.19,0,0,0,13.53-2.88,7.09,7.09,0,0,0-.82-3.86L62.59,58.49,57.77,43.3,64.13,31l31.3-11.9a7.19,7.19,0,0,0,4.79-6.28A7.07,7.07,0,0,0,99.83,10a7.19,7.19,0,0,0-9.17-4.4L63.55,16,60.08,5A7.19,7.19,0,0,0,51.05.34Z"/></svg>
                        </a>
                    </div>

                    <div class="main-nav-wrapper">
                        <button data-toggle="modal" data-target="#search-modal" class="search-trigger order-1 order-lg-3" title="search">
                            <svg xmlns="http://www.w3.org/2000/svg" width="25" height="25" viewBox="0 0 22 22">
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
                                    <a title="View Data" href="#" class="nav-link">View Data</a>
                                </li>
                                <li itemscope="itemscope" itemtype="https://www.schema.org/SiteNavigationElement" class="menu-item menu-item-has-children dropdown nav-item">
                                    <a title="New Project" href="#" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false" class="dropdown-toggle nav-link">New Project</a>
                                    <ul class="dropdown-menu" role="menu">
                                        <li itemscope="itemscope" itemtype="https://www.schema.org/SiteNavigationElement" class="menu-item nav-item">
                                            <a title="Project Page 1" href="#" class="dropdown-item">Project Page 1</a>
                                        </li>
                                        <li itemscope="itemscope" itemtype="https://www.schema.org/SiteNavigationElement" class="menu-item nav-item">
                                            <a title="Project Page 2" href="#" class="dropdown-item">Project Page 2</a>
                                        </li>
                                        <li itemscope="itemscope" itemtype="https://www.schema.org/SiteNavigationElement" class="menu-item nav-item">
                                            <a title="Project Page 3" href="#" class="dropdown-item">Project Page 3</a>
                                        </li>
                                    </ul>
                                </li>
                                <li itemscope="itemscope" itemtype="https://www.schema.org/SiteNavigationElement" class="menu-item menu-item-has-children dropdown nav-item">
                                    <a title="Support" href="#" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false" class="dropdown-toggle nav-link"
                                       id="menu-item-dropdown-9">Support</a>
                                    <ul class="dropdown-menu" role="menu">
                                        <li itemscope="itemscope" itemtype="https://www.schema.org/SiteNavigationElement" class="menu-item nav-item">
                                            <a title="Support Page 1" href="#" class="dropdown-item">Support Page 1</a>
                                        </li>
                                        <li itemscope="itemscope" itemtype="https://www.schema.org/SiteNavigationElement" class="menu-item nav-item">
                                            <a title="Support Page 2" href="#" class="dropdown-item">Support Page 2</a>
                                        </li>
                                        <li itemscope="itemscope" itemtype="https://www.schema.org/SiteNavigationElement" class="menu-item nav-item">
                                            <a title="Support Page 3" href="#" class="dropdown-item">Support Page 3</a>
                                        </li>
                                    </ul>
                                </li>
                            </ul>
                        </div>
                    </div>

                </div>
            </div><!-- .container -->

        </nav><!-- .site-navigation -->

    </div><!-- #wrapper-navbar end -->
    <div class="wrapper" id="home">

        <main class="site-main" id="main" role="main">

            <section class="hero-slider swiper-container">
                <div class="swiper-wrapper">
                    <div class="swiper-slide" style="background-image: url('${asset.assetPath(src:"assets/img/banner.jpg")}');">
                        <div class="slide-overlay">
                            <div class="container d-none d-md-block">
                                <h1>Hero banner heading tag line goes here</h1>
                                <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut
                                labore et dolore magna aliqua.</p>
                                <a href="#" class="btn btn-primary-dark btn-lg">Call to Action</a>
                            </div>
                        </div>
                    </div>
                    <div class="swiper-slide" style="background-image: url('pivotal/assets/img/banner2.jpg');">
                        <div class="slide-overlay">
                            <div class="container d-none d-md-block">
                                <h1>Hero banner heading tag line goes here</h1>
                                <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut
                                labore et dolore magna aliqua.</p>
                                <a href="#" class="btn btn-primary-dark btn-lg">Call to Action</a>
                            </div>
                        </div>
                    </div>
                    <div class="swiper-slide" style="background-image: url('pivotal/assets/img/banner3.jpg');">
                        <div class="slide-overlay">
                            <div class="container d-none d-md-block">
                                <h1>Hero banner heading tag line goes here</h1>
                                <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut
                                labore et dolore magna aliqua.</p>
                                <a href="#" class="btn btn-primary-dark btn-lg">Call to Action</a>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="swiper-pagination"></div>

                <div class="search-overlay">
                    <div class="container">
                        <div class="search-container row">
                            <div class="col-md-12">
                                <form class="form-inline">
                                    <div class="form-group flex-grow-1">
                                        <label for="search" class="sr-only">Search for projects</label>
                                        <input type="search" class="form-control flex-grow-1" id="search" placeholder="Search for projects..">
                                    </div>
                                    <button type="submit" class="btn btn-primary-dark">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 22 22">
                                            <defs>
                                                <style>
                                                .search-icon {
                                                    fill: #fff;
                                                    fill-rule: evenodd;
                                                }
                                                </style>
                                            </defs>
                                            <path class="search-icon" d="M1524.33,60v1.151a7.183,7.183,0,1,1-2.69.523,7.213,7.213,0,0,1,2.69-.523V60m0,0a8.333,8.333,0,1,0,7.72,5.217A8.323,8.323,0,0,0,1524.33,60h0Zm6.25,13.772-0.82.813,7.25,7.254a0.583,0.583,0,0,0,.82,0,0.583,0.583,0,0,0,0-.812l-7.25-7.254h0Zm-0.69-7.684,0.01,0c0-.006-0.01-0.012-0.01-0.018s-0.01-.015-0.01-0.024a6,6,0,0,0-7.75-3.3l-0.03.009-0.02.006v0a0.6,0.6,0,0,0-.29.293,0.585,0.585,0,0,0,.31.756,0.566,0.566,0,0,0,.41.01V63.83a4.858,4.858,0,0,1,6.32,2.688l0.01,0a0.559,0.559,0,0,0,.29.29,0.57,0.57,0,0,0,.75-0.305A0.534,0.534,0,0,0,1529.89,66.089Z" transform="translate(-1516 -60)"/>
                                        </svg>
                                        Search
                                    </button>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
                <!-- /.search-overlay -->
            </section>

            <section id="about" class="dark-bg text-center section-padding">
                <div class="container">
                    <div class="row">
                        <div class="col-12 col-md-10 offset-0 offset-md-1">
                            <h2>Advanced data collection for biodiversity projects</h2>
                            <p>BioCollect is a sophisticated, yet simple to use tool developed by the Atlas of Living Australia (ALA) in collaboration with over 100 organisations which are involved in field data capture. It has been developed to support the needs of scientists, ecologists, citizen scientists and natural resource managers in the field-collection and management of biodiversity, ecological and natural resource management (NRM) data. The tool is developed and hosted by the ALA and is free for public use.</p>
                            <a href="#" title="Learn More">Learn More...</a>
                        </div>
                    </div>
                </div>
            </section>

            <section class="section-padding">
                <div class="container">
                    <div class="row">
                        <div class="col-12 col-lg-4">
                            <h2 class="darker-text">BioCollect provides form-based structured data collection for</h2>
                        </div>
                        <div class="col-12 col-lg-8">
                            <ol>
                                <li>Ad-hoc survey-based records</li>
                                <li>Method-based systematic structured surveys</li>
                                <li>Activity-based projects such as natural resource management intervention projects (e.g. revegetation, site restoration, seed collection, weed and pest management, etc.)</li>
                            </ol>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-12 col-md-10 offset-0 offset-md-1 text-center mt-5">
                            <p>It also supports upload of unstructured data in the form of data files, grey literature, images, sound bytes, videos, etc.</p>
                            <p>The system is fully integrated with other Atlas tools and we are currently working to enable seamless linkages with other global project finders, and other related national research infrastructure facilities such as the Terrestrial Ecosystem Research Network (TERN) and the Australian National Data Service (ANDS).</p>
                        </div>
                    </div>
                </div>
            </section>

            <section class="section-padding border-top">
                <div class="container">
                    <div class="row">
                        <div class="col-12 col-lg-4">
                            <div class="d-flex icon-text">
                                <div class="image">
                                    <img src="${asset.assetPath(src:"assets/img/icons/map-dark.svg")}" alt="Create a Project">
                                </div>
                                <div class="content">
                                    <h4>Create a Project</h4>
                                    <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod</p>
                                </div>
                            </div>
                            <div class="d-flex icon-text">
                                <div class="image">
                                    <img src="${asset.assetPath(src:"assets/img/icons/search-dark.svg")}" alt="Search Projects">
                                </div>
                                <div class="content">
                                    <h4>Search Projects</h4>
                                    <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod</p>
                                </div>
                            </div>
                            <div class="d-flex icon-text">
                                <div class="image">
                                    <img src="${asset.assetPath(src:"assets/img/icons/browser-dark.svg")}" alt="View Data">
                                </div>
                                <div class="content">
                                    <h4>View Data</h4>
                                    <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod</p>
                                </div>
                            </div>
                        </div>
                        <div class="col-12 col-lg-4 mt-4 mt-lg-0">
                            <div class="d-flex icon-text mobile-app">
                                <div class="image">
                                    <img src="${asset.assetPath(src:"assets/img/icons/mobile-dark.svg")}" alt="Download our App">
                                </div>
                                <div class="content">
                                    <h4>BioCollect Mobile Apps</h4>
                                    <p>
                                        <a href="#" title="Download the BioCollect App on the Apple AppStore!" class="store-link">
                                            <img src="${asset.assetPath(src:"assets/img/badge-appstore.svg")}" alt="Apple AppStore" />
                                        </a>
                                        <a href="#" title="Download the BioCollect App on the Google Play Store!" class="store-link">
                                            <img src="${asset.assetPath(src:"assets/img/badge-playstore.svg")}" alt="Google Play Store" />
                                        </a>
                                    </p>
                                </div>
                            </div>
                            <div class="d-flex icon-text mobile-app">
                                <div class="image">
                                    <img src="${asset.assetPath(src:"assets/img/icons/mobile-dark.svg")}" alt="Download our App">
                                </div>
                                <div class="content">
                                    <h4>OzAtlas Mobile Apps</h4>
                                    <p>
                                        <a href="#" title="Download the OzAtlas App on the Apple AppStore!" class="store-link">
                                            <img src="${asset.assetPath(src:"assets/img/badge-appstore.svg")}" alt="Apple AppStore" />
                                        </a>
                                        <a href="#" title="Download the OzAtlas App on the Google Play Store!" class="store-link">
                                            <img src="${asset.assetPath(src:"assets/img/badge-playstore.svg")}" alt="Google Play Store" />
                                        </a>
                                    </p>
                                </div>
                            </div>
                            <ul class="tick">
                                <li>Record data offline</li>
                                <li>Automatic data upload to the database</li>
                                <li>Integrated device tools for data recording</li>
                                <li>GPS-based search</li>
                            </ul>
                        </div>
                        <div class="col-12 col-lg-4 mt-4 mt-lg-0">
                            <ul class="links">
                                <li><a href="#" title="BioCollect for Citizen Science">BioCollect for Citizen Science <i class="fas fa-long-arrow-alt-right" aria-hidden="true"></i></a></li>
                                <li><a href="#" title="BioCollect for Ecological Science">BioCollect for Ecological Science <i class="fas fa-long-arrow-alt-right" aria-hidden="true"></i></a></li>
                                <li><a href="#" title="BioCollect for NRM">BioCollect for NRM <i class="fas fa-long-arrow-alt-right" aria-hidden="true"></i></a></li>
                                <li><a href="#" title="BioCollect Hubs">BioCollect Hubs <i class="fas fa-long-arrow-alt-right" aria-hidden="true"></i></a></li>
                                <li><a href="#" title="Developer Resources">Developer Resources <i class="fas fa-long-arrow-alt-right" aria-hidden="true"></i></a></li>
                            </ul>
                        </div>
                    </div>
                </div>
            </section>

            <section class="latest-posts-block section-padding">
                <div class="container">
                    <div class="row">
                        <div class="col-12 col-md-4 col-lg-4">

                            <h2 role="heading" aria-level="2" class="section-heading">Featured Projects</h2>

                            <div class="post-list swiper-container post-slider">

                                <div class="swiper-wrapper">

                                    <article class="post swiper-slide" id="post-1">

                                        <a href="#" class="post-link" rel="bookmark" title="Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do">

                                            <div class="post-image">
                                                <img src="${asset.assetPath(src:"assets/img/blog1.jpg")}" alt="Lorem ipsum dolor sit amet, consectetur adipisicing elit"/>
                                            </div>

                                            <header class="entry-header">

                                                <h3 class="entry-title">Lorem ipsum dolor sit amet, consectetur adipisicing elit</h3>

                                                <div class="entry-meta">
                                                    <span class="posted-on">
                                                        <span class="sr-only">Posted on </span>
                                                        <time aria-label="Date Posted" datetime="2018-06-18T08:51:56+00:00">18th June 2018</time>
                                                    </span>
                                                </div><!-- .entry-meta -->

                                            </header><!-- .entry-header -->

                                        </a>

                                    </article><!-- #post-## -->

                                    <article class="post swiper-slide" id="post-1b">

                                        <a href="#" class="post-link" rel="bookmark" title="Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do">

                                            <div class="post-image">
                                                <img src="${asset.assetPath(src:"assets/img/blog2.jpg")}" alt="Lorem ipsum dolor sit amet, consectetur adipisicing elit"/>
                                            </div>

                                            <header class="entry-header">

                                                <h3 class="entry-title">Lorem ipsum dolor sit amet, consectetur adipisicing elit</h3>

                                                <div class="entry-meta">
                                                    <span class="posted-on">
                                                        <span class="sr-only">Posted on </span>
                                                        <time aria-label="Date Posted" datetime="2018-06-18T08:51:56+00:00">18th June 2018</time>
                                                    </span>
                                                </div><!-- .entry-meta -->

                                            </header><!-- .entry-header -->

                                        </a>

                                    </article><!-- #post-## -->

                                </div>

                                <div class="text-center mt-3">
                                    <a href="#" class="btn btn-primary-dark btn-sm" title="View More - Featured Projects">View More</a>
                                </div>

                            </div>
                        </div>
                        <div class="col-12 col-md-4 col-lg-4 mt-5 mt-md-0">

                            <h2 role="heading" aria-level="2" class="section-heading">Use BioCollect for...</h2>

                            <div class="post-list swiper-container post-slider">

                                <div class="swiper-wrapper">

                                    <article class="post swiper-slide" id="post-2">

                                        <a href="#" class="post-link" rel="bookmark" title="Eiusmod tempor incididunt ut labore et dolore magna aliqua">

                                            <div class="post-image">
                                                <img src="${asset.assetPath(src:"assets/img/blog2.jpg")}" alt="Eiusmod tempor incididunt ut labore et dolore magna aliqua"/>
                                            </div>

                                            <header class="entry-header">

                                                <h3 class="entry-title">Eiusmod tempor incididunt ut labore et dolore magna aliqua</h3>

                                                <div class="entry-meta">
                                                    <span class="posted-on">
                                                        <span class="sr-only">Posted on </span>
                                                        <time aria-label="Date Posted" datetime="2018-08-18T08:51:56+00:00">18th August 2018</time>
                                                    </span>
                                                </div><!-- .entry-meta -->

                                            </header><!-- .entry-header -->

                                        </a>

                                    </article><!-- #post-## -->

                                    <article class="post swiper-slide" id="post-2b">

                                        <a href="#" class="post-link" rel="bookmark" title="Eiusmod tempor incididunt ut labore et dolore magna aliqua">

                                            <div class="post-image">
                                                <img src="${asset.assetPath(src:"assets/img/blog1.jpg")}" alt="Eiusmod tempor incididunt ut labore et dolore magna aliqua"/>
                                            </div>

                                            <header class="entry-header">

                                                <h3 class="entry-title">Eiusmod tempor incididunt ut labore et dolore magna aliqua</h3>

                                                <div class="entry-meta">
                                                    <span class="posted-on">
                                                        <span class="sr-only">Posted on </span>
                                                        <time aria-label="Date Posted" datetime="2018-08-18T08:51:56+00:00">18th August 2018</time>
                                                    </span>
                                                </div><!-- .entry-meta -->

                                            </header><!-- .entry-header -->

                                        </a>

                                    </article><!-- #post-## -->

                                </div>

                                <div class="text-center mt-3">
                                    <a href="#" class="btn btn-primary-dark btn-sm" title="View More - Use BioCollect for...">View More</a>
                                </div>

                            </div>
                        </div>
                        <div class="col-12 col-md-4 col-lg-4 mt-5 mt-md-0">

                            <h2 role="heading" aria-level="2" class="section-heading">How To...</h2>

                            <div class="post-list swiper-container post-slider">

                                <div class="swiper-wrapper">

                                    <article class="post swiper-slide" id="post-4">

                                        <a href="#" class="post-link" rel="bookmark" title="Duis aute irure dolor in reprehenderit in voluptate velit">

                                            <div class="post-image">
                                                <img src="${asset.assetPath(src:"assets/img/blog2.jpg")}" alt="Duis aute irure dolor in reprehenderit in voluptate velit"/>
                                            </div>

                                            <header class="entry-header">
                                                <h3 class="entry-title">Duis aute irure dolor in reprehenderit in voluptate velit</h3>
                                            </header><!-- .entry-header -->

                                            <div class="entry-meta">
                                                <span class="posted-on">
                                                    <span class="sr-only">Posted on </span>
                                                    <time aria-label="Date Posted" datetime="2018-08-18T08:51:56+00:00">18th August 2018</time>
                                                </span>
                                            </div><!-- .entry-meta -->

                                        </a>

                                    </article><!-- #post-## -->

                                    <article class="post swiper-slide" id="post-4b">

                                        <a href="#" class="post-link" rel="bookmark" title="Duis aute irure dolor in reprehenderit in voluptate velit">

                                            <div class="post-image">
                                                <img src="${asset.assetPath(src:"assets/img/blog1.jpg")}" alt="Duis aute irure dolor in reprehenderit in voluptate velit"/>
                                            </div>

                                            <header class="entry-header">
                                                <h3 class="entry-title">Duis aute irure dolor in reprehenderit in voluptate velit</h3>
                                            </header><!-- .entry-header -->

                                            <div class="entry-meta">
                                                <span class="posted-on">
                                                    <span class="sr-only">Posted on </span>
                                                    <time aria-label="Date Posted" datetime="2018-08-18T08:51:56+00:00">18th August 2018</time>
                                                </span>
                                            </div><!-- .entry-meta -->

                                        </a>

                                    </article><!-- #post-## -->

                                </div>

                                <div class="text-center mt-3">
                                    <a href="#" class="btn btn-primary-dark btn-sm" title="View More - How To...">View More</a>
                                </div>

                            </div>
                        </div>
                    </div>
                </div>
            </section>

        </main><!-- #main -->

    </div><!-- #full-width-page-wrapper -->
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
