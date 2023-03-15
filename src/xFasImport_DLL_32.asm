
proc RunDllDlg
	push	esi
	push	edi

	invoke	DialogBoxParamA, [hInstance], ID_DLG_DLL, [hwndDlg], DialogProcDll, 0
	test	eax, eax
	js	.m0
	
	mov	ecx, sizeof.X_DLL_LIST
	mul	ecx
	mov	edi, eax
	invoke	LocalLock, [hDllList]
	add	edi, eax
	
	lea	ecx, [edi+X_DLL_LIST.Image]
	stdcall	LoadFasSymbols, ecx

	invoke	LocalUnlock, [hDllList]

.m0:

	pop	edi
	pop	esi
	ret
endp


proc DialogProcDll, .hWnd, .uMsg, .wParam, .lParam
locals
 lvi LV_ITEM
endl

	push	ebx
	push	esi
	cmp	[.uMsg], WM_COMMAND
	je	.wp_cmd
	cmp	[.uMsg], WM_CLOSE
	je	.dll_cancel
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
	cmp	eax, dlg_dll_cancel
	je	.dll_cancel
	cmp	eax, dlg_dll_load
	je	.dll_load
	jmp	.wp_end

.dll_load:
	invoke	SendMessageW, [hListViewDLL], LVM_GETNEXTITEM, -1, LVNI_SELECTED
	test	eax, eax
	js	.dll_cancel
	
	lea	esi, [lvi]
	mov	[lvi.mask], LVIF_PARAM
	mov	[lvi.iItem], eax
	mov	[lvi.iSubItem], 0
	invoke	SendMessageW, [hListViewDLL], LVM_GETITEM, 0, esi

	invoke	EndDialog, [.hWnd], [lvi.lParam]
	jmp	.wp_end

.dll_cancel:
	invoke	EndDialog, [.hWnd], -1
	jmp	.wp_end

.wp_notify:
	cmp	[.wParam], dlg_dll_list
	jne	.wp_end
	mov	eax, [.lParam]
	cmp	[eax+NM_LISTVIEW.hdr.code], NM_DBLCLK
	je	.dll_load
	cmp	[eax+NM_LISTVIEW.hdr.code], LVN_ITEMCHANGED
	je	.allow_continue
	cmp	[eax+NM_LISTVIEW.hdr.code], LVN_COLUMNCLICK
	je	.sort
	jmp	.wp_end

.allow_continue:
	xor	ebx, ebx
	test	[eax+NM_LISTVIEW.uNewState], LVIS_SELECTED
	setnz	bl
	invoke	GetDlgItem, [.hWnd], dlg_dll_load
	invoke	EnableWindow, eax, ebx
	jmp	.wp_end

.sort:
	mov	esi, [eax+NM_LISTVIEW.iSubItem]
	invoke	SendMessageW, [hListViewDLL], LVM_GETITEMCOUNT, 0, 0
	test	eax, eax
	jz	.wp_end

	lea	eax, [sort_directions_dll+esi]
	mov	bl, [eax]
	cmp	bl, 1
	je	.s2
	mov	bl, 1
	jmp	.s3
.s2:	mov	bl, 2
.s3:	mov	byte [eax], bl

	invoke	SendMessageW, [hListViewDLL], LVM_SORTITEMSEX, esi, SortCompareFuncDLL
	jmp	.wp_end

.wp_init:

	invoke	SetWindowTextW, [.hWnd], [title_dlg_dll]
	stdcall	set_lng_dialog, [.hWnd], table_lang_dlg_dll
	invoke	GetDlgItem, [.hWnd], dlg_dll_list
	mov	[hListViewDLL], eax
	stdcall	init_listview_dll
	invoke	GetDlgItem, [.hWnd], dlg_dll_load
	invoke	EnableWindow, eax, 0
	stdcall	helper_dll_list

	jmp	.wp_end
endp


proc init_listview_dll
locals
 text_buffer sized dw 50 dup (?)
 lvc LV_COLUMN
 lvi LV_ITEM
