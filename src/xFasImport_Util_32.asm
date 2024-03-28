

proc delete_old_labels
locals
 text_buffer sized dw 300 dup (?)
endl
	push	esi
	push	edi

	cmp	[config_delete_old_labels], 0
	je	.skip_delete_labels

	mov	ecx, [current_base_addr]
	mov	edx, [original_SizeOfImage]
	add	edx, ecx
	dec	edx
	mov	edi, edx

	lea	esi, [.t_mask_auto]
	cmp	[config_flag_labels_manual], 0
	je	.flg_A
	lea	esi, [.t_mask_manual]
	cinvoke	DbgClearLabelRange, ecx, edx
	jmp	.result
.flg_A:	cinvoke	DbgClearAutoLabelRange, ecx, edx

.result:
	lea	ecx, [text_buffer]
	cinvoke	wnsprintfW, ecx, (sizeof.text_buffer)/2, esi, [current_base_addr], edi
	lea	ecx, [text_buffer]
	stdcall	LogPrintW, ecx

.skip_delete_labels:

	pop	edi
	pop	esi
	ret
.t_mask_manual: du "DbgClearLabelRange: start 0x%08X, end 0x%08X",0
.t_mask_auto: du "DbgClearAutoLabelRange: start 0x%08X, end 0x%08X",0
endp

proc delete_old_comments
locals
 text_buffer sized dw MAX_PATH+200 dup (?)
endl
	push	esi
	push	edi

	cmp	[config_delete_old_comments], 0
	je	.skip_delete_comments

	mov	ecx, [current_base_addr]
	mov	edx, [original_SizeOfImage]
	add	edx, ecx
	dec	edx
	mov	edi, edx

	lea	esi, [.t_mask_auto]
	cmp	[config_flag_comments_manual], 0
	je	.flg_A
	lea	esi, [.t_mask_manual]
	cinvoke	DbgClearCommentRange, ecx, edx
	jmp	.result
.flg_A:	cinvoke	DbgClearAutoCommentRange, ecx, edx

.result:
	lea	ecx, [text_buffer]
	cinvoke	wnsprintfW, ecx, (sizeof.text_buffer)/2, esi, [current_base_addr], edi
	lea	ecx, [text_buffer]
	stdcall	LogPrintW, ecx

.skip_delete_comments:

	pop	edi
	pop	esi
	ret
.t_mask_manual: du "DbgClearCommentRange: start 0x%08X, end 0x%08X",0
.t_mask_auto: du "DbgClearAutoCommentRange: start 0x%08X, end 0x%08X",0
endp


proc set_buffFasFileName, .image_file


	invoke	lstrcpynW, buffFasFileName, [.image_file], MAX_PATH
	invoke	PathRenameExtensionW, buffFasFileName, .t_fas

	ret
.t_fas du ".fas",0
endp


proc set_basepath

	invoke	lstrcpynW, buffBasePath, buffFasFileName, MAX_PATH
	invoke	PathRemoveFileSpecW, buffBasePath

	ret
endp



proc load_basepath_fileA_to_mem, .filenameA ; return - eax hMemory, edx size, ecx timecode. eax=0 - error
locals
 filenameW sized dw MAX_PATH dup (?)
 fullfilenameW sized dw MAX_PATH dup (?)
endl
	push	esi
	push	edi


	lea	edi, [filenameW]
	mov	word [edi], 0
	invoke	MultiByteToWideChar, CP_ACP, 0, [.filenameA], -1, edi, MAX_PATH
	invoke	PathIsRelativeW, edi
	test	eax, eax
	jnz	.m1
	mov	esi, edi
	jmp	.m2
.m1:
	lea	esi, [fullfilenameW]
	cinvoke	wnsprintfW, esi, MAX_PATH, .mask1, buffBasePath, edi
.m2:
	stdcall	load_file_to_mem, esi, -1

	pop	edi
	pop	esi
	ret
.mask1 du "%s\%s",0
endp



proc DbgModBaseFromName_W, .image
locals
 filename8 sized dw MAX_PATH dup (?)
