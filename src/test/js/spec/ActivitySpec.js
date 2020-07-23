
describe('Test activity view models', function () {
    beforeAll(function() {
        window.fcConfig = {
        }
    });

    it('add button should be hidden for works projects', function () {
        var vm = new ActivityRecordViewModel({projectType: "works"});
        expect(vm.showAdd()).toBe(false);
        var vm = new ActivityRecordViewModel({projectType: "survey"});
        expect(vm.showAdd()).toBe(true);
    });
});