endl
	push	esi
	push	edi
	push	ebx


	mov	dword [sort_directions_dll], 0

	mov	ebx, [hListViewDLL]

	lea	edi, [lvc]
	mov	[lvc.mask], LVCF_FMT or LVCF_TEXT or LVCF_WIDTH
	mov	[lvc.fmt], LVCFMT_LEFT
	mov	[lvc.cx], 150
	mov	eax, [dlg_dll_listview_module]
	mov	[lvc.pszText], eax
	invoke	SendMessageW, ebx, LVM_INSERTCOLUMNW, 1, edi
	mov	[lvc.cx], 100
	mov	eax, [dlg_dll_listview_baseaddr]
	mov	[lvc.pszText], eax
	invoke	SendMessageW, ebx, LVM_INSERTCOLUMNW, 2, edi
	mov	[lvc.cx], 325
	mov	eax, [dlg_dll_listview_imagename]
	mov	[lvc.pszText], eax
	invoke	SendMessageW, ebx, LVM_INSERTCOLUMNW, 3, edi
	mov	[lvc.cx], 150
	mov	eax, [dlg_dll_listview_filetime]
	mov	[lvc.pszText], eax
	invoke	SendMessageW, ebx, LVM_INSERTCOLUMNW, 4, edi
	invoke	SendMessageW, ebx, LVM_SETEXTENDEDLISTVIEWSTYLE, 0, LVS_EX_FULLROWSELECT or LVS_EX_GRIDLINES
	; the number of columns must match the number of bytes in sort_directions

	cmp	[hDllList], 0
	je	.skip_list
	invoke	LocalLock, [hDllList]
	mov	ebx, eax
	lea	edi, [lvi]
	mov	[lvi.iItem], 0
	

.list_loop:
	mov	eax, [lvi.iItem]
	cmp	eax, [itemsDllList]
	jae	.exit_loop

	mov	esi, ebx
	mov	ecx, sizeof.X_DLL_LIST
	mul	ecx
	add	esi, eax

	mov	[lvi.mask], LVIF_TEXT or LVIF_PARAM
	mov	eax, [lvi.iItem]
	mov	[lvi.lParam], eax ; to keep the element number (in hDllList) after sorting the rows
	lea	eax, [esi+X_DLL_LIST.Module]
	mov	[lvi.pszText], eax
	mov	[lvi.iSubItem], 0
	invoke	SendMessageW, [hListViewDLL], LVM_INSERTITEMW, 0, edi

	mov	[lvi.mask], LVIF_TEXT
	mov	eax, dword [esi+X_DLL_LIST.BaseOfImage]

	lea	ecx, [text_buffer]
	mov	[lvi.pszText], ecx
	cinvoke	wnsprintfW, ecx, (sizeof.text_buffer)/2, .t_maskBase, eax
	mov	[lvi.iSubItem], 1
	invoke	SendMessageW, [hListViewDLL], LVM_SETITEMW, 0, edi

	lea	eax, [esi+X_DLL_LIST.Image]
	mov	[lvi.pszText], eax
	mov	[lvi.iSubItem], 2
	invoke	SendMessageW, [hListViewDLL], LVM_SETITEMW, 0, edi

	lea	eax, [esi+X_DLL_LIST.time]
	mov	[lvi.pszText], eax
	mov	[lvi.iSubItem], 3
	invoke	SendMessageW, [hListViewDLL], LVM_SETITEMW, 0, edi
	
	inc	[lvi.iItem]
	jmp	.list_loop
	
.exit_loop:
	invoke	LocalUnlock, [hDllList]

.skip_list:


	pop	ebx
	pop	edi
	pop	esi
	ret

.t_maskBase du "0x%08X",0
.t_maskSize du "0x%08X",0
endp


struct X_DLL_LIST
 BaseOfImage rq 1
 Module rw MAX_PATH
 Image rw MAX_PATH
 time rw 100
ends



proc init_dll_list

	mov	[itemsDllList], 0
	invoke	LocalAlloc, LMEM_MOVEABLE or LMEM_ZEROINIT, 16
	mov	[hDllList], eax
	test	eax, eax
	jnz	.ok
	stdcall	LogErrW, .t_init_dll_list, .t_err_LocalAlloc, 0, 0 ; .checkpoint_name, .winapi_name, .processed_object, .infotext
	xor	eax, eax
	ret
	.ok:

	mov	eax, 1
	ret
