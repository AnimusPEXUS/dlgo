module dlgo.net.conv;

import std.typecons;
import std.socket;

import dlgo;
import dlgo.net;

Tuple!(Addr, gerror) convertAddressToAddr(Address a)
{
    switch (a.addressFamily())
    {
    default:
        return tuple(
            cast(Addr) null,
            new Exception("conversion not supported")
        );
    case AddressFamily.UNIX:
        auto t = cast(UnixAddress) a;
        if (t is null)
        {
            return tuple(
                cast(Addr) null,
                new Exception(
                    "couldn't cast AddressFamily.UNIX Address to UnixAddress"
            )
            );
        }
        return tuple(convertAddressToAddr(t), cast(Exception) null);
    case AddressFamily.INET:
        auto t = cast(InternetAddress) a;
        if (t is null)
        {
            return tuple(
                cast(Addr) null,
                new Exception(
                    "couldn't cast AddressFamily.INET Address to InternetAddress"
            )
            );
        }
        return tuple(convertAddressToAddr(t), cast(Exception) null);
    case AddressFamily.INET6:
        auto t = cast(Internet6Address) a;
        if (t is null)
        {
            return tuple(
                cast(Addr) null,
                new Exception(
                    "couldn't cast AddressFamily.INET6 Address to Internet6Address"
            )
            );
        }
        return tuple(convertAddressToAddr(t), cast(Exception) null);
    }

}

Addr convertAddressToAddr(InternetAddress a)
{
    return new TCPAddr(a.addr, a.port);
}

Addr convertAddressToAddr(Internet6Address a)
{
    return new TCPAddr(a.addr, a.port);
}

Addr convertAddressToAddr(UnixAddress a)
{
    return new UNIXAddr(a.path, "unix");
}
