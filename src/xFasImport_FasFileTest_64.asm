
proc RunFasFileTestDlg
frame
	mov	word [buffFasFileName], 0
	stdcall	LoadFasFile, buffFasFileName, 1 ; set pFasFile
	test	rax, rax
	jz	.m0

	stdcall	prepare_fas_file ; check fas-file and set offsets in memory
	test	rax, rax
	jz	.m0

	stdcall	set_basepath ; setting the base path (for relative links in fas-file (buffFasFileName) to asm-files)

	stdcall	init_FasFileTest_list
	test	rax, rax
	jz	.m0

	stdcall	import_fft_data

	invoke	DialogBoxParamA, [hInstance], ID_DLG_FASFILETEST, [hwndDlg], DialogProcFasFileTest, 0

	stdcall	kill_FasFileTest_list

.m0:
endf
	ret
endp



proc DialogProcFasFileTest, .hWnd, .uMsg, .wParam, .lParam
locals
 lvi LV_ITEM
endl
	mov	[.hWnd], rcx
	push	rbx
	push	rsi
	cmp	rdx, WM_COMMAND
	je	.wp_cmd
	cmp	rdx, WM_CLOSE
	je	.fft_close
	cmp	rdx, WM_NOTIFY
	je	.wp_notify
	cmp	rdx, WM_INITDIALOG
	je	.wp_init
.wp_end:
	pop	rsi
	pop	rbx
	xor	eax, eax
	ret

.wp_cmd:

	cmp	r8, dlg_FasFileTest_close
	je	.fft_close
	jmp	.wp_end

.fft_close:
	invoke	EndDialog, [.hWnd], -1
	jmp	.wp_end

.wp_notify:
	cmp	r8, dlg_FasFileTest_list
	jne	.wp_end

	cmp	[r9+NM_LISTVIEW.hdr.code], LVN_COLUMNCLICK
	je	.sort
	jmp	.wp_end

.sort:
	mov	esi, [r9+NM_LISTVIEW.iSubItem]
	invoke	SendMessageW, [hListViewFFT], LVM_GETITEMCOUNT, 0, 0
	test	rax, rax
	jz	.wp_end

	lea	rax, [sort_directions_fft+rsi]
	mov	bl, [rax]
	cmp	bl, 1
	je	.s2
	mov	bl, 1
	jmp	.s3
.s2:	mov	bl, 2
.s3:	mov	byte [rax], bl

	invoke	SendMessageW, [hListViewFFT], LVM_SORTITEMSEX, rsi, SortCompareFuncFFT
	jmp	.wp_end

.wp_init:
frame
	invoke	SetWindowTextW, [.hWnd], [title_dlg_FasFileTest]
	stdcall	set_lng_dialog, [.hWnd], table_lang_dlg_FasFileTest
	invoke	GetDlgItem, [.hWnd], dlg_FasFileTest_list
	mov	[hListViewFFT], rax
	stdcall	init_listview_fft
endf
	cmp	[item_fft_list_helper], -1
	je	.wp_end
	invoke	SendMessageW, [hListViewFFT], LVM_ENSUREVISIBLE, [item_fft_list_helper], 0
	jmp	.wp_end
endp


proc init_listview_fft
locals
 text_buffer sized dw 50 dup (?)
 lvc LV_COLUMN
 lvi LV_ITEM
endl
	push	rsi
	push	rdi
	push	rbx
	push	r12 ; stack align
