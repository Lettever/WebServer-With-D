import std;

struct Header {
    string method;
    string url;
    string _version;
    string[string] fields;
    string body;
}

int counter = 0;

void main() {
    immutable server_host = "0.0.0.0";
    immutable server_port = 8080;
    auto server_socket = new Socket(AddressFamily.INET, SocketType.STREAM);
    scope(exit) server_socket.close();
    server_socket.setOption(SocketOptionLevel.SOCKET, SocketOption.REUSEADDR, 1);
    Address addr = getAddress(server_host, server_port)[0];
    server_socket.bind(addr);
    server_socket.listen(4);
    writefln("Listening on - http://localhost:%s/", server_port);
    
    while(true) {
        Socket client = server_socket.accept();
        scope(exit) client.close();
        try {
            auto request = readHttpRequest(client);
            if (!request.empty) {
                auto response = handleRequest(request);
                client.send(response);
            }
        } catch(Exception e) {
            stderr.writeln("Error handling request: ", e.msg);
        }
    }
}

string readHttpRequest(Socket client) {
    ubyte[65536] buffer;
    string request;
    
    auto received = client.receive(buffer);
    if (received <= 0) return "";
    
    request = cast(string)buffer[0..received];
    
    auto headerEnd = request.indexOf("\r\n\r\n");
    if (headerEnd == -1) {
        // Malformed request - no header terminator
        return request;
    }
    
    headerEnd += 4;
    
    if (request.startsWith("POST")) {
        int contentLength = 0;
        auto contentLengthPos = request.indexOf("Content-Length:");
        if (contentLengthPos != -1) {
            auto lineEnd = request.indexOf("\r\n", contentLengthPos);
            if (lineEnd != -1) {
                auto clHeader = request[contentLengthPos..lineEnd];
                auto parts = clHeader.split(":");
                if (parts.length >= 2) {
                    contentLength = parts[1].strip().to!int;
                }
            }
        }
        
        auto bodyReadSoFar = cast(int)(request.length - headerEnd);
        
        if (bodyReadSoFar < contentLength) {
            int remaining = contentLength - bodyReadSoFar;
            
            while (remaining > 0) {
                auto bytesRead = client.receive(buffer);
                if (bytesRead <= 0) break;
                
                auto take = min(bytesRead, remaining);
                request ~= cast(string)buffer[0..take];
                remaining -= take;
            }
        }
    }
    
    return request;
}

Header parseHeader(string request) {
    Header header;
    
    string[] parts = request.split("\r\n\r\n");
    if (parts.length < 1) return header;
    
    string[] headerLines = parts[0].split("\r\n");
    if (headerLines.length < 1) return header;
    
    parseRequestLine(header, headerLines[0]);    
    parseHeaders(header, headerLines);
    
    if (parts.length >= 2) {
        header.body = parts[1];
    }
    
    return header;
}

void parseRequestLine(ref Header header, string line) {
    string[] requestLineParts = line.split();
    if (requestLineParts.length >= 3) {
        header.method = requestLineParts[0];
        header.url = requestLineParts[1];
        header._version = requestLineParts[2];
    } else {
        stderr.writeln("Malformed request line: ", line);
    }
}

void parseHeaders(ref Header header, string[] headerLines) {
    foreach (line; headerLines[1..$]) {
        auto colonPos = line.indexOf(':');
        if (colonPos != -1) {
            string key = line[0..colonPos].strip();
            string value = line[colonPos + 1..$].strip();
            header.fields[key] = value;
        } else if (!line.strip.empty) {
            stderr.writeln("Malformed header line ", i + 2, ": ", line);
        }
    }
}

string handleRequest(string request) {
    auto header = parseHeader(request);
    
    if (header.method == "GET") return handleGetRequest(header);
    if (header.method == "POST") return handlePostRequest(header);
    return "HTTP/1.1 405 Method Not Allowed\r\n\r\n";
}

string handleGetRequest(Header header) {
    writeln("GET received: ", header.url);
    if (header.url == "/counter") {
        string text = readText("./counter.html");
        return "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n" ~ text.format(counter);
    }
    
    string html = `
        <!DOCTYPE html>
        <html>
        <head>
            <title>Hello</title>
        </head>
        <body>
            <h1>Hello /<span style="text-decoration: underline">%s</span></h1>
        </body>
        </html>
    `;
    
    string url = header.url.length > 1 ? header.url[1..$] : "";
    return "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n" ~ html.format(url);
}

string handlePostRequest(Header header) {
    writeln("POST received: ", header.url);
    writeln("POST body: ", header.body);
    return "";
}