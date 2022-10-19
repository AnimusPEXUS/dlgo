module dlgo.net.Resolver;

import std.typecons;

import dlgo;
import dlgo.context;
import dlgo.net;

interface ResolverI
{
    Tuple!(gstring[], gerror) LookupAddr(Context ctx, gstring addr);
    Tuple!(gstring, gerror) LookupCNAME(Context ctx, gstring host);
    Tuple!(gstring[], gerror) LookupHost(Context ctx, gstring host);
    Tuple!(IP[], gerror) LookupIP(Context ctx, gstring network, gstring host);
    Tuple!(IPAddr[], gerror) LookupIPAddr(Context ctx, gstring host);
    Tuple!(MX*[], gerror) LookupMX(Context ctx, gstring name);
    Tuple!(NS*[], gerror) LookupNS(Context ctx, gstring name);
    // Tuple!(netip.Addr[], gerror) LookupNetIP(Context ctx, gstring network, gstring host);
    Tuple!(gint, gerror) LookupPort(Context ctx, gstring network, gstring service);
    Tuple!(gstring, SRV*[], gerror) LookupSRV(Context ctx, gstring service, gstring proto, gstring name);
    Tuple!(gstring[], gerror) LookupTXT(Context ctx, string name);
}

// class Resolver : ResolverI
// {
//     Tuple!(gstring[], gerror) LookupAddr(Context ctx, gstring addr);
//     Tuple!(gstring, gerror) LookupCNAME(Context ctx, gstring host);
//     Tuple!(gstring[], gerror) LookupHost(Context ctx, gstring host);
//     Tuple!(IP[], gerror) LookupIP(Context ctx, gstring network, gstring host);
//     Tuple!(IPAddr[], gerror) LookupIPAddr(Context ctx, gstring host);
//     Tuple!(MX*[], gerror) LookupMX(Context ctx, gstring name);
//     Tuple!(NS*[], gerror) LookupNS(Context ctx, gstring name);
//     // Tuple!(netip.Addr[], gerror) LookupNetIP(Context ctx, gstring network, gstring host);
//     Tuple!(gint, gerror) LookupPort(Context ctx, gstring network, gstring service);
//     Tuple!(gstring, SRV*[], gerror) LookupSRV(Context ctx, gstring service, gstring proto, gstring name);
//     Tuple!(gstring[], gerror) LookupTXT(Context ctx, string name);
// }

struct MX
{
    gstring host;
    guint16 pref;
}

struct NS
{
    gstring host;
}

struct SRV
{
    gstring target;
    guint16 port;
    guint16 priority;
    guint16 weight;
}
