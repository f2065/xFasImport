

proc delete_old_labels
locals
 text_buffer sized dw 300 dup (?)
endl
	push	rsi
	push	rdi
frame
	cmp	[config_delete_old_labels], 0
	je	.skip_delete_labels

	mov	rcx, [current_base_addr]
	mov	rdx, [original_SizeOfImage]
	add	rdx, rcx
	dec	rdx
	mov	rdi, rdx

	lea	rsi, [.t_mask_auto]
	cmp	[config_flag_labels_manual], 0
	je	.flg_A
	lea	rsi, [.t_mask_manual]
	cinvoke	DbgClearLabelRange, rcx, rdx
	jmp	.result
.flg_A:	cinvoke	DbgClearAutoLabelRange, rcx, rdx

.result:
	lea	rcx, [text_buffer]
	cinvoke	wnsprintfW, rcx, (sizeof.text_buffer)/2, rsi, [current_base_addr], rdi
	lea	rcx, [text_buffer]
	stdcall	LogPrintW, rcx

.skip_delete_labels:
endf
	pop	rdi
	pop	rsi
	ret
.t_mask_manual: du "DbgClearLabelRange: start 0x%08X, end 0x%08X",0
.t_mask_auto: du "DbgClearAutoLabelRange: start 0x%08X, end 0x%08X",0
endp

proc delete_old_comments
locals
 text_buffer sized dw MAX_PATH+200 dup (?)
endl
	push	rsi
	push	rdi
frame
	cmp	[config_delete_old_comments], 0
	je	.skip_delete_comments

	mov	rcx, [current_base_addr]
	mov	rdx, [original_SizeOfImage]
	add	rdx, rcx
	dec	rdx
	mov	rdi, rdx

	lea	rsi, [.t_mask_auto]
	cmp	[config_flag_comments_manual], 0
	je	.flg_A
	lea	rsi, [.t_mask_manual]
	cinvoke	DbgClearCommentRange, rcx, rdx
	jmp	.result
.flg_A:	cinvoke	DbgClearAutoCommentRange, rcx, rdx

.result:
	lea	rcx, [text_buffer]
	cinvoke	wnsprintfW, rcx, (sizeof.text_buffer)/2, rsi, [current_base_addr], rdi
	lea	rcx, [text_buffer]
	stdcall	LogPrintW, rcx

.skip_delete_comments:
endf
	pop	rdi
	pop	rsi
	ret
.t_mask_manual: du "DbgClearCommentRange: start 0x%08X, end 0x%08X",0
.t_mask_auto: du "DbgClearAutoCommentRange: start 0x%08X, end 0x%08X",0
endp


proc set_buffFasFileName, .image_file
frame
	mov	rdx, rcx ; .image_file
	invoke	lstrcpynW, buffFasFileName, rdx, MAX_PATH
	invoke	PathRenameExtensionW, buffFasFileName, .t_fas
endf
	ret
.t_fas du ".fas",0
endp


proc set_basepath
frame
	invoke	lstrcpynW, buffBasePath, buffFasFileName, MAX_PATH
	invoke	PathRemoveFileSpecW, buffBasePath
endf
	ret
endp



proc load_basepath_fileA_to_mem, .filenameA ; return - eax hMemory, edx size, ecx timecode. eax=0 - error
locals
 filenameW sized dw MAX_PATH dup (?)
 fullfilenameW sized dw MAX_PATH dup (?)
endl
	push	rsi
	push	rdi
frame
	mov	r8, rcx ; .filenameA
	lea	rdi, [filenameW]
	mov	word [rdi], 0
	invoke	MultiByteToWideChar, CP_ACP, 0, r8, -1, rdi, MAX_PATH
	invoke	PathIsRelativeW, rdi
	test	rax, rax
	jnz	.m1
	mov	rsi, rdi
	jmp	.m2
.m1:
	lea	rsi, [fullfilenameW]
	cinvoke	wnsprintfW, rsi, MAX_PATH, .mask1, buffBasePath, rdi
.m2:
	stdcall	load_file_to_mem, rsi, -1
endf
	pop	rdi
	pop	rsi
	ret
.mask1 du "%s\%s",0
endp



proc DbgModBaseFromName_W, .image
locals
 filename8 sized dw MAX_PATH dup (?)
