
; https://github.com/tgrysztar/fasm/blob/master/TOOLS/FAS.TXT
 
; Table 1  Header
struct fheader
 signature                     rd 1
 major                         rb 1
 minor                         rb 1
 length_header                 rw 1
 offset_input_file_name        rd 1
 offset_output_file_name       rd 1
 offset_string_table           rd 1
 length_string_table           rd 1
 offset_symbol_table           rd 1
 length_symbol_table           rd 1
 offset_preprocessed_source    rd 1
 length_preprocessed_source    rd 1
 offset_assembly_dump          rd 1
 length_assembly_dump          rd 1
 offset_section_table          rd 1
 length_section_table          rd 1
 offset_symbol_ref             rd 1
 length_symbol_ref             rd 1
ends ;fheader


; Table 2  Symbol structure
struct fsymbol
 value                         rq 1
 flags                         rw 1
 size_data                     rb 1
 _type                         rb 1
 ext_sib                       rd 1
 pass_num_def                  rw 1
 pass_num_use                  rw 1
 union
   section                     rd 1
   ext_symb_string_offset      rd 1
 ends
 union
   symb_name_prep_offset       rd 1
   symb_name_string_offset     rd 1
 ends
 line_prep_offset              rd 1
ends ;fsymbol


; Table 3  Preprocessed line
struct preprocessed_line
 offset_file_name              rd 1
 number_line                   rd 1
 union
   position_file               rd 1
   offset_prep_line            rd 1
 ends
 offset_prep_line_in_macro_def rd 1
 line_content                  rd 1 ; floating size!
ends ;preprocessed_line


; Table 4  Row of the assembly dump
struct assembly_dump
  offset_in_output_file        rd 1
  offset_of_line_in_source     rd 1
  address                      rq 1
  sib                          rd 1
  info_external_symbol         rd 1
  type_of_address              rb 1
  type_of_code                 rb 1
  flags                        rb 1
  address_higher_bits          rb 1
ends ;assembly_dump
