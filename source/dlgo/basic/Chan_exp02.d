module dlgo.basic.Chan_exp02;

import dlgo;

import observable.signal;

import std.stdio;
import std.format;
import std.datetime;

import core.atomic;
import core.sync.mutex;
import core.sync.condition;
import core.sync.semaphore;

struct ChanPutResult
{
    gbool success;
    gbool full;
    gerror error;

    string toString()
    {
        return "success: %s, full: %s, error: %s".format(
            success,
            full,
            error
        );
    }
}

struct ChanPullCBValue(T)
{
    gbool success;
    gbool empty;
    T value;
    // gerror error;

    string toString()
    {
        return "success: %s, empty: %s, value: %s".format(
            success,
            empty,
            value
        );
    }
}

class Chan_exp02(T)
{
    // this is signalled if some space to put values appeared
    Signal!() signal_not_empty;

    // this is signalled if some some items to get appeared
    Signal!() signal_not_full;

    T[] pool;

    // default capacity is endless
    uint capacity;

    Mutex pool_mut;

    this()
    {
        pool_mut = new Mutex;
    }

    this(uint capacity)
    {
        this.capacity = capacity;
    }

    bool isFull()
    {
        pool_mut.lock();
        scope (exit)
        {
            pool_mut.unlock();
        }
        if (capacity == 0)
            return false;
        return pool.length >= capacity;
    }

    bool isEmpty()
    {
        pool_mut.lock();
        scope (exit)
        {
            pool_mut.unlock();
        }
        return pool.length == capacity;
    }

    ChanPutResult* put(T value)
    {
        auto ret = new ChanPutResult();
        pool_mut.lock();
        scope (exit)
        {
            pool_mut.unlock();
        }

        try
        {
            bool emit_signal_not_empty = isEmpty();

            if (isFull())
            {
                ret.full = true;
                return ret;
            }
            else
            {
                pool ~= value;
                ret.success = true;
                if (emit_signal_not_empty)
                    signal_not_empty.emit();
                return ret;
            }
        }
        catch (gerror e)
        {
            ret.success = false;
            ret.error = e;
            return ret;
        }
    }

    gerror pull(
        bool delegate(ChanPullCBValue!T* cb_value) cb
    )
    {
        pool_mut.lock();
        scope (exit)
        {
            pool_mut.unlock();
        }

        try
        {
            auto cb_value = new ChanPullCBValue!T;
            bool emit_signal_not_full = isFull();

            if (isEmpty())
            {
                // cb_value.success=false;
                cb_value.empty = true;
                cb(cb_value);
                return null;
            }
            else
            {
                cb_value.success = true;
                cb_value.value = pool[0];
                auto cb_res = cb(cb_value);
                if (cb_res)
                {
                    pool = pool[1 .. $];
                    if (emit_signal_not_full)
                    {
                        signal_not_full.emit();
                    }
                }
                return null;
            }
        }
        catch (gerror e)
        {
            return e;
        }
    }
}
