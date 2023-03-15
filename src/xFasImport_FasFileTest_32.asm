
proc RunFasFileTestDlg

	mov	word [buffFasFileName], 0
	stdcall	LoadFasFile, buffFasFileName, 1 ; set pFasFile
	test	eax, eax
	jz	.m0

	stdcall	prepare_fas_file ; check fas-file and set offsets in memory
	test	eax, eax
	jz	.m0

	stdcall	set_basepath ; setting the base path (for relative links in fas-file (buffFasFileName) to asm-files)

	stdcall	init_FasFileTest_list
	test	eax, eax
	jz	.m0

	stdcall	import_fft_data

	invoke	DialogBoxParamA, [hInstance], ID_DLG_FASFILETEST, [hwndDlg], DialogProcFasFileTest, 0

	stdcall	kill_FasFileTest_list

.m0:

	ret
endp



proc DialogProcFasFileTest, .hWnd, .uMsg, .wParam, .lParam
locals
 lvi LV_ITEM
endl

	push	ebx
	push	esi
	cmp	[.uMsg], WM_COMMAND
	je	.wp_cmd
	cmp	[.uMsg], WM_CLOSE
	je	.fft_close
	cmp	[.uMsg], WM_NOTIFY
	je	.wp_notify
	cmp	[.uMsg], WM_INITDIALOG
	je	.wp_init
.wp_end:
	pop	esi
	pop	ebx
	xor	eax, eax
	ret

.wp_cmd:
	mov	eax, [.wParam]
	cmp	eax, dlg_FasFileTest_close
	je	.fft_close
	jmp	.wp_end

.fft_close:
	invoke	EndDialog, [.hWnd], -1
	jmp	.wp_end

.wp_notify:
	cmp	[.wParam], dlg_FasFileTest_list
	jne	.wp_end
	mov	eax, [.lParam]
	cmp	[eax+NM_LISTVIEW.hdr.code], LVN_COLUMNCLICK
	je	.sort
	jmp	.wp_end

.sort:
	mov	esi, [eax+NM_LISTVIEW.iSubItem]
	invoke	SendMessageW, [hListViewFFT], LVM_GETITEMCOUNT, 0, 0
	test	eax, eax
	jz	.wp_end

	lea	eax, [sort_directions_fft+esi]
	mov	bl, [eax]
	cmp	bl, 1
	je	.s2
	mov	bl, 1
	jmp	.s3
.s2:	mov	bl, 2
.s3:	mov	byte [eax], bl

	invoke	SendMessageW, [hListViewFFT], LVM_SORTITEMSEX, esi, SortCompareFuncFFT
	jmp	.wp_end

.wp_init:

	invoke	SetWindowTextW, [.hWnd], [title_dlg_FasFileTest]
	stdcall	set_lng_dialog, [.hWnd], table_lang_dlg_FasFileTest
	invoke	GetDlgItem, [.hWnd], dlg_FasFileTest_list
	mov	[hListViewFFT], eax
	stdcall	init_listview_fft

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
	push	esi
	push	edi
	push	ebx


	mov	dword [sort_directions_fft], 0

	mov	ebx, [hListViewFFT]

	lea	edi, [lvc]
	mov	[lvc.mask], LVCF_FMT or LVCF_TEXT or LVCF_WIDTH
	mov	[lvc.fmt], LVCFMT_LEFT
	mov	[lvc.cx], 130
	mov	eax, [dlg_FasFileTest_listview_data]
	mov	[lvc.pszText], eax
	invoke	SendMessageW, ebx, LVM_INSERTCOLUMNW, 1, edi
	mov	[lvc.cx], 330
	mov	eax, [dlg_FasFileTest_listview_filepath]
	mov	[lvc.pszText], eax
	invoke	SendMessageW, ebx, LVM_INSERTCOLUMNW, 2, edi
	mov	[lvc.cx], 150
	mov	eax, [dlg_FasFileTest_listview_filetime]
	mov	[lvc.pszText], eax
	invoke	SendMessageW, ebx, LVM_INSERTCOLUMNW, 3, edi
	mov	[lvc.cx], 230
	mov	eax, [dlg_FasFileTest_listview_status]
	mov	[lvc.pszText], eax
	invoke	SendMessageW, ebx, LVM_INSERTCOLUMNW, 4, edi
	invoke	SendMessageW, ebx, LVM_SETEXTENDEDLISTVIEWSTYLE, 0, LVS_EX_FULLROWSELECT or LVS_EX_GRIDLINES
	; the number of columns must match the number of bytes in sort_directions

	cmp	[hFftList], 0
	je	.skip_list
	invoke	LocalLock, [hFftList]
	mov	ebx, eax
	lea	edi, [lvi]
	mov	[lvi.iItem], 0
	

