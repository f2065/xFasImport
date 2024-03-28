
szPLUGIN_NAME_A db "xFasImport", 0
szPLUGIN_NAME_W du "xFasImport", 0

t_SettingSection = szPLUGIN_NAME_A
t_Setting_codepage db "sources_codepage",0
t_Setting_dellabels db "delete_old_labels",0
t_Setting_labels db "import_labels",0
t_Setting_delcomments db "delete_old_comments",0
t_Setting_sources db "import_sources",0
t_Setting_append db "append_labels",0
t_Setting_spaces db "remove_spaces",0
t_Setting_tabsize1 db "tabsize1",0
t_Setting_tabsize2 db "tabsize2",0
t_Setting_tabsize3 db "tabsize3",0
t_Setting_tabsize4 db "tabsize4",0
t_Setting_tabsize5 db "tabsize5",0
t_Setting_flag_labels_manual db "flag_labels_manual",0
t_Setting_flag_comments_manual db "flag_comments_manual",0
t_Setting_OFN_force db "OFN_force",0
t_Setting_autoload_file db "autoload_file",0
t_DataBase_time_image db "time_image",0
t_DataBase_time_fas db "time_fas",0

align memsize

config_sources_codepage DWORD_PTR ?
config_delete_old_labels DWORD_PTR ?
config_import_labels DWORD_PTR ?
config_delete_old_comments DWORD_PTR ?
config_import_sources DWORD_PTR ?
config_append_labels DWORD_PTR ?
config_remove_spaces DWORD_PTR ?
config_tabsize1 DWORD_PTR ?
config_tabsize2 DWORD_PTR ?
config_tabsize3 DWORD_PTR ?
config_tabsize4 DWORD_PTR ?
config_tabsize5 DWORD_PTR ?
config_flag_labels_manual DWORD_PTR ?
config_flag_comments_manual DWORD_PTR ?
config_OFN_force DWORD_PTR ?
config_autoload_file DWORD_PTR ?

database_time_image DWORD_PTR ?
database_time_fas DWORD_PTR ?

hInstance DWORD_PTR ?
pluginHandle DWORD_PTR ?
hwndDlg DWORD_PTR ?
hMenu DWORD_PTR ?

hCodePageComboBox DWORD_PTR ?
imported_labels_counter DWORD_PTR ?
imported_comments_counter DWORD_PTR ?

pFasFile DWORD_PTR ?
szFasFile DWORD_PTR ?
timeFasFile DWORD_PTR ?
timeImageFile DWORD_PTR ?
incorrect_time_flag DWORD_PTR ?
address_string_table DWORD_PTR ?
address_symbol_table DWORD_PTR ?
endOf_symbol_table DWORD_PTR ?
address_preprocessed_source DWORD_PTR ?
endOf_preprocessed_source DWORD_PTR ?
address_assembly_dump DWORD_PTR ?
address_section_table DWORD_PTR ?
address_symbol_ref DWORD_PTR ?
endOf_symbol_ref DWORD_PTR ?
address_input_file_name DWORD_PTR ?
address_output_file_name DWORD_PTR ?
size_exe_by_fas DWORD_PTR ?
start_import_table DWORD_PTR ?
endOf_import_table DWORD_PTR ?
original_base_addr DWORD_PTR ?
original_SizeOfImage DWORD_PTR ?
current_base_addr DWORD_PTR ?

hListViewDLL DWORD_PTR ?
hDllList DWORD_PTR ?
itemsDllList DWORD_PTR ?
sort_directions_dll rb 8 ; see init_listview_dll

hListViewFFT DWORD_PTR ?
hFftList DWORD_PTR ?
itemsFftList DWORD_PTR ?
sort_directions_fft rb 8 ; see init_listview_fft
item_fft_list_helper DWORD_PTR ?

currentLocale sized rw 30
lang_file_load db ?
lang_file_incomplete db ?

align 2
tDbgMainFileName rw MAX_PATH
buffFasFileName rw MAX_PATH
buffBasePath rw MAX_PATH

