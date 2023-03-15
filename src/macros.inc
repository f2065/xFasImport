
; http://board.flatassembler.net/topic.php?p=121612
struc sized [args] {
common . args
sizeof.#. = $ - .
}

; https://t.me/ChatAssembler/155278
macro stringify_equ a*,b* { 
match a-b,a-b \{ a equ \`b \} 
}

; https://t.me/ChatAssembler/156207
macro fix_reloc_size_alignment {
reloc_block = $$
while reloc_block < $

	; On the initial passes, sometimes zero values.
	load reloc_block_page dword from (reloc_block + 0)
	if ~reloc_block_page
		break
	end if
	load reloc_block_size dword from (reloc_block + 4)
	if ~reloc_block_size
		break
	end if

	; Suddenly there will be not the last block with the incorrect size?
	if ((reloc_block + reloc_block_size) < $) & (reloc_block_size and 3)
		display "There is an unaligned data in the middle table, or extraneous data in the reloc-section"
		err
		break
	end if

	if ((reloc_block + reloc_block_size) = $) & (reloc_block_size and 3)
		new_aligned_size = (reloc_block_size + 3) and not 3
		store dword new_aligned_size at (reloc_block + 4)
		db (new_aligned_size - reloc_block_size) dup 0
		break
	end if

	reloc_block = reloc_block + reloc_block_size

end while
}

macro fix_null_reloc {
if ($ - $$) < 8
	db (8 - ($ - $$)) dup 0
end if
}

