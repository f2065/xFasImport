
proc RunAboutDlg
	invoke	DialogBoxParamA, [hInstance], ID_DLG_ABOUT, [hwndDlg], DialogProcAbout, 0
	ret
endp



proc DialogProcAbout, .hWnd, .uMsg, .wParam, .lParam
locals
 text_buff_temp sized dw 300+MAX_PATH dup (?)
endl

	cmp	[.uMsg], WM_COMMAND
	je	.wp_cmd
	cmp	[.uMsg], WM_CLOSE
	je	.about_cancel
	cmp	[.uMsg], WM_NOTIFY
	je	.wp_ntf
	cmp	[.uMsg], WM_INITDIALOG
	je	.wp_init
.wp_end:
	xor	eax, eax
	ret

.wp_cmd:
	mov	eax, [.wParam]
	cmp	eax, dlg_about_close
	je	.about_cancel
	jmp	.wp_end

.wp_init:

	invoke	SetWindowTextW, [.hWnd], [title_dlg_about]
	stdcall	set_lng_dialog, [.hWnd], table_lang_dlg_about

	cmp	[lang_file_load], 0
	jnz	.check_lang_status2
	invoke	GetDlgItem, [.hWnd], dlg_about_lang_author
	invoke	ShowWindow, eax, SW_HIDE
	invoke	GetDlgItem, [.hWnd], dlg_about_lang_version
	invoke	ShowWindow, eax, SW_HIDE
	lea	ecx, [text_buff_temp]
	cinvoke	wnsprintfW, ecx, (sizeof.text_buff_temp)/2, .text_status_internal_lang, currentLocale
	lea	eax, [text_buff_temp]
	jmp	.set_lang_status
.check_lang_status2:
	mov	eax, [msg_incomplete_translation]
	cmp	[lang_file_incomplete], 0
	jnz	.set_lang_status
	lea	eax, [text_empty]
.set_lang_status:
	invoke	SetDlgItemTextW, [.hWnd], dlg_about_lang_status, eax

	jmp	.wp_end

.about_cancel:
	invoke	EndDialog, [.hWnd], 0
	jmp	.wp_end

.wp_ntf:
	mov	eax, [.wParam]
	lea	ecx, [table_author_url]
	cmp	eax, dlg_about_author_url
	je	.wp_ntf_URL
	lea	ecx, [table_sources_url]
	cmp	eax, dlg_about_sources_url
	je	.wp_ntf_URL
	lea	ecx, [table_forum_url]
	cmp	eax, dlg_about_forum_url
	je	.wp_ntf_URL
	jmp	.wp_end
.wp_ntf_URL:
	mov	eax, [.lParam]
	mov	edx, [eax+NMHDR.code]
	cmp	edx, NM_CLICK
	je	@f
	cmp	edx, NM_RETURN
	jne	.wp_end
	@@:
	mov	eax, [eax+NMLINK.item.iLink]
	cmp	eax, 3
	jb	@f
	xor	eax, eax
	@@:
;	lea	ecx, [.url_list]
	mov	ecx, [ecx+(eax*memsize)]
	invoke	ShellExecuteA, 0, .t_openA, ecx, 0, 0, SW_SHOW
	jmp	.wp_end

.t_openA db "open",0

.text_status_internal_lang du "Language file 'xFasImport_%s.lng' not found, built-in English will be used",0

endp
