
proc RunSettingsDlg
	invoke	DialogBoxParamA, [hInstance], ID_DLG_SETTINGS, [hwndDlg], DialogProcSettings, 0
	ret
endp



proc DialogProcSettings, .hWnd, .uMsg, .wParam, .lParam

	cmp	[.uMsg], WM_COMMAND
	je	.wp_cmd
	cmp	[.uMsg], WM_CLOSE
	je	.settings_cancel
	cmp	[.uMsg], WM_INITDIALOG
	je	.wp_init
.wp_end:
	xor	eax, eax
	ret

.wp_cmd:
	mov	eax, [.wParam]
	cmp	eax, dlg_settings_ok
	je	.setting_ok
	cmp	eax, dlg_settings_cancel
	je	.settings_cancel
	cmp	eax, dlg_settings_import_sources
	je	.hide_opt_comments
	cmp	eax, dlg_settings_remove_spaces
	je	.hide_opt_comments
	cmp	eax, dlg_settings_tabsize_def
	je	.tabsize_def
	jmp	.wp_end

.setting_ok:

	invoke	SendMessageW, [hCodePageComboBox], CB_GETCURSEL, 0, 0
	test	eax, eax
	js	.cp_err
	invoke	SendMessageW, [hCodePageComboBox], CB_GETITEMDATA, eax, 0
	mov	[config_sources_codepage], eax
	jmp	.cp_end
.cp_err:
	mov	[config_sources_codepage], 0
.cp_end:

	invoke	IsDlgButtonChecked, [.hWnd], dlg_settings_delete_old_labels
	mov	[config_delete_old_labels], eax
	invoke	IsDlgButtonChecked, [.hWnd], dlg_settings_import_labels
	mov	[config_import_labels], eax
	invoke	IsDlgButtonChecked, [.hWnd], dlg_settings_delete_old_comments
	mov	[config_delete_old_comments], eax
	invoke	IsDlgButtonChecked, [.hWnd], dlg_settings_import_sources
	mov	[config_import_sources], eax
	invoke	IsDlgButtonChecked, [.hWnd], dlg_settings_append_labels
	mov	[config_append_labels], eax
	invoke	IsDlgButtonChecked, [.hWnd], dlg_settings_remove_spaces
	mov	[config_remove_spaces], eax

	invoke	GetDlgItemInt, [.hWnd], dlg_settings_tabsize1, 0, 0
	mov	[config_tabsize1], eax
	invoke	GetDlgItemInt, [.hWnd], dlg_settings_tabsize2, 0, 0
	mov	[config_tabsize2], eax
	invoke	GetDlgItemInt, [.hWnd], dlg_settings_tabsize3, 0, 0
	mov	[config_tabsize3], eax
	invoke	GetDlgItemInt, [.hWnd], dlg_settings_tabsize4, 0, 0
	mov	[config_tabsize4], eax
	invoke	GetDlgItemInt, [.hWnd], dlg_settings_tabsize5, 0, 0
	mov	[config_tabsize5], eax
	stdcall	tabsize_check_ranges

	invoke	IsDlgButtonChecked, [.hWnd], dlg_settings_flag_MANUAL_labels
	mov	[config_flag_labels_manual], eax
	invoke	IsDlgButtonChecked, [.hWnd], dlg_settings_flag_MANUAL_comments
	mov	[config_flag_comments_manual], eax
	invoke	IsDlgButtonChecked, [.hWnd], dlg_settings_OFN_force
	mov	[config_OFN_force], eax

	stdcall	save_settings

.settings_cancel:
	invoke	EndDialog, [.hWnd], 0
	jmp	.wp_end

.tabsize_def:

	invoke	SetDlgItemInt, [.hWnd], dlg_settings_tabsize1, 8*1, 0
	invoke	SetDlgItemInt, [.hWnd], dlg_settings_tabsize2, 8*2, 0
	invoke	SetDlgItemInt, [.hWnd], dlg_settings_tabsize3, 8*3, 0
	invoke	SetDlgItemInt, [.hWnd], dlg_settings_tabsize4, 8*4, 0
	invoke	SetDlgItemInt, [.hWnd], dlg_settings_tabsize5, 8*5, 0

	jmp	.wp_end
	
