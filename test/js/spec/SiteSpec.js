describe("SiteViewModelWithMapIntegration Spec", function () {

    beforeAll(function() {
        $.ajax = function() {
            var dummy = {}
            dummy.done = function() { return dummy; }
            return dummy;
        }
        window.fcConfig = {
            imageLocation:'/'
        }
    });
    afterAll(function() {
        delete window.fcConfig;
    });

    it("should be able to convert a drawn rectangle into geojson", function() {
        var model = new SiteViewModelWithMapIntegration({});
        var bounds = new Bounds([-150, 32], [-160, 34]);

        var shape = { getBounds: function() { return bounds; } };

        model.updateExtent('drawn');
        model.shapeDrawn('drawn', 'rectangle', shape);

        expect(model.extent().source()).toBe('drawn');
        expect(model.extent().geometry().type()).toBe('Polygon');
        var coordinates = model.extent().geometry().coordinates();
        expect(coordinates.length).toBe(1);
        expect(coordinates[0].length).toBe(5);
        expect(coordinates[0][0]).toEqual([-160, 34]);
        expect(coordinates[0][1]).toEqual([-160, 32]);
        expect(coordinates[0][2]).toEqual([-150, 32]);
        expect(coordinates[0][3]).toEqual([-150, 34]);
        expect(coordinates[0][4]).toEqual([-160, 34]);

    });


});