.t_init_dll_list du "init_dll_list",0
.t_err_LocalAlloc du "LocalAlloc",0
endp


proc append_to_dll_list, .LOADDLL
locals
 ftime FILETIME
 sys_time SYSTEMTIME
 loc_time SYSTEMTIME
endl
	push	esi
	push	edi
	push	ebx


	cmp	[hDllList], 0
	je	.m0

	mov	esi, [.LOADDLL] ; PLUG_CB_LOADDLL_32

	mov	eax, [itemsDllList]
	inc	eax
	mov	ecx, sizeof.X_DLL_LIST
	mul	ecx

	invoke	LocalReAlloc, [hDllList], eax, LMEM_MOVEABLE or LMEM_ZEROINIT
	test	eax, eax
	jnz	.m8
	stdcall	LogErrW, .t_append_to_dll_list, .t_LocalReAlloc, 0, 0 ; .checkpoint_name, .winapi_name, .processed_object, .infotext
	invoke	LocalFree, [hDllList]
	mov	[hDllList], 0
	jmp	.m0
	.m8:
	mov	[hDllList], eax

	mov	eax, sizeof.X_DLL_LIST
	mul	[itemsDllList]
	mov	edi, eax
	invoke	LocalLock, [hDllList]
	add	edi, eax
	
	mov	ecx, [esi+PLUG_CB_LOADDLL_32.modInfo] ; IMAGEHLP_MODULE64
	mov	eax, dword [ecx+IMAGEHLP_MODULE64.BaseOfImage]
	mov	dword [edi+X_DLL_LIST.BaseOfImage], eax
	mov	dword [edi+X_DLL_LIST.BaseOfImage+4], 0
	lea	edx, [ecx+IMAGEHLP_MODULE64.ImageName]
	lea	eax, [edi+X_DLL_LIST.Image]
	invoke	MultiByteToWideChar, CP_UTF8, 0, edx, -1, eax, MAX_PATH

	mov	edx, [esi+PLUG_CB_LOADDLL_32.modname]
	lea	eax, [edi+X_DLL_LIST.Module]
	invoke	MultiByteToWideChar, CP_UTF8, 0, edx, -1, eax, MAX_PATH

	mov	word [edi+X_DLL_LIST.time], 0
	lea	ecx, [edi+X_DLL_LIST.Image]
	invoke	CreateFileW, ecx, GENERIC_READ, FILE_SHARE_READ or FILE_SHARE_WRITE or FILE_SHARE_DELETE, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
	cmp	eax, INVALID_HANDLE_VALUE
	je	.time_skip
	mov	ebx, eax ; hFile

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
	lea	ecx, [edi+X_DLL_LIST.time]
	cinvoke	wnsprintfW, ecx, 100, .mask_time
	mov	esp, ebx
.time_skip:

	invoke	LocalUnlock, [hDllList]
	
	inc	[itemsDllList]

.m0:

	pop	ebx
	pop	edi
	pop	esi
	ret

.mask_time du "%04u.%02u.%02u %02u:%02u:%02u.%03u",0
.t_append_to_dll_list du "append_to_dll_list",0
.t_LocalReAlloc du "LocalReAlloc",0
endp

proc helper_dll_list
locals
 sysfolder sized dw MAX_PATH+8 dup (?)
 len_foldername dd ?
 item_dll_list_helper dd ?
 lvi_sel LV_ITEM
endl
	push	esi
	push	edi
	push	ebx


	mov	[item_dll_list_helper], -1

	cmp	[hDllList], 0
	je	.m0
	cmp	[itemsDllList], 0
	je	.m0

	lea	esi, [sysfolder]
	invoke	GetSystemWindowsDirectoryW, esi, MAX_PATH
	invoke	PathAddBackslashW, esi
	invoke	lstrlenW, esi
	mov	[len_foldername], eax
	
	invoke	LocalLock, [hDllList]
	mov	edi, eax

	xor	ebx, ebx
