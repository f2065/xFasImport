

proc update_status_for_autoload
	mov	eax, [imported_labels_counter]
	or	eax, [imported_comments_counter]
	jz	.clear

	mov	eax, [timeImageFile]
	mov	[database_time_image], eax
	mov	eax, [timeFasFile]
	mov	[database_time_fas], eax
	jmp	.m0

.clear:	mov	[database_time_image], eax
	mov	[database_time_fas], eax

.m0:	ret
endp

proc autoload_fas_file
locals
 text_buffer sized dw 300 dup (?)
 current_time_image dd ?
 current_time_fas dd ?
endl
	cmp	[config_autoload_file], 1
	jne	.skip

	stdcall	get_time_from_file_W, tDbgMainFileName
	mov	[current_time_image], eax
	stdcall	set_buffFasFileName, tDbgMainFileName
	stdcall	get_time_from_file_W, buffFasFileName
	mov	[current_time_fas], eax

	lea	ecx, [text_buffer]
	cinvoke	wnsprintfW, ecx, (sizeof.text_buffer)/2, .t_autoload, [current_time_image], [current_time_fas], [database_time_image], [database_time_fas]
	lea	ecx, [text_buffer]
	stdcall	LogPrintW, ecx

	mov	edx, [current_time_image]
	test	edx, edx
	jz	.skip ; unknown error
	mov	eax, [current_time_fas]
	test	eax, eax
	jz	.skip ; no fas-file

	mov	ecx, [database_time_fas]
	test	ecx, ecx
	jz	.load1 ; fas-file not previously imported
	cmp	ecx, eax
	je	.skip ; this fas-file is already imported

.load1:	sub	edx, eax ; if the difference is more than 3 seconds - the file is foreign
	cmp	edx, 3
	jge	.skip
	cmp	edx, -3
	jle	.skip

	stdcall	LoadFasSymbols, tDbgMainFileName
	stdcall	update_status_for_autoload

.skip:	ret
.t_autoload: du "autoload_fas_file: current_time_image %08X, current_time_fas %08X, database_time_image %08X, database_time_fas %08X",0
endp

proc save_xFasImport_data, .json_root
locals
 hObject dd ?
endl

	cinvoke	json_object
	mov	[hObject], eax

	cinvoke	json_integer, [database_time_image], 0
	cinvoke	json_object_set_new, [hObject], t_DataBase_time_image, eax

	cinvoke	json_integer, [database_time_fas], 0
	cinvoke	json_object_set_new, [hObject], t_DataBase_time_fas, eax

	cinvoke	json_object_set_new, [.json_root], szPLUGIN_NAME_A, [hObject]
	ret
endp

proc load_xFasImport_data, .json_root
locals
 hObject dd ?
endl
	cinvoke	json_object_get, [.json_root], szPLUGIN_NAME_A
	mov	[hObject], eax

	cinvoke	json_object_get, [hObject], t_DataBase_time_image
	cinvoke	json_integer_value, eax
	mov	[database_time_image], eax

	cinvoke	json_object_get, [hObject], t_DataBase_time_fas
	cinvoke	json_integer_value, eax
	mov	[database_time_fas], eax

	ret
endp
