
struct UNLOAD_DLL_DEBUG_INFO
  lpBaseOfDll dq ?
ends

struct LITEM
  mask dd ?
  iLink dd ?
  state dd ?
  stateMask dd ?
  szID dw MAX_LINKID_TEXT dup (?)
  szUrl dw L_MAX_URL_LENGTH dup (?)
ends

struct NMLINK
  hdr NMHDR
  item LITEM
ends

struct CPINFOEXW
  MaxCharSize dd ?
  DefaultChar db MAX_DEFAULTCHAR dup ?
  LeadByte db MAX_LEADBYTES dup ?
  UnicodeDefaultChar dw ?
  CodePage dd ?
  CodePageName dw MAX_PATH dup ?
ends

struct IMAGE_DOS_HEADER
  e_magic dw ? ; Magic number
  e_cblp dw ? ; Bytes on last page of file
  e_cp dw ? ; Pages in file
  e_crlc dw ? ; Relocations
  e_cparhdr dw ? ; Size of header in paragraphs
  e_minalloc dw ? ; Minimum extra paragraphs needed
  e_maxalloc dw ? ; Maximum extra paragraphs needed
  e_ss dw ? ; Initial (relative) SS value
  e_sp dw ? ; Initial SP value
  e_csum dw ? ; Checksum
  e_ip dw ? ; Initial IP value
  e_cs dw ? ; Initial (relative) CS value
  e_lfarlc dw ? ; File address of relocation table
  e_ovno dw ? ; Overlay number
  e_res dw 4 dup ? ; Reserved words
  e_oemid dw ? ; OEM identifier (for e_oeminfo)
  e_oeminfo dw ? ; OEM information; e_oemid specific
  e_res2 dw 10 dup ? ; Reserved words
  e_lfanew dd ? ; File address of new exe header
ends

struct IMAGE_FILE_HEADER
  Machine dw ?
  NumberOfSections dw ?
  TimeDateStamp dd ?
  PointerToSymbolTable dd ?
  NumberOfSymbols dd ?
  SizeOfOptionalHeader dw ?
  Characteristics dw ?
ends

struct IMAGE_DATA_DIRECTORY
  VirtualAddress dd ?
  Size dd ?
ends

struct IMAGE_OPTIONAL_HEADER32
  Magic dw ?
  MajorLinkerVersion db ?
  MinorLinkerVersion db ?
  SizeOfCode dd ?
  SizeOfInitializedData dd ?
  SizeOfUninitializedData dd ?
  AddressOfEntryPoint dd ?
  BaseOfCode dd ?
  BaseOfData dd ?
  ImageBase dd ?
  SectionAlignment dd ?
  FileAlignment dd ?
  MajorOperatingSystemVersion dw ?
  MinorOperatingSystemVersion dw ?
  MajorImageVersion dw ?
  MinorImageVersion dw ?
  MajorSubsystemVersion dw ?
  MinorSubsystemVersion dw ?
  Win32VersionValue dd ?
  SizeOfImage dd ?
  SizeOfHeaders dd ?
  CheckSum dd ?
  Subsystem dw ?
  DllCharacteristics dw ?
  SizeOfStackReserve dd ?
  SizeOfStackCommit dd ?
  SizeOfHeapReserve dd ?
  SizeOfHeapCommit dd ?
  LoaderFlags dd ?
  NumberOfRvaAndSizes dd ?
  DataDirectory rb sizeof.IMAGE_DATA_DIRECTORY * IMAGE_NUMBEROF_DIRECTORY_ENTRIES
ends

struct IMAGE_OPTIONAL_HEADER64
  Magic dw ?
  MajorLinkerVersion db ?
  MinorLinkerVersion db ?
  SizeOfCode dd ?
  SizeOfInitializedData dd ?
  SizeOfUninitializedData dd ?
  AddressOfEntryPoint dd ?
  BaseOfCode dd ?
  ImageBase dq ?
  SectionAlignment dd ?
  FileAlignment dd ?
  MajorOperatingSystemVersion dw ?
  MinorOperatingSystemVersion dw ?
  MajorImageVersion dw ?
  MinorImageVersion dw ?
  MajorSubsystemVersion dw ?
  MinorSubsystemVersion dw ?
  Win32VersionValue dd ?
  SizeOfImage dd ?
  SizeOfHeaders dd ?
  CheckSum dd ?
  Subsystem dw ?
  DllCharacteristics dw ?
  SizeOfStackReserve dq ?
  SizeOfStackCommit dq ?
  SizeOfHeapReserve dq ?
  SizeOfHeapCommit dq ?
  LoaderFlags dd ?
  NumberOfRvaAndSizes dd ?
  DataDirectory rb sizeof.IMAGE_DATA_DIRECTORY * IMAGE_NUMBEROF_DIRECTORY_ENTRIES
ends

struct IMAGE_NT_HEADERS32
  Signature dd ?
  FileHeader IMAGE_FILE_HEADER
  OptionalHeader IMAGE_OPTIONAL_HEADER32
ends

struct IMAGE_NT_HEADERS64
  Signature dd ?
  FileHeader IMAGE_FILE_HEADER
  OptionalHeader IMAGE_OPTIONAL_HEADER64
ends
