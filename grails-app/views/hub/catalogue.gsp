
<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="description" content="">
    <meta name="author" content="">

    <title>BioCollect</title>

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

<body class="catalogue">

<div class="site" id="page">


    <!-- ******************* The Navbar Area ******************* -->
    <div id="wrapper-navbar" itemscope="" itemtype="http://schema.org/WebSite">
        <a class="skip-link sr-only sr-only-focusable" href="#content">Skip to content</a>

        <nav class="navbar navbar-expand-lg navbar-dark navbar-alt">
            <div class="container">

                <!-- Your site title as branding in the menu -->
                <a href="/" class="custom-logo-link navbar-brand" rel="home" itemprop="url">
                EcoScience Hub
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
                        <!--
                         <li class="menu-item">
                            <a title="Home" href="#">Home</a>
                        </li>
                        <li class="menu-item">
                            <a title="Target Species" href="#">Data</a>
                        </li>
                        <li class="menu-item">
                            <a title="Data" href="#">My Data</a>
                        </li>
                        <li class="menu-item">
                            <a title="Data" href="#">New Projects</a>
                        </li>
                        -->
                        <div id="navbarNavDropdown" class="collapse navbar-collapse offcanvas-collapse">
                            <ul class="navbar-nav ml-auto">
                                <li itemscope="itemscope" itemtype="https://www.schema.org/SiteNavigationElement" class="menu-item nav-item">
                                    <a title="Home" href="#" class="nav-link">Home</a>
                                </li>
                                <li itemscope="itemscope" itemtype="https://www.schema.org/SiteNavigationElement" class="menu-item nav-item">
                                    <a title="Target Species" href="#" class="nav-link">Data</a>
                                </li>
                                <li itemscope="itemscope" itemtype="https://www.schema.org/SiteNavigationElement" class="menu-item nav-item">
                                    <a title="Data" href="#" class="nav-link">New project</a>
                                </li>
                                <li itemscope="itemscope" itemtype="https://www.schema.org/SiteNavigationElement" class="menu-item nav-item">
                                    <a title="Data" href="#" class="nav-link">My profile</a>
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
    <div class="wrapper" id="catalogue">

        <main class="site-main" id="main" role="main">

            <article class="page">

                <div id="banner" class="page-banner" style="background-image: url('${asset.assetPath(src: "assets/img/banner.jpg")}'); ">

                </div>

                <div id="titleBar">
                    <div class="container">
                        <div class="row d-flex title-row">
                            <div class="col-12 col-lg-auto flex-shrink-1 d-flex mb-4 mb-lg-0 justify-content-center justify-content-lg-end">
                                <div class="main-image">
                                    <!--
                                    <img src="${asset.assetPath(src:"assets/img/acsa.jpg")}" alt="Australian Citizen Science Association"/>
                                    -->
                                    <img src="https://www.ala.org.au/app/uploads/2019/07/bc-brandmark-final_logo-horizontal-fc-e1563407983596.jpg" alt="Australian Citizen Science Association"/>

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
                                <p>The “ecoscience” project type is for any assessment & monitoring project which does not involve public participation. Ecoscience research projects are most typically set up by scientists collecting data for their own research projects or by ecologists and natural resource management (NRM) practitioners undertaking surveys for planning related development applications, long-term site monitoring projects, and more.</p>
                            </div>
                        </div>
                    </div>
                </section>

                <section id="catalogueSection">

                    <div class="container-fluid show expander projects-container">

                        <div id="sortBar" class="row d-flex">
                            <div class="col-6 col-md-4 mb-3 order-1 order-md-0">
                                <button
                                        data-toggle="collapse"
                                        data-target=".expander"
                                        aria-expanded="true"
                                        aria-controls="expander"
                                        class="btn btn-dark"
                                        title="Filter Projects">
                                    <i class="fas fa-filter"></i> Filter Projects
                                </button>
                            </div>
                            <div class="col-6 col-sm-6 col-md-4 mb-3 text-right text-md-center order-2 order-md-1">
                                <div class="btn-group" role="group" aria-label="Catalogue Display Options">
                                    <button type="button" class="btn btn-outline-dark active" title="View as Grid"><i class="fas fa-th-large"></i></button>
                                    <button type="button" class="btn btn-outline-dark" title="View as List"><i class="fas fa-list"></i></button>
                                    <button type="button" class="btn btn-outline-dark" title="View as Map"><i class="far fa-map"></i></button>
                                </div>
                            </div>
                            <div class="col-12 col-md-4 text-center text-md-right order-0 order-md-2 pl-0">
                                <div class="form-group">
                                    <label for="sortBy" class="col-form-label">Sort by</label>
                                    <select id="sortBy" class="form-control col custom-select" aria-label="Sort Order">
                                        <option value="Most Recent">Most Recent</option>
                                        <option value="Name - Desc">Name - Desc</option>
                                        <option value="Name - Asc">Name - Asc</option>
                                        <option value="Sightings - Desc">Sightings - Desc</option>
                                        <option value="Sightings - Asc">Sightings - Asc</option>
                                    </select>
                                </div>
                            </div>
                        </div>

                        <div class="filter-bar d-flex align-items-center">
                            <h4>Applied Filters: </h4>
                            <span class="filter-item">Filter Title <button class="remove" data-remove><i class="far fa-times-circle"></i></button></span>
                            <span class="filter-item">Filter Title <button class="remove" data-remove><i class="far fa-times-circle"></i></button></span>
                            <span class="filter-item">Filter Title <button class="remove" data-remove><i class="far fa-times-circle"></i></button></span>
                            <span class="filter-item">Filter Title <button class="remove" data-remove><i class="far fa-times-circle"></i></button></span>
                            <button type="button" class="btn btn-sm btn-dark clear-filters" aria-label="Clear all filters"><i class="far fa-times-circle"></i> Clear All</button>
                        </div>

                        <div id="projects" class="row">


                            <div class="col-12 col-sm-12 col-md-6 col-lg-4 col-xl-3 project-item">
                                <a href="#" class="project-image" title="Project Title">
                                    <div class="project-image-inner">
                                        <!--
                                        <img src="${asset.assetPath(src:"assets/img/example1.jpg")}" alt="Project Title" />
                                        -->
                                        <img src="https://ecodata.ala.org.au/uploads/2020-11/thumb_0_Tmba_KoalaandWildlife_Rescue_Logo.png" alt="Project Title" />

                                    </div>
                                </a>
                                <a href="#" class="project-link" title="Project Title">
                                    <h4>KOALA SIGHTINGS TOOWOOMBA REGION</h4>
                                    <p class="subtitle">Toowoomba Koala and Wildlife Rescue</p>
                                </a>
                                <div class="excerpt">To identify locations of koalas in the Greater Toowoomba Region and monitor t..</div>
                                <div class="detail">
                                    <span class="label">Status: </span>
                                    <span class="status">Project Ongoing</span>
                                </div>
                                <div class="detail">
                                    <span class="label">Start Date: </span>
                                    <time aria-label="Project Start Date" datetime="2018-06-18T08:51:56+00:00">12th July 2020</time>
                                </div>
                            </div>


                            <div class="col-12 col-sm-12 col-md-6 col-lg-4 col-xl-3 project-item">
                                <a href="#" class="project-image" title="Project Title">
                                    <div class="project-image-inner">
                                        <!--
                                        <img src="${asset.assetPath(src:"assets/img/example2.jpg")}" alt="Project Title" />
                                        -->
                                        <img src="https://ecodata.ala.org.au/uploads/2020-11/thumb_WetlandSnap_SquareBlock-01.png" alt="Project Title" />

                                    </div>
                                </a>
                                <a href="#" class="project-link" title="Project Title">
                                    <h4>WETLANDSNAP</h4>
                                    <p class="subtitle">Macquarie University</p>
                                </a>
                                <div class="excerpt">WetlandSnap is a photopoint monitoring citizen science initiative designed to..</div>
                                <div class="detail">
                                    <span class="label">Status: </span>
                                    <span class="status">Project Ongoing</span>
                                </div>
                                <div class="detail">
                                    <span class="label">Start Date: </span>
                                    <time aria-label="Project Start Date" datetime="2018-06-18T08:51:56+00:00">09th June 2020</time>
                                </div>
                            </div>


                            <div class="col-12 col-sm-12 col-md-6 col-lg-4 col-xl-3 project-item">
                                <a href="#" class="project-image" title="Project Title">
                                    <div class="project-image-inner">
                                        <!--
                                        <img src="${asset.assetPath(src:"assets/img/example3.jpg")}" alt="Project Title" />
                                        -->
                                        <img src="https://ecodata.ala.org.au/uploads/2020-10/thumb_0_BRUVNet_Picture.png" alt="Project Title" />

                                    </div>
                                </a>
                                <a href="#" class="project-link" title="Project Title">
                                    <h4>TRAINING ARTIFICIAL INTELLIGENCE TO IDENTIFY TR...</h4>
                                    <p class="subtitle">Supervising Scientist</p>
                                </a>
                                <div class="excerpt">To generate the worlds largest open-sourced dataset of freshwater and marine ...</div>
                                <div class="detail">
                                    <span class="label">Status: </span>
                                    <span class="status">Project Ongoing</span>
                                </div>
                                <div class="detail">
                                    <span class="label">Start Date: </span>
                                    <time aria-label="Project Start Date" datetime="2018-06-18T08:51:56+00:00">24th July 2018</time>
                                </div>
                            </div>


                            <div class="col-12 col-sm-12 col-md-6 col-lg-4 col-xl-3 project-item">
                                <a href="#" class="project-image" title="Project Title">
                                    <div class="project-image-inner">
                                        <!--
                                        <img src="${asset.assetPath(src:"assets/img/example4.jpg")}" alt="Project Title" />
                                        -->
                                        <img src="https://ecodata.ala.org.au/uploads/2020-10/thumb_0_0_Front_logo_shirt.jpg" alt="Project Title" />
                                    </div>
                                </a>
                                <a href="#" class="project-link" title="Project Title">
                                    <h4>REDMAP</h4>
                                    <p class="subtitle">University of Tasmania - Institute for Marine a...</p>
                                </a>
                                <div class="excerpt">Generate a database of "out of range" marine animal sightings.</div>
                                <div class="detail">
                                    <span class="label">Status: </span>
                                    <span class="status">Project Ongoing</span>
                                </div>
                                <div class="detail">
                                    <span class="label">Start Date: </span>
                                    <time aria-label="Project Start Date" datetime="2018-06-18T08:51:56+00:00">19th August 2020</time>
                                </div>
                            </div>


                            <div class="col-12 col-sm-12 col-md-6 col-lg-4 col-xl-3 project-item">
                                <a href="#" class="project-image" title="Project Title">
                                    <div class="project-image-inner">
                                        <!--
                                        <img src="${asset.assetPath(src:"assets/img/example1.jpg")}" alt="Project Title" />
                                        -->
                                        <img src="https://ecodata.ala.org.au/uploads/2020-09/thumb_0_coorong_LL96b_edit_Webpage_HCHBsml.jpg" alt="Project Title" />

                                    </div>
                                </a>
                                <a href="#" class="project-link" title="Project Title">
                                    <h4>COORONG WATCH</h4>
                                    <p class="subtitle">DEPARTMENT FOR ENVIRONMENT AND WATER</p>
                                </a>
                                <div class="excerpt">To provide information on the location and timing of algal blooms, black ooze...</div>
                                <div class="detail">
                                    <span class="label">Status: </span>
                                    <span class="status">Project Ongoing</span>
                                </div>
                                <div class="detail">
                                    <span class="label">Start Date: </span>
                                    <time aria-label="Project Start Date" datetime="2018-06-18T08:51:56+00:00">05th July 2018</time>
                                </div>
                            </div>


                            <div class="col-12 col-sm-12 col-md-6 col-lg-4 col-xl-3 project-item">
                                <a href="#" class="project-image" title="Project Title">
                                    <div class="project-image-inner">
                                        <!--
                                        <img src="${asset.assetPath(src:"assets/img/example2.jpg")}" alt="Project Title" />
                                        -->
                                        <img src="https://ecodata.ala.org.au/uploads/2020-09/thumb_0_Hollows.jpg" alt="Project Title" />

                                    </div>
                                </a>
                                <a href="#" class="project-link" title="Project Title">
                                    <h4>TREE HOLLOWS IN WYNDHAM</h4>
                                    <p class="subtitle">Wyndham City</p>
                                </a>
                                <div class="excerpt">To provide a landscape scale assessment of hollow presence in Wyndham.</div>
                                <div class="detail">
                                    <span class="label">Status: </span>
                                    <span class="status">Project Ongoing</span>
                                </div>
                                <div class="detail">
                                    <span class="label">Start Date: </span>
                                    <time aria-label="Project Start Date" datetime="2018-06-18T08:51:56+00:00">18th July 2018</time>
                                </div>
                            </div>


                            <div class="col-12 col-sm-12 col-md-6 col-lg-4 col-xl-3 project-item">
                                <a href="#" class="project-image" title="Project Title">
                                    <div class="project-image-inner">
                                        <!--
                                        <img src="${asset.assetPath(src:"assets/img/example3.jpg")}" alt="Project Title" />
                                        -->
                                        <img src="https://ecodata.ala.org.au/uploads/2020-08/thumb_0_YBG_Logo_Black_Gold_%282%29.png" alt="Project Title" />
                                    </div>
                                </a>
                                <a href="#" class="project-link" title="Project Title">
                                    <h4>THE YELLOW-BELLIED GLIDER PROJECT</h4>
                                    <p class="subtitle">Wildlife Queensland</p>
                                </a>
                                <div class="excerpt">To discover and monitor Yellow-bellied Gliders and Greater Gliders in south e...</div>
                                <div class="detail">
                                    <span class="label">Status: </span>
                                    <span class="status">Project Ongoing</span>
                                </div>
                                <div class="detail">
                                    <span class="label">Start Date: </span>
                                    <time aria-label="Project Start Date" datetime="2018-06-18T08:51:56+00:00">18th June 2018</time>
                                </div>
                            </div>


                            <div class="col-12 col-sm-12 col-md-6 col-lg-4 col-xl-3 project-item">
                                <a href="#" class="project-image" title="Project Title">
                                    <div class="project-image-inner">
                                        <!--
                                        <img src="${asset.assetPath(src:"assets/img/example4.jpg")}" alt="Project Title" />
                                        -->
                                        <img src="https://ecodata.ala.org.au/uploads/2020-08/thumb_1_Gorse.jpg" alt="Project Title" />

                                    </div>
                                </a>
                                <a href="#" class="project-link" title="Project Title">
                                    <h4>MAPPING GORSE ON THE TOORADIN FLOOD PLAIN</h4>
                                    <p class="subtitle">Western Port Catchment Landcare Network</p>
                                </a>
                                <div class="excerpt">To map gorse on the floodplain adjacent to the Bunyip River</div>
                                <div class="detail">
                                    <span class="label">Status: </span>
                                    <span class="status">Project Ongoing</span>
                                </div>
                                <div class="detail">
                                    <span class="label">Start Date: </span>
                                    <time aria-label="Project Start Date" datetime="2018-06-18T08:51:56+00:00">18th July 2018</time>
                                </div>
                            </div>


                            <div class="col-12 col-sm-12 col-md-6 col-lg-4 col-xl-3 project-item">
                                <a href="#" class="project-image" title="Project Title">
                                    <div class="project-image-inner">
                                        <!--
                                        <img src="${asset.assetPath(src:"assets/img/example1.jpg")}" alt="Project Title" />
                                        -->
                                        <img src="https://ecodata.ala.org.au/uploads/2020-08/thumb_Wyndham_logo.PNG" alt="Project Title" />
                                    </div>
                                </a>
                                <a href="#" class="project-link" title="Project Title">
                                    <h4>CAPE TULIP (MORAEA FLACCIDA AND MORAEA MINIATA)...</h4>
                                    <p class="subtitle">Wyndham City</p>
                                </a>
                                <div class="excerpt">To identify populations of the poisonous One-leaf Cape Tulip (Moraea flaccida...</div>
                                <div class="detail">
                                    <span class="label">Status: </span>
                                    <span class="status">Project Ongoing</span>
                                </div>
                                <div class="detail">
                                    <span class="label">Start Date: </span>
                                    <time aria-label="Project Start Date" datetime="2018-06-18T08:51:56+00:00">18th December 2018</time>
                                </div>
                            </div>


                            <div class="col-12 col-sm-12 col-md-6 col-lg-4 col-xl-3 project-item">
                                <a href="#" class="project-image" title="Project Title">
                                    <div class="project-image-inner">
                                        <!--
                                        <img src="${asset.assetPath(src:"assets/img/example2.jpg")}" alt="Project Title" />
                                        -->
                                        <img src="https://ecodata.ala.org.au/uploads/2020-09/thumb_up2us_logo.jpg" alt="Project Title" />

                                    </div>
                                </a>
                                <a href="#" class="project-link" title="Project Title">
                                    <h4>PADDOCK TREE MONITORING</h4>
                                    <p class="subtitle">Up2Us Landcare Alliance</p>
                                </a>
                                <div class="excerpt">For community to document the change in our paddock trees over time through p...</div>
                                <div class="detail">
                                    <span class="label">Status: </span>
                                    <span class="status">Project Ongoing</span>
                                </div>
                                <div class="detail">
                                    <span class="label">Start Date: </span>
                                    <time aria-label="Project Start Date" datetime="2018-06-18T08:51:56+00:00">18th Feb 2020</time>
                                </div>
                            </div>


                            <div class="col-12 col-sm-12 col-md-6 col-lg-4 col-xl-3 project-item">
                                <a href="#" class="project-image" title="Project Title">
                                    <div class="project-image-inner">
                                        <!--
                                        <img src="${asset.assetPath(src:"assets/img/example3.jpg")}" alt="Project Title" />
                                        -->
                                        <img src="https://ecodata.ala.org.au/uploads/2020-08/thumb_0_WWF_Logo_Large_RGB_72dpi.jpg" alt="Project Title" />

                                    </div>
                                </a>
                                <a href="#" class="project-link" title="Project Title">
                                    <h4>SPRING QUENDA COUNT 2020</h4>
                                    <p class="subtitle">WORLD WIDE FUND FOR NATURE AUSTRALIA</p>
                                </a>
                                <div class="excerpt">WWF-Australia and the WA Department of Biodiversity, Conservation and Attract...</div>
                                <div class="detail">
                                    <span class="label">Status: </span>
                                    <span class="status">Project Ongoing</span>
                                </div>
                                <div class="detail">
                                    <span class="label">Start Date: </span>
                                    <time aria-label="Project Start Date" datetime="2018-06-18T08:51:56+00:00">28th June 2018</time>
                                </div>
                            </div>


                            <div class="col-12 col-sm-12 col-md-6 col-lg-4 col-xl-3 project-item">
                                <a href="#" class="project-image" title="Project Title">
                                    <div class="project-image-inner">
                                        <!--
                                        <img src="${asset.assetPath(src:"assets/img/example4.jpg")}" alt="Project Title" />
                                        -->

                                        <img src="https://ecodata.ala.org.au/uploads/2020-09/thumb_10_logo.jpg" alt="Project Title" />
                                    </div>
                                </a>
                                <a href="#" class="project-link" title="Project Title">
                                    <h4>REIMAGINING BENDIGO CREEK, IRONBARK GULLY</h4>
                                    <p class="subtitle">Ironbark Gully Friends</p>
                                </a>
                                <div class="excerpt">To monitor changes in flora and fauna biodiversity along the Ironbark Gully T...</div>
                                <div class="detail">
                                    <span class="label">Status: </span>
                                    <span class="status">Project Ongoing</span>
                                </div>
                                <div class="detail">
                                    <span class="label">Start Date: </span>
                                    <time aria-label="Project Start Date" datetime="2018-06-18T08:51:56+00:00">11th August 2020</time>
                                </div>
                            </div>


                        </div>

                        <div class="pagination-container row">
                            <div class="col-xs-12 col-lg-4 d-flex align-items-center justify-content-center justify-content-lg-start">
                                <div class="showing">Showing 1 to 12 of 300 Projects</div>
                            </div>
                            <div class="col-xs-12 col-lg-4 d-flex align-items-center justify-content-center pt-3 pt-lg-0 pb-3 pb-lg-0">
                                <nav aria-label="Featured Projects Navigation">
                                    <ul class="pagination justify-content-center">
                                        <li class="page-item d-none">
                                            <a class="page-link" href="#" tabindex="-1"><i class="fas fa-chevron-left"></i></a>
                                        </li>
                                        <li class="page-item"><a class="page-link active" href="#">1</a></li>
                                        <li class="page-item"><a class="page-link" href="#">2</a></li>
                                        <li class="page-item"><a class="page-link" href="#">3</a></li>
                                        <li class="page-item"><a class="page-link" href="#">4</a></li>
                                        <li class="page-item"><a class="page-link" href="#">5</a></li>
                                        <li class="page-item">
                                            <a class="page-link" href="#"><i class="fas fa-chevron-right"></i></a>
                                        </li>
                                    </ul>
                                </nav>
                            </div>
                            <div class="col-xs-12 col-lg-4 d-flex align-items-center justify-content-center justify-content-lg-end">
                                <div class="limiter text-right">
                                    Show
                                    <label for="projectsLimit" class="sr-only">Projects per page</label>
                                    <select id="projectsLimit" class="custom-select projects-limiter">
                                        <option value="12">12</option>
                                        <option value="24">24</option>
                                        <option value="48">48</option>
                                        <option value="64">64</option>
                                    </select>
                                    projects per page
                                </div>
                            </div>
                        </div>

                    </div>


                    <div id="filters" class="collapse show expander">
                        <button
                                data-toggle="collapse"
                                data-target=".expander"
                                aria-expanded="true"
                                aria-controls="expander"
                                class="close"
                                title="Close Filters">
                            <i class="far fa-times-circle"></i>
                        </button>

                        <div class="title">
                            <h3>Filters</h3>
                            <button type="button" class="btn btn-sm btn-dark refine" aria-label="Refine Projects"><i class="fas fa-filter"></i> Refine</button>
                        </div>

                        <div class="filter-group">

                            <button class="accordion-header" type="button" data-toggle="collapse" data-target="#types" aria-expanded="true" aria-controls="types">
                                Project Types
                            </button>
                            <div class="collapse show accordion-body" id="types">
                                <div class="custom-checkbox">
                                    <input type="checkbox" name="types" id="citizenScience" value="Citizen Science" />
                                    <label for="citizenScience">Citizen Science (3)</label>
                                </div>
                                <div class="custom-checkbox">
                                    <input type="checkbox" name="types" id="ecologicalScience" value="Ecological Science" />
                                    <label for="ecologicalScience">Ecological Science (1)</label>
                                </div>
                                <div class="custom-checkbox">
                                    <input type="checkbox" name="types" id="meritScience" value="MERIT Science" />
                                    <label for="meritScience">NRM Projects (15)</label>
                                </div>
                            </div>

                            <button class="accordion-header collapsed" type="button" data-toggle="collapse" data-target="#Organization" aria-expanded="false" aria-controls="Organization">
                                Organization
                            </button>
                            <div class="collapse accordion-body" id="Organization">
                                Organization
                            </div>

                            <button class="accordion-header collapsed" type="button" data-toggle="collapse" data-target="#program" aria-expanded="false" aria-controls="program">
                                Sub Program
                            </button>
                            <div class="collapse accordion-body" id="program">
                                Sub Program
                            </div>

                            <button class="accordion-header collapsed" type="button" data-toggle="collapse" data-target="#status" aria-expanded="false" aria-controls="status">
                                Status
                            </button>
                            <div class="collapse accordion-body" id="status">
                                Status
                            </div>

                            <button class="accordion-header collapsed" type="button" data-toggle="collapse" data-target="#tags" aria-expanded="false" aria-controls="tags">
                                Tags
                            </button>
                            <div class="collapse accordion-body" id="tags">
                                Tags
                            </div>

                            <button class="accordion-header collapsed" type="button" data-toggle="collapse" data-target="#difficulty" aria-expanded="false" aria-controls="difficulty">
                                Difficulty
                            </button>
                            <div class="collapse accordion-body" id="difficulty">
                                Difficulty
                            </div>

                            <button class="accordion-header collapsed" type="button" data-toggle="collapse" data-target="#science" aria-expanded="false" aria-controls="science">
                                Science Type
                            </button>
                            <div class="collapse accordion-body" id="science">
                                Science Type
                            </div>

                        </div>

                        <div class="filters-footer">
                            <button class="btn btn-sm btn-dark"><i class="far fa-map"></i> Filter by geographic location</button>
                        </div>

                    </div>
                    <!-- /#filters -->

                </section>


            </article><!-- #article -->

        </main><!-- #main -->

    </div><!-- #full-width-page-wrapper --><footer class="site-footer footer-alt" id="footer">


    <div class="footer-top">
        <div class="container">
            <div class="row align-items-center">
                <div class="col-md-12 col-lg-8 align-center logo-column d-flex flex-column flex-md-row justify-content-center justify-content-lg-start align-items-center">
                    <h2>EcoScience Hub</h2>
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
                            <a title="Target Species" href="#">Data</a>
                        </li>
                        <li class="menu-item">
                            <a title="Data" href="#">My Data</a>
                        </li>
                        <li class="menu-item">
                            <a title="Data" href="#">New Projects</a>
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
                    <div class="powered-by">
                        <img src="${asset.assetPath(src:"assets/img/powered-biocollect.jpg")}" alt="Powered by Biocollect" />
                        <img src="${asset.assetPath(src:"assets/img/powered-ala.jpg")}" alt="Powered by ALA" />
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
