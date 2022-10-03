module main;

import std.stdio;
import std.socket;

import dlgo;
import dlgo.net;

void main()
{

    // testing addr parsing and endianness
    const string test_addr_str = "2001:0db8:0c10:fe01::";
    const auto test_addr_int =
        cast(guint16[8])[
            0x2001, 0x0db8, 0x0c10, 0xfe01, 0, 0, 0, 0
        ];
    const auto test_addr_bytes = new IP(test_addr_int).value;

    {
        foreach (
            v; [
                cast(gbyte[])[192, 168, 0, 1],
                cast(gbyte[])[
                    1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16
                ],
                cast(gbyte[])[1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16],
                cast(gbyte[])[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 16],
                cast(gbyte[])[1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                cast(gbyte[])[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                cast(gbyte[])[
                    1, 2, 0, 0, 5, 6, 0, 0, 0, 0, 0, 0, 13, 14, 15, 16
                ],
            ]
            )
        {
            auto ip = new IP(v);
            writefln("%s: %s", v, ip.toString());
        }

        foreach (
            v; [
                cast(guint16[8])[1, 2, 3, 4, 5, 6, 7, 8],
                cast(guint16[8])[1, 0x1234, 3, 4, 5, 6, 7, 8],
                test_addr_int,
            ]
            )
        {
            auto ip = new IP(v);
            writefln("%s: %s %s", v, ip.toString(), ip.toStringBin());
        }
    }

    {
        writeln("ipv6 text string parse test:", test_addr_str);
        auto parsed = Internet6Address.parse(test_addr_str);
        // foreach (index, key; parsed)
        // {
        //     writefln("%d: hex: %2$x dec: %2$d", index, key);
        // }

        auto addr = new IP(parsed);
        // writeln("before toString");
        // foreach (index, key; ip.value)
        // {
        //     writefln("%d: hex: %2$x dec: %2$d", index, key);
        // }
        writeln(addr.toString());
        // writeln("after toString");
        // foreach (index, key; ip.value)
        // {
        //     writefln("%d: hex: %2$x dec: %2$d", index, key);
        // }
    }

    {
        writeln("ipv6 with zone");
        auto addr = new IPAddr(test_addr_int, "zone");
        writeln(addr.toString(), " ", addr.network());
    }

    {
        writeln("ipv6 with zone and port");
        auto addr = new TCPAddr(test_addr_int, 80, "zone");
        writeln(addr.toString(), " ", addr.network());
    }

    {
        writeln("ipv6 with zone and port (udp)");
        auto addr = new UDPAddr(test_addr_int, 80, "zone");
        writeln(addr.toString(), " ", addr.network());
    }

    {
        writeln("parseIP");
        foreach (
            v; [
                "1.2.3.4",
                test_addr_str,
                "::",
                "::8",
                ":8:",
                "8::",
                "8::8",
                ":8:8",
            ]
            )
        {
            auto ip = parseIP(v);
            if (ip)
                writefln(
                    "%s => %s (value: %s) (ints: %s)",
                    v,
                    ip.toString(),
                    ip.value,
                    ip.getValueAsInts()
                );
            else
                writefln(
                    "%s => parse failed",
                    v,
                );
        }
    }

    /*
    string host = "localhost";
    ushort port = 6060;

    writefln("resolving %s %s", host, port);

    auto addrs = getAddress(host, port);
    foreach (n, a; addrs)
    {
        writefln("%d: %s", n, a);
    }

    if (addrs.length == 0)
    {
        writeln("0 results. exiting");
        return;
    }

    auto addr = addrs[0];

    writefln("connecting to %s..", addr);

    auto s = new Socket(
        addr.addressFamily,
        SocketType.STREAM,
        ProtocolType.TCP
    );

    s.connect(addr);

    auto sconn = new SocketConn(s);

    sconn.write(cast(gbyte[])("GET / HTTP/1.0\r\n\r\n"));

    ubyte[] buff = new ubyte[](1000);
    auto res = sconn.read(buff);
    if (res[1] !is null)
    {
        writeln("error: ", res[1]);
        return;
    }
    auto count = res[0];

    writeln(cast(string)(buff[0 .. count]));
    */
}
