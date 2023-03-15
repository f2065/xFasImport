
proc RunAboutDlg
	invoke	DialogBoxParamA, [hInstance], ID_DLG_ABOUT, [hwndDlg], DialogProcAbout, 0
	ret
endp



proc DialogProcAbout, .hWnd, .uMsg, .wParam, .lParam
locals
 text_buff_temp sized dw 300+MAX_PATH dup (?)
endl
	mov	[.hWnd], rcx
	cmp	rdx, WM_COMMAND
	je	.wp_cmd
	cmp	rdx, WM_CLOSE
	je	.about_cancel
	cmp	rdx, WM_NOTIFY
	je	.wp_ntf
	cmp	rdx, WM_INITDIALOG
	je	.wp_init
.wp_end:
	xor	eax, eax
	ret

.wp_cmd:

	cmp	r8, dlg_about_close
	je	.about_cancel
	jmp	.wp_end

.wp_init:
frame
	invoke	SetWindowTextW, [.hWnd], [title_dlg_about]
	stdcall	set_lng_dialog, [.hWnd], table_lang_dlg_about

	cmp	[lang_file_load], 0
	jnz	.check_lang_status2
	invoke	GetDlgItem, [.hWnd], dlg_about_lang_author
	invoke	ShowWindow, rax, SW_HIDE
	invoke	GetDlgItem, [.hWnd], dlg_about_lang_version
	invoke	ShowWindow, rax, SW_HIDE
	lea	rcx, [text_buff_temp]
	cinvoke	wnsprintfW, rcx, (sizeof.text_buff_temp)/2, .text_status_internal_lang, currentLocale
	lea	r8, [text_buff_temp]
	jmp	.set_lang_status
.check_lang_status2:
	mov	r8, [msg_incomplete_translation]
	cmp	[lang_file_incomplete], 0
	jnz	.set_lang_status
	lea	r8, [text_empty]
.set_lang_status:
	invoke	SetDlgItemTextW, [.hWnd], dlg_about_lang_status, r8
endf
	jmp	.wp_end

.about_cancel:
	invoke	EndDialog, [.hWnd], 0
	jmp	.wp_end

.wp_ntf:

	lea	rcx, [table_author_url]
	cmp	r8, dlg_about_author_url
	je	.wp_ntf_URL
	lea	rcx, [table_sources_url]
	cmp	r8, dlg_about_sources_url
	je	.wp_ntf_URL
	lea	rcx, [table_forum_url]
	cmp	r8, dlg_about_forum_url
	je	.wp_ntf_URL
	jmp	.wp_end
.wp_ntf_URL:

	mov	edx, [r9+NMHDR.code]
	cmp	edx, NM_CLICK
	je	@f
	cmp	edx, NM_RETURN
	jne	.wp_end
	@@:
	mov	eax, [r9+NMLINK.item.iLink]
	cmp	eax, 3
	jb	@f
	xor	eax, eax
	@@:
;	lea	rcx, [.url_list]
	mov	r8, [rcx+(rax*memsize)]
	invoke	ShellExecuteA, 0, .t_openA, r8, 0, 0, SW_SHOW
	jmp	.wp_end

.t_openA db "open",0

.text_status_internal_lang du "Language file 'xFasImport_%s.lng' not found, built-in English will be used",0

endp
