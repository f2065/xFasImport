;
; xFasImport - Plugin for importing debugging information from fasm assembler (from .fas file) into x64dbg debugger.
; Author - f2065
; This plugin uses the sources of the plugin xFasConv32 by litrovith and x64dbg_dd.exe by bazizmix
;

format PE64 GUI 5.01 DLL NX at 0x10000000

; DWORD_PTR: win32 dd, win64 dq
DWORD_PTR equ dq
; memsize: win32 4, win64 8
memsize = 8

 include '%fasm%\include\win64a.inc'
 include 'macros.inc'
 include 'xFasImport.inc'
 include 'WinAPI_ExtraConst.inc'
 include 'WinAPI_ExtraStruct64.inc'
 include 'x64dbg.inc'
 include 'fasm.inc'
 include 'build_datetime.inc'

; plugin version
__MAJOR_VERSION equ 2
__MINOR_VERSION equ 0
__RELEASE_NUM equ 0
__BUILD_NUM equ __build_counter_int__

stringify_equ verA,__MAJOR_VERSION
stringify_equ verB,__MINOR_VERSION
stringify_equ verC,__RELEASE_NUM
stringify_equ verD,__BUILD_NUM
xFasImport_version_text equ verA,'.',verB,'.',verC,'.',verD
xFasImport_version_DWORD = (__MAJOR_VERSION shl 27) or (__MINOR_VERSION shl 22) or (__RELEASE_NUM shl 16) or ( __BUILD_NUM and 0xFFFF)

entry DllEntryPoint

section '.code' code readable executable

 include 'xFasImport_Labels_64.asm'
 include 'xFasImport_Comments_64.asm'
 include 'xFasImport_Util_64.asm'
 include 'xFasImport_FasFileTest_64.asm'
 include 'xFasImport_Settings_64.asm'
 include 'xFasImport_DLL_64.asm'
 include 'xFasImport_Auto_64.asm'
 include 'xFasImport_About_64.asm'
 include 'xFasImport_Lang_64.asm'

proc LoadFasSymbols, .image_file
locals
 text_buff_temp sized dw 200 dup (?)
endl
	push	rbx
	push	rdi
	push	rsi
	push	r12 ; stack align
frame
	mov	r12, rcx ; [.image_file]

	mov	[imported_labels_counter], 0
	mov	[imported_comments_counter], 0
	mov	[incorrect_time_flag], 0

	stdcall	set_buffFasFileName, r12

	stdcall	LoadFasFile, buffFasFileName, [config_OFN_force] ; set pFasFile
	test	rax, rax
	jz	.m0

	stdcall	prepare_fas_file ; check fas-file and set offsets in header
	test	rax, rax
	jz	.m0

	stdcall	DbgModBaseFromName_W, r12 ; get the base address for the currently debugged process
	test	rax, rax
	jz	.m0
	mov	[current_base_addr], rax

	stdcall	get_header_from_exe, r12 ; set original_base_addr start_import_table endOf_import_table
	test	rax, rax
	jz	.m0

	stdcall	set_basepath ; setting the base path (for relative links in fas-file to asm-files)

	stdcall	delete_old_labels

	cmp	[config_import_labels], 0
	je	.skip_import_labels
	stdcall	import_labels
	jmp	.m1
.skip_import_labels:
	stdcall	LogPrintW, [msg_import_labels_off]
.m1:

	stdcall	delete_old_comments

	cmp	[config_import_sources], 0
	je	.skip_import_sources

	stdcall	prepare_asmdumps_offsets
	test	rax, rax
	jz	.m0

	stdcall	import_sources_to_comments
	test	rax, rax
	jz	.m0
	jmp	.m2

.skip_import_sources:
	stdcall	LogPrintW, [msg_import_sources_off]
