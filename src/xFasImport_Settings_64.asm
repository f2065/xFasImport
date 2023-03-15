
proc RunSettingsDlg
	invoke	DialogBoxParamA, [hInstance], ID_DLG_SETTINGS, [hwndDlg], DialogProcSettings, 0
	ret
endp



proc DialogProcSettings, .hWnd, .uMsg, .wParam, .lParam
	mov	[.hWnd], rcx
	cmp	rdx, WM_COMMAND
	je	.wp_cmd
	cmp	rdx, WM_CLOSE
	je	.settings_cancel
	cmp	rdx, WM_INITDIALOG
	je	.wp_init
.wp_end:
	xor	eax, eax
	ret

.wp_cmd:

	cmp	r8, dlg_settings_ok
	je	.setting_ok
	cmp	r8, dlg_settings_cancel
	je	.settings_cancel
	cmp	r8, dlg_settings_import_sources
	je	.hide_opt_comments
	cmp	r8, dlg_settings_remove_spaces
	je	.hide_opt_comments
	cmp	r8, dlg_settings_tabsize_def
	je	.tabsize_def
	jmp	.wp_end

.setting_ok:
frame
	invoke	SendMessageW, [hCodePageComboBox], CB_GETCURSEL, 0, 0
	test	rax, rax
	js	.cp_err
	invoke	SendMessageW, [hCodePageComboBox], CB_GETITEMDATA, rax, 0
	mov	[config_sources_codepage], rax
	jmp	.cp_end
.cp_err:
	mov	[config_sources_codepage], 0
.cp_end:

	invoke	IsDlgButtonChecked, [.hWnd], dlg_settings_delete_old_labels
	mov	[config_delete_old_labels], rax
	invoke	IsDlgButtonChecked, [.hWnd], dlg_settings_import_labels
	mov	[config_import_labels], rax
	invoke	IsDlgButtonChecked, [.hWnd], dlg_settings_delete_old_comments
	mov	[config_delete_old_comments], rax
	invoke	IsDlgButtonChecked, [.hWnd], dlg_settings_import_sources
	mov	[config_import_sources], rax
	invoke	IsDlgButtonChecked, [.hWnd], dlg_settings_append_labels
	mov	[config_append_labels], rax
	invoke	IsDlgButtonChecked, [.hWnd], dlg_settings_remove_spaces
	mov	[config_remove_spaces], rax

	invoke	GetDlgItemInt, [.hWnd], dlg_settings_tabsize1, 0, 0
	mov	[config_tabsize1], rax
	invoke	GetDlgItemInt, [.hWnd], dlg_settings_tabsize2, 0, 0
	mov	[config_tabsize2], rax
	invoke	GetDlgItemInt, [.hWnd], dlg_settings_tabsize3, 0, 0
	mov	[config_tabsize3], rax
	invoke	GetDlgItemInt, [.hWnd], dlg_settings_tabsize4, 0, 0
	mov	[config_tabsize4], rax
	invoke	GetDlgItemInt, [.hWnd], dlg_settings_tabsize5, 0, 0
	mov	[config_tabsize5], rax
	stdcall	tabsize_check_ranges

	invoke	IsDlgButtonChecked, [.hWnd], dlg_settings_flag_MANUAL_labels
	mov	[config_flag_labels_manual], rax
	invoke	IsDlgButtonChecked, [.hWnd], dlg_settings_flag_MANUAL_comments
	mov	[config_flag_comments_manual], rax
	invoke	IsDlgButtonChecked, [.hWnd], dlg_settings_OFN_force
	mov	[config_OFN_force], rax

	stdcall	save_settings
endf
.settings_cancel:
	invoke	EndDialog, [.hWnd], 0
	jmp	.wp_end

