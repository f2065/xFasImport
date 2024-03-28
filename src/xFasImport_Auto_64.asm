

proc update_status_for_autoload
	mov	rax, [imported_labels_counter]
	or	rax, [imported_comments_counter]
	jz	.clear

	mov	rax, [timeImageFile]
	mov	[database_time_image], rax
	mov	rax, [timeFasFile]
	mov	[database_time_fas], rax
	jmp	.m0

.clear:	mov	[database_time_image], rax
	mov	[database_time_fas], rax

.m0:	ret
endp

proc autoload_fas_file
locals
 text_buffer sized dw 300 dup (?)
 current_time_image dq ?
 current_time_fas dq ?
endl
	cmp	[config_autoload_file], 1
	jne	.skip

	stdcall	get_time_from_file_W, tDbgMainFileName
	mov	[current_time_image], rax
	stdcall	set_buffFasFileName, tDbgMainFileName
	stdcall	get_time_from_file_W, buffFasFileName
	mov	[current_time_fas], rax

	lea	rcx, [text_buffer]
	cinvoke	wnsprintfW, rcx, (sizeof.text_buffer)/2, .t_autoload, [current_time_image], [current_time_fas], [database_time_image], [database_time_fas]
	lea	rcx, [text_buffer]
	stdcall	LogPrintW, rcx

	mov	rdx, [current_time_image]
	test	rdx, rdx
	jz	.skip ; unknown error
	mov	rax, [current_time_fas]
	test	rax, rax
	jz	.skip ; no fas-file

	mov	rcx, [database_time_fas]
	test	rcx, rcx
	jz	.load1 ; fas-file not previously imported
	cmp	rcx, rax
	je	.skip ; this fas-file is already imported

.load1:	sub	rdx, rax ; if the difference is more than 3 seconds - the file is foreign
	cmp	rdx, 3
	jge	.skip
	cmp	rdx, -3
	jle	.skip

	stdcall	LoadFasSymbols, tDbgMainFileName
	stdcall	update_status_for_autoload

.skip:	ret
.t_autoload: du "autoload_fas_file: current_time_image %08X, current_time_fas %08X, database_time_image %08X, database_time_fas %08X",0
endp

proc save_xFasImport_data, .json_root
locals
 hObject dq ?
endl
	mov	[.json_root], rcx
	cinvoke	json_object
	mov	[hObject], rax

	cinvoke	json_integer, [database_time_image], 0
	cinvoke	json_object_set_new, [hObject], t_DataBase_time_image, rax

	cinvoke	json_integer, [database_time_fas], 0
	cinvoke	json_object_set_new, [hObject], t_DataBase_time_fas, rax

	cinvoke	json_object_set_new, [.json_root], szPLUGIN_NAME_A, [hObject]
	ret
endp

proc load_xFasImport_data, .json_root
locals
 hObject dq ?
endl
	cinvoke	json_object_get, rcx, szPLUGIN_NAME_A
	mov	[hObject], rax

	cinvoke	json_object_get, [hObject], t_DataBase_time_image
	cinvoke	json_integer_value, rax
	mov	[database_time_image], rax

	cinvoke	json_object_get, [hObject], t_DataBase_time_fas
	cinvoke	json_integer_value, rax
	mov	[database_time_fas], rax

	ret
endp
