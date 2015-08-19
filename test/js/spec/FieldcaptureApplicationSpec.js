/**
 * Created by sat01a on 3/07/15.
 */

describe("Validate iframe html format", function () {
    beforeAll(function() {
        window.fcConfig = {
            imageLocation:'/'
        }
    });
    afterAll(function() {
        delete window.fcConfig;
    });

    it("validate embedded iframe src", function () {
        expect(isUrlAndHostValid("https://www.youtube.com/embed/j1bR-0XBfcs")).toBe(true);
        expect(isUrlAndHostValid("https://embed-ssl.ted.com/talks/elora_hardy_magical_houses_made_of_bamboo.html")).toBe(true);
        expect(isUrlAndHostValid("http://google.com/")).toBe(false);
        expect(isUrlAndHostValid("http:")).toBe(false);
        expect(isUrlAndHostValid("http://w:")).toBe(false);
        expect(isUrlAndHostValid("http://localserver:")).toBe(false);
        expect(isUrlAndHostValid("https://google.com:")).toBe(false);
        expect(isUrlAndHostValid("derp://www.google.com")).toBe(false);
    });

    it("invalid iframe should not be rendered on the project home page", function () {
        var iframes = [
            '<iframe src="https://embed-ssl.ted.com/talks/elora_hardy_magical_houses_made_of_bamboo.html" width="560" height="315" frameborder="0" scrolling="no" webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe>',
            '<iframe src="https://embed-yahoo.ted.com/talks/elora_hardy_magical_houses_made_of_bamboo.html" width="560" height="315" frameborder="0" scrolling="no" webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe>',
            'iframe src="https://embed-yahoo.ted.com/talks/elora_hardy_magical_houses_made_of_bamboo.html" width="560" height="315" frameborder="0" scrolling="no" webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe>',
            '<o>invalid html format<.',
            '<iframe width="560" height="315" frameborder="0" scrolling="no" webkitAllowFullScreen mozallowfullscreen allowFullScreen></iframe>',
            '<iframe src="https://embed-ssl.ted.com/talks/elora_hardy_magical_houses_made_of_bamboo.html"></iframe>',
            '<iframe src="https://embed-ssl.ted.com/talks/elora_hardy_magical_houses_made_of_bamboo.html"></iframe>,<iframe src="https://embed-ssl.ted.com/talks/elora_hardy_magical_houses_made_of_bamboo.html"></iframe>',
            '<iframe src="https://abc-ssl.ted.com/talks/elora_hardy_magical_houses_made_of_bamboo.html"></iframe>,<iframe src="https://embed-ssl.ted.com/talks/elora_hardy_magical_houses_made_of_bamboo.html"></iframe>',
            '<iframe src="https://player.vimeo.com/talks/elora_hardy_magical_houses_made_of_bamboo.html"></iframe>,<iframe src="https://embed-ssl.ted.com/talks/elora_hardy_magical_houses_made_of_bamboo.html"></iframe>'
        ];
        var index = 0;
        expect(buildiFrame(iframes[index])).not.toEqual("");
        expect(buildiFrame(iframes[++index])).toEqual("");
        expect(buildiFrame(iframes[++index])).toEqual("");
        expect(buildiFrame(iframes[++index])).toEqual("");
        expect(buildiFrame(iframes[++index])).toEqual("");
        expect(buildiFrame(iframes[++index])).not.toEqual("");
        expect(buildiFrame(iframes[++index])).not.toEqual("");
        expect(buildiFrame(iframes[++index])).toEqual("");
        expect(buildiFrame(iframes[++index])).not.toEqual("");
    });
});