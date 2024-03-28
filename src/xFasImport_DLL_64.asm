
proc RunDllDlg
	push	rsi
	push	rdi
frame
	invoke	DialogBoxParamA, [hInstance], ID_DLG_DLL, [hwndDlg], DialogProcDll, 0
	test	rax, rax
	js	.m0

	mov	ecx, sizeof.X_DLL_LIST
	mul	rcx
	mov	rdi, rax
	invoke	LocalLock, [hDllList]
	add	rdi, rax

	lea	rcx, [rdi+X_DLL_LIST.Image]
	stdcall	LoadFasSymbols, rcx

	invoke	LocalUnlock, [hDllList]

.m0:
endf
	pop	rdi
	pop	rsi
	ret
endp


proc DialogProcDll, .hWnd, .uMsg, .wParam, .lParam
locals
 lvi LV_ITEM
endl
	mov	[.hWnd], rcx
	push	rbx
	push	rsi
	cmp	rdx, WM_COMMAND
	je	.wp_cmd
	cmp	rdx, WM_CLOSE
	je	.dll_cancel
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

	cmp	r8, dlg_dll_cancel
	je	.dll_cancel
	cmp	r8, dlg_dll_load
	je	.dll_load
	jmp	.wp_end

.dll_load:
	invoke	SendMessageW, [hListViewDLL], LVM_GETNEXTITEM, -1, LVNI_SELECTED
	test	rax, rax
	js	.dll_cancel

	lea	rsi, [lvi]
	mov	[lvi.mask], LVIF_PARAM
	mov	[lvi.iItem], eax
	mov	[lvi.iSubItem], 0
	invoke	SendMessageW, [hListViewDLL], LVM_GETITEM, 0, rsi

	invoke	EndDialog, [.hWnd], [lvi.lParam]
	jmp	.wp_end

.dll_cancel:
	invoke	EndDialog, [.hWnd], -1
	jmp	.wp_end

.wp_notify:
	cmp	r8, dlg_dll_list
	jne	.wp_end

	cmp	[r9+NM_LISTVIEW.hdr.code], NM_DBLCLK
	je	.dll_load
	cmp	[r9+NM_LISTVIEW.hdr.code], LVN_ITEMCHANGED
	je	.allow_continue
	cmp	[r9+NM_LISTVIEW.hdr.code], LVN_COLUMNCLICK
	je	.sort
	jmp	.wp_end

.allow_continue:
	xor	rbx, rbx
	test	[r9+NM_LISTVIEW.uNewState], LVIS_SELECTED
	setnz	bl
	invoke	GetDlgItem, [.hWnd], dlg_dll_load
	invoke	EnableWindow, rax, rbx
	jmp	.wp_end

.sort:
	mov	esi, [r9+NM_LISTVIEW.iSubItem]
	invoke	SendMessageW, [hListViewDLL], LVM_GETITEMCOUNT, 0, 0
	test	rax, rax
	jz	.wp_end

	lea	rax, [sort_directions_dll+rsi]
	mov	bl, [rax]
	cmp	bl, 1
	je	.s2
	mov	bl, 1
	jmp	.s3
.s2:	mov	bl, 2
.s3:	mov	byte [rax], bl

	invoke	SendMessageW, [hListViewDLL], LVM_SORTITEMSEX, rsi, SortCompareFuncDLL
	jmp	.wp_end

.wp_init:
frame
	invoke	SetWindowTextW, [.hWnd], [title_dlg_dll]
	stdcall	set_lng_dialog, [.hWnd], table_lang_dlg_dll
	invoke	GetDlgItem, [.hWnd], dlg_dll_list
	mov	[hListViewDLL], rax
	stdcall	init_listview_dll
	invoke	GetDlgItem, [.hWnd], dlg_dll_load
	invoke	EnableWindow, rax, 0
	stdcall	helper_dll_list
endf
	jmp	.wp_end
endp


