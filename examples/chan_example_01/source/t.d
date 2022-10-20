module main;

import std.stdio;
import std.socket;

import dlgo;

void main()
{
    auto c = new Chan!int();

    writeln("capacity: ", c.capacity);

    {
        auto res = c.put(123);
        writeln("put res: ", res);
    }

    {

        auto res = c.pull(
            delegate bool(ChanPullCBResult res, int value) {
            writeln("res: ", res, ", value: ", value);
            return false;
        }
        );

        writeln("pull res: ", res);
    }

    {

        auto res = c.pull(
            delegate bool(ChanPullCBResult res, int value) {
            writeln("res: ", res, ", value: ", value);
            return true;
        }
        );

        writeln("pull res: ", res);
    }

    {

        auto res = c.pull(
            delegate bool(ChanPullCBResult res, int value) {
            writeln("res: ", res, ", value: ", value);
            return true;
        }
        );

        writeln("pull res: ", res);
    }
}
