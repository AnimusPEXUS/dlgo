module main;

import std.stdio;
import std.socket;

import dlgo;

void main()
{
    auto c = new Chan_exp02!int();

    writeln("capacity: ", c.capacity);

    {
        auto res = c.put(123);
        writeln("put res: ", *res);
    }

    {
        ChanPullCBValue!int* cb_res;

        auto res = c.pull(
            delegate bool(ChanPullCBValue!int* cb_res2) {
            cb_res = cb_res2;
            writeln("cb_res2: ", *cb_res2);
            return false;
        }
        );

        writeln("pull res: ", res);
    }

    {
        ChanPullCBValue!int* cb_res;

        auto res = c.pull(
            delegate bool(ChanPullCBValue!int* cb_res2) {
            cb_res = cb_res2;
            writeln("cb_res2: ", *cb_res2);
            return true;
        }
        );

        writeln("pull res: ", res);
    }

    {
        ChanPullCBValue!int* cb_res;

        auto res = c.pull(
            delegate bool(ChanPullCBValue!int* cb_res2) {
            cb_res = cb_res2;
            writeln("cb_res2: ", *cb_res2);
            return true;
        }
        );

        writeln("pull res: ", res);
    }
}
