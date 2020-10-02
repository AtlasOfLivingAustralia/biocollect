<!-- ******************* The Navbar Area ******************* -->
<div id="wrapper-navbar" itemscope="" itemtype="http://schema.org/WebSite">
    <a class="skip-link sr-only sr-only-focusable" href="#content">Skip to content</a>
    <nav class="navbar navbar-expand-lg navbar-dark">
        <div class="container">

            <!-- Your site title as branding in the menu -->
            <a href="/" class="custom-logo-link navbar-brand" rel="home" itemprop="url">
                <!--
                <asset:image src="logo.png"/>
                -->
                <img width="183" height="80" src="${asset.assetPath(src:"assets/img/logo.png")}" class="logo light-logo" alt="BioCollect" itemprop="logo">
                <img width="183" height="80" src="${asset.assetPath(src:"assets/img/logo-dark.png")}" class="logo dark-logo" alt="BioCollect" itemprop="logo">
            </a> <!-- end custom logo -->

            <div class="outer-nav-wrapper">
                <div class="top-bar d-flex">
                    <ul class="social">
                        <li><a href="${grailsApplication.config.facebook.url}" target="_blank" title="Facebook"><i class="fab fa-facebook-f"></i></a></li>
                        <li><a href="${grailsApplication.config.twitter.url}" target="_blank" title="Twitter"><i class="fab fa-twitter"></i></a></li>
                    </ul>
                    <a href="${grailsApplication.config.blog.url}" class="btn btn-link btn-sm d-none d-lg-inline-block" title="Blog">Blog</a>
                    <a href="${grailsApplication.config.contactus.url}" class="btn btn-link btn-sm d-none d-lg-inline-block" title="Contact Us">Contact Us</a>

                    <div class="account d-none d-lg-block">
                        <g:set var="userLoggedIn"><fc:userIsLoggedIn/></g:set>
                        <g:if test="${userLoggedIn}">
                            <fc:loginLogoutButton logoutUrl="${grailsApplication.config.grails.serverURL}/logout/logout"/>
                        </g:if>
                        <g:else>
\                            <a target="_blank" href="${grailsApplication.config.userDetails.url}registration/createAccount" class="btn btn-outline-white btn-sm" title="Signup">Sign up</a>
                            <fc:loginLogoutButton/>
                        </g:else>
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
                                <a title="View Data" href="${createLink(controller: 'bioActivity', action: 'allRecords')}" class="nav-link">View Data</a>
                            </li>
                            <li itemscope="itemscope" itemtype="https://www.schema.org/SiteNavigationElement" class="menu-item menu-item-has-children dropdown nav-item">
                                <a title="New Project" href="${createLink(controller: 'project', action: 'create')}" class="nav-link">New Project</a>
                            </li>
                            <li itemscope="itemscope" itemtype="https://www.schema.org/SiteNavigationElement" class="menu-item menu-item-has-children dropdown nav-item">
                                <a title="Support" href="#" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false" class="dropdown-toggle nav-link"
                                   id="menu-item-dropdown-9">Help</a>
                                <ul class="dropdown-menu" role="menu">
                                    <li itemscope="itemscope" itemtype="https://www.schema.org/SiteNavigationElement" class="menu-item nav-item">
                                        <a title="Support Page 1" href="${grailsApplication.config.help.aboutBioCollect}" class="dropdown-item">What is BioCollect</a>
                                    </li>
                                    <li itemscope="itemscope" itemtype="https://www.schema.org/SiteNavigationElement" class="menu-item nav-item">
                                        <a title="Support Page 2" href="${grailsApplication.config.help.aboutProjects}" class="dropdown-item">About Projects</a>
                                    </li>
                                    <li itemscope="itemscope" itemtype="https://www.schema.org/SiteNavigationElement" class="menu-item nav-item">
                                        <a title="Support Page 2" href="${grailsApplication.config.help.aboutSurveys}" class="dropdown-item">About Surveys</a>
                                    </li>
                                    <li itemscope="itemscope" itemtype="https://www.schema.org/SiteNavigationElement" class="menu-item nav-item">
                                        <a title="Support Page 3" href="${grailsApplication.config.help.aboutNRM}" class="dropdown-item">Natural Resource Management Projects</a>
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
