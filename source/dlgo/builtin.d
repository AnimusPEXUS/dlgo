module dlgo.builtin;

// import std.exception;

alias gerror = Exception;

alias gbool = bool;

alias gfloat32 = float;
alias gfloat64 = double;
alias gint16 = short;
alias gint32 = int;
alias gint64 = long;
alias gint8 = byte;
alias grune = gint32;
alias gstring = string;
alias guint16 = ushort;
alias guint32 = uint;
alias guint64 = ulong;
alias guint8 = ubyte;
alias guintptr = size_t;
alias gbyte = guint8;

version (X86)
{
    alias gint = gint32;
    alias guint = guint32;
}
else version (X86_64)
{
    alias gint = gint64;
    alias guint = guint64;
}
else
{
    static assert(false, "version not supported");
}
