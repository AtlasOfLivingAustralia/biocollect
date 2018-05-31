<%@ page import="grails.converters.JSON; au.org.ala.biocollect.merit.SettingPageType" contentType="text/html;charset=UTF-8" %>
<!DOCTYPE HTML>
<html xmlns="http://www.w3.org/1999/html">
<head>
    <meta name="layout" content="${hubConfig.skin}"/>
    <title><g:message code="g.citizenScience"/> | <g:message code="g.fieldCapture"/></title>
    <asset:script type="text/javascript">
    var fcConfig = {
        baseUrl: "${grailsApplication.config.grails.serverURL}",
        spatialBaseUrl: "${grailsApplication.config.spatial.baseURL}",
        spatialWmsCacheUrl: "${grailsApplication.config.spatial.wms.cache.url}",
        spatialWmsUrl: "${grailsApplication.config.spatial.wms.url}",
        sldPolgonDefaultUrl: "${grailsApplication.config.sld.polgon.default.url}",
        sldPolgonHighlightUrl: "${grailsApplication.config.sld.polgon.highlight.url}",
        dashboardUrl: "${g.createLink(controller: 'report', action: 'dashboardReport', params: params)}"
    }
    </asset:script>
    <script type="text/javascript" src="//www.google.com/jsapi"></script>
</head>

<body>
<div id="wrapper" class="container-fluid">
    <div class="row-fluid">
        <div class="span4">
            <h2>Citizen Science</h2>
            <h3>What is 'citizen science'?</h3>
            The <a href="">Open Scientist</a> website offers this definition of citizen science:
            'The systematic collection and analysis of data, determination of technology, testing of natural phenomena,
            and the dissemination of these activities by researchers on a primarily avocational basis.'
            For Australia's biodiversity, it is the participation of anyone who is not a practising acologist,
            taxonomist, or biological scientist, in the collection of biodiversity related data.
            <img src="">
            <h3>Role of citizen science in the Atlas</h3>
            For the Atlas, citizen science is a very important source of data about biodiversity.
            Data and insights gained through the efforts of citizen scientists can be as valuable as that obtained
            by scientists working in academia, natural history collections, government agencies and business.
            Harnessing the efforts of the thousands of people participating in citizen science will enhance the
            range and depth of data available for analysis and research.
            <br/>
            <h3>Get involved in citizen science</h3>
            There are several ways for you to participate in citizen science:
            <ul>
            <li>Add your sightings of plants or animals directly into the Atlas of Living Australia (see below)</li>
            <li>Contribute your sightings to one of the many citizen science projects currently happening n different
            areas of Australia.  These range from species specific projects (eg. Koala counts, frogwatch, etc.) to
            regional or national multi-species themed projects (eg. Feral scan, ACT and Southern Tablelands
            Weedspotter, waterwatch, etc.), or regional atlases (eg. the Atlas of Life in the Coastal Wilderness).
            You can choose one that suits you!</li>
            <li>If you have skills in identifying one of the groups of organisms, why not join BowerBird and help
            other people identify their settings.</li>
            </ul>
            <p>Sometimes citizen science projects are run as short campaigns, such as bioblitzes, and sometimes
            they are ongoing data collection projects.  You can get as involved as much or as little as you like,
            but in all cases your sightings are valued contributions to the scientific knowledge and the national
            biodiversity database.</p>
            <p>Start recording the organisms in your own area and on your travels, and join thousands of other
            people in building Australia's biodiversity knowledge.  Get yourself on the Citizen Science Leader Board
            by recordign more different species as you can.</p>
        </div>
        <div class="span4">
            <h3>Add a record to the Atlas</h3>
            Join the hundreds of people who are adding their sightings of plants or animals directly into the Atlas.
            Register now and add yours.
            <br/>
            <a href="${createLink(action: 'record')}" class="btn btn-small">Record a sighting</a>
            <br/>
            <h3>Improve your nature photography</h3>
            Including good quality photos with your sighting record is important to support both the quality of
            your record and the correct identification if you need to seek help in identifying the specimen.
            Nature photography can also be fun and rewarding in itself.
            A quick <a href="">search on the internet</a> will provide lots of fantastic resources to help improve
            your photographic skills.
            <br/>
            <h3>Take great photos of small things</h3>
            Many organisms are very small and correct identification may require really good close-up (macro) photos,
            sometimes from several angles.  For insects, sharp photos of heads, mouth parts and reproductive organs
            are also important.
            <p>A search on the internet <a href="">such as this</a> will find several helpful tips on taking
            sharp macro natural photos.</p>
            <br/>
            <h3>Help me identify my sighting</h3>
            It can often be difficult to accurately identify a sighting out in the field and identifying organisms
            to species level can be challenging even for experts in some groups of organisms.
            <br/>
            <h3>Try to identify it yourself</h3>
            There are a couple of identification support tools available on the internet.
            These tools are constantly being updated and improved, but they can be difficult to use, particularly
            for non-taxonomists.
            <ul>
            <li>Link to Lucid keys
                <a href="http://www.lucidcentral.com/en-us/keys173;/searchforakey.aspx"><img src="http://www.lucidcentral.com/Portals/1/Skins/lucidcentral/home_logo.gif"</a></li>
            <li>Link to IdentifyLife keys
                <a href="http://www2.identifylife.org"></a></li>
            </ul>
            <br/>
            <h3>Let others identify my sighting</h3>
            The Atlas supported the development of BowerBird - a tool for communities of interest and the power of
            crowd sourcing to assist people with identifying the specimens in their images.
            <p>This is a different web tool and will require you to register separately, but when your image has
            been identified, the record, including your image, will be copied into the Atlas of Living Australia
            to be available for scientific use.</p>
            <p>Link to BowerBird <a href="http://bowerbird.org.au"><img src="http://www.bowerbird.org.au/img/logo.svg"></a></p>
        </div>
        <div class="span4">
            <h3>Citizen science in my area</h3>
            The Atlas is currently developing a tool for citizen science projects to be registered and to make it
            easy for you to find projects happening in your area or with a subject or theme that is of interest to you.
            <p>In the interim, here is a list of citizen science projects supported by Atlas infrastructure and
            other projects in Australia that the Atlas does not support directly, but that we are aware of.</p>
            <a href="${createLink(controller:'project', action:'homePage')}" class="btn btn-small">
                <g:message code="project.citizenScience.heading"/></a>
            <br/>
            <h3>Citizen Science Network Australia</h3>
            The national citizen science adovcay and community discussion forum
            <a href="">Join in and have your say</a>
        </div>
    </div>
</div>
</body>
</html>