endl
	push	rbx
	push	r12
frame
	mov	r12, rcx ; .image
	invoke	PathFindFileNameW, r12
	lea	rbx, [filename8]
	invoke	WideCharToMultiByte, CP_UTF8, 0, rax, -1, rbx, sizeof.filename8, 0, 0
	cinvoke	DbgModBaseFromName, rbx
	mov	rbx, rax
	test	rax, rax
	jnz	@f
	stdcall	LogErrW, .t_DbgModBaseFromName_W, 0, r12, .t_DbgModBaseFromName_error ; .checkpoint_name, .winapi_name, .processed_object, .infotext
	@@:
	mov	rax, rbx
endf
	pop	r12
	pop	rbx
	ret

.t_DbgModBaseFromName_W du "DbgModBaseFromName_W",0
.t_DbgModBaseFromName_error du "cannot get DbgModBaseFromName",0
endp



proc get_header_from_exe, .image
	push	rbx
	push	r12
	mov	r12, rcx ; .image

	stdcall	load_file_to_mem, r12, -1 ; return - eax hMemory, edx size, ecx timecode. eax=0 - error
	mov	[timeImageFile], rcx
	test	rax, rax
	jz	.m0
	mov	rbx, rax

	mov	rax, [timeFasFile] ; FAS-file must be written within a few seconds after the EXE-file.
	sub	rax, rcx
	jc	.time_err
	cmp	rax, 5
	jb	.time_ok
	.time_err:
	or	[incorrect_time_flag], 1
	.time_ok:
	mov	rax, rbx

	sub	rdx, memsize ; size.INT_PTR: 32=4, 64=8
	jbe	.error_file
	add	rdx, rax

	lea	rcx, [rax + IMAGE_DOS_HEADER.e_lfanew]
	cmp	rcx, rdx
	jae	.error_file
	mov	ecx, [rcx]
	cmp	rcx, rdx
	jae	.error_file
	add	rax, rcx

	lea	rcx, [rax + IMAGE_NT_HEADERS64.OptionalHeader.ImageBase]
	cmp	rcx, rdx
	jae	.error_file
	mov	rcx, [rcx]
	mov	[original_base_addr], rcx

	mov	ecx, [rax + IMAGE_NT_HEADERS64.OptionalHeader.SizeOfImage]
	mov	[original_SizeOfImage], rcx

	lea	rcx, [rax + IMAGE_NT_HEADERS64.OptionalHeader.DataDirectory + sizeof.IMAGE_DATA_DIRECTORY*IMAGE_DIRECTORY_ENTRY_IMPORT + IMAGE_DATA_DIRECTORY.VirtualAddress]
	cmp	rcx, rdx
	jae	.error_file
	mov	ecx, [rcx]
	add	rcx, [current_base_addr]
	mov	[start_import_table], rcx

	lea	rax, [rax + IMAGE_NT_HEADERS64.OptionalHeader.DataDirectory + sizeof.IMAGE_DATA_DIRECTORY*IMAGE_DIRECTORY_ENTRY_IMPORT + IMAGE_DATA_DIRECTORY.Size]
	cmp	rax, rdx
	jae	.error_file
	mov	eax, [rax]
	add	rcx, rax
	mov	[endOf_import_table], rcx

	invoke	LocalFree, rbx
	pop	r12
	pop	rbx
	mov	eax, 1
	ret

.error_file:
	stdcall	LogErrW, .t_get_header_from_exe, 0, r12, [msg_err_pe_header] ; .checkpoint_name, .winapi_name, .processed_object, .infotext
	invoke	LocalFree, rbx

.m0:	pop	r12
	pop	rbx
	xor	eax, eax
	ret

.t_get_header_from_exe du "get_header_from_exe",0
endp



proc is_file_exists, .filename
	invoke	CreateFileW, rcx, GENERIC_READ, FILE_SHARE_DELETE or FILE_SHARE_READ or FILE_SHARE_WRITE, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
	cmp	rax, INVALID_HANDLE_VALUE
	jne	@f
	xor	eax, eax
	ret
@@:	invoke	CloseHandle, rax
	xor	eax, eax
	inc	eax
	ret
endp