proc init_listview_dll
locals
 text_buffer sized dw 50 dup (?)
 lvc LV_COLUMN
 lvi LV_ITEM
endl
	push	rsi
	push	rdi
	push	rbx
	push	r12
frame
	mov	dword [sort_directions_dll], 0

	mov	r12, [hListViewDLL]

	lea	rdi, [lvc]
	mov	[lvc.mask], LVCF_FMT or LVCF_TEXT or LVCF_WIDTH
	mov	[lvc.fmt], LVCFMT_LEFT
	mov	[lvc.cx], 150
	mov	rax, [dlg_dll_listview_module]
	mov	[lvc.pszText], rax
	invoke	SendMessageW, r12, LVM_INSERTCOLUMNW, 1, rdi
	mov	[lvc.cx], 130
	mov	rax, [dlg_dll_listview_baseaddr]
	mov	[lvc.pszText], rax
	invoke	SendMessageW, r12, LVM_INSERTCOLUMNW, 2, rdi
	mov	[lvc.cx], 295
	mov	rax, [dlg_dll_listview_imagename]
	mov	[lvc.pszText], rax
	invoke	SendMessageW, r12, LVM_INSERTCOLUMNW, 3, rdi
	mov	[lvc.cx], 150
	mov	rax, [dlg_dll_listview_filetime]
	mov	[lvc.pszText], rax
	invoke	SendMessageW, r12, LVM_INSERTCOLUMNW, 4, rdi
	invoke	SendMessageW, r12, LVM_SETEXTENDEDLISTVIEWSTYLE, 0, LVS_EX_FULLROWSELECT or LVS_EX_GRIDLINES
	; the number of columns must match the number of bytes in sort_directions

	cmp	[hDllList], 0
	je	.skip_list
	invoke	LocalLock, [hDllList]
	mov	rbx, rax
	lea	rdi, [lvi]
	mov	[lvi.iItem], 0


.list_loop:
	mov	eax, [lvi.iItem]
	cmp	rax, [itemsDllList]
	jae	.exit_loop

	mov	rsi, rbx
	mov	ecx, sizeof.X_DLL_LIST
	mul	rcx
	add	rsi, rax

	mov	[lvi.mask], LVIF_TEXT or LVIF_PARAM
	mov	eax, [lvi.iItem]
	mov	[lvi.lParam], eax ; to keep the element number (in hDllList) after sorting the rows
	lea	rax, [rsi+X_DLL_LIST.Module]
	mov	[lvi.pszText], rax
	mov	[lvi.iSubItem], 0
	invoke	SendMessageW, r12, LVM_INSERTITEMW, 0, rdi

	mov	[lvi.mask], LVIF_TEXT
	mov	r10d, dword [rsi+X_DLL_LIST.BaseOfImage]
	mov	r9d, dword [rsi+X_DLL_LIST.BaseOfImage+4]
	lea	rcx, [text_buffer]
	mov	[lvi.pszText], rcx
	cinvoke	wnsprintfW, rcx, (sizeof.text_buffer)/2, .t_maskBase, r9, r10
	mov	[lvi.iSubItem], 1
	invoke	SendMessageW, r12, LVM_SETITEMW, 0, rdi

	lea	rax, [rsi+X_DLL_LIST.Image]
	mov	[lvi.pszText], rax
	mov	[lvi.iSubItem], 2
	invoke	SendMessageW, r12, LVM_SETITEMW, 0, rdi

	lea	rax, [rsi+X_DLL_LIST.time]
	mov	[lvi.pszText], rax
	mov	[lvi.iSubItem], 3
	invoke	SendMessageW, r12, LVM_SETITEMW, 0, rdi

	inc	[lvi.iItem]
	jmp	.list_loop

.exit_loop:
	invoke	LocalUnlock, [hDllList]

.skip_list:
endf
	pop	r12
	pop	rbx
	pop	rdi
	pop	rsi
	ret

.t_maskBase du "0x%08X%08X",0
.t_maskSize du "0x%08X",0
endp


