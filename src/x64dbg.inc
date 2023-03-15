
PLUG_SDKVERSION = 1

MAX_MODULE_SIZE = 256
MAX_LABEL_SIZE = 256
MAX_COMMENT_SIZE = 512
MAX_SETTING_SIZE = 65536
 
;CBTYPE
CB_INITDEBUG = 0
CB_STOPDEBUG = 1
CB_CREATEPROCESS = 2
CB_EXITPROCESS = 3
CB_CREATETHREAD = 4
CB_EXITTHREAD = 5
CB_SYSTEMBREAKPOINT = 6
CB_LOADDLL = 7
CB_UNLOADDLL = 8
CB_OUTPUTDEBUGSTRING = 9
CB_EXCEPTION = 10
CB_BREAKPOINT = 11
CB_PAUSEDEBUG = 12
CB_RESUMEDEBUG = 13
CB_STEPPED = 14
CB_ATTACH = 15
CB_DETACH = 16
CB_DEBUGEVENT = 17
CB_MENUENTRY = 18
CB_WINEVENT = 19
CB_WINEVENTGLOBAL = 20
 
SEG_DEFAULT = 0

; _plugins.h
struct PLUG_INITSTRUCT
  pluginHandle rd 1 ; provided by the debugger
  sdkVersion rd 1 ; provided by the pluginit function
  pluginVersion rd 1
  pluginName rd 1
ends
 
; _plugins.h
struct PLUG_SETUPSTRUCT_32
  hwndDlg rd 1 ; gui window handle
  hMenu rd 1 ; plugin menu handle
  hMenuDisasm rd 1 ; plugin disasm menu handle
  hMenuDump rd 1 ; plugin dump menu handle
  hMenuStack rd 1 ; plugin stack menu handle
  hMenuGraph rd 1 ; plugin graph menu handle
  hMenuMemmap rd 1 ; plugin memory map menu handle
  hMenuSymmod rd 1 ; plugin symbol module menu handle
ends

; _plugins.h
struct PLUG_SETUPSTRUCT_64
  hwndDlg rq 1 ; gui window handle
  hMenu rd 1 ; plugin menu handle
  hMenuDisasm rd 1 ; plugin disasm menu handle
  hMenuDump rd 1 ; plugin dump menu handle
  hMenuStack rd 1 ; plugin stack menu handle
  hMenuGraph rd 1 ; plugin graph menu handle
  hMenuMemmap rd 1 ; plugin memory map menu handle
  hMenuSymmod rd 1 ; plugin symbol module menu handle
  rd 1 ; align 16
ends

; _plugins.h
struct PLUG_CB_MENUENTRY
  hEntry rd 1
ends

; dbghelp.h
struct IMAGEHLP_MODULE64
  SizeOfStruct dd ? ; set to sizeof(IMAGEHLP_MODULE64)
  rd 1 ; align
  BaseOfImage dq ? ; base load address of module
  ImageSize dd ? ; virtual size of the loaded module
  TimeDateStamp dd ? ; date/time stamp from pe header
  CheckSum dd ? ; checksum from the pe header
  NumSyms dd ? ; number of symbols in the symbol table
  SymType dd ? ; type of symbols loaded
  ModuleName db 32 dup (?) ; module name
  ImageName db 256 dup (?) ; image name
  LoadedImageName db 256 dup (?) ; symbol file name
  LoadedPdbName db 256 dup (?) ; pdb file name
  CVSig dd ? ; Signature of the CV record in the debug directories
  CVData db MAX_PATH*3 dup (?) ; Contents of the CV record
  PdbSig dd ? ; Signature of PDB
  PdbSig70 db 16 dup (?) ; Signature of PDB (VC 7 and up)
  PdbAge dd ? ; DBI age of pdb
  PdbUnmatched db ? ; loaded an unmatched pdb
  rb 3
  DbgUnmatched db ? ; loaded an unmatched dbg
  rb 3
  LineNumbers db ? ; we have line number information
  rb 3
  GlobalSymbols db ? ; we have internal symbol information
  rb 3
  TypeInfo db ? ; we have type information
  rb 3
  SourceIndexed db ? ; pdb supports source server
  rb 3
  Publics db ? ; contains public symbols
  rb 3
ends

; _plugins.h
struct PLUG_CB_LOADDLL_32
  LoadDll rd 1 ; LOAD_DLL_DEBUG_INFO*
  modInfo rd 1 ; IMAGEHLP_MODULE64*
  modname rd 1 ; *
ends

; _plugins.h
struct PLUG_CB_LOADDLL_64
  LoadDll rq 1 ; LOAD_DLL_DEBUG_INFO*
  modInfo rq 1 ; IMAGEHLP_MODULE64*
  modname rq 1 ; *
ends

; _plugins.h
struct PLUG_CB_UNLOADDLL_32
  UnloadDll rd 1 ; UNLOAD_DLL_DEBUG_INFO*
ends

; _plugins.h
struct PLUG_CB_UNLOADDLL_64
  UnloadDll rq 1 ; UNLOAD_DLL_DEBUG_INFO*
ends

; _plugins.h
struct PLUG_CB_INITDEBUG_32
  szFileName rd 1
ends

; _plugins.h
struct PLUG_CB_INITDEBUG_64
  szFileName rq 1
ends

; bridgemain.h
struct ICONDATA_32
  data rd 1
  size rd 1
ends

; bridgemain.h
struct ICONDATA_64
  data rq 1
  size rq 1
ends





