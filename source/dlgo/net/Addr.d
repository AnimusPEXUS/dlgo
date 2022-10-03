module dlgo.net.Addr;

import std.stdio;
import std.socket;
import std.format;
import std.system;

// import std.regex;
import std.algorithm;
import std.array;
import std.conv;
import std.typecons;

import dlgo;

interface Addr
{
    gstring network();
    gstring toString();
}

gint16 swapBytes(gint16 val)
{
    gint16 ret;
    (cast(ubyte*)&ret)[1] = (cast(ubyte*)&val)[0];
    (cast(ubyte*)&ret)[0] = (cast(ubyte*)&val)[1];
    return ret;
}

gbyte[2] swapBytes(gbyte[2] val)
{
    auto z = val[0];
    val[0] = val[1];
    val[1] = z;
    return val;
}

unittest
{
    writeln("unittest for IP");

    {
        auto t = cast(gbyte[])[192, 168, 0, 1];
        auto ip = new IP(t);
        assert(ip.toString() == "192.168.0.1");
    }

    {
        auto bts_init = cast(gbyte[])[
            1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16
        ];
        auto bts_init_guint16 = cast(guint16[])[
            0x0102, 0x0304, 0x0506, 0x0708, 0x090a, 0xb0c, 0xd0e, 0x0f10
        ];
        auto bts_str_init = "102:304:506:708:90a:b0c:d0e:f10";

        auto bts_init_ip = new IP(bts_init);
        auto bts_init_ip_str = bts_init_ip.toString();

        auto ip_addr = new Internet6Address(
            bts_init[0 .. 16],
            Internet6Address.PORT_ANY
        );
        auto ip_addr_control_result = "[%s]:0".format(bts_str_init);

        assert(bts_init == ip_addr.addr());

        assert(
            ip_addr.toString() == ip_addr_control_result,
            "%s != %s".format(ip_addr.toString(), ip_addr_control_result)
        );

        assert(bts_init_ip_str == bts_str_init);

        bts_init_ip = new IP(bts_init_guint16);
        bts_init_ip_str = bts_init_ip.toString();

        assert(bts_init == ip_addr.addr());
        assert(ip_addr.toString() == ip_addr_control_result);
        assert(bts_init_ip_str == bts_str_init);
    }
}

// auto ipv4_re = ctRegex!(`(\d+)\.(\d+)\.(\d+)\.(\d+)`);

class IP
{
    // IPv6 value is always in bigendian
    gbyte[] value;

    this(guint16[8] value)
    {
        this(cast(guint16[]) value);
    }

    // value is usual integer array in your system endianness. 
    // there must be exactly 8 integers.
    this(guint16[] value)
    {
        auto val_len = value.length;
        if (val_len == 8)
        {
            {
                gbyte[2] t;
                this.value.length = 0;

                for (int i = 0; i != 8; i++)
                {
                    t = *cast(gbyte[2]*)&(value[i]);
                    version (LittleEndian)
                    {
                        t = swapBytes(t);
                    }
                    this.value ~= t;
                }
            }

            // debug writeln("this(guint16[] value)", this.value);
            return;
        }

        throw new Exception("invalid guint16[] value length: must be 8");
    }

    // value must be 4 or 16 unsigned bytes. 
    // if value length 4 - value treaded as IPv4.
    // if value length 16 - value treaded as IPv6.
    // IPv6 input must be in bigendian - each 2 bytes is treated as word (2 byte integer).
    this(gbyte[] value)
    {
        auto val_len = value.length;
        if (val_len == 4 || val_len == 16)
        {
            this.value = value;
            return;
        }

        throw new Exception("invalid gbyte[] value length: must be 4 or 16");
    }

    // returns 2 integers for IPv4 or 8 integers for IPv6
    guint16[] getValueAsInts()
    {
        guint16[] ret;

        guint16 tt;
        auto loop_end_value = (length() == 16 ? 8 : 2);

        for (int i = 0; i != loop_end_value; i++)
        {
            tt = *cast(guint16*)&(value[i * 2]);
            version (LittleEndian)
            {
                tt = swapBytes(tt);
            }
            ret ~= tt;
        }

        return ret;
    }

