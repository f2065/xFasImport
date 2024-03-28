



proc import_labels
locals
 text_buff_temp sized dw 200 dup (?)
 buffer_label sized db MAX_LABEL_SIZE+8 dup (?)
endl
	push	esi
	push	edi
	push	ebx


	mov	[imported_labels_counter], 0

	mov	ebx, [address_symbol_ref]
	mov	esi, [address_symbol_table]
	mov	edi, [address_preprocessed_source]

.loop_GetSymbols:
	cmp	ebx, [endOf_symbol_ref]
	jae	.ImportLabels_end
	mov	eax, dword[ebx]
	test	eax, eax
	jz	.do_loop_GetSymbols

	lea	eax, [eax+esi] ; ESI = address_symbol_table
	bt	[eax+fsymbol.flags], 8 ; Table 2.1 Symbol flags: b3 0x8 - Symbol was used.
	jnc	.do_loop_GetSymbols

	bt	[eax+fsymbol.symb_name_prep_offset], 31
	jnc	.in_prep_source
.in_strings_table:
	mov	ecx, [eax+fsymbol.symb_name_string_offset]
	btr	ecx, 31
	add	ecx, [address_string_table]
	push	ecx
	push	eax
	invoke	lstrlenA, ecx
	mov	edx, eax
	pop	eax
	pop	ecx
	jmp	.addrinfoset

.in_prep_source:
	mov	ecx, [eax+fsymbol.symb_name_prep_offset]
	lea	ecx, [ecx+edi]
	cmp	byte[ecx], 0
	je	.do_loop_GetSymbols
	movzx	edx, byte[ecx]
	inc	ecx
.addrinfoset:
	push	eax
	lea	eax, [buffer_label]
	stdcall	convert_8bit_to_utf8, ecx, edx, eax, MAX_LABEL_SIZE ; .in_text, .in_size, .out_text, .out_max_size
	pop	eax

	mov	eax, dword[eax+fsymbol.value]
	sub	eax, [original_base_addr]
	add	eax, [current_base_addr]

	cmp	eax, [start_import_table]
	jb	@f
	cmp	eax, [endOf_import_table]
	jb	.do_loop_GetSymbols ; skip labels in the import table

@@:	lea	edx, [buffer_label]
	cmp	[config_flag_labels_manual], 0
	je	.setA2
	cinvoke	DbgSetLabelAt, eax, edx
	jmp	.setZ2
.setA2:	cinvoke	DbgSetAutoLabelAt, eax, edx
.setZ2:
	inc	[imported_labels_counter]

.do_loop_GetSymbols:
	add	ebx, 8 ; The symbol references dump contains an array of 8-byte structures...
	jmp	.loop_GetSymbols
;---

.ImportLabels_end:

	lea	esi, [text_buff_temp]
	cinvoke	wnsprintfW, esi, (sizeof.text_buff_temp)/2, [msg_symbols_loaded_U], [imported_labels_counter]
	stdcall	LogPrintW, esi


	pop	ebx
	pop	edi
	pop	esi
	ret
endp