.list_loop:
	mov	eax, [lvi.iItem]
	cmp	eax, [itemsFftList]
	jae	.exit_loop

	mov	esi, ebx
	mov	ecx, sizeof.X_FFT_LIST
	mul	ecx
	add	esi, eax

	mov	[lvi.mask], LVIF_TEXT
	lea	eax, [esi+X_FFT_LIST.data_fas]
	mov	[lvi.pszText], eax
	mov	[lvi.iSubItem], 0
	invoke	SendMessageW, [hListViewFFT], LVM_INSERTITEMW, 0, edi

	lea	eax, [esi+X_FFT_LIST.image]
	mov	[lvi.pszText], eax
	mov	[lvi.iSubItem], 1
	invoke	SendMessageW, [hListViewFFT], LVM_SETITEMW, 0, edi

	lea	eax, [esi+X_FFT_LIST.time]
	mov	[lvi.pszText], eax
	mov	[lvi.iSubItem], 2
	invoke	SendMessageW, [hListViewFFT], LVM_SETITEMW, 0, edi

	lea	eax, [esi+X_FFT_LIST.status_text]
	mov	[lvi.pszText], eax
	mov	[lvi.iSubItem], 3
	invoke	SendMessageW, [hListViewFFT], LVM_SETITEMW, 0, edi
	
	inc	[lvi.iItem]
	jmp	.list_loop
	
.exit_loop:
	invoke	LocalUnlock, [hFftList]

.skip_list:


	pop	ebx
	pop	edi
	pop	esi
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

	mov	[itemsFftList], 0
	mov	[item_fft_list_helper], -1
	invoke	LocalAlloc, LMEM_MOVEABLE or LMEM_ZEROINIT, 16
	mov	[hFftList], eax
	test	eax, eax
	jnz	.ok
	stdcall	LogErrW, .t_init_fft_list, .t_err_LocalAlloc, 0, 0 ; .checkpoint_name, .winapi_name, .processed_object, .infotext
	xor	eax, eax
	ret
	.ok:

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

	push	esi
	push	edi
	push	ebx


	mov	[flag_skip], 0
	mov	[flag_fas], 0

	cmp	[hFftList], 0
	je	.m0

	mov	edi, [.filename]
	test	edi, edi
	jz	.get_default_filename
	cmp	edi, -1
	je	.get_output_file
	cmp	edi, -2
	je	.get_fas_file
	add	edi, [address_preprocessed_source]
	jmp	.filename_ok
.get_fas_file:
	mov	[flag_fas], 1
	jmp	.fas_skip1
.get_output_file:
	mov	edi, [address_output_file_name]
	jmp	.filename_ok
.get_default_filename:
	mov	edi, [address_input_file_name]
.filename_ok:

	lea	esi, [filenameW_buffer]
	invoke	MultiByteToWideChar, CP_ACP, 0, edi, -1, esi, MAX_PATH
	test	eax, eax
	jz	.m0

.fas_skip1:

	mov	eax, [itemsFftList]
	inc	eax
	mov	ecx, sizeof.X_FFT_LIST
	mul	ecx

	invoke	LocalReAlloc, [hFftList], eax, LMEM_MOVEABLE or LMEM_ZEROINIT
	test	eax, eax
	jnz	.m8
	stdcall	LogErrW, .t_append_to_fft_list, .t_LocalReAlloc, 0, 0 ; .checkpoint_name, .winapi_name, .processed_object, .infotext
	invoke	LocalFree, [hFftList]
	mov	[hFftList], 0
	jmp	.m0
	.m8:
	mov	[hFftList], eax

	mov	eax, sizeof.X_FFT_LIST
	mul	[itemsFftList]
	mov	edi, eax
	invoke	LocalLock, [hFftList]
	add	edi, eax
	
	cmp	[flag_fas], 0
	jz	.no_fas
	mov	word [edi+X_FFT_LIST.data_fas], 0
	lea	ecx, [edi+X_FFT_LIST.image]
	lea	edx, [buffFasFileName]
	invoke	lstrcpynW, ecx, edx, MAX_PATH
	jmp	.fas_skip2