frame
	mov	dword [sort_directions_fft], 0

	mov	rbx, [hListViewFFT]

	lea	rdi, [lvc]
	mov	[lvc.mask], LVCF_FMT or LVCF_TEXT or LVCF_WIDTH
	mov	[lvc.fmt], LVCFMT_LEFT
	mov	[lvc.cx], 130
	mov	rax, [dlg_FasFileTest_listview_data]
	mov	[lvc.pszText], rax
	invoke	SendMessageW, rbx, LVM_INSERTCOLUMNW, 1, rdi
	mov	[lvc.cx], 330
	mov	rax, [dlg_FasFileTest_listview_filepath]
	mov	[lvc.pszText], rax
	invoke	SendMessageW, rbx, LVM_INSERTCOLUMNW, 2, rdi
	mov	[lvc.cx], 150
	mov	rax, [dlg_FasFileTest_listview_filetime]
	mov	[lvc.pszText], rax
	invoke	SendMessageW, rbx, LVM_INSERTCOLUMNW, 3, rdi
	mov	[lvc.cx], 230
	mov	rax, [dlg_FasFileTest_listview_status]
	mov	[lvc.pszText], rax
	invoke	SendMessageW, rbx, LVM_INSERTCOLUMNW, 4, rdi
	invoke	SendMessageW, rbx, LVM_SETEXTENDEDLISTVIEWSTYLE, 0, LVS_EX_FULLROWSELECT or LVS_EX_GRIDLINES
	; the number of columns must match the number of bytes in sort_directions

	cmp	[hFftList], 0
	je	.skip_list
	invoke	LocalLock, [hFftList]
	mov	rbx, rax
	lea	rdi, [lvi]
	mov	[lvi.iItem], 0
	

.list_loop:
	mov	eax, [lvi.iItem]
	cmp	rax, [itemsFftList]
	jae	.exit_loop

	mov	rsi, rbx
	mov	ecx, sizeof.X_FFT_LIST
	mul	rcx
	add	rsi, rax

	mov	[lvi.mask], LVIF_TEXT
	lea	rax, [rsi+X_FFT_LIST.data_fas]
	mov	[lvi.pszText], rax
	mov	[lvi.iSubItem], 0
	invoke	SendMessageW, [hListViewFFT], LVM_INSERTITEMW, 0, rdi

	lea	rax, [rsi+X_FFT_LIST.image]
	mov	[lvi.pszText], rax
	mov	[lvi.iSubItem], 1
	invoke	SendMessageW, [hListViewFFT], LVM_SETITEMW, 0, rdi

	lea	rax, [rsi+X_FFT_LIST.time]
	mov	[lvi.pszText], rax
	mov	[lvi.iSubItem], 2
	invoke	SendMessageW, [hListViewFFT], LVM_SETITEMW, 0, rdi

	lea	rax, [rsi+X_FFT_LIST.status_text]
	mov	[lvi.pszText], rax
	mov	[lvi.iSubItem], 3
	invoke	SendMessageW, [hListViewFFT], LVM_SETITEMW, 0, rdi
	
	inc	[lvi.iItem]
	jmp	.list_loop
	
.exit_loop:
	invoke	LocalUnlock, [hFftList]

.skip_list:
endf
	pop	r12
	pop	rbx
	pop	rdi
	pop	rsi
	ret

.t_maskBase du "0x%08X",0
.t_maskSize du "0x%08X",0
endp


struct X_FFT_LIST
 data_fas rw MAX_PATH
 image rw MAX_PATH
 time rw 100
 status_text rw 300
ends



proc init_FasFileTest_list
frame
	mov	[itemsFftList], 0
	mov	[item_fft_list_helper], -1
	invoke	LocalAlloc, LMEM_MOVEABLE or LMEM_ZEROINIT, 16
	mov	[hFftList], rax
	test	rax, rax
	jnz	.ok
	stdcall	LogErrW, .t_init_fft_list, .t_err_LocalAlloc, 0, 0 ; .checkpoint_name, .winapi_name, .processed_object, .infotext
	xor	eax, eax
	ret
	.ok:
endf
	mov	eax, 1
	ret
.t_init_fft_list du "init_FasFileTest_list",0
.t_err_LocalAlloc du "LocalAlloc",0
endp

proc kill_FasFileTest_list
	cmp	[hFftList], 0
	je	.m0
	invoke	LocalFree, [hFftList]