.tabsize_def:
frame
	invoke	SetDlgItemInt, [.hWnd], dlg_settings_tabsize1, 8*1, 0
	invoke	SetDlgItemInt, [.hWnd], dlg_settings_tabsize2, 8*2, 0
	invoke	SetDlgItemInt, [.hWnd], dlg_settings_tabsize3, 8*3, 0
	invoke	SetDlgItemInt, [.hWnd], dlg_settings_tabsize4, 8*4, 0
	invoke	SetDlgItemInt, [.hWnd], dlg_settings_tabsize5, 8*5, 0
endf
	jmp	.wp_end

.wp_init:
frame
	invoke	SetWindowTextW, [.hWnd], [title_dlg_settings]

	invoke	GetDlgItem, [.hWnd], dlg_settings_codepage_select
	mov	[hCodePageComboBox], rax
	stdcall	set_codepages_list

	invoke	CheckDlgButton, [.hWnd], dlg_settings_delete_old_labels, [config_delete_old_labels]
	invoke	CheckDlgButton, [.hWnd], dlg_settings_import_labels, [config_import_labels]
	invoke	CheckDlgButton, [.hWnd], dlg_settings_delete_old_comments, [config_delete_old_comments]
	invoke	CheckDlgButton, [.hWnd], dlg_settings_import_sources, [config_import_sources]
	invoke	CheckDlgButton, [.hWnd], dlg_settings_append_labels, [config_append_labels]
	invoke	CheckDlgButton, [.hWnd], dlg_settings_remove_spaces, [config_remove_spaces]
	invoke	SetDlgItemInt, [.hWnd], dlg_settings_tabsize1, [config_tabsize1], 0
	invoke	SetDlgItemInt, [.hWnd], dlg_settings_tabsize2, [config_tabsize2], 0
	invoke	SetDlgItemInt, [.hWnd], dlg_settings_tabsize3, [config_tabsize3], 0
	invoke	SetDlgItemInt, [.hWnd], dlg_settings_tabsize4, [config_tabsize4], 0
	invoke	SetDlgItemInt, [.hWnd], dlg_settings_tabsize5, [config_tabsize5], 0
	invoke	CheckDlgButton, [.hWnd], dlg_settings_flag_MANUAL_labels, [config_flag_labels_manual]
	invoke	CheckDlgButton, [.hWnd], dlg_settings_flag_MANUAL_comments, [config_flag_comments_manual]
	invoke	CheckDlgButton, [.hWnd], dlg_settings_OFN_force, [config_OFN_force]

	stdcall	set_lng_dialog, [.hWnd], table_lang_dlg_settings

endf

.hide_opt_comments:
	push	rbx
	push	r12 ; stack align
	xor	ebx, ebx

frame
	invoke	IsDlgButtonChecked, [.hWnd], dlg_settings_import_sources
	test	rax, rax
	setnz	bl
	invoke	GetDlgItem, [.hWnd], dlg_settings_remove_spaces
	invoke	EnableWindow, rax, rbx
	invoke	GetDlgItem, [.hWnd], dlg_settings_append_labels
	invoke	EnableWindow, rax, rbx
	test	rbx, rbx
	jz	@f

	invoke	IsDlgButtonChecked, [.hWnd], dlg_settings_remove_spaces
	test	rax, rax
	setz	bl
@@:	invoke	GetDlgItem, [.hWnd], dlg_settings_tabsize_info
	invoke	EnableWindow, rax, rbx
	invoke	GetDlgItem, [.hWnd], dlg_settings_tabsize1
	invoke	EnableWindow, rax, rbx
	invoke	GetDlgItem, [.hWnd], dlg_settings_tabsize2
	invoke	EnableWindow, rax, rbx
	invoke	GetDlgItem, [.hWnd], dlg_settings_tabsize3
	invoke	EnableWindow, rax, rbx
	invoke	GetDlgItem, [.hWnd], dlg_settings_tabsize4
	invoke	EnableWindow, rax, rbx
	invoke	GetDlgItem, [.hWnd], dlg_settings_tabsize5
	invoke	EnableWindow, rax, rbx
	invoke	GetDlgItem, [.hWnd], dlg_settings_tabsize_def
	invoke	EnableWindow, rax, rbx