; Load file to memory.
; filename - UTF16,UTF8,ANSI... codepage - -1(UTF16), CP_UTF8, CP_ACP
; return - eax hMemory, edx size, ecx timecode. eax=0 - error
proc load_file_to_mem, .filename, .codepage
locals
 dqFileSize dq ?
 pFilename dq ?
 dwTemp dq ?
 ftime FILETIME
 filename_converted sized dw MAX_PATH dup (?)
endl
	push	rdi
	push	rsi
	push	rbx
	push	r12 ; stack align
frame
	mov	rdi, rcx ; [.filename]
	mov	rcx, rdx ; [.codepage]
	cmp	rcx, -1
	je	.use_W
	mov	rsi, rdi
	lea	rdi, [filename_converted]
	invoke	MultiByteToWideChar, rcx, 0, rsi, -1, rdi, MAX_PATH
.use_W:
	mov	[pFilename], rdi

;	invoke	MessageBoxW, 0, [.filename], 0, 0
	invoke	CreateFileW, [pFilename], GENERIC_READ, FILE_SHARE_READ or FILE_SHARE_WRITE or FILE_SHARE_DELETE, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
	cmp	rax, INVALID_HANDLE_VALUE
	jne	.cr_OK
	stdcall	LogErrW, .t_load_file_to_mem, .t_err_CreateFileW, [pFilename], 0 ; .checkpoint_name, .winapi_name, .processed_object, .infotext
	jmp	.load_err
.cr_OK:
	mov	rbx, rax ; hFile


	lea	rsi, [dqFileSize]
	mov	qword [rsi], 0

	invoke	GetFileSizeEx, rbx, rsi
	test	rax, rax
	jnz	.sz_OK
	stdcall	LogErrW, .t_load_file_to_mem, .t_err_GetFileSizeEx, [pFilename], 0 ; .checkpoint_name, .winapi_name, .processed_object, .infotext
	invoke	CloseHandle, rbx
	jmp	.load_err
.sz_OK:

	cmp	dword [rsi+4], 0
	jne	.sz_err2
	mov	rsi, [rsi+0]
	test	rsi, rsi
	js	.sz_err2
	jnz	.sz_OK2
.sz_err2:
	invoke	CloseHandle, rbx
	stdcall	LogErrW, .t_load_file_to_mem, 0, [pFilename], [msg_invalid_filesize] ; .checkpoint_name, .winapi_name, .processed_object, .infotext
	jmp	.load_err
.sz_OK2:

	test	rsi, rsi
	jnz	.sz_OK3
	xor	edi, edi
	dec	rsi
	jmp	.rd_OK
.sz_OK3:

	invoke	LocalAlloc, LPTR, rsi
	mov	rdi, rax
	test	rax, rax
	jnz	.mem_ok2
	stdcall	LogErrW, .t_load_file_to_mem, .t_err_LocalAlloc, [pFilename], 0 ; .checkpoint_name, .winapi_name, .processed_object, .infotext
	invoke	CloseHandle, rbx
	jmp	.load_err
	.mem_ok2:

	lea	r9, [dwTemp]
	invoke	ReadFile, rbx, rdi, rsi, r9, 0
	test	rax, rax
	jnz	.rd_OK
	stdcall	LogErrW, .t_load_file_to_mem, .t_err_ReadFile, [pFilename], 0 ; .checkpoint_name, .winapi_name, .processed_object, .infotext
	invoke	CloseHandle, rbx
	invoke	LocalFree, rdi
	jmp	.load_err
.rd_OK:

	lea	r12, [ftime]
	mov	qword [r12], 0

	invoke	GetFileTime, rbx, 0, 0, r12

	invoke	CloseHandle, rbx

	mov	rcx, qword [r12]
	stdcall	convert_FILETIME_to_code, rcx
	mov	rcx, rax ; timecode

	mov	rdx, rsi ; szMem
	mov	rax, rdi ; hMem
.load_exit:
endf
	pop	r12
	pop	rbx
	pop	rsi
	pop	rdi
	ret


.load_err:
	xor	eax, eax
	xor	edx, edx
	xor	ecx, ecx
	jmp	.load_exit

.t_load_file_to_mem du "load_file_to_mem",0
.t_err_CreateFileW du "CreateFileW",0
.t_err_GetFileSizeEx du "GetFileSizeEx",0
.t_err_LocalAlloc du "LocalAlloc",0
.t_err_ReadFile du "ReadFile",0
endp