.m2:

	lea	rsi, [text_buff_temp]
	cinvoke	wnsprintfW, rsi, (sizeof.text_buff_temp), [msg_result_info_U_U], [imported_labels_counter], [imported_comments_counter]
	stdcall	LogPrintW, rsi

	mov	rcx, [msg_result_warning1]
	cmp	[incorrect_time_flag], 1
	je	.time_err
	mov	rcx, [msg_result_warning2]
	cmp	[incorrect_time_flag], 2
	je	.time_err
	mov	rcx, [msg_result_warning3]
	cmp	[incorrect_time_flag], 3
	jne	.time_ok
	.time_err:
	stdcall	LogPrintW, rcx
	.time_ok:

.m0:
	mov	rcx, [pFasFile]
	test	rcx, rcx
	je	@f
	invoke	LocalFree, rcx
	mov	[pFasFile], 0
@@:

	cinvoke	GuiUpdateAllViews

endf
	pop	r12
	pop	rsi
	pop	rdi
	pop	rbx
	ret
endp;LoadFasSymbols



proc DllEntryPoint, hinstDLL, fdwReason, lpvReserved

	mov	[hInstance], rcx
	mov	eax, 1
	ret
endp;DllEntryPoint

proc pluginit c, initStruct
frame

	mov	eax, [rcx+PLUG_INITSTRUCT.pluginHandle]
	mov	[pluginHandle], rax
	mov	[rcx+PLUG_INITSTRUCT.pluginVersion], xFasImport_version_DWORD
	mov	[rcx+PLUG_INITSTRUCT.sdkVersion], PLUG_SDKVERSION
	lea	rcx, [rcx+PLUG_INITSTRUCT.pluginName]
	invoke	lstrcpyA, rcx, szPLUGIN_NAME_A
	stdcall	init_language
	stdcall	init_dll_list
endf
	mov	eax, 1
	ret
endp;pluginit

proc plugsetup c, setupStruct
locals
 IconData ICONDATA_64
 lhRes rq 1
 text_buff_temp sized db 200 dup (?)
endl
	push	rdi
	push	rsi ; stack align
frame

	mov	rax, [rcx+PLUG_SETUPSTRUCT_64.hwndDlg]
	mov	[hwndDlg], rax
	mov	eax, [rcx+PLUG_SETUPSTRUCT_64.hMenu]
	mov	[hMenu], rax

	lea	rdi, [text_buff_temp]
	mov	word [rdi], 0x003F
	invoke	WideCharToMultiByte, CP_UTF8, 0, [menu_LoadMainSymbols], -1, rdi, sizeof.text_buff_temp, 0, 0
	cinvoke	_plugin_menuaddentry, [hMenu], MENU_LoadMain, rdi
	mov	word [rdi], 0x003F
	invoke	WideCharToMultiByte, CP_UTF8, 0, [menu_LoadDllSymbols], -1, rdi, sizeof.text_buff_temp, 0, 0
	cinvoke	_plugin_menuaddentry, [hMenu], MENU_LoadDll, rdi
	mov	word [rdi], 0x003F
	invoke	WideCharToMultiByte, CP_UTF8, 0, [menu_FasFileTest], -1, rdi, sizeof.text_buff_temp, 0, 0
	cinvoke	_plugin_menuaddentry, [hMenu], MENU_FasFileTest, rdi
	mov	word [rdi], 0x003F
	invoke	WideCharToMultiByte, CP_UTF8, 0, [menu_Settings], -1, rdi, sizeof.text_buff_temp, 0, 0
	cinvoke	_plugin_menuaddentry, [hMenu], MENU_Settings, rdi
	mov	word [rdi], 0x003F
	invoke	WideCharToMultiByte, CP_UTF8, 0, [menu_About], -1, rdi, sizeof.text_buff_temp, 0, 0
	cinvoke	_plugin_menuaddentry, [hMenu], MENU_About, rdi
	invoke	FindResourceA, [hInstance], ID_ICON_MAIN, RT_RCDATA
	mov	[lhRes], rax
	invoke	SizeofResource, [hInstance], rax
	mov	[IconData.size], rax
	invoke	LoadResource, [hInstance], [lhRes]
	mov	[IconData.data], rax
	lea	rdx, [IconData]
	cinvoke	_plugin_menuseticon, [hMenu], rdx
