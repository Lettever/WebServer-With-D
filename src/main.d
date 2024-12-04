import std;
import utils;

alias Req = char[65536];
struct Header {
    string[] first_line;
    string[string] values;
    string body;
    string HTTP_type() => first_line[0];
    string url() => first_line[1];
}

string a() {
    return q{<h1>Hello</h1>};
}

void main() {
    writeln(formatString("Hello $(name)", ["name": "Joe"]));
    writeln(formatString("Hello $$(name)", ["name": "Joe"]));
    writeln(formatString("Hello $$$(name)", ["name": "Joe"]));
    writeln(formatString("$(name) $$$(age)", ["name":"a", "age": "20"]));
    return;
    int cnt = 0;
    const server_host = "0.0.0.0";
    const server_port = 8080;
    auto server_socket = new Socket(AddressFamily.INET, SocketType.STREAM);
    scope(exit) { server_socket.close(); }
    server_socket.setOption(SocketOptionLevel.SOCKET, SocketOption.REUSEADDR, 1);
    Address addr = getAddress(server_host, server_port)[0];
    server_socket.bind(addr);
    server_socket.listen(1);
    writefln("Listening on - http://localhost:%s/", server_port);
    
    while(true) {
        Req req;
        Socket client = server_socket.accept();
        cnt += 1;
        client.receive(req);
        try {
            client.send(handle_request2(req));
        } catch (Exception e) {
            writeln("> " ~ e.msg ~ " <");
        }
        writeln(cnt);
        client.close();
    }
}

string handle_request(Req req) {
    string res = "HTTP/1.1 200 OK\r\n";
    string json = q{"{name: 'foo', age: 10, cool: false}"};
    res ~= "Content-Length: %s\r\n\r\n".format(json.length);
    res ~= json;
    return res;
}

string handle_request2(Req req) {
    Header header = parse_header(req);
    writeln("header: ", header.first_line);
    string foo = "function foo() {
        fetch('/clicked', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            key0: 'value0',key1: 'value1',key2: 'value2',key3: 'value3',key4: 'value4',key5: 'value5',key6: 'value6',key7: 'value7',key8: 'value8',key9: 'value9',key10: 'value10',key11: 'value11',key12: 'value12',key13: 'value13',key14: 'value14',key15: 'value15',key16: 'value16',key17: 'value17',key18: 'value18',key19: 'value19',key20: 'value20',key21: 'value21',key22: 'value22',key23: 'value23',key24: 'value24',key25: 'value25',key26: 'value26',key27: 'value27',key28: 'value28',key29: 'value29',key30: 'value30',key31: 'value31',key32: 'value32',key33: 'value33',key34: 'value34',key35: 'value35',key36: 'value36',key37: 'value37',key38: 'value38',key39: 'value39',key40: 'value40',key41: 'value41',key42: 'value42',key43: 'value43',key44: 'value44',key45: 'value45',key46: 'value46',key47: 'value47',key48: 'value48',key49: 'value49',key50: 'value50',key51: 'value51',key52: 'value52',key53: 'value53',key54: 'value54',key55: 'value55',key56: 'value56',key57: 'value57',key58: 'value58',key59: 'value59',key60: 'value60',key61: 'value61',key62: 'value62',key63: 'value63',key64: 'value64',key65: 'value65',key66: 'value66',key67: 'value67',key68: 'value68',key69: 'value69',key70: 'value70',key71: 'value71',key72: 'value72',key73: 'value73',key74: 'value74',key75: 'value75',key76: 'value76',key77: 'value77',key78: 'value78',key79: 'value79',key80: 'value80',key81: 'value81',key82: 'value82',key83: 'value83',key84: 'value84',key85: 'value85',key86: 'value86',key87: 'value87',key88: 'value88',key89: 'value89',key90: 'value90',key91: 'value91',key92: 'value92',key93: 'value93',key94: 'value94',key95: 'value95',key96: 'value96',key97: 'value97',key98: 'value98',key99: 'value99'
        })
        })
        .then(response => response.json())
        .then(data => console.log(data))
        .catch(error => console.error('Error:', error));
    }";
    if(header.HTTP_type() == "GET") {
        string url = header.url();
        string html = q{
            <!DOCTYPE html>
            <html>
            <head>
                <title>Hello</title>
            </head>
            <body>
                <button onclick="foo()">Click me</button>
                <h1>Hello /<span style="text-decoration: underline">%s</h1>
                <script>
                    %s
                </script>
            </body>
            </html>
        };
        return ("HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n" ~ html.format(url[1 .. $], foo));
    }
    return handle_request(req);
}

Header parse_header(Req req) {
    auto a = req.to!string.split("\r\n\r\n");
    string[] header = a[0].split("\r\n");
    string[] first_line = header[0].split();
    string body = a[1];
    string[string] values;
    foreach(line; header[1 .. $]) {
        auto w = line.findSplit(":");
        w[2] = w[2].chompPrefix(" ");
        values[w[0]] = w[2];
    }
    return Header(first_line, values, body);
}