endl
	push	ebx



	invoke	PathFindFileNameW, [.image]
	lea	ebx, [filename8]
	invoke	WideCharToMultiByte, CP_UTF8, 0, eax, -1, ebx, sizeof.filename8, 0, 0
	cinvoke	DbgModBaseFromName, ebx
	mov	ebx, eax
	test	eax, eax
	jnz	@f
	stdcall	LogErrW, .t_DbgModBaseFromName_W, 0, [.image], .t_DbgModBaseFromName_error ; .checkpoint_name, .winapi_name, .processed_object, .infotext
	@@:
	mov	eax, ebx


	pop	ebx
	ret

.t_DbgModBaseFromName_W du "DbgModBaseFromName_W",0
.t_DbgModBaseFromName_error du "cannot get DbgModBaseFromName",0
endp



proc get_header_from_exe, .image
	push	ebx



	stdcall	load_file_to_mem, [.image], -1 ; return - eax hMemory, edx size, ecx timecode. eax=0 - error
	mov	[timeImageFile], ecx
	test	eax, eax
	jz	.m0
	mov	ebx, eax

	mov	eax, [timeFasFile] ; FAS-file must be written within a few seconds after the EXE-file.
	sub	eax, ecx
	jc	.time_err
	cmp	eax, 5
	jb	.time_ok
	.time_err:
	or	[incorrect_time_flag], 1
	.time_ok:
	mov	eax, ebx

	sub	edx, memsize ; size.INT_PTR: 32=4, 64=8
	jbe	.error_file
	add	edx, eax

	lea	ecx, [eax + IMAGE_DOS_HEADER.e_lfanew]
	cmp	ecx, edx
	jae	.error_file
	mov	ecx, [ecx]
	cmp	ecx, edx
	jae	.error_file
	add	eax, ecx

	lea	ecx, [eax + IMAGE_NT_HEADERS32.OptionalHeader.ImageBase]
	cmp	ecx, edx
	jae	.error_file
	mov	ecx, [ecx]
	mov	[original_base_addr], ecx

	mov	ecx, [eax + IMAGE_NT_HEADERS32.OptionalHeader.SizeOfImage]
	mov	[original_SizeOfImage], ecx

	lea	ecx, [eax + IMAGE_NT_HEADERS32.OptionalHeader.DataDirectory + sizeof.IMAGE_DATA_DIRECTORY*IMAGE_DIRECTORY_ENTRY_IMPORT + IMAGE_DATA_DIRECTORY.VirtualAddress]
	cmp	ecx, edx
	jae	.error_file
	mov	ecx, [ecx]
	add	ecx, [current_base_addr]
	mov	[start_import_table], ecx

	lea	eax, [eax + IMAGE_NT_HEADERS32.OptionalHeader.DataDirectory + sizeof.IMAGE_DATA_DIRECTORY*IMAGE_DIRECTORY_ENTRY_IMPORT + IMAGE_DATA_DIRECTORY.Size]
	cmp	eax, edx
	jae	.error_file
	add	ecx, [eax]

	mov	[endOf_import_table], ecx

	invoke	LocalFree, ebx

	pop	ebx
	mov	eax, 1
	ret

.error_file:
	stdcall	LogErrW, .t_get_header_from_exe, 0, [.image], [msg_err_pe_header] ; .checkpoint_name, .winapi_name, .processed_object, .infotext
	invoke	LocalFree, ebx

.m0:
	pop	ebx
	xor	eax, eax
	ret

.t_get_header_from_exe du "get_header_from_exe",0
endp



proc is_file_exists, .filename
	invoke	CreateFileW, [.filename], GENERIC_READ, FILE_SHARE_DELETE or FILE_SHARE_READ or FILE_SHARE_WRITE, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
	cmp	eax, INVALID_HANDLE_VALUE
	jne	@f
	xor	eax, eax
	ret
@@:	invoke	CloseHandle, eax
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
 pFilename dd ?
 dwTemp dd ?
 ftime FILETIME
 filename_converted sized dw MAX_PATH dup (?)
endl
	push	edi
	push	esi
	push	ebx


	mov	edi, [.filename]
	mov	eax, [.codepage]
	cmp	eax, -1
	je	.use_W
	mov	esi, edi
	lea	edi, [filename_converted]
	invoke	MultiByteToWideChar, eax, 0, esi, -1, edi, MAX_PATH
.use_W:
	mov	[pFilename], edi