.no_fas:

	call	.is_duplicate ; in: esi - string, eax - memory
	test	eax, eax
	setnz	[flag_skip]
	jnz	.skip_item

	lea	ecx, [edi+X_FFT_LIST.data_fas]
	invoke	lstrcpynW, ecx, esi, MAX_PATH
	
	invoke	PathIsRelativeW, esi
	test	eax, eax
	jnz	.m1
	mov	edx, esi
	jmp	.m2
.m1:
	lea	ecx, [fullfilenameW_buffer]
	cinvoke	wnsprintfW, ecx, MAX_PATH, .mask_S_S, buffBasePath, esi
	lea	edx, [fullfilenameW_buffer]
.m2:
	lea	ecx, [edi+X_FFT_LIST.image]
	invoke	lstrcpynW, ecx, edx, MAX_PATH

.fas_skip2:
	mov	word [edi+X_FFT_LIST.time], 0
	lea	esi, [edi+X_FFT_LIST.image]
	invoke	CreateFileW, esi, GENERIC_READ, FILE_SHARE_READ or FILE_SHARE_WRITE or FILE_SHARE_DELETE, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
	cmp	eax, INVALID_HANDLE_VALUE
	jne	.cr_OK

	call	.set_status_error
	lea	ecx, [edi+X_FFT_LIST.status_text]
	lea	edx, [buffer_text_result]
	invoke	lstrcpynW, ecx, edx, 300 ; !!! size
	mov	word [edi+X_FFT_LIST.time], 0
	mov	eax, [itemsFftList]
	mov	[item_fft_list_helper], eax
	jmp	.skip_item
.cr_OK:	mov	ebx, eax ; hFile

	lea	esi, [ftime]
	mov	[esi+FILETIME.dwLowDateTime], 0
	mov	[esi+FILETIME.dwHighDateTime], 0
	invoke	GetFileTime, ebx, 0, 0, esi
	invoke	CloseHandle, ebx
	lea	ebx, [sys_time]
	invoke	FileTimeToSystemTime, esi, ebx
	lea	edx, [loc_time]
	invoke	SystemTimeToTzSpecificLocalTime, 0, ebx, edx
	
	mov	ebx, esp
	movzx	eax, [loc_time.wMilliseconds]
	push	eax
	movzx	eax, [loc_time.wSecond]
	push	eax
	movzx	eax, [loc_time.wMinute]
	push	eax
	movzx	eax, [loc_time.wHour]
	push	eax
	movzx	eax, [loc_time.wDay]
	push	eax
	movzx	eax, [loc_time.wMonth]
	push	eax
	movzx	eax, [loc_time.wYear]
	push	eax
	lea	ecx, [edi+X_FFT_LIST.time]
	cinvoke	wnsprintfW, ecx, 100, .mask_time
	mov	esp, ebx

	lea	eax, [ftime]
	stdcall	convert_FILETIME_to_code, eax
	mov	ecx, eax
	mov	eax, [timeFasFile] ; file must be written before FAS-file.
	cmp	eax, ecx
	jae	.time_ok
	mov	eax, [itemsFftList]
	mov	[item_fft_list_helper], eax
	mov	edx, [msg_FasFileTest_listview_status_time]
	jmp	.status_end		
.time_ok:
	mov	edx, [msg_FasFileTest_listview_status_ok]
.status_end:
	lea	ecx, [edi+X_FFT_LIST.status_text]
	invoke	lstrcpynW, ecx, edx, 300 ; !!! size	

.skip_item:
	invoke	LocalUnlock, [hFftList]
	
	cmp	[flag_skip], 0
	jnz	.m0
	inc	[itemsFftList]

.m0:


	pop	ebx
	pop	edi
	pop	esi
	ret