endf

	pop	r12
	pop	rbx

	jmp	.wp_end
endp



proc set_codepages_list
locals
 text_buffer rw MAX_PATH+200
 cp_info CPINFOEXW
endl

	push	rsi
	push	rdi
	push	rbx
	push	r12 ; stack align
frame
	invoke	SendMessageW, [hCodePageComboBox], CB_RESETCONTENT, 0, 0

	lea	rdi, [text_buffer]
	lea	rsi, [cp_info.CodePageName]
	lea	rbx, [cp_info]

	mov	word [rsi], 0
	invoke	GetACP
	invoke	GetCPInfoExW, rax, 0, rbx
	cinvoke	wnsprintfW, rdi, MAX_PATH+200, .t_acp_mask, rsi
	invoke	SendMessageW, [hCodePageComboBox], CB_ADDSTRING, 0, rdi
	invoke	SendMessageW, [hCodePageComboBox], CB_SETITEMDATA, rax, CP_ACP

	mov	word [rsi], 0
	invoke	GetOEMCP
	invoke	GetCPInfoExW, rax, 0, rbx
	cinvoke	wnsprintfW, rdi, MAX_PATH+200, .t_oem_mask, rsi
	invoke	SendMessageW, [hCodePageComboBox], CB_ADDSTRING, 0, rdi
	invoke	SendMessageW, [hCodePageComboBox], CB_SETITEMDATA, rax, CP_OEMCP

	invoke	SendMessageW, [hCodePageComboBox], CB_ADDSTRING, 0, .t_utf8
	invoke	SendMessageW, [hCodePageComboBox], CB_SETITEMDATA, rax, CP_UTF8

	invoke	EnumSystemCodePagesW, EnumCodePagesProc, CP_SUPPORTED

	invoke	SendMessageW, [hCodePageComboBox], CB_GETCURSEL, 0, 0
	test	rax, rax
	jns	.cp_set_ok
	mov	rax, [config_sources_codepage]
	xor	r8, r8
	cmp	rax, CP_ACP
	je	.cp_set_EDX
	inc	r8
	cmp	rax, CP_OEMCP
	je	.cp_set_EDX
	inc	r8
	cmp	rax, CP_UTF8
	je	.cp_set_EDX
	jmp	.cp_set_ok
.cp_set_EDX:
	invoke	SendMessageW, [hCodePageComboBox], CB_SETCURSEL, r8, 0
.cp_set_ok:
endf
	pop	r12
	pop	rbx
	pop	rdi
	pop	rsi
	ret

.t_acp_mask du "Windows default (%s)",0
.t_oem_mask du "DOS default (%s)",0
.t_utf8 du "UTF-8",0
endp



proc EnumCodePagesProc, .lpCodePageString
locals
 cp_info CPINFOEXW
endl
	push	rsi
	push	rdi
frame
	invoke	StrToIntW, rcx
	test	rax, rax
	jz	.m0
	cmp	rax, CP_UTF8 ; WIN/DOS/UTF8 are setting separately - at top of list
	je	.m0
	mov	rdi, rax

	lea	rsi, [cp_info.CodePageName]
	mov	word [rsi], 0

	lea	r8, [cp_info]
	invoke	GetCPInfoExW, rdi, 0, r8
	test	rax, rax
	jz	.m0
	cmp	word [rsi], 0
	je	.m0

	invoke	SendMessageW, [hCodePageComboBox], CB_ADDSTRING, 0, rsi
	mov	rsi, rax
	invoke	SendMessageW, [hCodePageComboBox], CB_SETITEMDATA, rax, rdi

	cmp	[config_sources_codepage], rdi
	jne	.m0
	invoke	SendMessageW, [hCodePageComboBox], CB_SETCURSEL, rsi, 0

.m0:
endf
	pop	rdi
	pop	rsi
	mov	eax, 1
	ret
endp



proc load_settings
locals
 temp_uint_value rq 1
endl
	push	rdi
	push	r12 ; stack align
