const http = require("http");
const path = require("path")
const fs = require("fs");

const mimeTypes = {
    ".html": "text/html",
    ".wasm": "application/wasm",
};

const getMimeType = (filePath) => {
    const extName = path.extname(filePath);
    const mimeType = mimeTypes[extName];
    if (mimeType) {
        return mimeType;
    }
    return "text/plain";
};

this._server = http.createServer();
this._server.on("request", (req, res) => {
    let filePath;
    if (req.url === "/") {
        filePath = "index.html"
    } else {
        const matchData = req.url.match(/^\/(.+)/);
        filePath = matchData[1];
    }
    if (fs.existsSync(filePath)) {
        res.writeHead(200, { "Content-Type": getMimeType(filePath) });
        const file = fs.readFileSync(filePath);
        res.write(file);
    } else {
        res.writeHead(404, {});
        res.write("");
    }
    res.end();
});
this._server.listen(8080);