proc convert_FILETIME_to_code, .ftime

	mov	rax, rcx ; [.ftime]


	mov	rdx, 129067776000000000 ; 2000-01-01 00:00:00 = filetime 129067776000000000 = 1CA 8A75 5C6E 0000
	sub	rax, rdx
	jnc	@f

	xor	eax, eax
	@@:
	xor	edx, edx
	mov	rcx, 10000000 ; 100nanosec
	div	rcx
	ret
endp

proc get_time_from_file_W, .filename
locals
 LastWriteTime dq ? ; FILETIME
endl
	push	rsi
	push	rbx

	invoke	CreateFileW, rcx, GENERIC_READ, FILE_SHARE_READ or FILE_SHARE_WRITE or FILE_SHARE_DELETE, 0, OPEN_EXISTING, 0, 0
	cmp	eax, INVALID_HANDLE_VALUE
	je	.no_info
	mov	rbx, rax ; hFile
	lea	rsi, [LastWriteTime]
	xor	eax, eax
	mov	qword [rsi], rax

	invoke	GetFileTime, rbx, rax, rax, rsi
	invoke	CloseHandle, rbx

	stdcall	convert_FILETIME_to_code, qword [rsi]

	jmp	.end

.no_info:
	xor	eax, eax

.end:	pop	rbx
	pop	rsi
	ret
endp

proc LogErrW, .checkpoint_name, .winapi_name, .processed_object, .infotext
locals
 buffer_text_error sized dw 1500 dup (?)
 buffer_text_result sized dw 2500 dup (?)
 buffer_text_utf8 sized dw 2500 dup (?)
endl
	push	rbx
	push	rdi
	push	rsi
	push	r12
frame
	mov	[.checkpoint_name], rcx
	mov	[.winapi_name], rdx
	mov	[.processed_object], r8
	mov	[.infotext], r9

	invoke	GetLastError
	mov	rbx, rax ; error_code

	lea	rdi, [buffer_text_result] ; tmp_pos
	mov	rsi, (sizeof.buffer_text_result)/2 ; tmp_size

	mov	r10, [.checkpoint_name]
	test	r10, r10
	jz	.no_checkpoint
	cinvoke	wnsprintfW, rdi, rsi, .MsgErr_mask1, szPLUGIN_NAME_W, [msg_MsgErr_loc], r10
	test	rax, rax
	js	.no_checkpoint
	sub	rsi, rax
	shl	rax, 1
	add	rdi, rax
	.no_checkpoint:

	mov	r10, [.winapi_name]
	test	r10, r10
	jz	.no_winapi
	test	rsi, rsi
	jle	.no_winapi
;test eax, eax
;eax>0  jg
;eax>=0 jge
;eax<0  jl
;eax<=0 jle
;eax=0  jz
;eax<>0 jnz
	cinvoke	wnsprintfW, rdi, rsi, .MsgErr_mask2, szPLUGIN_NAME_W, r10
	test	rax, rax
	jle	.no_winapi
	sub	rsi, rax
	shl	rax, 1
	add	rdi, rax
	.no_winapi:

	mov	r10, [.processed_object]
	test	r10, r10
	jz	.no_object
	test	rsi, rsi
	jle	.no_object
	cinvoke	wnsprintfW, rdi, rsi, .MsgErr_mask1, szPLUGIN_NAME_W, [msg_MsgErr_object], r10
	test	rax, rax
	jle	.no_object
	sub	rsi, rax
	shl	rax, 1
	add	rdi, rax
	.no_object:

	mov	r10, [.infotext]
	test	r10, r10
	jz	.mode_error
	test	rsi, rsi
	jle	.overbuffer
	cinvoke	wnsprintfW, rdi, rsi, .MsgErr_mask5, szPLUGIN_NAME_W, r10
	jmp	.message_ok

	.mode_error:
	test	rsi, rsi
	jle	.overbuffer
	lea	r12, [buffer_text_error]

	invoke	FormatMessageW, FORMAT_MESSAGE_IGNORE_INSERTS or FORMAT_MESSAGE_FROM_SYSTEM, 0, rbx, 0, r12, ((sizeof.buffer_text_error)/2), 0

	test	rax, rax
	jle	.no_message
	cinvoke	wnsprintfW, rdi, rsi, .MsgErr_mask3, szPLUGIN_NAME_W, [msg_MsgErr_err], rbx, r12
	jmp	.message_ok
	.no_message:
	cinvoke	wnsprintfW, rdi, rsi, .MsgErr_mask4, szPLUGIN_NAME_W, [msg_MsgErr_err], rbx
	.message_ok:
	.overbuffer:

	lea	rsi, [buffer_text_result]
	lea	rdi, [buffer_text_utf8]
	mov	dword [rdi], 0
	invoke	WideCharToMultiByte, CP_UTF8, 0, rsi, -1, rdi, sizeof.buffer_text_utf8, 0, 0

	cinvoke	GuiAddLogMessage, rdi