.wp_init:

	invoke	SetWindowTextW, [.hWnd], [title_dlg_settings]

	invoke	GetDlgItem, [.hWnd], dlg_settings_codepage_select
	mov	[hCodePageComboBox], eax
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



.hide_opt_comments:
	push	ebx

	xor	ebx, ebx


	invoke	IsDlgButtonChecked, [.hWnd], dlg_settings_import_sources
	test	eax, eax
	setnz	bl
	invoke	GetDlgItem, [.hWnd], dlg_settings_remove_spaces
	invoke	EnableWindow, eax, ebx
	invoke	GetDlgItem, [.hWnd], dlg_settings_append_labels
	invoke	EnableWindow, eax, ebx
	test	ebx, ebx
	jz	@f
	
	invoke	IsDlgButtonChecked, [.hWnd], dlg_settings_remove_spaces
	test	eax, eax
	setz	bl
@@:	invoke	GetDlgItem, [.hWnd], dlg_settings_tabsize_info
	invoke	EnableWindow, eax, ebx
	invoke	GetDlgItem, [.hWnd], dlg_settings_tabsize1
	invoke	EnableWindow, eax, ebx
	invoke	GetDlgItem, [.hWnd], dlg_settings_tabsize2
	invoke	EnableWindow, eax, ebx
	invoke	GetDlgItem, [.hWnd], dlg_settings_tabsize3
	invoke	EnableWindow, eax, ebx
	invoke	GetDlgItem, [.hWnd], dlg_settings_tabsize4
	invoke	EnableWindow, eax, ebx
	invoke	GetDlgItem, [.hWnd], dlg_settings_tabsize5
	invoke	EnableWindow, eax, ebx
	invoke	GetDlgItem, [.hWnd], dlg_settings_tabsize_def
	invoke	EnableWindow, eax, ebx



	pop	ebx

	jmp	.wp_end
endp



proc set_codepages_list
locals
 text_buffer rw MAX_PATH+200
 cp_info CPINFOEXW
endl

	push	esi
	push	edi
	push	ebx


	invoke	SendMessageW, [hCodePageComboBox], CB_RESETCONTENT, 0, 0

	lea	edi, [text_buffer]
	lea	esi, [cp_info.CodePageName]
	lea	ebx, [cp_info]

	mov	word [esi], 0
	invoke	GetACP
	invoke	GetCPInfoExW, eax, 0, ebx
	cinvoke	wnsprintfW, edi, MAX_PATH+200, .t_acp_mask, esi
	invoke	SendMessageW, [hCodePageComboBox], CB_ADDSTRING, 0, edi
	invoke	SendMessageW, [hCodePageComboBox], CB_SETITEMDATA, eax, CP_ACP

	mov	word [esi], 0
	invoke	GetOEMCP
	invoke	GetCPInfoExW, eax, 0, ebx
	cinvoke	wnsprintfW, edi, MAX_PATH+200, .t_oem_mask, esi
	invoke	SendMessageW, [hCodePageComboBox], CB_ADDSTRING, 0, edi
	invoke	SendMessageW, [hCodePageComboBox], CB_SETITEMDATA, eax, CP_OEMCP

	invoke	SendMessageW, [hCodePageComboBox], CB_ADDSTRING, 0, .t_utf8
	invoke	SendMessageW, [hCodePageComboBox], CB_SETITEMDATA, eax, CP_UTF8

	invoke	EnumSystemCodePagesW, EnumCodePagesProc, CP_SUPPORTED

	invoke	SendMessageW, [hCodePageComboBox], CB_GETCURSEL, 0, 0
	test	eax, eax
	jns	.cp_set_ok
	mov	eax, [config_sources_codepage]
	xor	edx, edx
	cmp	eax, CP_ACP
	je	.cp_set_EDX
	inc	edx
	cmp	eax, CP_OEMCP
	je	.cp_set_EDX
	inc	edx
	cmp	eax, CP_UTF8
	je	.cp_set_EDX
	jmp	.cp_set_ok