endf
	pop	rsi
	pop	rdi
	ret
endp;plugsetup

proc CBMENUENTRY c, cbType, cbInfo

	mov	edx, [rdx+PLUG_CB_MENUENTRY.hEntry]
	cmp	edx, MENU_LoadMain
	je	.load_main
	cmp	edx, MENU_LoadDll
	je	.load_dll
	cmp	edx, MENU_FasFileTest
	je	.start_test
	cmp	edx, MENU_Settings
	je	.start_cfg
	cmp	edx, MENU_About
	je	.start_about
.CBMENUENTRY_ret:
	mov	eax, 1
	ret
.load_main:
	stdcall	LoadFasSymbols, tDbgMainFileName
	stdcall	update_status_for_autoload
	jmp	.CBMENUENTRY_ret
.load_dll:
	stdcall	RunDllDlg
	jmp	.CBMENUENTRY_ret
.start_test:
	stdcall	RunFasFileTestDlg
	jmp	.CBMENUENTRY_ret
.start_cfg:
	stdcall	RunSettingsDlg
	jmp	.CBMENUENTRY_ret
.start_about:
	stdcall	RunAboutDlg
	jmp	.CBMENUENTRY_ret
endp;CBMENUENTRY

proc CBINITDEBUG c, cbType, cbInfo
frame
	mov	r8, [rdx+PLUG_CB_INITDEBUG_64.szFileName]
	invoke	MultiByteToWideChar, CP_UTF8, 0, r8, -1, tDbgMainFileName, MAX_PATH
	stdcall	load_settings
endf
	mov	eax, 1
	ret
endp;CBINITDEBUG

proc CBCREATEPROCESS c, cbType, cbInfo
	stdcall autoload_fas_file
	mov	eax, 1
	ret
endp;CBCREATEPROCESS

proc CBLOADDB c, cbType, cbInfo

	cmp	[rdx+PLUG_CB_LOADSAVEDB_64.loadSaveType], PLUG_DB_LOADSAVE_DATA
	je	.m1
	cmp	[rdx+PLUG_CB_LOADSAVEDB_64.loadSaveType], PLUG_DB_LOADSAVE_ALL
	jne	.m0
.m1:	stdcall	load_xFasImport_data, [rdx+PLUG_CB_LOADSAVEDB_64.root]
.m0:	mov	eax, 1
	ret
endp;CBLOADDB

proc CBSAVEDB c, cbType, cbInfo

	cmp	[rdx+PLUG_CB_LOADSAVEDB_64.loadSaveType], PLUG_DB_LOADSAVE_DATA
	je	.m1
	cmp	[rdx+PLUG_CB_LOADSAVEDB_64.loadSaveType], PLUG_DB_LOADSAVE_ALL
	jne	.m0
.m1:	stdcall	save_xFasImport_data, [rdx+PLUG_CB_LOADSAVEDB_64.root]
.m0:	mov	eax, 1
	ret
endp;CBSAVEDB

proc CBSTOPDEBUG c, cbType, cbInfo
	stdcall	kill_dll_list
	xor	eax, eax
	mov	word[tDbgMainFileName], ax
	mov	word[buffFasFileName], ax
	inc	eax
	ret
endp;CBSTOPDEBUG

proc plugstop c
	cinvoke	_plugin_menuclear, [hMenu]
	mov	eax, 1
	ret
endp;plugstop

proc CBLOADDLL c, cbType, cbInfo

	stdcall	append_to_dll_list, rdx
	mov	eax, 1
	ret
endp;CBLOADDLL

