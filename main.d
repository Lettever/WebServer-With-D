import std;

alias Req = char[1024];
struct Header {
    string[] firstLine;
    string[string] values;
    string body;
}

void main() {
    const serverHost = "0.0.0.0";
    const serverPort = 8080;
    auto serverSocket = new Socket(AddressFamily.INET, SocketType.STREAM);
    scope(exit) { serverSocket.close(); }
    serverSocket.setOption(SocketOptionLevel.SOCKET, SocketOption.REUSEADDR, 1);
    auto addr = getAddress(serverHost, serverPort)[0];
    serverSocket.bind(addr);
    serverSocket.listen(1);
    writefln("Listening on - http://localhost:%s/", serverPort);
    
    while(true) {
        Req req;
        auto client = serverSocket.accept();
        try {
        client.receive(req);
        encode(req);
        auto header = parseHeaders(req);
        client.send("HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n" ~ handleRequest(req));
        } catch(Exception e) {
            writeln("> " ~ e.msg ~ " <");
        }
        client.close();
    }
}


string handleRequest(Req req) {
    string url = req.to!string.split('\n')[0].split()[1];
    string html = q{
        <!DOCTYPE html>
        <html>
        <head>
            <title>Hello</title>
        </head>
        <body>
            <h1>Hello /<span style="text-decoration: underline">%s</h1>
        </body>
        </html>
    };
    return html.format(url[1 .. $]);
}

Header parseHeaders(Req req) {
    auto a = req.to!string.split("\r\n\r\n");
    string[] header = a[0].split("\r\n");
    string[] firstLine = header[0].split();
    char a1 = 0xFF;
    char a2 = 0x00;
    string body = a[1];//.to!(char[]).replace(a1, '-').to!(string);
    string[string] values;
    foreach(line; header[1 .. $]) {
        auto w = line.findSplit(":");
        w[2] = w[2].chompPrefix(" ");
        values[w[0]] = w[2];
    }
    return Header(firstLine, values, body);
}
string a = "
GET /adasd HTTP/1.1
Host: localhost:8000
User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:132.0) Gecko/20100101 Firefox/132.0
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
Accept-Language: en-US,en;q=0.5
Accept-Encoding: gzip, deflate, br, zstd
Connection: keep-alive
Upgrade-Insecure-Requests: 1
Sec-Fetch-Dest: document
Sec-Fetch-Mode: navigate
Sec-Fetch-Site: cross-site
DNT: 1
Sec-GPC: 1
Priority: u=0, i
";