.set_status_error:
	push	ebx
	push	esi
	push	edi
	invoke	GetLastError
	mov	ebx, eax

	lea	edi, [buffer_text_result]	
	lea	esi, [buffer_text_error]
	invoke	FormatMessageW, FORMAT_MESSAGE_IGNORE_INSERTS or FORMAT_MESSAGE_FROM_SYSTEM, 0, ebx, 0, esi, (sizeof.buffer_text_error)/2, 0
	test	eax, eax
	jz	.no_err_msg
	cinvoke	wnsprintfW, edi, (sizeof.buffer_text_result)/2, .MsgErr_mask3, [msg_MsgErr_err], ebx, esi
	jmp	.err_msg_ok
	.no_err_msg:
	cinvoke	wnsprintfW, edi, (sizeof.buffer_text_result)/2, .MsgErr_mask4, [msg_MsgErr_err], ebx
	.err_msg_ok:

	pop	edi
	pop	esi
	pop	ebx
	retn



.is_duplicate: ; esi - string, eax - memory
	push	esi
	push	edi
	push	ebx
	xor	ebx, ebx
	mov	edi, eax

.id_loop:
	cmp	ebx, [itemsFftList]
	jae	.id0

	mov	eax, sizeof.X_FFT_LIST
	mul	ebx
	add	eax, edi
	
	invoke	lstrcmpiW, eax, esi
	test	eax, eax
	jz	.id1
	inc	ebx
	jmp	.id_loop
	
.id0:	xor	eax, eax
	jmp	.id_exit
.id1:	mov	eax, 1
.id_exit:

	pop	ebx
	pop	edi
	pop	esi
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
	push	esi
	push	edi
	push	ebx


	mov	[lvi_sort.mask], LVIF_TEXT
	mov	[lvi_sort.cchTextMax], MAX_PATH

	mov	eax, [lParamSort] 
	mov	[lvi_sort.iSubItem], eax ; [lParamSort] - number of column by which sort is called

	mov	esi, [lParam1]
	mov	edi, [lParam2]
	cmp	byte [sort_directions_fft+eax], 1
	jne	@f
	xchg	esi, edi
@@:

	lea	ebx, [lvi_sort]
	lea	ecx, [tSort1]
	mov	[lvi_sort.pszText], ecx
	invoke	SendMessageW, [hListViewFFT], LVM_GETITEMTEXTW, esi, ebx
	lea	ecx, [tSort2]
	mov	[lvi_sort.pszText], ecx
	invoke	SendMessageW, [hListViewFFT], LVM_GETITEMTEXTW, edi, ebx

	lea	ecx, [tSort1]
	lea	edx, [tSort2]
	invoke lstrcmpW, ecx, edx


	pop	ebx
	pop	edi
	pop	esi
	ret
endp




proc import_fft_data
	push	esi
	push	edi

	stdcall	append_to_fft_list, -2 ; append fas file to list
	stdcall	append_to_fft_list, -1 ; append output (exe/dll) file to list

	mov	esi, [address_preprocessed_source]

	; ESI - real address of preprocessed source.

.main_loop:
	cmp	esi, [endOf_preprocessed_source] ; ESI = real addr of preprocessed source.
	jae	.end_main_loop

	test	byte [esi+preprocessed_line.number_line+3], 0x80 ; If bit31=0 = line was loaded from source, If bit31=1 = line was generated by macroinstruction.
	jnz	.skip_line ; line by macroinstruction

	mov	edi, [esi+preprocessed_line.offset_file_name]
	stdcall	append_to_fft_list, edi
	
.skip_line:
	stdcall	get_next_preprocessed_source_item, esi
	mov	esi, eax
	cmp	esi, [endOf_preprocessed_source]
	jae	.end_main_loop

	test	byte [esi+preprocessed_line.number_line+3], 0x80 ; If highest bit 0 = line loaded from source. If highest bit 1 = line generated by macroinstruction.
	jnz	.skip_line ; JMP - line by macroinstruction

	cmp	edi, [esi+preprocessed_line.offset_file_name] ; cmp with the previous item
	je	.skip_line
	jmp	.main_loop

.end_main_loop:

	xor	eax, eax
	inc	eax

	pop	edi
	pop	esi
	ret
endp