    invariant
    {
        auto val_len = value.length;
        assert(val_len == 4 || val_len == 16);
    }

    typeof(value.length) length() const
    {
        return value.length;
    }

    override gstring toString()
    {
        final switch (length())
        {
        case 4:
            return toStringPriv(10);
        case 16:
            return toStringPriv(16);
        }
    }

    gstring toStringBin()
    {
        return toStringPriv(2);
    }

    private gstring toStringPriv(ubyte base = 16)
    {
        auto val_len = value.length;
        if (val_len == 4)
        {
            final switch (base)
            {
            case 2:
                return "%b.%b.%b.%b".format(
                    value[0],
                    value[1],
                    value[2],
                    value[3]
                );
            case 10:
                return "%d.%d.%d.%d".format(
                    value[0],
                    value[1],
                    value[2],
                    value[3]
                );
            case 16:
                return "%x.%x.%x.%x".format(
                    value[0],
                    value[1],
                    value[2],
                    value[3]
                );
            }
        }

        if (val_len == 16)
        {
            guint16[] val_guint16;

            val_guint16 = getValueAsInts();

            assert(
                val_guint16.length == 8,
                "val_guint16.length is %d. must be 8".format(val_guint16.length)
            );

            bool have_zeroes;

            foreach (v; val_guint16)
            {
                if (v == 0)
                {
                    have_zeroes = true;
                    break;
                }
            }

            struct zero_group
            {
                ubyte first;
                ubyte last;
            }

            zero_group longest_group;

            if (have_zeroes)
            {
                zero_group[] zero_groups;
                bool zero_group_started;

                foreach (i, v; val_guint16)
                {
                    if (v == 0)
                    {
                        if (!zero_group_started)
                        {
                            zero_group_started = true;
                            zero_groups ~= zero_group(cast(ubyte) i, 0);
                        }

                        if (zero_group_started)
                        {
                            zero_groups[$ - 1].last = cast(ubyte) i;
                        }
                    }
                    else
                    {
                        if (zero_group_started)
                        {
                            zero_group_started = false;
                        }
                    }
                }

                if (zero_group_started)
                {
                    zero_groups[$ - 1].last = 7;
                }

                longest_group = zero_groups[0];

                if (zero_groups.length > 1)
                {
                    foreach (v; zero_groups[1 .. $])
                    {
                        if ((v.last - v.first) >
                            (longest_group.last - longest_group.first))
                        {
                            longest_group = v;
                        }
                    }
                }
            }

            if (!have_zeroes)
            {
                return representIPv6guint16ArrayToString(
                    val_guint16,
                    base
                );
            }
            else
            {
                auto part_before_zeroes = val_guint16[0 .. longest_group.first];

                auto part_after_zeroes = val_guint16[
                    (longest_group.last == 7 ? 8 : longest_group.last + 1) .. $
                ];

                return representIPv6guint16ArrayToString(
                    part_before_zeroes,
                    base
                )
                    ~ "::" ~ representIPv6guint16ArrayToString(
                        part_after_zeroes,
                        base
                    );
            }
        }

        throw new Exception("invalid data in IP instance");
    }