endf
	pop	r12
	pop	rsi
	pop	rdi
	pop	rbx
	ret

.MsgErr_mask1 du "[%s] %s: %s",13,10,0
.MsgErr_mask2 du "[%s] WinAPI: %s",13,10,0
.MsgErr_mask3 du "[%s] %s: %d - %s",13,10,0
.MsgErr_mask4 du "[%s] %s: %d",13,10,0
.MsgErr_mask5 du "[%s] %s",13,10,0
endp


proc LogPrint8, .text1
locals
 text_buff8 sized db 3000 dup (?)
endl
frame
	mov	r10, rcx ; [.text1]
	lea	rcx, [text_buff8]
	cinvoke	wnsprintfA, rcx, sizeof.text_buff8, .mask1, szPLUGIN_NAME_A, r10
	lea	rcx, [text_buff8]
	cinvoke	GuiAddLogMessage, rcx
endf
	ret
.mask1 db "[%s] %s",13,10,0
endp


proc LogPrintW, .text1
locals
 text_buff8 sized db 3000 dup (?)
endl
	push	rdi
	push	r12
frame
	lea	rdi, [text_buff8]
	mov	word [rdi], 0
	mov	r8, rcx ; [.text1]
	invoke	WideCharToMultiByte, CP_UTF8, 0, r8, -1, rdi, sizeof.text_buff8, 0, 0
	stdcall	LogPrint8, rdi
endf
	pop	r12
	pop	rdi
	ret
endp


proc convert_8bit_to_utf8, .in_text, .in_size, .out_text, .out_max_size
locals
 text_buffW sized dw MAX_COMMENT_SIZE+100 dup (?)
endl
	push	rbx
	push	r12
	push	r13
	push	r14
frame
	mov	r12, r8 ; .out_text
	mov	r13, r9 ; .out_max_size
	mov	r8, rcx ; .in_text
	mov	r9, rdx ; .in_size
	lea	rbx, [text_buffW]
	invoke	MultiByteToWideChar, [config_sources_codepage], 0, r8, r9, rbx, (sizeof.text_buffW)/2
	test	rax, rax
	jz	.m0
	mov	word [rbx+(rax*2)], 0
	invoke	WideCharToMultiByte, CP_UTF8, 0, rbx, -1, r12, r13, 0, 0
	test	rax, rax
	jz	.m0
.m1:
endf
	pop	r14
	pop	r13
	pop	r12
	pop	rbx
	ret

.m0:

	mov	dword [r12], 0x525245 ; "ERR",0
	xor	eax, eax
	jmp	.m1
endp


proc LoadFasFile, .fasfilename, .flag_force_OFN
locals
 ofn OPENFILENAME
 text_buffer sized dw MAX_PATH+300 dup (?)
endl

	push	rbx
	push	rsi
	push	rdi
	push	r12
