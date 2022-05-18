/*
	This is the Geb configuration file.

	See: http://www.gebish.org/manual/current/configuration.html
*/


import org.openqa.selenium.chrome.ChromeDriver
import org.openqa.selenium.chrome.ChromeOptions
import org.openqa.selenium.firefox.FirefoxDriver
//import org.openqa.selenium.phantomjs.PhantomJSDriver

if (!System.getProperty("webdriver.chrome.driver")) {
    System.setProperty("webdriver.chrome.driver", "node_modules/chromedriver/bin/chromedriver")
}
driver = { new ChromeDriver() }
baseUrl = 'http://devt.ala.org.au:8087/'
atCheckWaiting = true
waiting {
    timeout = 20
    retryInterval = 0.5
}

environments {

    reportsDir = 'build/reports/geb-reports'

    // run as grails -Dgeb.env=chrome test-app
    chrome {

        driver = { new ChromeDriver() }
    }

    firefox {
        driver = { new FirefoxDriver() }
    }

//    phantomjs {
//        if (!System.getProperty("phantomjs.binary.path")) {
//            String phantomjsPath = "node_modules/phantomjs-prebuilt/lib/phantom/bin/phantomjs"
//            if (!new File(phantomjsPath).exists()) {
//                throw new RuntimeException("Please install node modules before running functional tests")
//            }
//
//            System.setProperty("phantomjs.binary.path", phantomjsPath)
//        }
//
//        driver = { new PhantomJSDriver() }
//    }

    chromeHeadless {

        if (!System.getProperty("webdriver.chrome.driver")) {
            System.setProperty("webdriver.chrome.driver", "node_modules/chromedriver/bin/chromedriver")
        }
        driver = {
            ChromeOptions o = new ChromeOptions()
            o.addArguments('headless')
            o.addArguments("window-size=1920,1080")
            o.addArguments('--disable-dev-shm-usage')
            new ChromeDriver(o)
        }
    }

}
