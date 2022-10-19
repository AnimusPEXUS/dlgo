module dlgo.net.Listener;

import std.typecons;

import dlgo;
import dlgo.net;

interface Listener
{
    // Accept waits for and returns the next connection to the listener.
    Tuple!(Conn, gerror) accept();

    // Close closes the listener.
    // Any blocked Accept operations will be unblocked and return errors.
    gerror close();

    // AddrI returns the listener's network address.
    AddrI addr();
}