;	invoke	MessageBoxW, 0, [.filename], 0, 0
	invoke	CreateFileW, [pFilename], GENERIC_READ, FILE_SHARE_READ or FILE_SHARE_WRITE or FILE_SHARE_DELETE, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
	cmp	eax, INVALID_HANDLE_VALUE
	jne	.cr_OK
	stdcall	LogErrW, .t_load_file_to_mem, .t_err_CreateFileW, [pFilename], 0 ; .checkpoint_name, .winapi_name, .processed_object, .infotext
	jmp	.load_err
.cr_OK:
	mov	ebx, eax ; hFile


	lea	esi, [dqFileSize]
	mov	dword [esi], 0
	mov	dword [esi+4], 0
	invoke	GetFileSizeEx, ebx, esi
	test	eax, eax
	jnz	.sz_OK
	stdcall	LogErrW, .t_load_file_to_mem, .t_err_GetFileSizeEx, [pFilename], 0 ; .checkpoint_name, .winapi_name, .processed_object, .infotext
	invoke	CloseHandle, ebx
	jmp	.load_err
.sz_OK:

	cmp	dword [esi+4], 0
	jne	.sz_err2
	mov	esi, [esi+0]
	test	esi, esi
	js	.sz_err2
	jnz	.sz_OK2
.sz_err2:
	invoke	CloseHandle, ebx
	stdcall	LogErrW, .t_load_file_to_mem, 0, [pFilename], [msg_invalid_filesize] ; .checkpoint_name, .winapi_name, .processed_object, .infotext
	jmp	.load_err
.sz_OK2:

	test	esi, esi
	jnz	.sz_OK3
	xor	edi, edi
	dec	esi
	jmp	.rd_OK
.sz_OK3:

	invoke	LocalAlloc, LPTR, esi
	mov	edi, eax
	test	eax, eax
	jnz	.mem_ok2
	stdcall	LogErrW, .t_load_file_to_mem, .t_err_LocalAlloc, [pFilename], 0 ; .checkpoint_name, .winapi_name, .processed_object, .infotext
	invoke	CloseHandle, ebx
	jmp	.load_err
	.mem_ok2:

	lea	edx, [dwTemp]
	invoke	ReadFile, ebx, edi, esi, edx, 0
	test	eax, eax
	jnz	.rd_OK
	stdcall	LogErrW, .t_load_file_to_mem, .t_err_ReadFile, [pFilename], 0 ; .checkpoint_name, .winapi_name, .processed_object, .infotext
	invoke	CloseHandle, ebx
	invoke	LocalFree, edi
	jmp	.load_err
.rd_OK:

	lea	edx, [ftime]
	mov	[edx+FILETIME.dwLowDateTime], 0
	mov	[edx+FILETIME.dwHighDateTime], 0
	invoke	GetFileTime, ebx, 0, 0, edx

	invoke	CloseHandle, ebx

	lea	eax, [ftime]
	stdcall	convert_FILETIME_to_code, eax
	mov	ecx, eax ; timecode

	mov	edx, esi ; szMem
	mov	eax, edi ; hMem
.load_exit:


	pop	ebx
	pop	esi
	pop	edi
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

	mov	edx, [.ftime]
	mov	eax, [edx+FILETIME.dwLowDateTime]
	mov	edx, [edx+FILETIME.dwHighDateTime]
	sub	eax, 0x5C6E0000 ; 2000-01-01 00:00:00 = filetime 129067776000000000 = 1CA 8A75 5C6E 0000
	sbb	edx, 0x01CA8A75
	jnc	@f
	xor	edx, edx
	xor	eax, eax
	@@:

	mov	ecx, 10000000 ; 100nanosec
	div	ecx
	ret
endp

proc get_time_from_file_W, .filename
locals
 LastWriteTime dq ? ; FILETIME
endl
	push	esi
	push	ebx

	invoke	CreateFileW, [.filename], GENERIC_READ, FILE_SHARE_READ or FILE_SHARE_WRITE or FILE_SHARE_DELETE, 0, OPEN_EXISTING, 0, 0
	cmp	eax, INVALID_HANDLE_VALUE
	je	.no_info
	mov	ebx, eax ; hFile
	lea	esi, [LastWriteTime]
	xor	eax, eax
	mov	dword [esi], eax
	mov	dword [esi+4], eax
	invoke	GetFileTime, ebx, eax, eax, esi
	invoke	CloseHandle, ebx

	stdcall	convert_FILETIME_to_code, esi

	jmp	.end

