<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <meta name="layout" content="ala4"/>
    <title> Homepage | <g:message code="g.biocollect"/> </title>
</head>

<body>
<!--
http://devt.ala.org.au:8087/project/projectFinder#isCitizenScience=true&fq=featured:T&queryList=featured:T
-->
<div class="wrapper" id="home">

    <main class="site-main" id="main" role="main">

        <section class="hero-slider swiper-container">
            <div class="swiper-wrapper">
                <div class="swiper-slide"
                     style="background-image: url('${asset.assetPath(src: "assets/img/banner.jpg")}');">
                    <div class="slide-overlay">
                        <div class="container d-none d-md-block">
                            <h1>Data collection tool for biodiversity science</h1>

                            <p>COLLECT and SHARE your data</p>
                            <div class="dropdown">
                                <button class="btn btn-primary-dark dropdown-toggle" type="button" id="dropdownMenuButton" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                    Explore Projects
                                </button>
                                <div class="dropdown-menu" aria-labelledby="dropdownMenuButton">
                                    <a class="dropdown-item" href="${createLink(controller: 'hub', action: 'index', params: [citizenScience:true, hub:'acsa'])}">Citizen science</a>
                                    <a class="dropdown-item" href="${createLink(controller: 'hub', action: 'index', params: [citizenScience:true, hub:'ecoscience'])}">Researchers, ecologists & industry</a>
                                    <a class="dropdown-item" href="${createLink(controller: 'hub', action: 'index', params: [hub:'nrmworks'])}">Natural resource management</a>
                                </div>
                            </div>

                            <!--
                            <a href="${createLink(controller: 'hub', action: 'index', params: [citizenScience:true, hub:'acsa'])}" class="btn btn-primary-dark btn-small"></a>
                            -->
                        </div>
                    </div>
                </div>
                <!--
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
                -->
            </div>

            <div class="swiper-pagination"></div>

            <div class="search-overlay">
                <div class="container">
                    <div class="search-container row">
                        <div class="col-md-12">
                            <form class="form-inline">
                                <div class="form-group flex-grow-1">
                                    <label for="search" class="sr-only">Search for projects</label>
                                    <input type="search" class="form-control flex-grow-1" id="search"
                                           placeholder="Search for projects..">
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
                                        <path class="search-icon"
                                              d="M1524.33,60v1.151a7.183,7.183,0,1,1-2.69.523,7.213,7.213,0,0,1,2.69-.523V60m0,0a8.333,8.333,0,1,0,7.72,5.217A8.323,8.323,0,0,0,1524.33,60h0Zm6.25,13.772-0.82.813,7.25,7.254a0.583,0.583,0,0,0,.82,0,0.583,0.583,0,0,0,0-.812l-7.25-7.254h0Zm-0.69-7.684,0.01,0c0-.006-0.01-0.012-0.01-0.018s-0.01-.015-0.01-0.024a6,6,0,0,0-7.75-3.3l-0.03.009-0.02.006v0a0.6,0.6,0,0,0-.29.293,0.585,0.585,0,0,0,.31.756,0.566,0.566,0,0,0,.41.01V63.83a4.858,4.858,0,0,1,6.32,2.688l0.01,0a0.559,0.559,0,0,0,.29.29,0.57,0.57,0,0,0,.75-0.305A0.534,0.534,0,0,0,1529.89,66.089Z"
                                              transform="translate(-1516 -60)"/>
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
                        <h2>Collectively contribute to “big science”</h2>

                        <p>BioCollect is a sophisticated, yet simple to use tool developed by the Atlas of Living Australia (ALA) in collaboration with over 100 organisations which are involved in field data capture. It has been developed to support the needs of scientists, ecologists, citizen scientists and natural resource managers in the field-collection and management of biodiversity, ecological and natural resource management (NRM) data. The tool is developed and hosted by the ALA and is free for public use.</p>
                        <!--<a href="#" title="Learn More">Learn More...</a> -->
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
                                <img src="${asset.assetPath(src: "assets/img/icons/map-dark.svg")}"
                                     alt="Create a Project">
                            </div>

                            <div class="content">
                                <h4>Create a Project</h4>

                                <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod</p>
                            </div>
                        </div>

                        <div class="d-flex icon-text">
                            <div class="image">
                                <img src="${asset.assetPath(src: "assets/img/icons/search-dark.svg")}"
                                     alt="Search Projects">
                            </div>

                            <div class="content">
                                <h4>Search Projects</h4>

                                <p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod</p>
                            </div>
                        </div>

                        <div class="d-flex icon-text">
                            <div class="image">
                                <img src="${asset.assetPath(src: "assets/img/icons/browser-dark.svg")}" alt="View Data">
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
                                <img src="${asset.assetPath(src: "assets/img/icons/mobile-dark.svg")}"
                                     alt="Download our App">
                            </div>

                            <div class="content">
                                <h4>BioCollect Mobile Apps</h4>

                                <p>
                                    <a href="#" title="Download the BioCollect App on the Apple AppStore!"
                                       class="store-link">
                                        <img src="${asset.assetPath(src: "assets/img/badge-appstore.svg")}"
                                             alt="Apple AppStore"/>
                                    </a>
                                    <a href="#" title="Download the BioCollect App on the Google Play Store!"
                                       class="store-link">
                                        <img src="${asset.assetPath(src: "assets/img/badge-playstore.svg")}"
                                             alt="Google Play Store"/>
                                    </a>
                                </p>
                            </div>
                        </div>

                        <div class="d-flex icon-text mobile-app">
                            <div class="image">
                                <img src="${asset.assetPath(src: "assets/img/icons/mobile-dark.svg")}"
                                     alt="Download our App">
                            </div>

                            <div class="content">
                                <h4>OzAtlas Mobile Apps</h4>

                                <p>
                                    <a href="#" title="Download the OzAtlas App on the Apple AppStore!"
                                       class="store-link">
                                        <img src="${asset.assetPath(src: "assets/img/badge-appstore.svg")}"
                                             alt="Apple AppStore"/>
                                    </a>
                                    <a href="#" title="Download the OzAtlas App on the Google Play Store!"
                                       class="store-link">
                                        <img src="${asset.assetPath(src: "assets/img/badge-playstore.svg")}"
                                             alt="Google Play Store"/>
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
                            <li><a href="#" title="BioCollect for Citizen Science">BioCollect for Citizen Science <i
                                    class="fas fa-long-arrow-alt-right" aria-hidden="true"></i></a></li>
                            <li><a href="#"
                                   title="BioCollect for Ecological Science">BioCollect for Ecological Science <i
                                        class="fas fa-long-arrow-alt-right" aria-hidden="true"></i></a></li>
                            <li><a href="#" title="BioCollect for NRM">BioCollect for NRM <i
                                    class="fas fa-long-arrow-alt-right" aria-hidden="true"></i></a></li>
                            <li><a href="#" title="BioCollect Hubs">BioCollect Hubs <i
                                    class="fas fa-long-arrow-alt-right" aria-hidden="true"></i></a></li>
                            <li><a href="#" title="Developer Resources">Developer Resources <i
                                    class="fas fa-long-arrow-alt-right" aria-hidden="true"></i></a></li>
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

                                    <a href="#" class="post-link" rel="bookmark"
                                       title="Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do">

                                        <div class="post-image">
                                            <img src="${asset.assetPath(src: "assets/img/blog1.jpg")}"
                                                 alt="Lorem ipsum dolor sit amet, consectetur adipisicing elit"/>
                                        </div>

                                        <header class="entry-header">

                                            <h3 class="entry-title">Lorem ipsum dolor sit amet, consectetur adipisicing elit</h3>

                                            <div class="entry-meta">
                                                <span class="posted-on">
                                                    <span class="sr-only">Posted on</span>
                                                    <time aria-label="Date Posted"
                                                          datetime="2018-06-18T08:51:56+00:00">18th June 2018</time>
                                                </span>
                                            </div><!-- .entry-meta -->

                                        </header><!-- .entry-header -->

                                    </a>

                                </article><!-- #post-## -->

                                <article class="post swiper-slide" id="post-1b">

                                    <a href="#" class="post-link" rel="bookmark"
                                       title="Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do">

                                        <div class="post-image">
                                            <img src="${asset.assetPath(src: "assets/img/blog2.jpg")}"
                                                 alt="Lorem ipsum dolor sit amet, consectetur adipisicing elit"/>
                                        </div>

                                        <header class="entry-header">

                                            <h3 class="entry-title">Lorem ipsum dolor sit amet, consectetur adipisicing elit</h3>

                                            <div class="entry-meta">
                                                <span class="posted-on">
                                                    <span class="sr-only">Posted on</span>
                                                    <time aria-label="Date Posted"
                                                          datetime="2018-06-18T08:51:56+00:00">18th June 2018</time>
                                                </span>
                                            </div><!-- .entry-meta -->

                                        </header><!-- .entry-header -->

                                    </a>

                                </article><!-- #post-## -->

                            </div>

                            <div class="text-center mt-3">
                                <a href="http://devt.ala.org.au:8087/project/projectFinder#isCitizenScience=true&fq=featured:T&queryList=featured:T" class="btn btn-primary-dark btn-sm"
                                   title="View More - Featured Projects">View More</a>
                            </div>

                        </div>
                    </div>

                    <div class="col-12 col-md-4 col-lg-4 mt-5 mt-md-0">

                        <h2 role="heading" aria-level="2" class="section-heading">Featured Hubs</h2>

                        <div class="post-list swiper-container post-slider">

                            <div class="swiper-wrapper">

                                <article class="post swiper-slide" id="post-2">

                                    <a href="#" class="post-link" rel="bookmark"
                                       title="Eiusmod tempor incididunt ut labore et dolore magna aliqua">

                                        <div class="post-image">
                                            <img src="${asset.assetPath(src: "assets/img/blog2.jpg")}"
                                                 alt="Eiusmod tempor incididunt ut labore et dolore magna aliqua"/>
                                        </div>

                                        <header class="entry-header">

                                            <h3 class="entry-title">Eiusmod tempor incididunt ut labore et dolore magna aliqua</h3>

                                            <div class="entry-meta">
                                                <span class="posted-on">
                                                    <span class="sr-only">Posted on</span>
                                                    <time aria-label="Date Posted"
                                                          datetime="2018-08-18T08:51:56+00:00">18th August 2018</time>
                                                </span>
                                            </div><!-- .entry-meta -->

                                        </header><!-- .entry-header -->

                                    </a>

                                </article><!-- #post-## -->

                                <article class="post swiper-slide" id="post-2b">

                                    <a href="#" class="post-link" rel="bookmark"
                                       title="Eiusmod tempor incididunt ut labore et dolore magna aliqua">

                                        <div class="post-image">
                                            <img src="${asset.assetPath(src: "assets/img/blog1.jpg")}"
                                                 alt="Eiusmod tempor incididunt ut labore et dolore magna aliqua"/>
                                        </div>

                                        <header class="entry-header">

                                            <h3 class="entry-title">Eiusmod tempor incididunt ut labore et dolore magna aliqua</h3>

                                            <div class="entry-meta">
                                                <span class="posted-on">
                                                    <span class="sr-only">Posted on</span>
                                                    <time aria-label="Date Posted"
                                                          datetime="2018-08-18T08:51:56+00:00">18th August 2018</time>
                                                </span>
                                            </div><!-- .entry-meta -->

                                        </header><!-- .entry-header -->

                                    </a>

                                </article><!-- #post-## -->

                            </div>

                            <div class="text-center mt-3">
                                <a href="#" class="btn btn-primary-dark btn-sm"
                                   title="View More - Use BioCollect for...">View More</a>
                            </div>

                        </div>
                    </div>

                    <div class="col-12 col-md-4 col-lg-4 mt-5 mt-md-0">

                        <h2 role="heading" aria-level="2" class="section-heading">Use BioCollect for...</h2>

                        <div class="post-list swiper-container post-slider">

                            <div class="swiper-wrapper">

                                <article class="post swiper-slide" id="post-4">

                                    <a href="#" class="post-link" rel="bookmark"
                                       title="Duis aute irure dolor in reprehenderit in voluptate velit">

                                        <div class="post-image">
                                            <img src="${asset.assetPath(src: "assets/img/blog2.jpg")}"
                                                 alt="Duis aute irure dolor in reprehenderit in voluptate velit"/>
                                        </div>

                                        <header class="entry-header">
                                            <h3 class="entry-title">Duis aute irure dolor in reprehenderit in voluptate velit</h3>
                                        </header><!-- .entry-header -->

                                        <div class="entry-meta">
                                            <span class="posted-on">
                                                <span class="sr-only">Posted on</span>
                                                <time aria-label="Date Posted"
                                                      datetime="2018-08-18T08:51:56+00:00">18th August 2018</time>
                                            </span>
                                        </div><!-- .entry-meta -->

                                    </a>

                                </article><!-- #post-## -->

                                <article class="post swiper-slide" id="post-4b">

                                    <a href="#" class="post-link" rel="bookmark"
                                       title="Duis aute irure dolor in reprehenderit in voluptate velit">

                                        <div class="post-image">
                                            <img src="${asset.assetPath(src: "assets/img/blog1.jpg")}"
                                                 alt="Duis aute irure dolor in reprehenderit in voluptate velit"/>
                                        </div>

                                        <header class="entry-header">
                                            <h3 class="entry-title">Duis aute irure dolor in reprehenderit in voluptate velit</h3>
                                        </header><!-- .entry-header -->

                                        <div class="entry-meta">
                                            <span class="posted-on">
                                                <span class="sr-only">Posted on</span>
                                                <time aria-label="Date Posted"
                                                      datetime="2018-08-18T08:51:56+00:00">18th August 2018</time>
                                            </span>
                                        </div><!-- .entry-meta -->

                                    </a>

                                </article><!-- #post-## -->

                            </div>

                            <div class="text-center mt-3">
                                <a href="#" class="btn btn-primary-dark btn-sm"
                                   title="View More - How To...">View More</a>
                            </div>

                        </div>
                    </div>
                </div>
            </div>
        </section>

    </main><!-- #main -->

</div><!-- #full-width-page-wrapper -->

</body>
</html>