.m0:	mov	[hFftList], 0
	mov	[itemsFftList], 0
	ret
endp


proc append_to_fft_list, .filename
locals
 filenameW_buffer sized dw MAX_PATH+8 dup (?)
 fullfilenameW_buffer sized dw MAX_PATH+8 dup (?)
 ftime FILETIME
 sys_time SYSTEMTIME
 loc_time SYSTEMTIME
 buffer_text_error sized dw 1500 dup (?)
 buffer_text_result sized dw 2500 dup (?)
 flag_skip db ?
 flag_fas db ?
endl

	push	rsi
	push	rdi
	push	rbx
	push	r12 ; stack align

	mov	[flag_skip], 0
	mov	[flag_fas], 0

	cmp	[hFftList], 0
	je	.m0

	mov	rdi, rcx ; [.filename]
	test	rdi, rdi
	jz	.get_default_filename
	cmp	rdi, -1
	je	.get_output_file
	cmp	rdi, -2
	je	.get_fas_file
	add	rdi, [address_preprocessed_source]
	jmp	.filename_ok
.get_fas_file:
	mov	[flag_fas], 1
	jmp	.fas_skip1
.get_output_file:
	mov	rdi, [address_output_file_name]
	jmp	.filename_ok
.get_default_filename:
	mov	rdi, [address_input_file_name]
.filename_ok:

	lea	rsi, [filenameW_buffer]
	invoke	MultiByteToWideChar, CP_ACP, 0, rdi, -1, rsi, MAX_PATH
	test	rax, rax
	jz	.m0

.fas_skip1:

	mov	rax, [itemsFftList]
	inc	rax
	mov	ecx, sizeof.X_FFT_LIST
	mul	rcx

	invoke	LocalReAlloc, [hFftList], rax, LMEM_MOVEABLE or LMEM_ZEROINIT
	test	rax, rax
	jnz	.m8
	stdcall	LogErrW, .t_append_to_fft_list, .t_LocalReAlloc, 0, 0 ; .checkpoint_name, .winapi_name, .processed_object, .infotext
	invoke	LocalFree, [hFftList]
	mov	[hFftList], 0
	jmp	.m0
	.m8:
	mov	[hFftList], rax

	mov	eax, sizeof.X_FFT_LIST
	mul	[itemsFftList]
	mov	rdi, rax
	invoke	LocalLock, [hFftList]
	add	rdi, rax

	cmp	[flag_fas], 0
	jz	.no_fas
	mov	word [rdi+X_FFT_LIST.data_fas], 0
	lea	rcx, [rdi+X_FFT_LIST.image]
	lea	rdx, [buffFasFileName]
	invoke	lstrcpynW, rcx, rdx, MAX_PATH
	jmp	.fas_skip2
.no_fas:

	call	.is_duplicate ; in: esi - string, eax - memory
	test	rax, rax
	setnz	[flag_skip]
	jnz	.skip_item

	lea	rcx, [rdi+X_FFT_LIST.data_fas]
	invoke	lstrcpynW, rcx, rsi, MAX_PATH
	
	invoke	PathIsRelativeW, rsi
	test	rax, rax
	jnz	.m1
	mov	rdx, rsi
	jmp	.m2
.m1:
	lea	rcx, [fullfilenameW_buffer]
	cinvoke	wnsprintfW, rcx, MAX_PATH, .mask_S_S, buffBasePath, rsi
	lea	rdx, [fullfilenameW_buffer]
.m2:
	lea	rcx, [rdi+X_FFT_LIST.image]
	invoke	lstrcpynW, rcx, rdx, MAX_PATH

