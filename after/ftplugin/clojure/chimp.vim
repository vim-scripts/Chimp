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
try
	if !gatekeeper#Guard("b:clojure_chimp", "1.0.0")
		finish
	endif
catch /^Vim\%((\a\+)\)\=:E117/
	if exists("b:clojure_chimp_loaded")
		finish
	endif
	let b:clojure_chimp_loaded = "1.0.0"
endtry

let s:save_cpo = &cpo
set cpo&vim
"###### [ }}} ]

"###### VARIABLES [ {{{ ]
" Be sure to load this only once, even of the script is sourced in
" several buffers.
if !exists("s:CurrentNamespace")
	let s:CurrentNamespace = "user"
endif
"###### [ }}} ]

"###### FUNCTIONS [ {{{ ]
function! s:MakePlug(mode, plug, f)
	execute a:mode . "noremap <Plug>ClojureChimp" . a:plug
				\ . " :call <SID>" . a:f . "<CR>"
endfunction

function! s:MapPlug(mode, keys, plug)
	if !hasmapto("<Plug>ClojureChimp" . a:plug)
		execute a:mode . "map <buffer> <unique> <silent> <LocalLeader>" . a:keys
					\ . " <Plug>ClojureChimp" . a:plug
	endif
endfunction

function! s:Connect()
	if !exists("s:ChimpId")
		let s:ChimpId = input("Please give Chimp Id: ")
	endif
endfunction

function! s:ResetChimp()
	unlet s:ChimpId
	call s:Connect()
endfunction

function! s:GetBufferNamespace()
	let cursor = getpos(".")

	if search('^(\(clojure/\)\=in-ns', "b") == 0
		if search('^(\(clojure/\)\=in-ns') == 0
			let b:ClojureChimpNamespace = "user"
			return
		endif
	endif

	let ns = substitute(getline("."),
				\ "^(\\(clojure/\\)\\=in-ns '\\(.*\\)).*",
				\ "\\2", "")

	let b:ClojureChimpNamespace = ns

	call setpos(".", cursor)
endfunction

function! s:ChangeNamespace(ns)
	let msg = "(clojure/in-ns '" . a:ns . ")"
	call chimp#SendMessage(s:ChimpId, msg)
	let s:CurrentNamespace = a:ns
endfunction

function! s:ChangeNamespaceIfNecessary()
	if !exists("b:ClojureChimpNamespace")
		call s:GetBufferNamespace()
	endif
	if b:ClojureChimpNamespace != s:CurrentNamespace
		call s:ChangeNamespace(b:ClojureChimpNamespace)
	endif
endfunction

function! s:SwitchNamespace()
	call s:Connect()

	let ns = input("New Namespace: ")
	call s:ChangeNamespace(ns)
endfunction

function! s:Yank(how)
	let save_l = @l
	execute a:how
	let text = @l
	let @l = save_l
	return text
endfunction

function! s:EvalBlock() range
	call s:Connect()
	call s:ChangeNamespaceIfNecessary()

	let b = s:Yank(a:firstline . "," . a:lastline . "yank l")

	call chimp#SendMessage(s:ChimpId, b)
endfunction

function! s:SendSexp(innerOrTop)
	if a:innerOrTop == 'top'
		let addFlags = 'r'
	else
		let addFlags = ''
	endif

	call s:Connect()
	call s:ChangeNamespaceIfNecessary()

	let cursor = getpos(".")

	let p = searchpairpos('(', '', ')', 'bW' . addFlags,
				\ 'synIDattr(synID(line("."), col("."), 0), "name") != "Delimiter"')
	if p != [0, 0]
		let sexp = s:Yank('normal "ly%')

		call chimp#SendMessage(s:ChimpId, sexp)

		call setpos(".", cursor)
	endif
endfunction

function! s:EvalInnerSexp()
	call s:SendSexp('inner')
endfunction

function! s:EvalTopSexp()
	call s:SendSexp('top')
endfunction

function! s:LoadFile(fname)
	call s:Connect()
	call s:ChangeNamespaceIfNecessary()

	let c = getpos(".")
	let msg = s:Yank('normal ggVG"ly')
	call setpos(".", c)

	call chimp#SendMessage(s:ChimpId, msg)
endfunction
"###### [ }}} ]

"###### MAPS [ {{{ ]
if !exists("no_plugin_maps") && !exists("no_clojure_chimp_maps")
	call s:MakePlug('v', 'EvalBlock', 'EvalBlock()')
	call s:MakePlug('n', 'EvalInnerSexp', 'EvalInnerSexp()')
	call s:MakePlug('n', 'EvalTopSexp', 'EvalTopSexp()')
	call s:MakePlug('n', 'LoadFile', 'LoadFile(expand("%:p"))')
	call s:MakePlug('n', 'ResetChimp', 'ResetChimp()')
	call s:MakePlug('n', 'SwitchNamespace', 'SwitchNamespace()')

	call s:MapPlug('v', 'eb', 'EvalBlock')
	call s:MapPlug('n', 'es', 'EvalInnerSexp')
	call s:MapPlug('n', 'et', 'EvalTopSexp')
	call s:MapPlug('n', 'ef', 'LoadFile')
	call s:MapPlug('n', 'rc', 'ResetChimp')
	call s:MapPlug('n', 'sn', 'SwitchNamespace')
endif
"###### [ }}} ]

"###### COMMANDS [ {{{ ]
command! -nargs=1 -complete=file -buffer LoadFile call <SID>LoadFile(<f-args>)
"###### [ }}} ]

"###### EPILOG [ {{{ ]
let &cpo = s:save_cpo
"###### [ }}} ]