.cp_set_EDX:
	invoke	SendMessageW, [hCodePageComboBox], CB_SETCURSEL, edx, 0
.cp_set_ok:


	pop	ebx
	pop	edi
	pop	esi
	ret

.t_acp_mask du "Windows default (%s)",0
.t_oem_mask du "DOS default (%s)",0
.t_utf8 du "UTF-8",0
endp



proc EnumCodePagesProc, .lpCodePageString
locals
 cp_info CPINFOEXW
endl
	push	esi
	push	edi

	invoke	StrToIntW, [.lpCodePageString]
	test	eax, eax
	jz	.m0
	cmp	eax, CP_UTF8 ; WIN/DOS/UTF8 are setting separately - at top of list
	je	.m0
	mov	edi, eax

	lea	esi, [cp_info.CodePageName]
	mov	word [esi], 0

	lea	edx, [cp_info]
	invoke	GetCPInfoExW, edi, 0, edx
	test	eax, eax
	jz	.m0
	cmp	word [esi], 0
	je	.m0

	invoke	SendMessageW, [hCodePageComboBox], CB_ADDSTRING, 0, esi
	mov	esi, eax
	invoke	SendMessageW, [hCodePageComboBox], CB_SETITEMDATA, eax, edi

	cmp	[config_sources_codepage], edi
	jne	.m0
	invoke	SendMessageW, [hCodePageComboBox], CB_SETCURSEL, esi, 0

.m0:

	pop	edi
	pop	esi
	mov	eax, 1
	ret
endp



proc load_settings
locals
 temp_uint_value rd 1