frame
	lea	rdi, [temp_uint_value]

	cinvoke	BridgeSettingGetUint, t_SettingSection, t_Setting_codepage, rdi
	test	rax, rax
	jnz	@f
	mov	qword [rdi], rax
	@@:
	mov	rax, [rdi]
	mov	[config_sources_codepage], rax

	cinvoke	BridgeSettingGetUint, t_SettingSection, t_Setting_dellabels, rdi
	test	rax, rax
	jnz	@f
	mov	qword [rdi], 1
	@@:
	mov	rax, [rdi]
	mov	[config_delete_old_labels], rax

	cinvoke	BridgeSettingGetUint, t_SettingSection, t_Setting_labels, rdi
	test	rax, rax
	jnz	@f
	mov	qword [rdi], 1
	@@:
	mov	rax, [rdi]
	mov	[config_import_labels], rax

	cinvoke	BridgeSettingGetUint, t_SettingSection, t_Setting_delcomments, rdi
	test	rax, rax
	jnz	@f
	mov	qword [rdi], 1
	@@:
	mov	rax, [rdi]
	mov	[config_delete_old_comments], rax

	cinvoke	BridgeSettingGetUint, t_SettingSection, t_Setting_sources, rdi
	test	rax, rax
	jnz	@f
	mov	qword [rdi], 1
	@@:
	mov	rax, [rdi]
	mov	[config_import_sources], rax

	cinvoke	BridgeSettingGetUint, t_SettingSection, t_Setting_append, rdi
	test	rax, rax
	jnz	@f
	mov	qword [rdi], 1
	@@:
	mov	rax, [rdi]
	mov	[config_append_labels], rax

	cinvoke	BridgeSettingGetUint, t_SettingSection, t_Setting_spaces, rdi
	test	rax, rax
	jnz	@f
	mov	qword [rdi], rax
	@@:
	mov	rax, [rdi]
	mov	[config_remove_spaces], rax

	cinvoke	BridgeSettingGetUint, t_SettingSection, t_Setting_tabsize1, rdi
	test	rax, rax
	jnz	@f
	mov	qword [rdi], 8*1
	@@:
	mov	rax, [rdi]
	mov	[config_tabsize1], rax

	cinvoke	BridgeSettingGetUint, t_SettingSection, t_Setting_tabsize2, rdi
	test	rax, rax
	jnz	@f
	mov	qword [rdi], 8*2
	@@:
	mov	rax, [rdi]
	mov	[config_tabsize2], rax

	cinvoke	BridgeSettingGetUint, t_SettingSection, t_Setting_tabsize3, rdi
	test	rax, rax
	jnz	@f
	mov	qword [rdi], 8*3
	@@:
	mov	rax, [rdi]
	mov	[config_tabsize3], rax

	cinvoke	BridgeSettingGetUint, t_SettingSection, t_Setting_tabsize4, rdi
	test	rax, rax
	jnz	@f
	mov	qword [rdi], 8*4
	@@:
	mov	rax, [rdi]
	mov	[config_tabsize4], rax

	cinvoke	BridgeSettingGetUint, t_SettingSection, t_Setting_tabsize5, rdi
	test	rax, rax
	jnz	@f
	mov	qword [rdi], 8*5
	@@:
	mov	rax, [rdi]
	mov	[config_tabsize5], rax

	stdcall	tabsize_check_ranges

	cinvoke	BridgeSettingGetUint, t_SettingSection, t_Setting_flag_labels_manual, rdi
	test	rax, rax
	jnz	@f
	mov	dword [rdi], 0
	@@:
	mov	rax, [rdi]
	mov	[config_flag_labels_manual], rax

	cinvoke	BridgeSettingGetUint, t_SettingSection, t_Setting_flag_comments_manual, rdi
	test	rax, rax
	jnz	@f
	mov	qword [rdi], 0
	@@:
	mov	rax, [rdi]
	mov	[config_flag_comments_manual], rax

	cinvoke	BridgeSettingGetUint, t_SettingSection, t_Setting_OFN_force, rdi
	test	rax, rax
	jnz	@f
	mov	qword [rdi], 0
	@@:
	mov	rax, [rdi]
	mov	[config_OFN_force], rax
