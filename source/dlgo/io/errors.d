module dlgo.io.errors;

import dlgo.errors;

mixin errorCT!("EOF", q{"EOF"});
mixin errorCT!("ErrClosedPipe", q{"io: read/write on closed pipe"});
mixin errorCT!("ErrNoProgress", q{"multiple Read calls return no data or error"});
mixin errorCT!("ErrShortBuffer", q{"short buffer"});
mixin errorCT!("ErrShortWrite", q{"short write"});
mixin errorCT!("ErrUnexpectedEOF", q{"unexpected EOF"});