    static IP parse(gstring s)
    {
        // TODO: add IPv4-mapped IPv6 support
        if (s.length == 0)
        {
            return null;
        }

        {
            auto ipv4_split_res = s.split('.');
            // writeln("ipv4_split_res ", ipv4_split_res);
            if (ipv4_split_res.length != 4)
            {
                goto try_ipv6_parse;
            }

            gbyte[] ret;
            auto spc = singleSpec("%d");
            foreach (v; ipv4_split_res)
            {
                gbyte t;
                try
                {
                    t = unformatValue!gbyte(v, spc);
                }
                catch (Exception e)
                {
                    goto try_ipv6_parse;
                }
                ret ~= t;
            }

            IP ret2;
            try
            {
                ret2 = new IP(ret);
            }
            catch (Exception e)
            {
                goto try_ipv6_parse;
            }
            return ret2;

        }

    try_ipv6_parse:
        {
            if (s[0] == ':')
            {
                s = "0" ~ s;
            }

            if (s[$ - 1] == ':')
            {
                s = s ~ "0";
            }

            auto ipv6_split_res = s.split(':');
            if (ipv6_split_res.length >= 3 && ipv6_split_res.length <= 8)
            {

                if (ipv6_split_res.canFind(""))
                {

                    auto empty_index = ipv6_split_res.length
                        - (ipv6_split_res.find("").length);

                    auto first_part = ipv6_split_res[0 .. empty_index];
                    auto last_part = ipv6_split_res[empty_index + 1 .. $];

                    byte missing_count =
                        cast(byte)(8 - (first_part.length + last_part.length));

                    if (missing_count < 0)
                        return null;

                    string[] ipv6_split_res_new;

                    ipv6_split_res_new ~= first_part;

                    for (auto i = 0; i != missing_count; i++)
                    {
                        ipv6_split_res_new ~= "0";
                    }

                    ipv6_split_res_new ~= last_part;

                    ipv6_split_res = ipv6_split_res_new;
                }

                guint16[] ret;
                auto spc = singleSpec("%x");
                foreach (v; ipv6_split_res)
                {
                    guint16 t;
                    try
                    {
                        t = unformatValue!guint16(v, spc);
                    }
                    catch (Exception e)
                    {
                        return null;
                    }
                    ret ~= t;
                }

                IP ret2;
                try
                {
                    ret2 = new IP(ret);
                }
                catch (Exception e)
                {
                    return null;
                }
                return ret2;
            }
        }

        return null;
    }

}

private string representIPv6guint16ArrayToString(
    guint16[] values,
    ubyte base
)
{
    string ret = "";
    auto values_length = values.length;
    foreach (i, b; values)
    {
        final switch (base)
        {
        case 2:
            ret ~= "%b".format(b);
            break;
        case 10:
            ret ~= "%d".format(b);
            break;
        case 16:
            ret ~= "%x".format(b);
            break;
        }
        if (i < values_length - 1)
        {
            ret ~= ":";
        }
    }
    return ret;
}

unittest
{
    writeln("unittest for IPAddr");

    {
        const auto test_addr_int =
            cast(guint16[8])[
                0x2001, 0x0db8, 0x0c10, 0xfe01, 0, 0, 0, 0
            ];

        auto addr = new IPAddr(test_addr_int, "zone");
        assert(addr.toString() == "[2001:db8:c10:fe01::%zone]");
    }
}

class IPAddr : Addr
{

    IP ip;
    gstring zone;

    this(IP ip, gstring zone = "")
    {
        this.ip = ip;
        this.zone = zone;
    }

    this(gbyte[] ip, gstring zone = "")
    {
        this.ip = new IP(ip);
        this.zone = zone;
    }

    this(gbyte[4] ip, gstring zone = "")
    {
        this.ip = new IP(ip);
        this.zone = zone;
    }

    this(gbyte[16] ip, gstring zone = "")
    {
        this.ip = new IP(ip);
        this.zone = zone;
    }

    this(guint16[] ip, gstring zone = "")
    {
        this.ip = new IP(ip);
        this.zone = zone;
    }

    this(guint16[8] ip, gstring zone = "")
    {
        this.ip = new IP(ip);
        this.zone = zone;
    }

    invariant
    {
        assert(zone != "" && ip.length() == 16);
    }

    gstring network()
    {
        final switch (ip.length)
        {
        case 4:
            return "ip4";
        case 16:
            return "ip6";
        }
    }