struct X_DLL_LIST
 BaseOfImage rq 1
 Module rw MAX_PATH
 Image rw MAX_PATH
 time rw 100
ends



proc init_dll_list
frame
	mov	[itemsDllList], 0
	invoke	LocalAlloc, LMEM_MOVEABLE or LMEM_ZEROINIT, 16
	mov	[hDllList], rax
	test	rax, rax
	jnz	.ok
	stdcall	LogErrW, .t_init_dll_list, .t_err_LocalAlloc, 0, 0 ; .checkpoint_name, .winapi_name, .processed_object, .infotext
	xor	eax, eax
	ret
	.ok:
endf
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
	push	rsi
	push	rdi
	push	rbx
	push	r12 ; stack align

	cmp	[hDllList], 0
	je	.m0

	mov	rsi, rcx ; [.LOADDLL] = PLUG_CB_LOADDLL_64

	mov	rax, [itemsDllList]
	inc	rax
	mov	ecx, sizeof.X_DLL_LIST
	mul	rcx

	invoke	LocalReAlloc, [hDllList], rax, LMEM_MOVEABLE or LMEM_ZEROINIT
	test	rax, rax
	jnz	.m8
	stdcall	LogErrW, .t_append_to_dll_list, .t_LocalReAlloc, 0, 0 ; .checkpoint_name, .winapi_name, .processed_object, .infotext
	invoke	LocalFree, [hDllList]
	mov	[hDllList], 0
	jmp	.m0
	.m8:
	mov	[hDllList], rax

	mov	eax, sizeof.X_DLL_LIST
	mul	[itemsDllList]
	mov	rdi, rax
	invoke	LocalLock, [hDllList]
	add	rdi, rax

	mov	rcx, [rsi+PLUG_CB_LOADDLL_64.modInfo] ; IMAGEHLP_MODULE64
	mov	rax, [rcx+IMAGEHLP_MODULE64.BaseOfImage]
	mov	[rdi+X_DLL_LIST.BaseOfImage], rax

	lea	r8, [rcx+IMAGEHLP_MODULE64.ImageName]
	lea	r10, [rdi+X_DLL_LIST.Image]
	invoke	MultiByteToWideChar, CP_UTF8, 0, r8, -1, r10, MAX_PATH

	mov	r8, [rsi+PLUG_CB_LOADDLL_64.modname]
	lea	r10, [rdi+X_DLL_LIST.Module]
	invoke	MultiByteToWideChar, CP_UTF8, 0, r8, -1, r10, MAX_PATH

	mov	word [rdi+X_DLL_LIST.time], 0
	lea	rcx, [rdi+X_DLL_LIST.Image]
	invoke	CreateFileW, rcx, GENERIC_READ, FILE_SHARE_READ or FILE_SHARE_WRITE or FILE_SHARE_DELETE, 0, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
	cmp	rax, INVALID_HANDLE_VALUE
	je	.time_skip
	mov	rbx, rax ; hFile

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
	lea	rcx, [rdi+X_DLL_LIST.time]
	cinvoke	wnsprintfW, rcx, 100, .mask_time, rax
	mov	rsp, rbx
.time_skip:

	invoke	LocalUnlock, [hDllList]

	inc	[itemsDllList]

.m0:
	pop	r12
	pop	rbx
	pop	rdi
	pop	rsi
	ret

.mask_time du "%04u.%02u.%02u %02u:%02u:%02u.%03u",0
.t_append_to_dll_list du "append_to_dll_list",0
.t_LocalReAlloc du "LocalReAlloc",0
endp

proc helper_dll_list
locals
 sysfolder sized dw MAX_PATH+8 dup (?)
 len_foldername dq ?
 item_dll_list_helper dq ?
 lvi_sel LV_ITEM
endl
	push	rsi
	push	rdi
	push	rbx
	push	r12 ; stack align
