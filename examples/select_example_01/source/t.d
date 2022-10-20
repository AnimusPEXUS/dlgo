module main;

import core.thread;
import std.parallelism;
import std.stdio;
// import std.socket;
import std.datetime;

import dlgo;

void _timer(
    Duration d,
    Chan!bool c
)
{
    assert(c !is null);
    while (true)
    {
        Thread.sleep(d);
        c.put(false);
    }
}

Chan!bool timer(Duration d)
{
    Chan!bool c;
    c = new Chan!bool();
    auto t = task!_timer(d, c);
    t.executeInNewThread();
    assert(c !is null);
    return c;
}

void main()
{
    auto t1 = timer(dur!"seconds"(1));
    auto t5 = timer(dur!"seconds"(5));
    auto t10 = timer(dur!"seconds"(10));

    bool sel_ret;

    while (true)
    {
        gselect(
            gcase!bool(&sel_ret, "<-", t1, { writeln("gcase 1"); }),
            gcase!bool(&sel_ret, "<-", t5, { writeln("gcase 5"); }),
            gcase!bool(&sel_ret, "<-", t10, { writeln("gcase 10"); })
        );
    }

}