proc CBUNLOADDLL c, cbType, cbInfo

	mov	rcx, [rdx+PLUG_CB_UNLOADDLL_64.UnloadDll] ; UNLOAD_DLL_DEBUG_INFO
	mov	rcx, [rcx+UNLOAD_DLL_DEBUG_INFO.lpBaseOfDll]
	stdcall	remove_from_dll_list, ecx
	mov	eax, 1
	ret
endp;CBUNLOADDLL


section '.data' data readable writeable

include 'xFasImport_Lang_texts.asm'
include 'xFasImport_Data.asm'

section '.idata' import data readable writeable

 library kernel,'kernel32.dll',\
	user,'user32.dll',\
	shlwapi,'shlwapi.dll',\
	comdlg,'comdlg32.dll',\
	shell,'shell32.dll',\
	x64dbg,'x64dbg.dll',\
	x64bridge,'x64bridge.dll',\
	jansson,'jansson.dll'

 import kernel,\
	CloseHandle,'CloseHandle',\
	CreateFileW,'CreateFileW',\
	FindResourceA,'FindResourceA',\
	FormatMessageW,'FormatMessageW',\
	GetACP,'GetACP',\
	GetCPInfoExW,'GetCPInfoExW',\
	GetFileSizeEx,'GetFileSizeEx',\
	GetFileTime,'GetFileTime',\
	GetLastError,'GetLastError',\
	GetModuleHandleA,'GetModuleHandleA',\
	GetModuleFileNameW,'GetModuleFileNameW',\
	GetOEMCP,'GetOEMCP',\
	GetSystemWindowsDirectoryW,'GetSystemWindowsDirectoryW',\
	LoadResource,'LoadResource',\
	LocalAlloc,'LocalAlloc',\
	LocalReAlloc,'LocalReAlloc',\
	LocalLock,'LocalLock',\
	LocalUnlock,'LocalUnlock',\
	LocalFree,'LocalFree',\
	MultiByteToWideChar,'MultiByteToWideChar',\
	WideCharToMultiByte,'WideCharToMultiByte',\
	ReadFile,'ReadFile',\
	SizeofResource,'SizeofResource',\
	lstrcpynW,'lstrcpynW',\
	lstrcpyA,'lstrcpyA',\
	lstrlenA,'lstrlenA',\
	lstrlenW,'lstrlenW',\
	lstrcmpW,'lstrcmpW',\
	lstrcmpiW,'lstrcmpiW',\
	FileTimeToSystemTime,'FileTimeToSystemTime',\
	SystemTimeToTzSpecificLocalTime,'SystemTimeToTzSpecificLocalTime',\
	EnumSystemCodePagesW,'EnumSystemCodePagesW'

 import user,\
	DialogBoxParamA,'DialogBoxParamA',\
	EndDialog,'EndDialog',\
	GetDlgItem,'GetDlgItem',\
	SendMessageW,'SendMessageW',\
	IsDlgButtonChecked,'IsDlgButtonChecked',\
	CheckDlgButton,'CheckDlgButton',\
	GetDlgItemInt,'GetDlgItemInt',\
	SetDlgItemInt,'SetDlgItemInt',\
	EnableWindow,'EnableWindow',\
	ShowWindow,'ShowWindow',\
	SetDlgItemTextW,'SetDlgItemTextW',\
	SetWindowTextW,'SetWindowTextW'

 import shlwapi,\
	PathRenameExtensionW,'PathRenameExtensionW',\
	PathAddBackslashW,'PathAddBackslashW',\
	PathFindFileNameW,'PathFindFileNameW',\
	PathRemoveFileSpecW,'PathRemoveFileSpecW',\
	PathIsRelativeW,'PathIsRelativeW',\
	wnsprintfA,'wnsprintfA',\
	wnsprintfW,'wnsprintfW',\
	StrToIntW,'StrToIntW',\
	StrCmpNIW,'StrCmpNIW',\
	StrStrNW,'StrStrNW'

 import comdlg,\
	GetOpenFileNameW,'GetOpenFileNameW'

 import shell,\
	ShellExecuteA,'ShellExecuteA'

 import x64dbg,\
	_plugin_menuaddentry,'_plugin_menuaddentry',\
	_plugin_menuseticon,'_plugin_menuseticon',\
	_plugin_menuclear,'_plugin_menuclear'

 import x64bridge,\
	DbgModBaseFromName,'DbgModBaseFromName',\
	GuiAddLogMessage,'GuiAddLogMessage',\
	GuiUpdateAllViews,'GuiUpdateAllViews',\
	BridgeSettingGetUint,'BridgeSettingGetUint',\
	BridgeSettingSetUint,'BridgeSettingSetUint',\
	BridgeSettingGet,'BridgeSettingGet',\
	BridgeSettingFlush,'BridgeSettingFlush',\
	DbgClearAutoBookmarkRange,'DbgClearAutoBookmarkRange',\
	DbgClearAutoCommentRange,'DbgClearAutoCommentRange',\
	DbgClearAutoFunctionRange,'DbgClearAutoFunctionRange',\
	DbgClearAutoLabelRange,'DbgClearAutoLabelRange',\
	DbgClearBookmarkRange,'DbgClearBookmarkRange',\
	DbgClearCommentRange,'DbgClearCommentRange',\
	DbgClearLabelRange,'DbgClearLabelRange',\
	DbgSetAutoCommentAt,'DbgSetAutoCommentAt',\
	DbgSetAutoLabelAt,'DbgSetAutoLabelAt',\
	DbgGetLabelAt,'DbgGetLabelAt',\
	DbgSetLabelAt,'DbgSetLabelAt',\
	DbgGetCommentAt,'DbgGetCommentAt',\
	DbgSetCommentAt,'DbgSetCommentAt'