endf
	pop	r12
	pop	rdi
	ret
endp


proc save_settings
frame
	cinvoke	BridgeSettingSetUint, t_SettingSection, t_Setting_codepage, [config_sources_codepage]
	cinvoke	BridgeSettingSetUint, t_SettingSection, t_Setting_dellabels, [config_delete_old_labels]
	cinvoke	BridgeSettingSetUint, t_SettingSection, t_Setting_labels, [config_import_labels]
	cinvoke	BridgeSettingSetUint, t_SettingSection, t_Setting_delcomments, [config_delete_old_comments]
	cinvoke	BridgeSettingSetUint, t_SettingSection, t_Setting_sources, [config_import_sources]
	cinvoke	BridgeSettingSetUint, t_SettingSection, t_Setting_append, [config_append_labels]
	cinvoke	BridgeSettingSetUint, t_SettingSection, t_Setting_spaces, [config_remove_spaces]
	cinvoke	BridgeSettingSetUint, t_SettingSection, t_Setting_tabsize1, [config_tabsize1]
	cinvoke	BridgeSettingSetUint, t_SettingSection, t_Setting_tabsize2, [config_tabsize2]
	cinvoke	BridgeSettingSetUint, t_SettingSection, t_Setting_tabsize3, [config_tabsize3]
	cinvoke	BridgeSettingSetUint, t_SettingSection, t_Setting_tabsize4, [config_tabsize4]
	cinvoke	BridgeSettingSetUint, t_SettingSection, t_Setting_tabsize5, [config_tabsize5]
	cinvoke	BridgeSettingSetUint, t_SettingSection, t_Setting_flag_labels_manual, [config_flag_labels_manual]
	cinvoke	BridgeSettingSetUint, t_SettingSection, t_Setting_flag_comments_manual, [config_flag_comments_manual]
	cinvoke	BridgeSettingSetUint, t_SettingSection, t_Setting_OFN_force, [config_OFN_force]
endf
	ret
endp


proc tabsize_check_ranges

	mov	rax, [config_tabsize1]
	cmp	rax, 1
	jae	@f
	mov	eax, 4
	@@:
	cmp	rax, 30
	jbe	@f
	mov	eax, 30
	@@:
	mov	[config_tabsize1],rax

	mov	rdx, rax
	mov	rax, [config_tabsize2]
	test	rax, rax
	jnz	@f
	lea	rax, [rdx+8]
	@@:
	cmp	rax, rdx
	ja	@f
	lea	rax, [rdx+1]
	@@:
	cmp	rax, 90
	jbe	@f
	mov	eax, 90
	@@:
	mov	[config_tabsize2], rax

	mov	rdx, rax
	mov	rax, [config_tabsize3]
	test	rax, rax
	jnz	@f
	lea	rax, [rdx+8]
	@@:
	cmp	rax, rdx
	ja	@f
	lea	rax, [rdx+1]
	@@:
	cmp	rax, 92
	jbe	@f
	mov	eax, 92
	@@:
	mov	[config_tabsize3], rax
	
	mov	rdx, rax
	mov	rax, [config_tabsize4]
	test	rax, rax
	jnz	@f
	lea	rax, [rdx+8]
	@@:
	cmp	rax, rdx
	ja	@f
	lea	rax, [rdx+1]
	@@:
	cmp	rax, 94
	jbe	@f
	mov	eax, 94
	@@:
	mov	[config_tabsize4], rax

	mov	rdx, rax
	mov	rax, [config_tabsize5]
	test	rax, rax
	jnz	@f
	lea	rax, [rdx+8]
	@@:
	cmp	rax, rdx
	ja	@f
	lea	rax, [rdx+1]
	@@:
	cmp	rax, 96
	jbe	@f
	mov	eax, 96
	@@:
	mov	[config_tabsize5], rax

	ret
endp
