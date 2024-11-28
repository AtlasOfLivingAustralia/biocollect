const StubbedCasSpec = require("./StubbedCasSpec");

class HomePage extends StubbedCasSpec {
    async open() {
        console.log(`Opening ${this.baseUrl}`);
        await browser.url(`${this.baseUrl}`);
    }

    async at() {
        let title = await browser.getTitle();
        return /Homepage/i.test(title);
    }
}

module.exports = HomePage;