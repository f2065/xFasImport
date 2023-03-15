
align memsize

table_lang:

menu_LoadMainSymbols DWORD_PTR menu_LoadMainSymbols_en, var_menu_LoadMainSymbols
menu_LoadDllSymbols DWORD_PTR menu_LoadDllSymbols_en, var_menu_LoadDllSymbols
menu_Settings DWORD_PTR menu_Settings_en, var_menu_Settings
menu_FasFileTest DWORD_PTR menu_FasFileTest_en, var_menu_FasFileTest
menu_About DWORD_PTR menu_About_en, var_menu_About

msg_err_pe_header DWORD_PTR msg_err_pe_header_en, var_msg_err_pe_header
msg_no_asm_dump DWORD_PTR msg_no_asm_dump_en, var_msg_no_asm_dump
msg_invalid_fas_header DWORD_PTR msg_invalid_fas_header_en, var_msg_invalid_fas_header
msg_invalid_filesize DWORD_PTR msg_invalid_filesize_en, var_msg_invalid_filesize

msg_openfilename_title DWORD_PTR msg_openfilename_title_en, var_msg_openfilename_title
msg_openfilename_ext_fas DWORD_PTR msg_openfilename_ext_fas_en, var_msg_openfilename_ext_fas
msg_openfilename_ext_all DWORD_PTR msg_openfilename_ext_all_en, var_msg_openfilename_ext_all
msg_opened_symbol_file_S DWORD_PTR msg_opened_symbol_file_S_en, var_msg_opened_symbol_file_S

msg_MsgErr_object DWORD_PTR msg_MsgErr_object_en, var_msg_MsgErr_object
msg_MsgErr_loc DWORD_PTR msg_MsgErr_loc_en, var_msg_MsgErr_loc
msg_MsgErr_err DWORD_PTR msg_MsgErr_err_en, var_msg_MsgErr_err

msg_import_labels_off DWORD_PTR msg_import_labels_off_en, var_msg_import_labels_off
msg_import_sources_off DWORD_PTR msg_import_sources_off_en, var_msg_import_sources_off
msg_result_info_U_U DWORD_PTR msg_result_info_U_U_en, var_msg_result_info_U_U
msg_result_warning1 DWORD_PTR msg_result_warning1_en, var_msg_result_warning1
msg_result_warning2 DWORD_PTR msg_result_warning2_en, var_msg_result_warning2
msg_result_warning3 DWORD_PTR msg_result_warning3_en, var_msg_result_warning3

msg_symbols_loaded_U DWORD_PTR msg_symbols_loaded_U_en, var_msg_symbols_loaded_U
msg_comments_loaded_U DWORD_PTR msg_comments_loaded_U_en, var_msg_comments_loaded_U

title_dlg_settings DWORD_PTR title_dlg_settings_en, var_title_dlg_settings

title_dlg_dll DWORD_PTR title_dlg_dll_en, var_title_dlg_dll
dlg_dll_listview_module DWORD_PTR dlg_dll_listview_module_en, var_dlg_dll_listview_module
dlg_dll_listview_baseaddr DWORD_PTR dlg_dll_listview_baseaddr_en, var_dlg_dll_listview_baseaddr
dlg_dll_listview_imagename DWORD_PTR dlg_dll_listview_imagename_en, var_dlg_dll_listview_imagename
dlg_dll_listview_filetime DWORD_PTR dlg_dll_listview_filetime_en, var_dlg_dll_listview_filetime

title_dlg_about DWORD_PTR title_dlg_about_en, var_title_dlg_about
msg_incomplete_translation DWORD_PTR msg_incomplete_translation_en, var_msg_incomplete_translation

