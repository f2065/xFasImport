
proc init_language
locals
hLngMem rq 1
szLngMem rq 1
plugin_filename rw MAX_PATH
lang_filename rw MAX_PATH
text_buff_temp sized dw 300+MAX_PATH dup (?)
endl
	push	rbx
	push	rsi
	push	rdi
	push	r12

	mov	[lang_file_incomplete], 0
	mov	[lang_file_load], 0
	lea	rsi, [currentLocale]
	mov	word [rsi], 0

; get currentLocale from x64dbg
	invoke	LocalAlloc, LPTR, MAX_SETTING_SIZE+10
	mov	rdi, rax
	test	rax, rax
	jnz	.mem_ok
	stdcall	LogErrW, .t_init_language, .t_err_LocalAlloc, 0, 0 ; .checkpoint_name, .winapi_name, .processed_object, .infotext
	jmp	.m0
	.mem_ok:

	cinvoke	BridgeSettingGet, .t_Engine, .t_Language, rdi
	test	rax, rax
	jz	.rd_err
	
	invoke	MultiByteToWideChar, CP_UTF8, 0, rdi, -1, rsi, (sizeof.currentLocale)/2
	
	.rd_err:
	invoke	LocalFree, rdi

	cmp	word [rsi], 0 ; esi = currentLocale
	je	.m0


; build filename
	lea	rdi, [plugin_filename]
	mov	word [rdi], 0
	invoke	GetModuleFileNameW, [hInstance], rdi, MAX_PATH
	invoke	PathRemoveFileSpecW, rdi

	lea	rbx, [lang_filename]
	cinvoke	wnsprintfW, rbx, MAX_PATH, .t_langfile_mask, rdi, rsi
	
	stdcall	is_file_exists, rbx
	test	rax, rax
	jnz	.load_file_lng
	lea	rsi, [text_buff_temp]
	cinvoke	wnsprintfW, rsi, (sizeof.text_buff_temp)/2, .t_langfile_notfound, rbx
	stdcall	LogPrintW, rsi
	jmp	.m0

.load_file_lng:
; Load file to memory.
; filename - UTF16,UTF8,ANSI... codepage - -1(UTF16), CP_UTF8, CP_ACP
; return - eax hMemory, edx size, ecx timecode. eax=0 - error
	stdcall	load_file_to_mem, rbx, -1
	test	rax, rax
	jz	.m0
	mov	[hLngMem], rax
	mov	[szLngMem], rdx
	cld

	lea	rsi, [text_buff_temp]
	cinvoke	wnsprintfW, rsi, (sizeof.text_buff_temp)/2, .t_langfile_used, rbx
	stdcall	LogPrintW, rsi

; init lng tables
	lea	rsi, [table_lang]
	mov	rbx, memsize*2
	call	.find_next_lng
	lea	rsi, [table_lang_dlg_settings]
	mov	rbx, memsize*3
	call	.find_next_lng
	lea	rsi, [table_lang_dlg_dll]
	call	.find_next_lng
	lea	rsi, [table_lang_dlg_about]
	call	.find_next_lng
	lea	rsi, [table_lang_dlg_FasFileTest]
	call	.find_next_lng

	lea	rsi, [table_lang]
	mov	rbx, memsize*2
	call	.set_EOL_text
	lea	rsi, [table_lang_dlg_settings]
	mov	rbx, memsize*3
	call	.set_EOL_text
	lea	rsi, [table_lang_dlg_dll]
	call	.set_EOL_text
	lea	rsi, [table_lang_dlg_about]
	call	.set_EOL_text
	lea	rsi, [table_lang_dlg_FasFileTest]
	call	.set_EOL_text
	
	mov	[lang_file_load], 1

.m0:
	pop	r12
	pop	rdi
	pop	rsi
	pop	rbx
	ret


; matching table of translatable strings
.find_next_lng: ; rsi = table_lang, rbx = table row size
	cmp	qword [rsi], 0
	je	.end_lng_table
	mov	rdx, [rsi+(memsize*1)]
	test	rdx, rdx
	jz	.skip_lng_row
;	mov	eax, [szLngMem]
;	shr	eax, 1
;	invoke	StrStrNW, [hLngMem], edx, eax
	stdcall	fast_StrStrNW, [hLngMem], rdx, [szLngMem]
	test	rax, rax
	jnz	.set_lng_text
	mov	[lang_file_incomplete], 1
	add	rsi, rbx
	jmp	.find_next_lng
.set_lng_text:
	mov	[rsi], rax
.skip_lng_row:
	add	rsi, rbx
	jmp	.find_next_lng
.end_lng_table:
	retn






; setting line endings and newlines
.set_EOL_text: ; rsi = table_lang, rbx = table row size
	mov	rdx, [rsi]
	test	rdx, rdx
	jz	.end_EOL_text
.s2:	cmp	word [rdx], 0x0020
	jb	.set_NULL
	cmp	dword [rdx], 0x005E005E ; "^^" replace to CR+LF
	je	.set_CRLF
	inc	rdx
	inc	rdx
	jmp	.s2
.set_NULL:
	mov	word [rdx], 0
	add	rsi, rbx
	jmp	.set_EOL_text
.set_CRLF:
	mov	dword [rdx], 0x000A000D ; CR,LF
	add	rdx, 4
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
	push	rbx
	push	rsi
	push	rdi
	push	r12
	
	mov	rsi, rcx ; [.mem_start]
	mov	rbx, rsi
	mov	rcx, r8 ; [.size_mem]
	add	rcx, rsi
	
.fs1:	mov	rdi, rdx ; [.name]
	mov	rsi, rbx
	
.fs3:	cmp	rsi, rcx
	jae	.fs_end
	mov	ax, [rsi]
	cmp	[rdi], ax
	je	.fs2
	inc	rsi
	inc	rsi
	jmp	.fs3
	
.fs2:	lea	rbx, [rsi+2]

.fs4:	inc	rdi
	inc	rdi
	inc	rsi
	inc	rsi
	cmp	rsi, rcx
	jae	.fs_end
	mov	ax, [rsi]
	cmp	[rdi], ax
	je	.fs4
	cmp	ax, 0x003D ; "="
	jne	.fs1
	cmp	word [rdi], 0
	jne	.fs1
	;found
	mov	rax, rsi
	add	rax, 2
	jmp	.fs_ret
.fs_end:
	xor	eax, eax
.fs_ret:
	pop	r12
	pop	rdi
	pop	rsi
	pop	rbx
	ret
	
endp



proc set_lng_dialog, .hWindow, .lng_table
	push	rsi
	push	rdi
	mov	[.hWindow], rcx
	mov	rsi, rdx ; [.lng_table]
.dlg_loop:
	mov	rax, [rsi]
	test	rax, rax
	jz	.dlg_end
	mov	rdx, [rsi+(memsize*2)]
	invoke	SetDlgItemTextW, [.hWindow], rdx, rax
	add	rsi, memsize*3
	jmp	.dlg_loop
.dlg_end:
	pop	rdi
	pop	rsi
	ret
endp
