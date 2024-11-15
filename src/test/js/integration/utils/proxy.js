const http = require('http');
const httpProxy = require('http-proxy');
// Start an HTTP server to handle requests
let server
let block = ""
const target_address = "http://localhost:8087"
async function startServer(blockUrl="", port=8081) {
    const proxy = httpProxy.createProxyServer({});
    server = http.createServer((req, res) => {
        // Example blacklist: Block localhost:8080
        console.log(`block: ${block}`);
        if (block) {
            console.log(`Blocking request to ${req.url}`);
            res.writeHead(503, { 'Content-Type': 'text/plain' });
            res.end('Service Unavailable - Simulating Offline Mode');
        } else {
            console.log(`Received request for ${req.url}`);
            // Otherwise, forward the request to the target server
            proxy.web(req, res, { target: target_address });
        }
    });

    return new Promise(resolve => {
        server.listen(port, () => {
            console.log(`Proxy server listening on port ${port}`);
            resolve(server);
        });
    })
}

function stopServer() {
    if(server) {
        server.on('close', (err) => {
            console.log('shutting down server');
        });

        let promise = new Promise((resolve, reject) => {
            server.close((err) => {
                if (err) {
                    reject(err);
                } else {
                    resolve();
                    server = null;
                }
            });
        });

        return promise;
    }

    return Promise.resolve();
}



function blockSite(blockUrl) {
    block = blockUrl;
    console.log(`Blocking site: ${block}`);
}

function unblockSite() {
    block = "";
    console.log(`Unblocking site`);
}

module.exports = {startServer, stopServer, blockSite, unblockSite};