title_dlg_FasFileTest DWORD_PTR title_dlg_FasFileTest_en, var_title_dlg_FasFileTest
dlg_FasFileTest_listview_data DWORD_PTR dlg_FasFileTest_listview_data_en, var_dlg_FasFileTest_listview_data
dlg_FasFileTest_listview_filepath DWORD_PTR dlg_FasFileTest_listview_filepath_en, var_dlg_FasFileTest_listview_filepath
dlg_FasFileTest_listview_filetime DWORD_PTR dlg_FasFileTest_listview_filetime_en, var_dlg_FasFileTest_listview_filetime
dlg_FasFileTest_listview_status DWORD_PTR dlg_FasFileTest_listview_status_en, var_dlg_FasFileTest_listview_status
msg_FasFileTest_listview_status_time DWORD_PTR msg_FasFileTest_listview_status_time_en, var_msg_FasFileTest_listview_status_time
msg_FasFileTest_listview_status_ok DWORD_PTR msg_FasFileTest_listview_status_ok_en, var_msg_FasFileTest_listview_status_ok

	DWORD_PTR 0, 0 ; end

var_menu_LoadMainSymbols du "menu_LoadMainSymbols",0
menu_LoadMainSymbols_en du "Load .fas-file for main process",0

var_menu_LoadDllSymbols du "menu_LoadDllSymbols",0
menu_LoadDllSymbols_en du "Load .fas-file for DLL",0

var_menu_Settings du "menu_Settings",0
menu_Settings_en du "Settings",0

var_menu_FasFileTest du "menu_FasFileTest",0
menu_FasFileTest_en du "Test external links in .fas-file",0

var_menu_About du "menu_About",0
menu_About_en du "About",0

var_msg_err_pe_header du "msg_err_pe_header",0
msg_err_pe_header_en du "Invalid or unsupported PE header",0

var_msg_no_asm_dump du "msg_no_asm_dump",0
msg_no_asm_dump_en du "Input fas-file does not contain an assembly dump",0
var_msg_invalid_fas_header du "msg_invalid_fas_header",0
msg_invalid_fas_header_en du "Invalid or unsupported fas-header",0
var_msg_invalid_filesize du "msg_invalid_filesize",0
msg_invalid_filesize_en du "Invalid file size (size must be greater than 0 B and less than 2 GiB).",0

var_msg_openfilename_title du "msg_openfilename_title",0
msg_openfilename_title_en du "Select fasm symbolic information file",0

var_msg_openfilename_ext_fas du "msg_openfilename_ext_fas",0
msg_openfilename_ext_fas_en du "fasm symbol files (*.fas)",0
var_msg_openfilename_ext_all du "msg_openfilename_ext_all",0
msg_openfilename_ext_all_en du "all files (*)",0

var_msg_opened_symbol_file_S du "msg_opened_symbol_file_S",0
msg_opened_symbol_file_S_en du "Symbol file: %s",0

var_msg_MsgErr_object du "msg_MsgErr_object",0
msg_MsgErr_object_en du "Processed object",0
var_msg_MsgErr_loc du "msg_MsgErr_location",0
msg_MsgErr_loc_en du "Internal error location",0
var_msg_MsgErr_err du "msg_MsgErr_errcode",0
msg_MsgErr_err_en du "System Error Code",0

var_msg_import_labels_off du "msg_import_labels_off",0
msg_import_labels_off_en du "Labels import is disabled in settings.",0

var_msg_import_sources_off du "msg_import_sources_off",0
msg_import_sources_off_en du "Sources import is disabled in settings.",0

var_msg_result_info_U_U du "msg_result_info_U_U",0
msg_result_info_U_U_en du "Result: %u symbols and %u comments loaded.",0

var_msg_result_warning1 du "msg_result_warning1",0
msg_result_warning1_en du "Warning: The FAS-file is older than the executable program, it is likely that the FAS-file does not match this assembly and the data imported from it is not correct.",0
var_msg_result_warning2 du "msg_result_warning2",0
msg_result_warning2_en du "Warning: Some source files are newer than the FAS-file, probably the source was changed after the build and the data imported from it is not correct.",0
var_msg_result_warning3 du "msg_result_warning3",0
msg_result_warning3_en du "Warning: The FAS-file is older than the executable and source files, it is likely that the FAS-file does not match this assembly and the imported data is not correct.",0

var_msg_symbols_loaded_U du "msg_symbols_loaded_U",0
msg_symbols_loaded_U_en du "%u symbols loaded", 0

var_msg_comments_loaded_U du "msg_comments_loaded_U",0
msg_comments_loaded_U_en du "%u comments loaded",0

