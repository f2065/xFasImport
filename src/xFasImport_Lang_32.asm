
proc init_language
locals
hLngMem rd 1
szLngMem rd 1
plugin_filename rw MAX_PATH
lang_filename rw MAX_PATH
text_buff_temp sized dw 300+MAX_PATH dup (?)
endl
	push	ebx
	push	esi
	push	edi


	mov	[lang_file_incomplete], 0
	mov	[lang_file_load], 0
	lea	esi, [currentLocale]
	mov	word [esi], 0

; get currentLocale from x64dbg
	invoke	LocalAlloc, LPTR, MAX_SETTING_SIZE+10
	mov	edi, eax
	test	eax, eax
	jnz	.mem_ok
	stdcall	LogErrW, .t_init_language, .t_err_LocalAlloc, 0, 0 ; .checkpoint_name, .winapi_name, .processed_object, .infotext
	jmp	.m0
	.mem_ok:

	cinvoke	BridgeSettingGet, .t_Engine, .t_Language, edi
	test	eax, eax
	jz	.rd_err

	invoke	MultiByteToWideChar, CP_UTF8, 0, edi, -1, esi, (sizeof.currentLocale)/2

	.rd_err:
	invoke	LocalFree, edi

	cmp	word [esi], 0 ; esi = currentLocale
	je	.m0


; build filename
	lea	edi, [plugin_filename]
	mov	word [edi], 0
	invoke	GetModuleFileNameW, [hInstance], edi, MAX_PATH
	invoke	PathRemoveFileSpecW, edi

	lea	ebx, [lang_filename]
	cinvoke	wnsprintfW, ebx, MAX_PATH, .t_langfile_mask, edi, esi

	stdcall	is_file_exists, ebx
	test	eax, eax
	jnz	.load_file_lng

	invoke	lstrlenW, esi ; if 'xx_XX' is not found - search for 'xx'
	cmp	eax, 5
	jne	.no_file
	cmp	word [esi+4], 0x5F ; '_'
	jne	.no_file
	mov	word [esi+4], 0

	cinvoke	wnsprintfW, ebx, MAX_PATH, .t_langfile_mask, edi, esi

	stdcall	is_file_exists, ebx
	test	eax, eax
	jnz	.load_file_lng

.no_file:
	lea	esi, [text_buff_temp]
	cinvoke	wnsprintfW, esi, (sizeof.text_buff_temp)/2, .t_langfile_notfound, ebx
	stdcall	LogPrintW, esi
	jmp	.m0

.load_file_lng:
; Load file to memory.
; filename - UTF16,UTF8,ANSI... codepage - -1(UTF16), CP_UTF8, CP_ACP
; return - eax hMemory, edx size, ecx timecode. eax=0 - error
	stdcall	load_file_to_mem, ebx, -1
	test	eax, eax
	jz	.m0
	mov	[hLngMem], eax
	mov	[szLngMem], edx
	cld

	lea	esi, [text_buff_temp]
	cinvoke	wnsprintfW, esi, (sizeof.text_buff_temp)/2, .t_langfile_used, ebx
	stdcall	LogPrintW, esi

; init lng tables
	lea	esi, [table_lang]
	mov	ebx, memsize*2
	call	.find_next_lng
	lea	esi, [table_lang_dlg_settings]
	mov	ebx, memsize*3
	call	.find_next_lng
	lea	esi, [table_lang_dlg_dll]
	call	.find_next_lng
	lea	esi, [table_lang_dlg_about]
	call	.find_next_lng
	lea	esi, [table_lang_dlg_FasFileTest]
	call	.find_next_lng

	lea	esi, [table_lang]
	mov	ebx, memsize*2
	call	.set_EOL_text
	lea	esi, [table_lang_dlg_settings]
	mov	ebx, memsize*3
	call	.set_EOL_text
	lea	esi, [table_lang_dlg_dll]
	call	.set_EOL_text
	lea	esi, [table_lang_dlg_about]
	call	.set_EOL_text
	lea	esi, [table_lang_dlg_FasFileTest]
	call	.set_EOL_text

	mov	[lang_file_load], 1

.m0:

	pop	edi
	pop	esi
	pop	ebx
	ret


; matching table of translatable strings
.find_next_lng: ; esi = table_lang, ebx = table row size
	cmp	dword [esi], 0
	je	.end_lng_table
	mov	edx, [esi+(memsize*1)]
	test	edx, edx
	jz	.skip_lng_row
;	mov	eax, [szLngMem]
;	shr	eax, 1
;	invoke	StrStrNW, [hLngMem], edx, eax
	stdcall	fast_StrStrNW, [hLngMem], edx, [szLngMem]
	test	eax, eax
	jnz	.set_lng_text
	mov	[lang_file_incomplete], 1
	add	esi, ebx
	jmp	.find_next_lng
.set_lng_text:
	mov	[esi], eax
.skip_lng_row:
	add	esi, ebx
	jmp	.find_next_lng
.end_lng_table:
	retn






; setting line endings and newlines
.set_EOL_text: ; esi = table_lang, ebx = table row size
	mov	edx, [esi]
	test	edx, edx
	jz	.end_EOL_text
.s2:	cmp	word [edx], 0x0020
	jb	.set_NULL
	cmp	dword [edx], 0x005E005E ; "^^" replace to CR+LF
	je	.set_CRLF
	inc	edx
	inc	edx
	jmp	.s2
.set_NULL:
	mov	word [edx], 0
	add	esi, ebx
	jmp	.set_EOL_text
.set_CRLF:
	mov	dword [edx], 0x000A000D ; CR,LF
	add	edx, 4
	jmp	.s2
.end_EOL_text:
	retn


.t_init_language du "init_language",0

.t_Engine db "Engine",0
.t_Language db "Language",0

.t_langfile_mask du "%s\xFasImport_%s.lng",0
.t_langfile_notfound du "Language file %s not found, built-in English will be used.",0
.t_langfile_used du "Language file used: %s",0

.t_err_LocalAlloc du "LocalAlloc",0
endp


proc fast_StrStrNW, .mem_start, .name, .size_mem
	push	ebx
	push	esi
	push	edi


	mov	esi, [.mem_start]
	mov	ebx, esi
	mov	ecx, [.size_mem]
	add	ecx, esi

.fs1:	mov	edi, [.name]
	mov	esi, ebx

.fs3:	cmp	esi, ecx
	jae	.fs_end
	mov	ax, [esi]
	cmp	[edi], ax
	je	.fs2
	inc	esi
	inc	esi
	jmp	.fs3

.fs2:	lea	ebx, [esi+2]

.fs4:	inc	edi
	inc	edi
	inc	esi
	inc	esi
	cmp	esi, ecx
	jae	.fs_end
	mov	ax, [esi]
	cmp	[edi], ax
	je	.fs4
	cmp	ax, 0x003D ; "="
	jne	.fs1
	cmp	word [edi], 0
	jne	.fs1
	;found
	mov	eax, esi
	add	eax, 2
	jmp	.fs_ret
.fs_end:
	xor	eax, eax
.fs_ret:

	pop	edi
	pop	esi
	pop	ebx
	ret

endp



proc set_lng_dialog, .hWindow, .lng_table
	push	esi
	push	edi

	mov	esi, [.lng_table]
.dlg_loop:
	mov	eax, [esi]
	test	eax, eax
	jz	.dlg_end
	mov	edx, [esi+(memsize*2)]
	invoke	SetDlgItemTextW, [.hWindow], edx, eax
	add	esi, memsize*3
	jmp	.dlg_loop
.dlg_end:
	pop	edi
	pop	esi
	ret
endp
