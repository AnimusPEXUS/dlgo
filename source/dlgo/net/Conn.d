module dlgo.net.Conn;

import std.typecons;
import std.socket;
import std.datetime;
import std.socket;

import dlgo;
import dlgo.time;
import dlgo.io;
import dlgo.net;

interface Conn : ReadWriteCloser
{
    //     Tuple!(gint, gerror) read(gbyte[] b);
    //     Tuple!(gint, gerror) write(gbyte[] b);

    //     gerror close();

    Addr localAddr();
    Addr remoteAddr();

    gerror setDeadline(DateTime t);
    gerror setReadDeadline(DateTime t);
    gerror setWriteDeadline(DateTime t);
}

// bool isSocket(Conn conn)
// {
//     return getSocket(conn) !is null;
// }

// Socket getSocket(Conn conn)
// {
//     return (cast(Socket) conn);
// }

// alias IPAddr = 

// interface Addr {
//     gstring network();
//     gstring toString();
// }

class SocketConn : Conn
{
    Socket s;

    this(Socket s)
    {
        this.s = s;
    }

    gerror close()
    {
        try
        {
            s.close();
        }
        catch (Exception e)
        {
            return e;
        }

        return null;
    }

    Tuple!(gint, gerror) read(gbyte[] p)
    {
        gint count;
        try
        {
            count = s.receive(p);
        }
        catch (Exception e)
        {
            return tuple(0L, e);
        }

        return tuple(count, cast(gerror) null);
    }

    Tuple!(gint, gerror) write(gbyte[] p)
    {
        gint count;
        try
        {
            count = s.send(p);
        }
        catch (Exception e)
        {
            return tuple(0L, e);
        }

        return tuple(count, cast(gerror) null);
    }

    Addr localAddr()
    {
        auto gAddr = convertAddressToAddr(s.localAddress());
        if (gAddr[1]!is null)
        {
            throw gAddr[1];
        }
        return gAddr[0];
    }

    Addr remoteAddr()
    {
        auto gAddr = convertAddressToAddr(s.remoteAddress());
        if (gAddr[1]!is null)
        {
            throw gAddr[1];
        }
        return gAddr[0];
    }

    gerror setDeadline(DateTime t)
    {
        return null;
    }

    gerror setReadDeadline(DateTime t)
    {
        return null;
    }

    gerror setWriteDeadline(DateTime t)
    {
        return null;
    }

}

class IPConn
{

}

class TCPConn
{
    
}

class UDPConn
{
    
}
class UNIXConn
{
    
}