.no_info:
	xor	eax, eax

.end:	pop	ebx
	pop	esi
	ret
endp

proc LogErrW, .checkpoint_name, .winapi_name, .processed_object, .infotext
locals
 buffer_text_error sized dw 1500 dup (?)
 buffer_text_result sized dw 2500 dup (?)
 buffer_text_utf8 sized dw 2500 dup (?)
endl
	push	ebx
	push	edi
	push	esi







	invoke	GetLastError
	mov	ebx, eax ; error_code

	lea	edi, [buffer_text_result] ; tmp_pos
	mov	esi, (sizeof.buffer_text_result)/2 ; tmp_size

	mov	eax, [.checkpoint_name]
	test	eax, eax
	jz	.no_checkpoint
	cinvoke	wnsprintfW, edi, esi, .MsgErr_mask1, szPLUGIN_NAME_W, [msg_MsgErr_loc], eax
	test	eax, eax
	js	.no_checkpoint
	sub	esi, eax
	shl	eax, 1
	add	edi, eax
	.no_checkpoint:

	mov	eax, [.winapi_name]
	test	eax, eax
	jz	.no_winapi
	test	esi, esi
	jle	.no_winapi
;test eax, eax
;eax>0  jg
;eax>=0 jge
;eax<0  jl
;eax<=0 jle
;eax=0  jz
;eax<>0 jnz
	cinvoke	wnsprintfW, edi, esi, .MsgErr_mask2, szPLUGIN_NAME_W, eax
	test	eax, eax
	jle	.no_winapi
	sub	esi, eax
	shl	eax, 1
	add	edi, eax
	.no_winapi:

	mov	eax, [.processed_object]
	test	eax, eax
	jz	.no_object
	test	esi, esi
	jle	.no_object
	cinvoke	wnsprintfW, edi, esi, .MsgErr_mask1, szPLUGIN_NAME_W, [msg_MsgErr_object], eax
	test	eax, eax
	jle	.no_object
	sub	esi, eax
	shl	eax, 1
	add	edi, eax
	.no_object:

	mov	eax, [.infotext]
	test	eax, eax
	jz	.mode_error
	test	esi, esi
	jle	.overbuffer
	cinvoke	wnsprintfW, edi, esi, .MsgErr_mask5, szPLUGIN_NAME_W, eax
	jmp	.message_ok

	.mode_error:
	test	esi, esi
	jle	.overbuffer
	lea	eax, [buffer_text_error]
	push	eax
	invoke	FormatMessageW, FORMAT_MESSAGE_IGNORE_INSERTS or FORMAT_MESSAGE_FROM_SYSTEM, 0, ebx, 0, eax, ((sizeof.buffer_text_error)/2), 0
	pop	edx ; buffer_text_error
	test	eax, eax
	jle	.no_message
	cinvoke	wnsprintfW, edi, esi, .MsgErr_mask3, szPLUGIN_NAME_W, [msg_MsgErr_err], ebx, edx
	jmp	.message_ok
	.no_message:
	cinvoke	wnsprintfW, edi, esi, .MsgErr_mask4, szPLUGIN_NAME_W, [msg_MsgErr_err], ebx
	.message_ok:
	.overbuffer:

	lea	esi, [buffer_text_result]
	lea	edi, [buffer_text_utf8]
	mov	dword [edi], 0
	invoke	WideCharToMultiByte, CP_UTF8, 0, esi, -1, edi, sizeof.buffer_text_utf8, 0, 0

	cinvoke	GuiAddLogMessage, edi


	pop	esi
	pop	edi
	pop	ebx
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


	lea	ecx, [text_buff8]
	cinvoke	wnsprintfA, ecx, sizeof.text_buff8, .mask1, szPLUGIN_NAME_A, [.text1]
	lea	ecx, [text_buff8]
	cinvoke	GuiAddLogMessage, ecx

	ret
.mask1 db "[%s] %s",13,10,0
endp


proc LogPrintW, .text1
locals
 text_buff8 sized db 3000 dup (?)
endl
	push	edi


	lea	edi, [text_buff8]
	mov	word [edi], 0

	invoke	WideCharToMultiByte, CP_UTF8, 0, [.text1], -1, edi, sizeof.text_buff8, 0, 0
	stdcall	LogPrint8, edi


	pop	edi
	ret
