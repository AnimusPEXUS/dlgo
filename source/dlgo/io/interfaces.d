module dlgo.io.interfaces;

import std.typecons;

import dlgo;
import dlgo.errors;

interface ByteReader
{
    Tuple!(gbyte, gerror) readByte();
}

interface ByteScanner : ByteReader
{
    gerror unreadByte();
}

interface ByteWriter
{
    gerror writeByte(gbyte c);
}

interface Closer
{
    gerror close();
}

interface ReadCloser : Reader, Closer
{
}

interface ReadSeeker : Reader, Seeker
{
}

interface ReadSeekCloser : Reader, Seeker, Closer
{
}

interface ReadWriteCloser : Reader, Writer, Closer
{
}

interface ReadWriteSeeker : Reader, Writer, Seeker
{
}

interface ReadWriter : Reader, Writer
{
}

interface Reader
{
    Tuple!(gint, gerror) read(gbyte[] p);
}

interface ReaderAt
{
    Tuple!(gint, gerror) readAt(gbyte[] p, gint64 off);
}

interface ReaderFrom
{
    Tuple!(gint64, gerror) readFrom(Reader r);
}

interface RuneReader
{
    Tuple!(grune, gint, gerror) readRune();
}

interface RuneScanner : RuneReader
{
    gerror unreadRune();
}

interface Seeker
{
    Tuple!(gint64, gerror) seek(gint64 offset, gint whence);
}

interface WriteCloser : Writer, Closer
{
}

interface WriteSeeker : Writer, Seeker
{
}

interface Writer
{
    Tuple!(gint, gerror) write(gbyte[] p);
}

interface WriterAt
{
    Tuple!(gbyte[], gerror) writeAt(gint n, gint64 off);
}

interface WriterFrom
{
    Tuple!(gint64, gerror) writeFrom(Reader r);
}