import jansson,\
	json_object,'json_object',\
	json_object_get,'json_object_get',\
	json_object_set_new,'json_object_set_new',\
	json_integer,'json_integer',\
	json_integer_value,'json_integer_value'


section '.edata' export data readable
 export 'xFasImport.dp64',\
	pluginit,'pluginit',\
	plugsetup,'plugsetup',\
	plugstop,'plugstop',\
	CBMENUENTRY,'CBMENUENTRY',\
	CBINITDEBUG,'CBINITDEBUG',\
	CBLOADDB,'CBLOADDB',\
	CBSAVEDB,'CBSAVEDB',\
	CBCREATEPROCESS,'CBCREATEPROCESS',\
	CBSTOPDEBUG,'CBSTOPDEBUG',\
	CBLOADDLL,'CBLOADDLL',\
	CBUNLOADDLL,'CBUNLOADDLL'


section '.rsrc' resource data readable
 directory RT_DIALOG,dialogs,\
	RT_RCDATA,main_icon,\
	RT_VERSION,versions

 resource main_icon,ID_ICON_MAIN,LANG_NEUTRAL,main_icon_data
 resdata main_icon_data
  file 'FASMW.png'
 endres

 resource versions,1,LANG_NEUTRAL,version
 versioninfo version,VOS_NT_WINDOWS32,VFT_DLL,VFT2_UNKNOWN,LANG_ENGLISH+SUBLANG_DEFAULT,1200,\
	'CompanyName', <'https://f2065.ru',13,10,'support@f2065.ru'>,\
	'FileDescription','Import FASM debug info in x64dbg',\
	'FileVersion',xFasImport_version_text,\
	'InternalName','xFasImport',\
	'LegalCopyright','© f2065',\
	'OriginalFilename','xFasImport.dp64',\
	'ProductName','xFasImport',\
	'ProductVersion',xFasImport_version_text

include 'xFasImport_Dialogs.asm'

section '.reloc' data readable discardable fixups
fix_reloc_size_alignment
fix_null_reloc
