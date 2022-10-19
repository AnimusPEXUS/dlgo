module dlgo.io.errors;

import dlgo.errors;

mixin newErrorCT!("EOF", q{"EOF"});
mixin newErrorCT!("ErrClosedPipe", q{"io: read/write on closed pipe"});
mixin newErrorCT!("ErrNoProgress", q{"multiple Read calls return no data or error"});
mixin newErrorCT!("ErrShortBuffer", q{"short buffer"});
mixin newErrorCT!("ErrShortWrite", q{"short write"});
mixin newErrorCT!("ErrUnexpectedEOF", q{"unexpected EOF"});
