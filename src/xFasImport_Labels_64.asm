



proc import_labels
locals
 text_buff_temp sized dw 200 dup (?)
 buffer_label sized db MAX_LABEL_SIZE+8 dup (?)
endl
	push	rsi
	push	rdi
	push	rbx
	push	r12

	mov	[imported_labels_counter], 0

	mov	rbx, [address_symbol_ref]
	mov	rsi, [address_symbol_table]
	mov	rdi, [address_preprocessed_source]

.loop_GetSymbols:
	cmp	rbx, [endOf_symbol_ref]
	jae	.ImportLabels_end
	mov	eax, dword[rbx]
	test	eax, eax
	jz	.do_loop_GetSymbols

	lea	rax, [rax+rsi] ; RSI = address_symbol_table
	bt	[rax+fsymbol.flags], 8 ; Table 2.1 Symbol flags: b3 0x8 - Symbol was used.
	jnc	.do_loop_GetSymbols

	bt	[rax+fsymbol.symb_name_prep_offset], 31
	jnc	.in_prep_source
.in_strings_table:
	mov	ecx, [rax+fsymbol.symb_name_string_offset]
	btr	ecx, 31
	add	rcx, [address_string_table]
	push	rcx
	push	rax
	invoke	lstrlenA, rcx
	mov	rdx, rax
	pop	rax
	pop	rcx
	jmp	.addrinfoset

.in_prep_source:
	mov	ecx, [rax+fsymbol.symb_name_prep_offset]
	lea	rcx, [rcx+rdi]
	cmp	byte[rcx], 0
	je	.do_loop_GetSymbols
	movzx	rdx, byte[rcx]
	inc	rcx
.addrinfoset:
	mov	r12, rax
	lea	r8, [buffer_label]
	stdcall	convert_8bit_to_utf8, rcx, rdx, r8, MAX_LABEL_SIZE ; .in_text, .in_size, .out_text, .out_max_size
	mov	rax, r12

	mov	rax, [rax+fsymbol.value]
	sub	rax, [original_base_addr]
	add	rax, [current_base_addr]

	cmp	rax, [start_import_table]
	jb	@f
	cmp	rax, [endOf_import_table]
	jb	.do_loop_GetSymbols ; skip labels in the import table

@@:	lea	rdx, [buffer_label]
	cmp	[config_flag_labels_manual], 0
	je	.setA2
	cinvoke	DbgSetLabelAt, rax, rdx
	jmp	.setZ2
.setA2:	cinvoke	DbgSetAutoLabelAt, rax, rdx
.setZ2:
	inc	[imported_labels_counter]

.do_loop_GetSymbols:
	add	rbx, 8 ; The symbol references dump contains an array of 8-byte structures...
	jmp	.loop_GetSymbols
;---

.ImportLabels_end:

	lea	rsi, [text_buff_temp]
	cinvoke	wnsprintfW, rsi, (sizeof.text_buff_temp)/2, [msg_symbols_loaded_U], [imported_labels_counter]
	stdcall	LogPrintW, rsi

	pop	r12
	pop	rbx
	pop	rdi
	pop	rsi
	ret
endp