var_title_dlg_settings du "dlg_settings",0
title_dlg_settings_en du "xFasImport Settings",0

var_title_dlg_dll du "dlg_dll",0
title_dlg_dll_en du "Load .fas-file for DLL",0

var_dlg_dll_listview_module du "dlg_dll_listview_module",0
dlg_dll_listview_module_en du "Module",0
var_dlg_dll_listview_baseaddr du "dlg_dll_listview_baseaddr",0
dlg_dll_listview_baseaddr_en du "Base load address",0 ; base load address of module
var_dlg_dll_listview_imagename du "dlg_dll_listview_imagename",0
dlg_dll_listview_imagename_en du "ImageName",0 ; image full filename
var_dlg_dll_listview_filetime du "dlg_dll_listview_filetime",0
dlg_dll_listview_filetime_en du "File modification time",0


var_title_dlg_about du "dlg_about",0
title_dlg_about_en du "About",0
var_msg_incomplete_translation du "msg_incomplete_translation",0
msg_incomplete_translation_en du "The translation is outdated or incomplete - some strings were not found.",0

var_title_dlg_FasFileTest du "dlg_FasFileTest",0
title_dlg_FasFileTest_en du "Test external links in .fas-file",0

var_dlg_FasFileTest_listview_data du "dlg_FasFileTest_listview_data",0
dlg_FasFileTest_listview_data_en du "Link",0
var_dlg_FasFileTest_listview_filepath du "dlg_FasFileTest_listview_filepath",0
dlg_FasFileTest_listview_filepath_en du "Full filename",0
var_dlg_FasFileTest_listview_filetime du "dlg_FasFileTest_listview_filetime",0
dlg_FasFileTest_listview_filetime_en du "File modification time",0
var_dlg_FasFileTest_listview_status du "dlg_FasFileTest_listview_status",0
dlg_FasFileTest_listview_status_en du "Status",0

var_msg_FasFileTest_listview_status_time du "msg_FasFileTest_listview_status_time",0
msg_FasFileTest_listview_status_time_en du "Warning, the file has been modified after the .fas-file",0
var_msg_FasFileTest_listview_status_ok du "msg_FasFileTest_listview_status_ok",0
msg_FasFileTest_listview_status_ok_en du "OK",0


align memsize
table_lang_dlg_settings:
	DWORD_PTR text_dlg_settings_codepage_info_en, var_dlg_settings_codepage_info, dlg_settings_codepage_info
	DWORD_PTR text_dlg_settings_delete_old_labels_en, var_dlg_settings_delete_old_labels, dlg_settings_delete_old_labels
	DWORD_PTR text_dlg_settings_import_labels_en, var_dlg_settings_import_labels, dlg_settings_import_labels
	DWORD_PTR text_dlg_settings_delete_old_comments_en, var_dlg_settings_delete_old_comments, dlg_settings_delete_old_comments
	DWORD_PTR text_dlg_settings_import_sources_en, var_dlg_settings_import_sources, dlg_settings_import_sources
	DWORD_PTR text_dlg_settings_append_labels_en, var_dlg_settings_append_labels, dlg_settings_append_labels
	DWORD_PTR text_dlg_settings_remove_spaces_en, var_dlg_settings_remove_spaces, dlg_settings_remove_spaces
	DWORD_PTR text_dlg_settings_tabsize_info_en, var_dlg_settings_tabsize_info, dlg_settings_tabsize_info
	DWORD_PTR text_dlg_settings_tabsize_def_en, var_dlg_settings_tabsize_def, dlg_settings_tabsize_def
	DWORD_PTR text_dlg_settings_tabsize_def_en, var_dlg_settings_tabsize_def, dlg_settings_tabsize_def
	DWORD_PTR text_dlg_settings_tabsize_def_en, var_dlg_settings_tabsize_def, dlg_settings_tabsize_def
	DWORD_PTR text_dlg_settings_tabsize_def_en, var_dlg_settings_tabsize_def, dlg_settings_tabsize_def
	DWORD_PTR text_dlg_settings_flag_MANUAL_labels_en, var_dlg_settings_flag_MANUAL_labels, dlg_settings_flag_MANUAL_labels
	DWORD_PTR text_dlg_settings_flag_MANUAL_comments_en, var_dlg_settings_flag_MANUAL_comments, dlg_settings_flag_MANUAL_comments
	DWORD_PTR text_dlg_settings_flags_info_en, var_dlg_settings_flags_info, dlg_settings_flags_info
	DWORD_PTR text_dlg_settings_OFN_force_en, var_dlg_settings_OFN_force, dlg_settings_OFN_force
	DWORD_PTR text_dlg_ok_en, var_dlg_ok, dlg_settings_ok
	DWORD_PTR text_dlg_cancel_en, var_dlg_cancel, dlg_settings_cancel
	DWORD_PTR 0,0,0 ; end