.fas_skip2:
	mov	word [rdi+X_FFT_LIST.time], 0
	lea	rsi, [rdi+X_FFT_LIST.image]
	invoke	CreateFileW, rsi, GENERIC_READ, FILE_SHARE_READ or FILE_SHARE_WRITE or FILE_SHARE_DELETE, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
	cmp	rax, INVALID_HANDLE_VALUE
	jne	.cr_OK

	call	.set_status_error
	lea	rcx, [rdi+X_FFT_LIST.status_text]
	lea	rdx, [buffer_text_result]
	invoke	lstrcpynW, rcx, rdx, 300 ; !!! size
	mov	word [rdi+X_FFT_LIST.time], 0
	mov	rax, [itemsFftList]
	mov	[item_fft_list_helper], rax
	jmp	.skip_item
.cr_OK:	mov	rbx, rax ; hFile

	lea	rsi, [ftime]
	mov	[rsi+FILETIME.dwLowDateTime], 0
	mov	[rsi+FILETIME.dwHighDateTime], 0
	invoke	GetFileTime, rbx, 0, 0, rsi
	invoke	CloseHandle, rbx
	lea	rbx, [sys_time]
	invoke	FileTimeToSystemTime, rsi, rbx
	lea	r8, [loc_time]
	invoke	SystemTimeToTzSpecificLocalTime, 0, rbx, r8

	mov	rbx, rsp
	movzx	eax, [loc_time.wMilliseconds]
	push	rax
	movzx	eax, [loc_time.wSecond]
	push	rax
	movzx	eax, [loc_time.wMinute]
	push	rax
	movzx	eax, [loc_time.wHour]
	push	rax
	movzx	eax, [loc_time.wDay]
	push	rax
	movzx	eax, [loc_time.wMonth]
	push	rax
	movzx	eax, [loc_time.wYear]
;	push	rax
	lea	rcx, [rdi+X_FFT_LIST.time]
	cinvoke	wnsprintfW, rcx, 100, .mask_time, rax
	mov	rsp, rbx

	lea	rax, [ftime]
	stdcall	convert_FILETIME_to_code, rax
	mov	rcx, rax
	mov	rax, [timeFasFile] ; file must be written before FAS-file.
	cmp	rax, rcx
	jae	.time_ok
	mov	rax, [itemsFftList]
	mov	[item_fft_list_helper], rax
	mov	rdx, [msg_FasFileTest_listview_status_time]
	jmp	.status_end		
.time_ok:
	mov	rdx, [msg_FasFileTest_listview_status_ok]
.status_end:
	lea	rcx, [rdi+X_FFT_LIST.status_text]
	invoke	lstrcpynW, rcx, rdx, 300 ; !!! size	

.skip_item:
	invoke	LocalUnlock, [hFftList]
	
	cmp	[flag_skip], 0
	jnz	.m0
	inc	[itemsFftList]

.m0:
	
	pop	r12
	pop	rbx
	pop	rdi
	pop	rsi
	ret

.set_status_error:
	push	rbx
	push	rsi
	push	rdi
	invoke	GetLastError
	mov	rbx, rax

	lea	rdi, [buffer_text_result]	
	lea	rsi, [buffer_text_error]
	invoke	FormatMessageW, FORMAT_MESSAGE_IGNORE_INSERTS or FORMAT_MESSAGE_FROM_SYSTEM, 0, rbx, 0, rsi, (sizeof.buffer_text_error)/2, 0
	test	rax, rax
	jz	.no_err_msg
	cinvoke	wnsprintfW, rdi, (sizeof.buffer_text_result)/2, .MsgErr_mask3, [msg_MsgErr_err], rbx, rsi
	jmp	.err_msg_ok
	.no_err_msg:
	cinvoke	wnsprintfW, rdi, (sizeof.buffer_text_result)/2, .MsgErr_mask4, [msg_MsgErr_err], rbx
	.err_msg_ok:

	pop	rdi
	pop	rsi
	pop	rbx
	retn



.is_duplicate: ; esi - string, eax - memory
	push	rsi
	push	rdi
	push	rbx
	xor	ebx, ebx
	mov	rdi, rax