frame
	mov	r12, rcx ; [.fasfilename]
	mov	[.flag_force_OFN], rdx

	lea	rdi, [ofn]
	mov	rsi, rdi
	cld
	xor	eax, eax
	mov	ecx, sizeof.OPENFILENAME/4
	rep	stosd

	mov	rax, [hwndDlg]
	mov	[ofn.hwndOwner], rax
	mov	[ofn.lStructSize], sizeof.OPENFILENAME

	mov	word [text_buffer], 0
	lea	rdi, [text_buffer]
	mov	[ofn.lpstrFilter], rdi
	mov	ebx, ((sizeof.text_buffer)/2)-10
	invoke	lstrcpynW, rdi, [msg_openfilename_ext_fas], rbx
	invoke	lstrlenW, rdi
	inc	eax ; skip null
	shl	eax, 1 ; wchar
	sub	ebx, eax
	jbe	.end_buff
	add	rdi, rax
	invoke	lstrcpynW, rdi, .ofn_read_ext_mask_fas, rbx
	invoke	lstrlenW, rdi
	inc	eax
	shl	eax, 1
	sub	ebx, eax
	jbe	.end_buff
	add	rdi, rax
	invoke	lstrcpynW, rdi, [msg_openfilename_ext_all], rbx
	invoke	lstrlenW, rdi
	inc	eax
	shl	eax, 1
	sub	ebx, eax
	jbe	.end_buff
	add	rdi, rax
	invoke	lstrcpynW, rdi, .ofn_read_ext_mask_all, rbx
	invoke	lstrlenW, rdi
	inc	eax
	shl	eax, 1
	sub	ebx, eax
	jbe	.end_buff
	add	rdi, rax
	xor	eax, eax
	stosd
	jmp	.buff_ok
.end_buff:
	xor	eax, eax
	jmp	.exit_EAX
.buff_ok:


	mov	[ofn.lpstrFile], r12 ; .fasfilename
	mov	[ofn.nMaxFile], MAX_PATH
	mov	[ofn.lpstrFileTitle], 0
	mov	rax, [msg_openfilename_title]
	mov	[ofn.lpstrTitle], rax
	mov	[ofn.Flags], OFN_FILEMUSTEXIST or OFN_PATHMUSTEXIST or OFN_HIDEREADONLY or OFN_EXPLORER
	mov	[ofn.lpTemplateName], 0
	mov	[ofn.lpstrDefExt], .ofn_read_FAS_type

	cmp	[.flag_force_OFN], 0
	jne	.force_OFN

	stdcall	is_file_exists, r12
	test	rax, rax
	jnz	.easy_load

.force_OFN:
	invoke	GetOpenFileNameW, rsi
	test	rax, rax
	jz	.exit_EAX

.easy_load:
	stdcall	load_file_to_mem, r12, -1
	test	rax, rax
	jz	.exit_EAX
	mov	[pFasFile], rax
	mov	[szFasFile], rdx
	mov	[timeFasFile], rcx

	lea	rcx, [text_buffer]
	cinvoke	wnsprintfW, rcx, (sizeof.text_buffer)/2, [msg_opened_symbol_file_S], r12
	lea	rcx, [text_buffer]
	stdcall	LogPrintW, rcx

	xor	eax, eax
	inc	eax

.exit_EAX:
endf
	pop	r12
	pop	rdi
	pop	rsi
	pop	rbx
	ret

.ofn_read_FAS_type du "fas",0
.ofn_read_ext_mask_fas du "*.fas",0
.ofn_read_ext_mask_all du "*",0
endp;LoadFasFile



proc prepare_fas_file
	push	rsi
	push	rbx