frame
	mov	[item_dll_list_helper], -1

	cmp	[hDllList], 0
	je	.m0
	cmp	[itemsDllList], 0
	je	.m0

	lea	rsi, [sysfolder]
	invoke	GetSystemWindowsDirectoryW, rsi, MAX_PATH
	invoke	PathAddBackslashW, rsi
	invoke	lstrlenW, rsi
	mov	[len_foldername], rax

	invoke	LocalLock, [hDllList]
	mov	rdi, rax

	xor	rbx, rbx
.loop:	cmp	rbx, [itemsDllList]
	jae	.end_loop

	mov	eax, sizeof.X_DLL_LIST
	mul	rbx
	lea	rcx, [rax+rdi+X_DLL_LIST.Image]

	invoke	StrCmpNIW, rcx, rsi, [len_foldername]
	test	rax, rax
	jz	.cont
	cmp	[item_dll_list_helper], -1
	jne	.end_double
	mov	[item_dll_list_helper], rbx

.cont:	inc	rbx
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
	mov	rax, [item_dll_list_helper]
	mov	[lvi_sel.iItem], eax
	mov	[lvi_sel.iSubItem], 0
	lea	r9, [lvi_sel]
	invoke	SendMessageW, [hListViewDLL], LVM_SETITEMSTATE, [item_dll_list_helper], r9
	invoke	SendMessageW, [hListViewDLL], LVM_ENSUREVISIBLE, [item_dll_list_helper], 0

.m0:
endf
	pop	r12
	pop	rbx
	pop	rdi
	pop	rsi
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
	push	rsi
	push	rdi
	push	rbx
	push	r12 ; stack align
frame
	mov	rdi, rcx ; [.removed_baseaddr]

	cmp	[hDllList], 0
	je	.m0
	cmp	[itemsDllList], 0
	je	.m0

	invoke	LocalLock, [hDllList]
	mov	rbx, rax

	xor	ecx, ecx
.loop:	cmp	rcx, [itemsDllList]
	jae	.end_loop

	mov	eax, sizeof.X_DLL_LIST
	mul	rcx

	cmp	[rax+rbx+X_DLL_LIST.BaseOfImage], rdi
	jne	.cont

	lea	rdi, [rax+rbx]
	lea	rsi, [rdi+sizeof.X_DLL_LIST]

	mov	eax, sizeof.X_DLL_LIST
	mul	[itemsDllList]
	add	rax, rbx
	sub	rax, rsi
	jb	.end_loop ; error?
	je	.skip_last_item
	mov	rcx, rax
	rep	movsb

.skip_last_item:

	dec	[itemsDllList]
	invoke	LocalUnlock, [hDllList]

	mov	rax, [itemsDllList]
	mov	ecx, sizeof.X_DLL_LIST
	mul	rcx
	add	rax, 16

	invoke	LocalReAlloc, [hDllList], rax, LMEM_MOVEABLE or LMEM_ZEROINIT
	mov	[hDllList], rax
	jmp	.m0

.cont:	inc	rcx
	jmp	.loop

.end_loop:
	invoke	LocalUnlock, [hDllList]

.m0:
endf
	pop	r12
	pop	rbx
	pop	rdi
	pop	rsi
	ret
endp


proc SortCompareFuncDLL, lParam1, lParam2, lParamSort
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
	cmp	byte [sort_directions_dll+r8], 1
	jne	@f
	xchg	rsi, rdi
@@:

	lea	rbx, [lvi_sort]
	lea	rcx, [tSort1]
	mov	[lvi_sort.pszText], rcx
	invoke	SendMessageW, [hListViewDLL], LVM_GETITEMTEXTW, rsi, rbx
	lea	rcx, [tSort2]
	mov	[lvi_sort.pszText], rcx
	invoke	SendMessageW, [hListViewDLL], LVM_GETITEMTEXTW, rdi, rbx

	lea	rcx, [tSort1]
	lea	rdx, [tSort2]
	invoke	lstrcmpW, rcx, rdx
endf
	pop	r12
	pop	rbx
	pop	rdi
	pop	rsi
	ret
endp
