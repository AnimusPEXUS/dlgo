module dlgo.basic.gselect;

import core.sync.mutex;
import core.sync.condition;

import std.exception;
import std.parallelism;
import std.traits;
import std.format;
import std.stdio;

import observable.signal;

import dlgo;

struct gcase(T)
{
    T* var;
    string mode;
    Chan_exp02!T chan;
    void function() code;

    invariant
    {
        assert(mode == "<-" || mode == "->");
    }

    this(T* var, string mode, Chan_exp02!T chan, void function() code)
    {
        this.var = var;
        this.mode = mode;
        this.chan = chan;
        this.code = code;
    }
}

void gselect(Args...)(Args args)
        if (
            () {
                foreach (i, v; Args)
                {
                    if (!__traits(isSame, TemplateOf!(v), gcase))
                        return false;
                }
                return true;
            }()
)
in
{
    foreach (v; args)
    {
        assert(v.mode == "<-" || v.mode == "->");
    }
}
do
{
    Condition signal_waiting_cond;
    bool signal_waiting_mode;
    Mutex signal_waiting_synchronization_lock;

    signal_waiting_synchronization_lock = new Mutex();
    signal_waiting_cond = new Condition(signal_waiting_synchronization_lock);

    bool signal_recvd;
    uint signalled_case;

    Exception signalException;

    static foreach (i, v; args)
    {
        mixin(
            q{
                SignalConnection sc%1$d;         

                v.chan.signal_not_empty.socket.connect(
                    sc%1$d,
                    delegate void() nothrow
                    {
                        try {
                        synchronized(signal_waiting_synchronization_lock)
                        {
                            if (signal_recvd)
                                return;
                            signal_recvd = true;
                            signalled_case = %1$d;
                            signal_waiting_cond.notify();
                        }
                        } catch (Exception e)
                        {
                            collectException(writeln("exception: ", e));
                            signalException = e;
                        }
                    }
                );          
            }.format(i)
        );
    }

    scope (exit)
    {
        static foreach (i, v; args)
        {
            mixin(
                q{
                sc%1$d.disconnect();         
            }.format(i)
            );

        }
    }

    static foreach (i, v; args)
    {
        mixin("try_work_on_case_%d:;".format(i));

        if (v.mode == "<-")
        {
            {
                bool pull_cb_delegate_success;
                typeof(v.chan.pool[0]) pull_cb_delegate_result;
                auto signal_cb_delegate = delegate bool(
                    ChanPullCBValue!(typeof(v.chan.pool[0]))* cb_value
                ) {
                    if (cb_value.success)
                    {
                        pull_cb_delegate_success = true;
                        pull_cb_delegate_result = cb_value.value;
                    }
                    return true;
                };
                v.chan.pull(signal_cb_delegate);
                if (pull_cb_delegate_success)
                {
                    *(v.var) = pull_cb_delegate_result;
                    v.code();
                    return;
                }
                if (signal_waiting_mode)
                    goto signal_waiting_mode_label;
            }
        }
        else if (v.mode == "->")
        {
            writeln("todo: push behavior");
        }
        else
        {
            assert(false, "invalid mode");
        }
    }

    signal_waiting_mode = true;

    signal_waiting_mode_label: synchronized (
        signal_waiting_synchronization_lock
        )
    {
        signal_waiting_cond.wait();
        mixin(
            () {
            auto ret = "";
            ret ~= "switch (signalled_case) {";
            for (int i = 0; i != args.length; i++)
            {
                ret ~= "case %1$d: goto try_work_on_case_%1$d;".format(i);
            }
            ret ~= `default: throw new Exception("programming error");`;
            ret ~= "}";
            return ret;
        }()
        );
    }
}
