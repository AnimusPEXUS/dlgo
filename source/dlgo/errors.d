module dlgo.errors;

import dlgo;

gerror newError(gstring text)
{
    return new Exception(text);
}

// mixin template newErrorCT(alias N, string MSG, alias P = Exception)
mixin template newErrorCT(string N, string MSG, string P = "Exception")
{
    import std.format;

    mixin(
        q{
            class %1$s : %3$s
            {
                this(string file = __FILE__, size_t line = __LINE__) {
                    super(%2$s, file, line);
                }
            }
        }.format(N, MSG, P)
         );

    // class N : P
    // {
    //     this(string file = __FILE__, size_t line = __LINE__) {
    //         super(MSG, file, line);
    //     }
    // }

}
