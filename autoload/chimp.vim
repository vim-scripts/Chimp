"###### LICENSE [ {{{ ]
"-
" Copyright 2008 (c) Meikel Brandmeyer.
" All rights reserved.
" 
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to deal
" in the Software without restriction, including without limitation the rights
" to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
" copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
"
" The above copyright notice and this permission notice shall be included in
" all copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
" OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
" THE SOFTWARE.
"###### [ }}} ]

"###### PROLOG [ {{{ ]
let s:save_cpo = &cpo
set cpo&vim
"###### [ }}} ]

"###### VARIABLES [ {{{ ]
if !exists("chimp#ScreenCommand")
	let chimp#ScreenCommand = "screen"
endif

if !exists("chimp#BufferDirectory")
	let chimp#BufferDirectory = "/tmp"
endif
"###### [ }}} ]

"###### FUNCTIONS [ {{{ ]
function! chimp#SendMessage(chimp, msg)
	call chimp#SendLines(a:chimp, split(a:msg, "\\n", 1))
endfunction

function! chimp#SendLines(chimp, lines)
	let buffile = g:chimp#BufferDirectory . "/chimp." . a:chimp . ".pipe"
	call writefile(a:lines, buffile)
	call system(g:chimp#ScreenCommand . ' -x ' . a:chimp
				\ . ' -X eval "select 0" "readbuf" "paste ."')
endfunction
"###### [ }}} ]

"###### EPILOG [ {{{ ]
let &cpo = s:save_cpo
"###### [ }}} ]