endp


proc convert_8bit_to_utf8, .in_text, .in_size, .out_text, .out_max_size
locals
 text_buffW sized dw MAX_COMMENT_SIZE+100 dup (?)
endl
	push	ebx








	lea	ebx, [text_buffW]
	invoke	MultiByteToWideChar, [config_sources_codepage], 0, [.in_text], [.in_size], ebx, (sizeof.text_buffW)/2
	test	eax, eax
	jz	.m0
	mov	word [ebx+(eax*2)], 0
	invoke	WideCharToMultiByte, CP_UTF8, 0, ebx, -1, [.out_text], [.out_max_size], 0, 0
	test	eax, eax
	jz	.m0
.m1:




	pop	ebx
	ret

.m0:
	mov	ebx, [.out_text]
	mov	dword [ebx], 0x525245 ; "ERR",0
	xor	eax, eax
	jmp	.m1
endp


proc LoadFasFile, .fasfilename, .flag_force_OFN
locals
 ofn OPENFILENAME
 text_buffer sized dw MAX_PATH+300 dup (?)
endl

	push	ebx
	push	esi
	push	edi





	lea	edi, [ofn]
	mov	esi, edi
	cld
	xor	eax, eax
	mov	ecx, sizeof.OPENFILENAME/4
	rep	stosd

	mov	eax, [hwndDlg]
	mov	[ofn.hwndOwner], eax
	mov	[ofn.lStructSize], sizeof.OPENFILENAME

	mov	word [text_buffer], 0
	lea	edi, [text_buffer]
	mov	[ofn.lpstrFilter], edi
	mov	ebx, ((sizeof.text_buffer)/2)-10
	invoke	lstrcpynW, edi, [msg_openfilename_ext_fas], ebx
	invoke	lstrlenW, edi
	inc	eax ; skip null
	shl	eax, 1 ; wchar
	sub	ebx, eax
	jbe	.end_buff
	add	edi, eax
	invoke	lstrcpynW, edi, .ofn_read_ext_mask_fas, ebx
	invoke	lstrlenW, edi
	inc	eax
	shl	eax, 1
	sub	ebx, eax
	jbe	.end_buff
	add	edi, eax
	invoke	lstrcpynW, edi, [msg_openfilename_ext_all], ebx
	invoke	lstrlenW, edi
	inc	eax
	shl	eax, 1
	sub	ebx, eax
	jbe	.end_buff
	add	edi, eax
	invoke	lstrcpynW, edi, .ofn_read_ext_mask_all, ebx
	invoke	lstrlenW, edi
	inc	eax
	shl	eax, 1
	sub	ebx, eax
	jbe	.end_buff
	add	edi, eax
	xor	eax, eax
	stosd
	jmp	.buff_ok
.end_buff:
	xor	eax, eax
	jmp	.exit_EAX
.buff_ok:

	mov	eax, [.fasfilename]
	mov	[ofn.lpstrFile], eax
	mov	[ofn.nMaxFile], MAX_PATH
	mov	[ofn.lpstrFileTitle], 0
	mov	eax, [msg_openfilename_title]
	mov	[ofn.lpstrTitle], eax
	mov	[ofn.Flags], OFN_FILEMUSTEXIST or OFN_PATHMUSTEXIST or OFN_HIDEREADONLY or OFN_EXPLORER
	mov	[ofn.lpTemplateName], 0
	mov	[ofn.lpstrDefExt], .ofn_read_FAS_type

	cmp	[.flag_force_OFN], 0
	jne	.force_OFN

	stdcall	is_file_exists, [.fasfilename]
	test	eax, eax
	jnz	.easy_load

.force_OFN:
	invoke	GetOpenFileNameW, esi
	test	eax, eax
	jz	.exit_EAX

.easy_load:
	stdcall	load_file_to_mem, [.fasfilename], -1
	test	eax, eax
	jz	.exit_EAX
	mov	[pFasFile], eax
	mov	[szFasFile], edx
	mov	[timeFasFile], ecx

	lea	ecx, [text_buffer]
	cinvoke	wnsprintfW, ecx, (sizeof.text_buffer)/2, [msg_opened_symbol_file_S], [.fasfilename]
	lea	ecx, [text_buffer]
	stdcall	LogPrintW, ecx

	xor	eax, eax
	inc	eax

