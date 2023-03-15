
 resource dialogs,\
	ID_DLG_SETTINGS,LANG_ENGLISH+SUBLANG_DEFAULT,main_dlg,\
	ID_DLG_DLL,LANG_ENGLISH+SUBLANG_DEFAULT,dll_dlg,\
	ID_DLG_FASFILETEST,LANG_ENGLISH+SUBLANG_DEFAULT,dll_fasfiletest,\
	ID_DLG_ABOUT,LANG_ENGLISH+SUBLANG_DEFAULT,about_dlg

 dialog main_dlg,"xFasConv2 Settings",0,0,396,249,WS_CAPTION or DS_3DLOOK or WS_VISIBLE or WS_POPUP or WS_SYSMENU or DS_MODALFRAME or DS_CENTER,WS_EX_DLGMODALFRAME,,"Microsoft Sans Serif",8
	dialogitem "Static","Source text codepage",dlg_settings_codepage_info,12,9,87,12,WS_CHILDWINDOW or WS_VISIBLE or SS_CENTERIMAGE
	dialogitem "ComboBox","",dlg_settings_codepage_select,102,9,279,51,WS_CHILDWINDOW or WS_VISIBLE or WS_TABSTOP or CBS_DROPDOWNLIST or WS_VSCROLL or WS_HSCROLL
	dialogitem "Button","Delete all old labels before import",dlg_settings_delete_old_labels,12,27,372,12,WS_CHILDWINDOW or WS_VISIBLE or WS_TABSTOP or BS_AUTOCHECKBOX
	dialogitem "Button","Import labels",dlg_settings_import_labels,12,42,372,12,WS_CHILDWINDOW or WS_VISIBLE or WS_TABSTOP or BS_AUTOCHECKBOX
	dialogitem "Button","Delete all old comments before import",dlg_settings_delete_old_comments,12,63,372,12,WS_CHILDWINDOW or WS_VISIBLE or WS_TABSTOP or BS_AUTOCHECKBOX
	dialogitem "Button","Import sources (to comment fields)",dlg_settings_import_sources,12,78,372,12,WS_CHILDWINDOW or WS_VISIBLE or WS_TABSTOP or BS_AUTOCHECKBOX
	dialogitem "Button","Append labels before source line (in comment fields)",dlg_settings_append_labels,12,93,372,12,WS_CHILDWINDOW or WS_VISIBLE or WS_TABSTOP or BS_AUTOCHECKBOX
	dialogitem "Button","Remove all consecutive spaces (0x20,0x20) and tab (0x09) in the sources",dlg_settings_remove_spaces,12,108,372,12,WS_CHILDWINDOW or WS_VISIBLE or WS_TABSTOP or BS_AUTOCHECKBOX
	dialogitem "Static","Tab character (0x09) indents",dlg_settings_tabsize_info,12,123,108,12,WS_CHILDWINDOW or WS_VISIBLE or SS_CENTERIMAGE
	dialogitem "Edit","",dlg_settings_tabsize1,123,123,15,12,WS_CHILDWINDOW or WS_VISIBLE or WS_TABSTOP or ES_NUMBER or ES_CENTER,WS_EX_CLIENTEDGE
	dialogitem "Edit","",dlg_settings_tabsize2,144,123,15,12,WS_CHILDWINDOW or WS_VISIBLE or WS_TABSTOP or ES_NUMBER or ES_CENTER,WS_EX_CLIENTEDGE
	dialogitem "Edit","",dlg_settings_tabsize3,165,123,15,12,WS_CHILDWINDOW or WS_VISIBLE or WS_TABSTOP or ES_NUMBER or ES_CENTER,WS_EX_CLIENTEDGE
	dialogitem "Edit","",dlg_settings_tabsize4,186,123,15,12,WS_CHILDWINDOW or WS_VISIBLE or WS_TABSTOP or ES_NUMBER or ES_CENTER,WS_EX_CLIENTEDGE
	dialogitem "Edit","",dlg_settings_tabsize5,207,123,15,12,WS_CHILDWINDOW or WS_VISIBLE or WS_TABSTOP or ES_NUMBER or ES_CENTER,WS_EX_CLIENTEDGE
	dialogitem "Button","set default tabs (8*n)",dlg_settings_tabsize_def,243,123,105,12,WS_CHILDWINDOW or WS_VISIBLE or WS_TABSTOP
	dialogitem "Button","Use flag MANUAL for labels (otherwise use flag AUTO)",dlg_settings_flag_MANUAL_labels,12,144,372,12,WS_CHILDWINDOW or WS_VISIBLE or WS_TABSTOP or BS_AUTOCHECKBOX
	dialogitem "Button","Use flag MANUAL for comments (otherwise use flag AUTO)",dlg_settings_flag_MANUAL_comments,12,156,372,12,WS_CHILDWINDOW or WS_VISIBLE or WS_TABSTOP or BS_AUTOCHECKBOX
	dialogitem "Static",<"These options affect conflict situations when using other methods",13,10,"(from other plugins, manually, etc.) of adding labels and comments.">,dlg_settings_flags_info,12,168,372,21,WS_CHILDWINDOW or WS_VISIBLE
	dialogitem "Button","Always use file select dialog",dlg_settings_OFN_force,12,189,372,12,WS_CHILDWINDOW or WS_VISIBLE or WS_TABSTOP or BS_AUTOCHECKBOX
	dialogitem "Button","OK",dlg_settings_ok,91,216,72,15,WS_CHILDWINDOW or WS_VISIBLE or WS_TABSTOP or BS_DEFPUSHBUTTON
	dialogitem "Button","Cancel",dlg_settings_cancel,232,216,72,15,WS_CHILDWINDOW or WS_VISIBLE or WS_TABSTOP
 enddialog

 dialog about_dlg,"xFasConv2 About",0,0,351,201,WS_CAPTION or DS_3DLOOK or WS_VISIBLE or WS_POPUP or WS_SYSMENU or DS_MODALFRAME or DS_CENTER,WS_EX_DLGMODALFRAME,,"Microsoft Sans Serif",8
	dialogitem "Static","xFasImport v.1.0.0 (2022-07-19)",dlg_about_version,6,6,339,12,WS_CHILDWINDOW or WS_VISIBLE or SS_CENTER
	dialogitem "Static","Plugin for importing debug information from flat assembler into x64dbg (from .fas file)",dlg_about_desc1,6,18,339,12,WS_CHILDWINDOW or WS_VISIBLE or SS_CENTER
	dialogitem "Static","Author",dlg_about_author,6,33,138,12,WS_CHILDWINDOW or WS_VISIBLE or SS_RIGHT
	dialogitem "SysLink","dlg_about_author_url",dlg_about_author_url,147,33,153,12,WS_CHILDWINDOW or WS_VISIBLE or LWS_TRANSPARENT
	dialogitem "Static","Sources",dlg_about_sources,6,45,138,12,WS_CHILDWINDOW or WS_VISIBLE or SS_RIGHT
	dialogitem "SysLink","dlg_about_sources_url",dlg_about_sources_url,147,45,153,9,WS_CHILDWINDOW or WS_VISIBLE or LWS_TRANSPARENT
	dialogitem "Static","Forum",dlg_about_forum,6,57,138,12,WS_CHILDWINDOW or WS_VISIBLE or SS_RIGHT
	dialogitem "SysLink","dlg_about_forum_url",dlg_about_forum_url,147,57,153,12,WS_CHILDWINDOW or WS_VISIBLE or LWS_TRANSPARENT
	dialogitem "Static","dlg_about_desc2",dlg_about_desc2,6,75,339,9,WS_CHILDWINDOW or WS_VISIBLE or SS_CENTER
	dialogitem "Static","dlg_about_help_fas",dlg_about_help_fas,6,87,339,27,WS_CHILDWINDOW or WS_VISIBLE or SS_CENTER
	dialogitem "Static","System language code",dlg_about_langcode,6,126,138,9,WS_CHILDWINDOW or WS_VISIBLE or SS_RIGHT
	dialogitem "Static","ru",dlg_about_langcode_data,147,126,198,9,WS_CHILDWINDOW or WS_VISIBLE
	dialogitem "Static","Translation author",dlg_about_lang_author,6,138,138,9,WS_CHILDWINDOW or WS_VISIBLE or SS_RIGHT
	dialogitem "Static","f2065",dlg_about_lang_author_data,147,138,198,9,WS_CHILDWINDOW or WS_VISIBLE
	dialogitem "Static","Translation version",dlg_about_lang_version,6,150,138,9,WS_CHILDWINDOW or WS_VISIBLE or SS_RIGHT
	dialogitem "Static","1.0.0 (2022-07-26)",dlg_about_lang_version_data,147,150,198,9,WS_CHILDWINDOW or WS_VISIBLE
	dialogitem "Static","",dlg_about_lang_status,6,162,339,9,WS_CHILDWINDOW or WS_VISIBLE or SS_CENTER
	dialogitem "Button","Close",dlg_about_close,144,174,63,15,WS_CHILDWINDOW or WS_VISIBLE or WS_TABSTOP or BS_DEFPUSHBUTTON
 enddialog
  
 dialog dll_dlg,"Load .fas for DLL",0,0,519,183,WS_CAPTION or DS_3DLOOK or WS_VISIBLE or WS_POPUP or WS_SYSMENU or DS_MODALFRAME or DS_CENTER,WS_EX_DLGMODALFRAME,,"Microsoft Sans Serif",8
	dialogitem "SysListView32","",dlg_dll_list,9,9,498,144,WS_CHILDWINDOW or WS_VISIBLE or WS_TABSTOP or LVS_REPORT or LVS_SHOWSELALWAYS or LVS_SINGLESEL,WS_EX_CLIENTEDGE
	dialogitem "Button","Cancel",dlg_dll_cancel,9,162,111,15,WS_CHILDWINDOW or WS_VISIBLE or WS_TABSTOP
	dialogitem "Button","Load .fas file",dlg_dll_load,396,162,111,15,WS_CHILDWINDOW or WS_VISIBLE or WS_TABSTOP or BS_DEFPUSHBUTTON
 enddialog

 dialog dll_fasfiletest,"Test .fas links",0,0,594,228,WS_CAPTION or DS_3DLOOK or WS_VISIBLE or WS_POPUP or WS_SYSMENU or DS_MODALFRAME or DS_CENTER,WS_EX_DLGMODALFRAME,,"Microsoft Sans Serif",8
	dialogitem "SysListView32","",dlg_FasFileTest_list,9,9,576,189,WS_CHILDWINDOW or WS_VISIBLE or WS_TABSTOP or LVS_REPORT or LVS_SHOWSELALWAYS or LVS_SINGLESEL,WS_EX_CLIENTEDGE
	dialogitem "Button","Close",dlg_FasFileTest_close,474,207,111,15,WS_CHILDWINDOW or WS_VISIBLE or WS_TABSTOP or BS_DEFPUSHBUTTON
 enddialog

