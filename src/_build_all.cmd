set fasm=E:\ASM\FASM

call build_datetime.cmd

%fasm%\FASM.EXE xFasImport_32.asm xFasImport.dp32 -s xFasImport_32.fas
%fasm%\FASM.EXE xFasImport_64.asm xFasImport.dp64 -s xFasImport_64.fas
pause
exit
