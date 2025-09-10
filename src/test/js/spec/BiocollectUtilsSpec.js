describe("BiocollectUtilsSpec", function () {
    describe('saveDocument', function () {
        var mockResult;
        // Define test data
        beforeEach(function () {
            mockResult = {
                data: {
                    file: {
                        type: "text/plain",
                        name: "mockFileName",
                        size: 100,
                        lastModified: "2019"
                    },
                    blob: 'mockBlobData'
                }
            };

            window.entities = {
                saveDocument: function (document) {
                }
            }
        });

        it('should resolve the promise when save operation is successful', async function (done) {
            // Mock the window.entities.saveDocument function to return a resolved promise
            spyOn(window.entities, 'saveDocument').and.returnValue(Promise.resolve({data: 1}));
            await biocollect.utils.saveDocument(mockResult).then(function (result) {
                expect(result.data).toBe(1);
                done();
            })
        });

        it('should reject the promise when save operation fails', async function (done) {
            // Mock the window.entities.saveDocument function to return a rejected promise
            spyOn(window.entities, 'saveDocument').and.returnValue(Promise.reject('Save failed'));
            biocollect.utils.saveDocument(mockResult).then(function (result) {
            }, function (error) {
                expect(error.error).toBe('Save failed');
                done();
            });
        });

        it('should reject the promise when window.entities is not defined', function (done) {
            // Undefine window.entities
            window.entities = undefined;
            biocollect.utils.saveDocument(mockResult).then(function (result) {
            }, function (error) {
                expect(error).toBeUndefined();
                done();
            });
        });

        it('should reject the promise when createDocument fails', async function (done) {
            // Mock createDocument to throw an error
            spyOn(biocollect.utils, 'createDocument').and.throwError('Document creation error');
            try {
                biocollect.utils.saveDocument(mockResult);
            } catch (error) {
                expect(error.message).toBe('Document creation error');
                done();
            }
        });
    });


    describe('addObjectURL', function () {
        let originalImageViewModel;

        beforeEach(function () {
            originalImageViewModel = window.ImageViewModel;

            window.ImageViewModel = {
                createObjectURL: jasmine.createSpy('createObjectURL').and.callFake(function (doc) {
                    if (doc && doc.blob) {
                        doc.blobObject = new Blob([doc.blob], { type: doc.contentType });
                        return 'http://www.blob.com/fakeUrl';
                    }
                    return null;
                })
            };
        });

        afterEach(function () {
            if (originalImageViewModel === undefined) delete window.ImageViewModel;
            else window.ImageViewModel = originalImageViewModel;
        });

        // Test case 1: Valid Blob
        it('should set thumbnailUrl and url when a valid blob is provided', function () {
            var mockDocument = {
                blob: 'mockBlobData',
                contentType: 'image/jpeg'
            };

            biocollect.utils.addObjectURL(mockDocument);

            expect(ImageViewModel.createObjectURL).toHaveBeenCalledWith(mockDocument);
            expect(mockDocument.blobObject instanceof Blob).toBe(true);
            expect(mockDocument.thumbnailUrl).toBe('http://www.blob.com/fakeUrl');
            expect(mockDocument.url).toBe('http://www.blob.com/fakeUrl');
        });

        // Test case 2: No Blob Provided
        it('should not modify document properties when no blob is provided', function () {
            var mockDocument = {};

            biocollect.utils.addObjectURL(mockDocument);

            expect(ImageViewModel.createObjectURL).toHaveBeenCalledWith(mockDocument);
            expect(mockDocument.blobObject).toBeUndefined();
            expect(mockDocument.thumbnailUrl).toBeUndefined();
            expect(mockDocument.url).toBeUndefined();
        });
    });

    describe('nodeScriptReplace', () => {
        it('should replace a script node with its clone if it is a script node', () => {
            // Create a sample DOM structure with a script node
            const scriptNode = document.createElement('script');
            const parentNode = document.createElement('div');
            parentNode.appendChild(scriptNode);

            // Call the function
            const result = biocollect.utils.nodeScriptReplace(parentNode);

            // Expect that the script node is replaced by its clone
            expect(result.childNodes.length).toBe(1);
            expect(result.childNodes[0].tagName).toBe('SCRIPT');
            expect(result.childNodes[0]).not.toBe(scriptNode);
        });

        it('should recursively replace script nodes within a nested structure', () => {
            // Create a nested DOM structure with script nodes
            const root = document.createElement('div');
            const div1 = document.createElement('div');
            const scriptNode1 = document.createElement('script');
            div1.appendChild(scriptNode1);

            const div2 = document.createElement('div');
            const scriptNode2 = document.createElement('script');
            div2.appendChild(scriptNode2);

            root.appendChild(div1);
            root.appendChild(div2);

            // Call the function
            const result = biocollect.utils.nodeScriptReplace(root);

            // Expect that all script nodes are replaced by their clones
            expect(result.childNodes.length).toBe(2);

            const replacedDiv1 = result.childNodes[0];
            expect(replacedDiv1.childNodes.length).toBe(1);
            expect(replacedDiv1.childNodes[0].tagName).toBe('SCRIPT');
            expect(replacedDiv1.childNodes[0]).not.toBe(scriptNode1);

            const replacedDiv2 = result.childNodes[1];
            expect(replacedDiv2.childNodes.length).toBe(1);
            expect(replacedDiv2.childNodes[0].tagName).toBe('SCRIPT');
            expect(replacedDiv2.childNodes[0]).not.toBe(scriptNode2);
        });
    });

    describe('nodeScriptClone', () => {
        it('should clone a script node with its attributes and text', () => {
            // Create a sample script node with attributes and text
            const scriptNode = document.createElement('script');
            scriptNode.setAttribute('src', 'sample.js');
            scriptNode.innerHTML = 'console.log("Hello, World!");';

            // Call the function
            const clonedNode = biocollect.utils.nodeScriptClone(scriptNode);

            // Expect that the cloned node has the same attributes and text
            expect(clonedNode.tagName).toBe('SCRIPT');
            expect(clonedNode.getAttribute('src')).toBe('sample.js');
            expect(clonedNode.innerHTML).toBe('console.log("Hello, World!");');
        });
    });

    describe('nodeScriptIs', () => {
        it('should return true if the node is a script node', () => {
            // Create a sample script node
            const scriptNode = document.createElement('script');

            // Call the function
            const isScript = biocollect.utils.nodeScriptIs(scriptNode);

            // Expect that it returns true
            expect(isScript).toBe(true);
        });

        it('should return false if the node is not a script node', () => {
            // Create a sample div node
            const divNode = document.createElement('div');

            // Call the function
            const isScript = biocollect.utils.nodeScriptIs(divNode);

            // Expect that it returns false
            expect(isScript).toBe(false);
        });
    });


    describe("readDocument", function() {
        it("should resolve the deferred with blob and file data when reading succeeds", function(done) {
            // Create a mock file
            const mockFile = new Blob(['Test content'], { type: 'text/plain' });

            // Create a mock FileReader
            const mockFileReader = {
                onload: null,
                onerror: null,
                readAsArrayBuffer: function(file) {
                    // Simulate successful reading
                    this.onload({ target: { result: 'Mock ArrayBuffer Data' } });
                }
            };

            // Spy on the FileReader constructor to return the mock FileReader
            spyOn(window, 'FileReader').and.returnValue(mockFileReader);

            // Call the readDocument function with the mock file
            biocollect.utils.readDocument(mockFile)
                .then(function(result) {
                    // Expect the promise to be resolved with the expected data
                    expect(result).toEqual({ data: { blob: 'Mock ArrayBuffer Data', file: mockFile } });
                    done(); // Call done to signal the test is complete
                })
                .catch(function(error) {
                    // Fail the test if there's an error
                    fail('Promise was rejected: ' + error);
                    done();
                });
        });
    });

});