;	stdcall	LogPrintW, .t_prepare_fas_file

	mov	rsi, [pFasFile]
	mov	rcx, [szFasFile]
	cmp	rcx, 0x40 ; minimum size FAS Table 1 Header
	jb	.err_head

	cmp	[rsi+fheader.signature], 0x1A736166 ;
	jne	.err_head

	movzx	rax, [rsi+fheader.length_header]
	cmp	rax, 0x40
	jb	.err_head
	cmp	rax, rcx
	jae	.err_head

	mov	eax, [rsi+fheader.offset_string_table]
	mov	edx, [rsi+fheader.length_string_table]
	call	.check_range ; rcx!
	jc	.err_head
	add	rax, rsi
	mov	[address_string_table], rax

	mov	eax, [rsi+fheader.offset_symbol_table]
	mov	edx, [rsi+fheader.length_symbol_table]
	call	.check_range ; rcx!
	jc	.err_head
	add	rax, rsi
	mov	[address_symbol_table], rax
	add	rax, rdx
	mov	[endOf_symbol_table], rax

	mov	eax, [rsi+fheader.offset_preprocessed_source]
	mov	edx, [rsi+fheader.length_preprocessed_source]
	call	.check_range ; rcx!
	jc	.err_head
	add	rax, rsi
	mov	[address_preprocessed_source], rax
	add	rax, rdx
	mov	[endOf_preprocessed_source], rax

	mov	eax, [rsi+fheader.offset_assembly_dump]
	mov	edx, [rsi+fheader.length_assembly_dump]
	test	edx, edx
	jz	.err_no_dump
	call	.check_range ; rcx!
	jc	.err_head
	add	rax, rsi
	mov	[address_assembly_dump], rax
	add	rax, rdx
	sub	rax, 4
	mov	eax, [rax]
	mov	[size_exe_by_fas], rax

	mov	eax, [rsi+fheader.offset_section_table]
	mov	edx, [rsi+fheader.length_section_table]
	call	.check_range ; rcx!
	jc	.err_head
	add	rax, rsi
	mov	[address_section_table], rax

	mov	eax, [rsi+fheader.offset_symbol_ref]
	mov	edx, [rsi+fheader.length_symbol_ref]
	call	.check_range ; rcx!
	jc	.err_head
	add	rax, rsi
	mov	[address_symbol_ref], rax
	add	rax, rdx
	mov	[endOf_symbol_ref], rax

	mov	rax, [address_string_table]
	mov	edx, [rsi+fheader.offset_input_file_name]
	add	rax, rdx
	mov	[address_input_file_name], rax
	mov	rax, [address_string_table]
	mov	edx, [rsi+fheader.offset_output_file_name]
	add	rax, rdx
	mov	[address_output_file_name], rax

;	stdcall	LogPrintW, .t_prepare_fas_file

	mov	eax, 1
.pff_exit:

	pop	rbx
	pop	rsi
	ret

.err_no_dump:
	stdcall	LogErrW, .t_prepare_fas_file, 0, 0, [msg_no_asm_dump] ; .checkpoint_name, .winapi_name, .processed_object, .infotext
	xor	eax, eax
	jmp	.pff_exit

.err_head:
	stdcall	LogErrW, .t_prepare_fas_file, 0, 0, [msg_invalid_fas_header] ; .checkpoint_name, .winapi_name, .processed_object, .infotext
	xor	eax, eax
	jmp	.pff_exit

; size check - ecx total array size, eax offset, edx data size
; NC - OK, C - error
.check_range:
	mov	rbx, rax
	cmp	rax, rcx
	ja	.ChkRange_err
	test	rdx, rdx
	jz	.ChkRange_ok
	add	rax, rdx
	jc	.ChkRange_err
	cmp	rax, rcx
	ja	.ChkRange_err
.ChkRange_ok:
	mov	rax, rbx
	clc
	retn
.ChkRange_err:
	mov	rax, rbx
	stc
	retn

.t_prepare_fas_file du "prepare_fas_file",0
endp



proc escaping_string_utf8, .in_text, .out_text, .out_max_size
	push	rsi
	push	rdi

	mov	rsi, rcx ; [.in_text]
	mov	rdi, rdx ; [.out_text]
	mov	rcx, r8 ; [.out_max_size]
	cld

; Escaping strings for x64dbg:
; if there is 0x7B in string, then all 0x7B and 0x7D (even the previous 0x7D) must be escaped.
; if there is no 0x7B in string, then there is no need to escape anything.

	mov	r9, rsi
	xor	edx, edx ; found '{' status
.loop_find_7B:
	lodsb
	cmp	al, '{'
	je	.found_7B
	test	al, al
	jne	.loop_find_7B
	jmp	.no_esc_mode
.found_7B:
	inc	edx ; found '{' status
.no_esc_mode:
	mov	rsi, r9 ; [.in_text]


.loop_esc_char:
	lodsb
	cmp	al, '{'
	jne	.norm1
	cmp	ecx, 3
	jb	.EOL
	stosb
	stosb
	sub	ecx, 2
	jmp	.loop_esc_char

.norm1:	cmp	al, '}'
	jne	.norm2
	test	edx, edx ; found '{' status
	jz	.norm2
	cmp	ecx, 3
	jb	.EOL
	stosb
	stosb
	sub	ecx, 2
	jmp	.loop_esc_char

.norm2:	cmp	ecx, 1
	je	.EOL
	stosb
	dec	ecx
	test	al, al
	jz	.end
	jmp	.loop_esc_char

.EOL:	xor	eax, eax
	stosb

.end:	pop	rdi
	pop	rsi
	ret
endp
