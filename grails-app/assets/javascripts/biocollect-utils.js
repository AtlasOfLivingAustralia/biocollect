var biocollect = {
    utils: {
        /**
         * https://stackoverflow.com/a/20584396
         * @param node
         * @returns {*}
         */
        nodeScriptReplace: function nodeScriptReplace(node) {
            if (biocollect.utils.nodeScriptIs(node) === true) {
                node.parentNode.replaceChild(biocollect.utils.nodeScriptClone(node), node);
            } else {
                var i = -1, children = node.childNodes;
                while (++i < children.length) {
                    biocollect.utils.nodeScriptReplace(children[i]);
                }
            }

            return node;
        },

        /**
         * https://stackoverflow.com/a/20584396
         * @param node
         * @returns {HTMLScriptElement}
         */
        nodeScriptClone: function nodeScriptClone(node) {
            var script = document.createElement("script");
            script.text = node.innerHTML;

            var i = -1, attrs = node.attributes, attr;
            while (++i < attrs.length) {
                script.setAttribute((attr = attrs[i]).name, attr.value);
            }
            return script;
        },

        /**
         * https://stackoverflow.com/a/20584396
         * @param node
         * @returns {boolean}
         */
        nodeScriptIs: function nodeScriptIs(node) {
            return node.tagName === 'SCRIPT';
        },
        readDocument: function readDocument(file) {
            var deferred = $.Deferred();
            if (file) {
                var reader = new FileReader();
                reader.onload = function (e) {
                    var contents = e.target.result;
                    deferred.resolve({data: {blob: contents, file: file}});
                };

                reader.onerror = function (e) {
                    deferred.reject({message: "Failed to read file" + file.name});
                };

                reader.readAsArrayBuffer(file);
            } else {
                deferred.reject();
            }

            return deferred.promise();
        },
        saveDocument: function saveDocument(result) {
            var deferred = $.Deferred(),
                file = result.data.file,
                blob = result.data.blob,
                document = biocollect.utils.createDocument(file, blob);

            if (window.entities)
                window.entities.saveDocument(document).then(deferred.resolve, function (error) {
                    deferred.reject({data: document, error: error});
                });
            else
                deferred.reject();

            return deferred.promise();
        },
        fetchDocument: function fetchDocument(result) {
            var documentId = result.data;
            return window.entities.offlineGetDocument(documentId);
        },
        addObjectURL: function addObjectURL(document) {
            var url = ImageViewModel.createObjectURL(document);
            if (url) {
                document.thumbnailUrl = document.url = url;
            }
        },
        createDocument: function createDocument(file, blob) {
            return {
                blob: blob,
                contentType: file.type,
                filename: file.name,
                name: file.name,
                filesize: file.size,
                dateTaken: new Date(file.lastModified).toISOStringNoMillis(),
                staged: false,
                attribution: "",
                licence: "",
                entityUpdated: true
            };
        }
    }
}