/*
	This is the Geb configuration file.

	See: http://www.gebish.org/manual/current/configuration.html
*/


import org.openqa.selenium.chrome.ChromeDriver
import org.openqa.selenium.firefox.FirefoxDriver

baseUrl = 'http://devt.ala.org.au:8087/fieldcapture-hub/'
reportsDir = 'target/geb-reports'


// Use htmlunit as the default
// See: http://code.google.com/p/selenium/wiki/HtmlUnitDriver
driver = {
    System.setProperty('webdriver.chrome.driver', '/opt/webdrivers/chromedriver')

    new ChromeDriver()
}

environments {

    // run as �grails -Dgeb.env=chrome test-app�
    // See: http://code.google.com/p/selenium/wiki/ChromeDriver
    chrome {
        System.setProperty('webdriver.chrome.driver', '/opt/webdrivers/chromedriver')
        driver = {
            new ChromeDriver()
        }
    }

    // run as �grails -Dgeb.env=firefox test-app�
    // See: http://code.google.com/p/selenium/wiki/FirefoxDriver
    firefox {
        driver = { new FirefoxDriver() }
    }

}