var_dlg_settings_codepage_info du "dlg_settings_codepage_info",0
text_dlg_settings_codepage_info_en du "Source text codepage",0

var_dlg_settings_delete_old_labels du "dlg_settings_delete_old_labels", 0
text_dlg_settings_delete_old_labels_en du "Delete all old labels before import",0

var_dlg_settings_import_labels du "dlg_settings_import_labels",0
text_dlg_settings_import_labels_en du "Import labels",0

var_dlg_settings_delete_old_comments du "dlg_settings_delete_old_comments",0
text_dlg_settings_delete_old_comments_en du "Delete all old comments before import",0

var_dlg_settings_import_sources du "dlg_settings_import_sources",0
text_dlg_settings_import_sources_en du "Import sources (to comment fields)",0

var_dlg_settings_append_labels du "dlg_settings_append_labels",0
text_dlg_settings_append_labels_en du "Append labels before source line (in comment fields)",0

var_dlg_settings_remove_spaces du "dlg_settings_remove_spaces",0
text_dlg_settings_remove_spaces_en du "Remove all consecutive spaces (0x20,0x20) and tab (0x09) in the sources",0

var_dlg_settings_tabsize_info du "dlg_settings_tabsize_info",0
text_dlg_settings_tabsize_info_en du "Tab character (0x09) indents",0

var_dlg_settings_tabsize_def du "dlg_settings_tabsize_def",0
text_dlg_settings_tabsize_def_en du "set default tabs (8*n)",0

var_dlg_settings_flag_MANUAL_labels du "dlg_settings_flag_MANUAL_labels",0
text_dlg_settings_flag_MANUAL_labels_en du "Use flag MANUAL for labels (otherwise use flag AUTO)",0

var_dlg_settings_flag_MANUAL_comments du "dlg_settings_flag_MANUAL_comments",0
text_dlg_settings_flag_MANUAL_comments_en du "Use flag MANUAL for comments (otherwise use flag AUTO)",0

var_dlg_settings_flags_info du "dlg_settings_flags_info",0
text_dlg_settings_flags_info_en du "These options affect conflict situations when using other methods",13,10,"(from other plugins, manually, etc.) of adding labels and comments to the x64dbg database.",0

var_dlg_settings_OFN_force du "dlg_settings_OFN_force",0
text_dlg_settings_OFN_force_en du "Always use the file selection dialog (otherwise, search by mask first)",0

var_dlg_ok du "dlg_ok",0
text_dlg_ok_en du "OK",0

var_dlg_cancel du "dlg_cancel",0
text_dlg_cancel_en du "Cancel",0

var_dlg_close du "dlg_close",0
text_dlg_close_en du "Close",0


align memsize
table_lang_dlg_dll:
	DWORD_PTR text_dlg_cancel_en, var_dlg_cancel, dlg_dll_cancel
	DWORD_PTR text_dlg_dll_load_en, var_dlg_dll_load, dlg_dll_load
	DWORD_PTR 0,0,0 ; end

var_dlg_dll_load du "dlg_dll_load",0
text_dlg_dll_load_en du "Load .fas file",0

align memsize
table_lang_dlg_FasFileTest:
	DWORD_PTR text_dlg_close_en, var_dlg_close, dlg_FasFileTest_close
	DWORD_PTR 0,0,0 ; end


