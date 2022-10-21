module dlgo.basic.Chan;

import dlgo;

import observable.signal;

import std.stdio;
import std.typecons;
import std.format;
import std.datetime;

import core.atomic;
import core.sync.mutex;
import core.sync.condition;
import core.sync.semaphore;

enum ChanPushResult : ubyte
{
    success,
    full,
    shuttingdown,
    closed,
    exception
}

enum ChanPullCBResult : ubyte
{
    success,
    empty,
    closed,
    exception
}

class Chan(T)
{
    // this is signalled if some space to put values appeared
    Signal!() signal_not_empty;

    // this is signalled if some some items to get appeared
    Signal!() signal_not_full;

    // this is called once Chan state is changed to closed
    Signal!() signal_closed;

    // this is called once Chan state is changed to closed
    Signal!() signal_shuttingdown;

    T[] pool;

    // default capacity is endless
    uint capacity;

    Mutex pool_mut;

    // true if Chan is closed
    private bool closed;

    // true if Chan should not longer accept pushes and will be closed
    // once pool is empty
    private bool shuttingdown;

    this()
    {
        pool_mut = new Mutex;
    }

    this(uint capacity)
    {
        this.capacity = capacity;
    }

    bool isShuttingdown()
    {
        pool_mut.lock();
        scope (exit)
        {
            pool_mut.unlock();
        }
        return shuttingdown;
    }

    bool isClosed()
    {
        pool_mut.lock();
        scope (exit)
        {
            pool_mut.unlock();
        }
        return closed;
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

    Tuple!(ChanPushResult, gerror) push(T value)
    {
        // auto ret = ChanPushResult.other;
        pool_mut.lock();
        scope (exit)
        {
            pool_mut.unlock();
        }

        if (shuttingdown)
        {
            return tuple(ChanPushResult.shuttingdown, cast(Exception) null);
        }

        if (closed)
        {
            return tuple(ChanPushResult.closed, cast(Exception) null);
        }

        try
        {
            bool emit_signal_not_empty = isEmpty();

            if (isFull())
            {
                return tuple(ChanPushResult.full, cast(Exception) null);
            }
            else
            {
                pool ~= value;
                if (emit_signal_not_empty)
                    signal_not_empty.emit();
                return tuple(ChanPushResult.success, cast(Exception) null);
            }
        }
        catch (gerror e)
        {
            // ret.success = false;
            // ret.error = e;
            return tuple(ChanPushResult.exception, e);
        }
    }

    gerror pull(
        bool delegate(ChanPullCBResult res, T cb_value) cb
    )
    {
        pool_mut.lock();
        scope (exit)
        {
            pool_mut.unlock();
        }

        if (closed)
        {
            cb(ChanPullCBResult.closed, T.init);
            return null;
        }

        try
        {
            bool emit_signal_not_full = isFull();

            if (isEmpty())
            {
                cb(ChanPullCBResult.empty, T.init);
                return null;
            }
            else
            {
                auto cb_res = cb(ChanPullCBResult.success, pool[0]);
                if (cb_res)
                {
                    pool = pool[1 .. $];
                    if (shuttingdown && isEmpty())
                    {
                        this.close();
                    }
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

    // puts Chan in `shuttingdown` mode: push returns error. pull works until
    // pool is empty, and once pool becomes empty - Chan becomes closed.
    void shutdown()
    {
        pool_mut.lock();
        scope (exit)
        {
            pool_mut.unlock();
        }
        shuttingdown = true;
        signal_shuttingdown.emit();
    }

    // puts Chan into `closed` mode: push/pull returns error, 
    // `shuttingdown` mode becomes 'false', pool.length reset to 0.
    void close()
    {
        pool_mut.lock();
        scope (exit)
        {
            pool_mut.unlock();
        }
        closed = true;
        shuttingdown = false;
        pool.length = 0;
        signal_closed.emit();
    }
}