.loop:	cmp	ebx, [itemsDllList]
	jae	.end_loop

	mov	eax, sizeof.X_DLL_LIST
	mul	ebx
	lea	ecx, [eax+edi+X_DLL_LIST.Image]
	
	invoke	StrCmpNIW, ecx, esi, [len_foldername]
	test	eax, eax
	jz	.cont
	cmp	[item_dll_list_helper], -1
	jne	.end_double
	mov	[item_dll_list_helper], ebx
	
.cont:	inc	ebx
	jmp	.loop

.end_double:
	mov	[item_dll_list_helper], -1

.end_loop:
	invoke	LocalUnlock, [hDllList]

	cmp	[item_dll_list_helper], -1
	je	.m0

	mov	[lvi_sel.mask], LVIF_STATE
	mov	[lvi_sel.state], LVIS_SELECTED
	mov	[lvi_sel.stateMask], LVIS_SELECTED
	mov	eax, [item_dll_list_helper]
	mov	[lvi_sel.iItem], eax
	mov	[lvi_sel.iSubItem], 0
	lea	edx, [lvi_sel]
	invoke	SendMessageW, [hListViewDLL], LVM_SETITEMSTATE, [item_dll_list_helper], edx
	invoke	SendMessageW, [hListViewDLL], LVM_ENSUREVISIBLE, [item_dll_list_helper], 0

.m0:


	pop	ebx
	pop	edi
	pop	esi
	ret
endp

proc kill_dll_list
	cmp	[hDllList], 0
	jz	.m0
	invoke	LocalFree, [hDllList]
.m0:	mov	[hDllList], 0
	mov	[itemsDllList], 0
	ret
endp

proc remove_from_dll_list, .removed_baseaddr
locals
 lvc LV_COLUMN
 lvi LV_ITEM
endl
	push	esi
	push	edi
	push	ebx


	mov	edi, [.removed_baseaddr]

	cmp	[hDllList], 0
	je	.m0
	cmp	[itemsDllList], 0
	je	.m0

	invoke	LocalLock, [hDllList]
	mov	ebx, eax

	xor	ecx, ecx
.loop:	cmp	ecx, [itemsDllList]
	jae	.end_loop

	mov	eax, sizeof.X_DLL_LIST
	mul	ecx

	cmp	dword [eax+ebx+X_DLL_LIST.BaseOfImage], edi
	jne	.cont

	lea	edi, [eax+ebx]
	lea	esi, [edi+sizeof.X_DLL_LIST]

	mov	eax, sizeof.X_DLL_LIST
	mul	[itemsDllList]
	add	eax, ebx
	sub	eax, esi
	jb	.end_loop ; error?
	je	.skip_last_item
	mov	ecx, eax
	rep	movsb

.skip_last_item:

	dec	[itemsDllList]
	invoke	LocalUnlock, [hDllList]
	
	mov	eax, [itemsDllList]
	mov	ecx, sizeof.X_DLL_LIST
	mul	ecx
	add	eax, 16

	invoke	LocalReAlloc, [hDllList], eax, LMEM_MOVEABLE or LMEM_ZEROINIT
	mov	[hDllList], eax
	jmp	.m0

.cont:	inc	ecx
	jmp	.loop

.end_loop:
	invoke	LocalUnlock, [hDllList]

.m0:


	pop	ebx
	pop	edi
	pop	esi
	ret
endp


proc SortCompareFuncDLL, lParam1, lParam2, lParamSort
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
	cmp	byte [sort_directions_dll+eax], 1
	jne	@f
	xchg	esi, edi
@@:

	lea	ebx, [lvi_sort]
	lea	ecx, [tSort1]
	mov	[lvi_sort.pszText], ecx
	invoke	SendMessageW, [hListViewDLL], LVM_GETITEMTEXTW, esi, ebx
	lea	ecx, [tSort2]
	mov	[lvi_sort.pszText], ecx
	invoke	SendMessageW, [hListViewDLL], LVM_GETITEMTEXTW, edi, ebx

	lea	ecx, [tSort1]
	lea	edx, [tSort2]
	invoke	lstrcmpW, ecx, edx


	pop	ebx
	pop	edi
	pop	esi
	ret
endp