    override gstring toString()
    {
        string ret;

        switch (ip.length())
        {
        default:
            throw new Exception("IP is invalid");
        case 4:
            ret = ip.toString();
            break;
        case 16:
            ret = "[%s%s]".format(ip.toString(), (zone != "" ? "%%%s".format(zone) : ""));
            break;
        }

        return ret;
    }
}

unittest
{
    writeln("unittest for TCPAddr");

    {
        const auto test_addr_int =
            cast(guint16[8])[
                0x2001, 0x0db8, 0x0c10, 0xfe01, 0, 0, 0, 0
            ];

        auto addr = new TCPAddr(test_addr_int, 80, "zone");
        assert(addr.toString() == "[2001:db8:c10:fe01::%zone]:80");
    }

    writeln("unittest for UDPAddr");

    {
        const auto test_addr_int =
            cast(guint16[8])[
                0x2001, 0x0db8, 0x0c10, 0xfe01, 0, 0, 0, 0
            ];

        auto addr = new UDPAddr(test_addr_int, 80, "zone");
        assert(addr.toString() == "[2001:db8:c10:fe01::%zone]:80");
    }
}

class TCPAddr : Addr
{

    IPAddr ip_addr;
    ushort port; // TODO: fix type

    this(guint32 ip, ushort port = 0, string zone = "")
    {
        // TODO: bite order check required
        union ip4bytesunion
        {
            guint32 ip_int;
            gbyte[4] ip_bytes;
        }

        auto t = ip4bytesunion(ip);

        this.ip_addr = new IPAddr(t.ip_bytes, zone);
        this.port = port;
    }

    this(gbyte[16] ip, ushort port = 0, string zone = "")
    {
        this.ip_addr = new IPAddr(ip, zone);
        this.port = port;
    }

    this(gbyte[4] ip, ushort port = 0, string zone = "")
    {
        this.ip_addr = new IPAddr(ip, zone);
        this.port = port;
    }

    this(guint16[8] ip, ushort port = 0, string zone = "")
    {
        this.ip_addr = new IPAddr(ip, zone);
        this.port = port;
    }

    this(IP ip, ushort port = 0, string zone = "")
    {
        this.ip_addr = new IPAddr(ip, zone);
        this.port = port;
    }

    this(IPAddr ip_addr, ushort port = 0)
    {
        this.ip_addr = ip_addr;
        this.port = port;
    }

    override gstring network()
    {
        final switch (ip_addr.ip.length())
        {
        case 4:
            return "tcp4";
        case 16:
            return "tcp6";
        }
    }

    override gstring toString()
    {
        return ip_addr.toString() ~ ":%d".format(port);
    }
}

UDPAddr asUDPAddr(TCPAddr a)
{
    return cast(UDPAddr) a;
}

class UDPAddr : TCPAddr
{
    //alias TCPAddr this;

    this(guint32 ip, ushort port = 0, string zone = "")
    {
        super(ip, port, zone);
    }

    this(gbyte[16] ip, ushort port = 0, string zone = "")
    {
        super(ip, port, zone);
    }

    this(gbyte[4] ip, ushort port = 0, string zone = "")
    {
        super(ip, port, zone);
    }

    this(guint16[8] ip, ushort port = 0, string zone = "")
    {
        super(ip, port, zone);
    }

    this(IP ip, ushort port = 0, string zone = "")
    {
        super(ip, port, zone);
    }

    this(IPAddr ip_addr, ushort port = 0)
    {
        super(ip_addr, port);
    }

    override gstring network()
    {
        final switch (ip_addr.ip.length())
        {
        case 4:
            return "udp4";
        case 16:
            return "udp6";
        }
    }

    // alias toString = TCPAddr.toString;
}

class UNIXAddr : Addr
{

    string name;
    string net;

    this(string name, string net)
    {
        this.name = name;
        this.net = net;
    }

    invariant
    {
        import std.algorithm;

        assert(["unix", "unixgram", "unixpacket"].canFind(net));
    }

    gstring network()
    {
        return net;
    }

    override gstring toString()
    {
        return name;
    }
}
