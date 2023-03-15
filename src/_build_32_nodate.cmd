set fasm=E:\ASM\FASM

rem call build_datetime.cmd

%fasm%\FASM.EXE xFasImport_32.asm xFasImport.dp32 -s xFasImport_32.fas
pause
exit