endl
	push	edi


	lea	edi, [temp_uint_value]

	cinvoke	BridgeSettingGetUint, t_SettingSection, t_Setting_codepage, edi
	test	eax, eax
	jnz	@f
	mov	dword [edi], eax
	@@:
	mov	eax, [edi]
	mov	[config_sources_codepage], eax

	cinvoke	BridgeSettingGetUint, t_SettingSection, t_Setting_dellabels, edi
	test	eax, eax
	jnz	@f
	mov	dword [edi], 1
	@@:
	mov	eax, [edi]
	mov	[config_delete_old_labels], eax

	cinvoke	BridgeSettingGetUint, t_SettingSection, t_Setting_labels, edi
	test	eax, eax
	jnz	@f
	mov	dword [edi], 1
	@@:
	mov	eax, [edi]
	mov	[config_import_labels], eax

	cinvoke	BridgeSettingGetUint, t_SettingSection, t_Setting_delcomments, edi
	test	eax, eax
	jnz	@f
	mov	dword [edi], 1
	@@:
	mov	eax, [edi]
	mov	[config_delete_old_comments], eax

	cinvoke	BridgeSettingGetUint, t_SettingSection, t_Setting_sources, edi
	test	eax, eax
	jnz	@f
	mov	dword [edi], 1
	@@:
	mov	eax, [edi]
	mov	[config_import_sources], eax

	cinvoke	BridgeSettingGetUint, t_SettingSection, t_Setting_append, edi
	test	eax, eax
	jnz	@f
	mov	dword [edi], 0
	@@:
	mov	eax, [edi]
	mov	[config_append_labels], eax

	cinvoke	BridgeSettingGetUint, t_SettingSection, t_Setting_spaces, edi
	test	eax, eax
	jnz	@f
	mov	dword [edi], eax
	@@:
	mov	eax, [edi]
	mov	[config_remove_spaces], eax

	cinvoke	BridgeSettingGetUint, t_SettingSection, t_Setting_tabsize1, edi
	test	eax, eax
	jnz	@f
	mov	dword [edi], 8*1
	@@:
	mov	eax, [edi]
	mov	[config_tabsize1], eax

	cinvoke	BridgeSettingGetUint, t_SettingSection, t_Setting_tabsize2, edi
	test	eax, eax
	jnz	@f
	mov	dword [edi], 8*2
	@@:
	mov	eax, [edi]
	mov	[config_tabsize2], eax

	cinvoke	BridgeSettingGetUint, t_SettingSection, t_Setting_tabsize3, edi
	test	eax, eax
	jnz	@f
	mov	dword [edi], 8*3
	@@:
	mov	eax, [edi]
	mov	[config_tabsize3], eax

	cinvoke	BridgeSettingGetUint, t_SettingSection, t_Setting_tabsize4, edi
	test	eax, eax
	jnz	@f
	mov	dword [edi], 8*4
	@@:
	mov	eax, [edi]
	mov	[config_tabsize4], eax

	cinvoke	BridgeSettingGetUint, t_SettingSection, t_Setting_tabsize5, edi
	test	eax, eax
	jnz	@f
	mov	dword [edi], 8*5
	@@:
	mov	eax, [edi]
	mov	[config_tabsize5], eax

	stdcall	tabsize_check_ranges

	cinvoke	BridgeSettingGetUint, t_SettingSection, t_Setting_flag_labels_manual, edi
	test	eax, eax
	jnz	@f
	mov	dword [edi], 0
	@@:
	mov	eax, [edi]
	mov	[config_flag_labels_manual], eax

	cinvoke	BridgeSettingGetUint, t_SettingSection, t_Setting_flag_comments_manual, edi
	test	eax, eax
	jnz	@f
	mov	dword [edi], 0
	@@:
	mov	eax, [edi]
	mov	[config_flag_comments_manual], eax

	cinvoke	BridgeSettingGetUint, t_SettingSection, t_Setting_OFN_force, edi
	test	eax, eax
	jnz	@f
	mov	dword [edi], 0
	@@:
	mov	eax, [edi]
	mov	[config_OFN_force], eax


	pop	edi
	ret
endp


proc save_settings

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

	ret
endp


proc tabsize_check_ranges

	mov	eax, [config_tabsize1]
	cmp	eax, 1
	jae	@f
	mov	eax, 4
	@@:
	cmp	eax, 30
	jbe	@f
	mov	eax, 30
	@@:
	mov	[config_tabsize1], eax

	mov	edx, eax
	mov	eax, [config_tabsize2]
	test	eax, eax
	jnz	@f
	lea	eax, [edx+8]
	@@:
	cmp	eax, edx
	ja	@f
	lea	eax, [edx+1]
	@@:
	cmp	eax, 90
	jbe	@f
	mov	eax, 90
	@@:
	mov	[config_tabsize2], eax

	mov	edx, eax
	mov	eax, [config_tabsize3]
	test	eax, eax
	jnz	@f
	lea	eax, [edx+8]
	@@:
	cmp	eax, edx
	ja	@f
	lea	eax, [edx+1]
	@@:
	cmp	eax, 92
	jbe	@f
	mov	eax, 92
	@@:
	mov	[config_tabsize3], eax
	
	mov	edx, eax
	mov	eax, [config_tabsize4]
	test	eax, eax
	jnz	@f
	lea	eax, [edx+8]
	@@:
	cmp	eax, edx
	ja	@f
	lea	eax, [edx+1]
	@@:
	cmp	eax, 94
	jbe	@f
	mov	eax, 94
	@@:
	mov	[config_tabsize4], eax

	mov	edx, eax
	mov	eax, [config_tabsize5]
	test	eax, eax
	jnz	@f
	lea	eax, [edx+8]
	@@:
	cmp	eax, edx
	ja	@f
	lea	eax, [edx+1]
	@@:
	cmp	eax, 96
	jbe	@f
	mov	eax, 96
	@@:
	mov	[config_tabsize5], eax

	ret
endp
