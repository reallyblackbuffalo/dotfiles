" Implement some helper functions to allow a functional style of programming.

function! Sorted(l)
	let new_list = deepcopy(a:l)
	call sort(new_list)
	return new_list
endfunction

function! Reversed(l)
	let new_list = deepcopy(a:l)
	call reverse(new_list)
	return new_list
endfunction

function! Append(l, val)
	let new_list = deepcopy(a:l)
	call add(new_list, a:val)
	return new_list
endfunction

function! Assoc(l, i, val)
	let new_list = deepcopy(a:l)
	let new_list[a:i] = a:val
	return new_list
endfunction

function! Pop(l, i)
	let new_list = deepcopy(a:l)
	call remove(new_list, a:i)
	return new_list
endfunction

" Higher-Order Functions

function! Mapped(fn, l)
	let new_list = deepcopy(a:l)
	call map(new_list, string(a:fn) . '(v:val)')
	return new_list
endfunction

function! Filtered(fn, l)
	let new_list = deepcopy(a:l)
	if type(a:l) ==# v:t_list
		call filter(new_list, string(a:fn) . '(v:val)')
	elseif type(a:l) ==# v:t_dict
		call filter(new_list, string(a:fn) . '(v:key, v:val)')
	endif
	return new_list
endfunction

function! Removed(fn, l)
	let new_list = deepcopy(a:l)
	if type(a:l) ==# v:t_list
		call filter(new_list, '!' . string(a:fn) . '(v:val)')
	elseif type(a:l) ==# v:t_dict
		call filter(new_list, '!' . string(a:fn) . '(v:key, v:val)')
	endif
	return new_list
endfunction

function! Reduced(fn, l, initial = v:null)
	let new_list = deepcopy(a:l)
	if a:initial is v:null
		return reduce(new_list, a:fn)
	else
		return reduce(new_list, a:fn, a:initial)
	endif
endfunction