align memsize
table_lang_dlg_about:
	DWORD_PTR text_dlg_about_version, 0, dlg_about_version
	DWORD_PTR text_dlg_about_desc1, 0, dlg_about_desc1
	DWORD_PTR text_dlg_about_author_en, var_dlg_about_author, dlg_about_author
	DWORD_PTR text_dlg_about_author_url, 0, dlg_about_author_url
	DWORD_PTR text_dlg_about_sources_en, var_dlg_about_sources, dlg_about_sources
	DWORD_PTR text_dlg_about_sources_url, 0, dlg_about_sources_url
	DWORD_PTR text_dlg_about_forum_en, var_dlg_about_forum, dlg_about_forum
	DWORD_PTR text_dlg_about_forum_url, 0, dlg_about_forum_url
	DWORD_PTR text_dlg_about_langcode, 0, dlg_about_langcode
	DWORD_PTR currentLocale, 0, dlg_about_langcode_data
	DWORD_PTR text_dlg_about_desc2_en, var_dlg_about_desc2, dlg_about_desc2
	DWORD_PTR text_dlg_about_help_fas_en, var_dlg_about_help_fas, dlg_about_help_fas
	DWORD_PTR text_dlg_close_en, var_dlg_close, dlg_about_close
	DWORD_PTR text_dlg_about_lang_author_en, var_dlg_about_lang_author, dlg_about_lang_author
	DWORD_PTR text_dlg_about_lang_version_en, var_dlg_about_lang_version, dlg_about_lang_version
	DWORD_PTR text_empty, var_lngfile_author, dlg_about_lang_author_data
	DWORD_PTR text_empty, var_lngfile_version, dlg_about_lang_version_data
	DWORD_PTR 0,0,0 ; end


if memsize = 4
text_dlg_about_version du "xFasImport v.",xFasImport_version_text,"  32-bit  (build ",__build_datetime_text__,")",0
else if memsize = 8
text_dlg_about_version du "xFasImport v.",xFasImport_version_text,"  64-bit  (build ",__build_datetime_text__,")",0
end if
text_dlg_about_desc1 du "Plugin for importing debug information from flat assembler into x64dbg (from .fas file)",0

var_dlg_about_author du "dlg_about_author",0
text_dlg_about_author_en du "Author",0
align memsize
table_author_url dd link_author_url1, link_author_url2
text_dlg_about_author_url du "<a>f2065.ru</a>  <a>support@f2065.ru</a>",0
link_author_url1 db "https:/f2065.ru",0
if memsize = 4
link_author_url2 db "mailto:support@f2065.ru?subject=xFasImport32",0
else if memsize = 8
link_author_url2 db "mailto:support@f2065.ru?subject=xFasImport64",0
end if

var_dlg_about_sources du "dlg_about_sources",0
text_dlg_about_sources_en du "Sources",0
align memsize
table_sources_url dd link_sources_url1
text_dlg_about_sources_url du "<a>https://github.com/f2065/xFasImport</a>",0
link_sources_url1 db "https://github.com/f2065/xFasImport",0

var_dlg_about_forum du "dlg_about_forum",0
text_dlg_about_forum_en du "Forum",0
align memsize
table_forum_url dd link_forum_url1
text_dlg_about_forum_url du "<a>https://board.flatassembler.net</a>",0
link_forum_url1 db "https://board.flatassembler.net/topic.php?t=22388",0


var_dlg_about_desc2 du "dlg_about_desc2",0
text_dlg_about_desc2_en du 0,0 ; this string is only used in localization
var_dlg_about_help_fas du "dlg_about_help_fas",0
text_dlg_about_help_fas_en du "To generate debug info (.fas file):",13,10,"for fasm.exe, use the -s switch (for example: fasm.exe test.asm -s test.fas test.exe),",13,10,"for fasmw.exe, use the Build symbols (Ctrl+F8) command.",0
text_dlg_about_langcode du "x64dbg language code",0
var_dlg_about_lang_author du "dlg_about_translation_author",0
text_dlg_about_lang_author_en du "Translation author",0
var_dlg_about_lang_version du "dlg_about_translation_version",0
text_dlg_about_lang_version_en du "Translation version",0
var_lngfile_author du "lngfile_author",0
var_lngfile_version du "lngfile_version",0

text_empty dw 0,0