.id_loop:
	cmp	rbx, [itemsFftList]
	jae	.id0

	mov	eax, sizeof.X_FFT_LIST
	mul	rbx
	add	rax, rdi
	
	invoke	lstrcmpiW, rax, rsi
	test	rax, rax
	jz	.id1
	inc	rbx
	jmp	.id_loop
	
.id0:	xor	eax, eax
	jmp	.id_exit
.id1:	mov	eax, 1
.id_exit:

	pop	rbx
	pop	rdi
	pop	rsi
	retn

.MsgErr_mask3 du "%s: %d - %s",0
.MsgErr_mask4 du "%s: %d",0
.mask_S_S du "%s\%s",0
.mask_time du "%04u.%02u.%02u %02u:%02u:%02u.%03u",0
.t_append_to_fft_list du "append_to_fft_list",0
.t_LocalReAlloc du "LocalReAlloc",0
endp


proc SortCompareFuncFFT, lParam1, lParam2, lParamSort
locals
 lvi_sort LV_ITEM
 tSort1 dw MAX_PATH dup (?)
 tSort2 dw MAX_PATH dup (?)
endl
	push	rsi
	push	rdi
	push	rbx
	push	r12
frame
	mov	[lvi_sort.mask], LVIF_TEXT
	mov	[lvi_sort.cchTextMax], MAX_PATH


	mov	[lvi_sort.iSubItem], r8d ; [lParamSort] - number of column by which sort is called

	mov	rsi, rcx ; [lParam1]
	mov	rdi, rdx ; [lParam2]
	cmp	byte [sort_directions_fft+rax], 1
	jne	@f
	xchg	rsi, rdi
@@:

	lea	rbx, [lvi_sort]
	lea	rcx, [tSort1]
	mov	[lvi_sort.pszText], rcx
	invoke	SendMessageW, [hListViewFFT], LVM_GETITEMTEXTW, rsi, rbx
	lea	rcx, [tSort2]
	mov	[lvi_sort.pszText], rcx
	invoke	SendMessageW, [hListViewFFT], LVM_GETITEMTEXTW, rdi, rbx

	lea	rcx, [tSort1]
	lea	rdx, [tSort2]
	invoke lstrcmpW, rcx, rdx
endf
	pop	r12
	pop	rbx
	pop	rdi
	pop	rsi
	ret
endp




proc import_fft_data
	push	rsi
	push	rdi
frame
	stdcall	append_to_fft_list, -2 ; append fas file to list
	stdcall	append_to_fft_list, -1 ; append output (exe/dll) file to list

	mov	rsi, [address_preprocessed_source]

	; ESI - real address of preprocessed source.

.main_loop:
	cmp	rsi, [endOf_preprocessed_source] ; ESI = real addr of preprocessed source.
	jae	.end_main_loop

	test	byte [rsi+preprocessed_line.number_line+3], 0x80 ; If bit31=0 = line was loaded from source, If bit31=1 = line was generated by macroinstruction.
	jnz	.skip_line ; line by macroinstruction

	mov	edi, [rsi+preprocessed_line.offset_file_name]
	stdcall	append_to_fft_list, rdi
	
.skip_line:
	stdcall	get_next_preprocessed_source_item, rsi
	mov	rsi, rax
	cmp	rsi, [endOf_preprocessed_source]
	jae	.end_main_loop

	test	byte [rsi+preprocessed_line.number_line+3], 0x80 ; If highest bit 0 = line loaded from source. If highest bit 1 = line generated by macroinstruction.
	jnz	.skip_line ; JMP - line by macroinstruction

	cmp	edi, [rsi+preprocessed_line.offset_file_name] ; cmp with the previous item
	je	.skip_line
	jmp	.main_loop

.end_main_loop:

	xor	eax, eax
	inc	eax
endf
	pop	rdi
	pop	rsi
	ret
endp

