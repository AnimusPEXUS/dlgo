module dlgo.net.interfaces;

import std.typecons;

import dlgo.time;
import dlgo.builtin;
import dlgo.io;

interface Conn : ReadWriteCloser
{
    //     Tuple!(gint, gerror) read(gbyte[] b);
    //     Tuple!(gint, gerror) write(gbyte[] b);

    //     gerror close();

    Addr localAddr();
    Addr remoteAddr();

    gerror setDeadline(Time t);
    gerror setReadDeadline(Time t);
    gerror setWriteDeadline(Time t);
}

interface Addr {
    gstring network();
    gstring toString();
}