.exit_EAX:


	pop	edi
	pop	esi
	pop	ebx
	ret

.ofn_read_FAS_type du "fas",0
.ofn_read_ext_mask_fas du "*.fas",0
.ofn_read_ext_mask_all du "*",0
endp;LoadFasFile



proc prepare_fas_file
	push	esi
	push	ebx

;	stdcall	LogPrintW, .t_prepare_fas_file

	mov	esi, [pFasFile]
	mov	ecx, [szFasFile]
	cmp	ecx, 0x40 ; minimum size FAS Table 1 Header
	jb	.err_head

	cmp	[esi+fheader.signature], 0x1A736166 ;
	jne	.err_head

	movzx	eax, [esi+fheader.length_header]
	cmp	eax, 0x40
	jb	.err_head
	cmp	eax, ecx
	jae	.err_head

	mov	eax, [esi+fheader.offset_string_table]
	mov	edx, [esi+fheader.length_string_table]
	call	.check_range ; ecx!
	jc	.err_head
	add	eax, esi
	mov	[address_string_table], eax

	mov	eax, [esi+fheader.offset_symbol_table]
	mov	edx, [esi+fheader.length_symbol_table]
	call	.check_range ; ecx!
	jc	.err_head
	add	eax, esi
	mov	[address_symbol_table], eax
	add	eax, edx
	mov	[endOf_symbol_table], eax

	mov	eax, [esi+fheader.offset_preprocessed_source]
	mov	edx, [esi+fheader.length_preprocessed_source]
	call	.check_range ; ecx!
	jc	.err_head
	add	eax, esi
	mov	[address_preprocessed_source], eax
	add	eax, edx
	mov	[endOf_preprocessed_source], eax

	mov	eax, [esi+fheader.offset_assembly_dump]
	mov	edx, [esi+fheader.length_assembly_dump]
	test	edx, edx
	jz	.err_no_dump
	call	.check_range ; ecx!
	jc	.err_head
	add	eax, esi
	mov	[address_assembly_dump], eax
	add	eax, edx
	sub	eax, 4
	mov	eax, [eax]
	mov	[size_exe_by_fas], eax

	mov	eax, [esi+fheader.offset_section_table]
	mov	edx, [esi+fheader.length_section_table]
	call	.check_range ; ecx!
	jc	.err_head
	add	eax, esi
	mov	[address_section_table], eax

	mov	eax, [esi+fheader.offset_symbol_ref]
	mov	edx, [esi+fheader.length_symbol_ref]
	call	.check_range ; ecx!
	jc	.err_head
	add	eax, esi
	mov	[address_symbol_ref], eax
	add	eax, edx
	mov	[endOf_symbol_ref], eax

	mov	eax, [address_string_table]
	mov	edx, [esi+fheader.offset_input_file_name]
	add	eax, edx
	mov	[address_input_file_name], eax
	mov	eax, [address_string_table]
	mov	edx, [esi+fheader.offset_output_file_name]
	add	eax, edx
	mov	[address_output_file_name], eax

;	stdcall	LogPrintW, .t_prepare_fas_file

	mov	eax, 1
.pff_exit:

	pop	ebx
	pop	esi
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
	mov	ebx, eax
	cmp	eax, ecx
	ja	.ChkRange_err
	test	edx, edx
	jz	.ChkRange_ok
	add	eax, edx
	jc	.ChkRange_err
	cmp	eax, ecx
	ja	.ChkRange_err
.ChkRange_ok:
	mov	eax, ebx
	clc
	retn
.ChkRange_err:
	mov	eax, ebx
	stc
	retn

.t_prepare_fas_file du "prepare_fas_file",0
endp



proc escaping_string_utf8, .in_text, .out_text, .out_max_size
	push	esi
	push	edi

	mov	esi, [.in_text]
	mov	edi, [.out_text]
	mov	ecx, [.out_max_size]
	cld

; Escaping strings for x64dbg:
; if there is 0x7B in string, then all 0x7B and 0x7D (even the previous 0x7D) must be escaped.
; if there is no 0x7B in string, then there is no need to escape anything.


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
	mov	esi, [.in_text]


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

.end:	pop	edi
	pop	esi
	ret
endp
