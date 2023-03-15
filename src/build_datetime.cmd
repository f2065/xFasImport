
rem increment build number
for /f "tokens=1" %%a in (build_counter.txt) do @set /a b=%%a
set /a b=b+1
echo %b% >build_counter.txt
echo __build_counter_text__ equ '%b%' >build_datetime.inc
echo __build_counter_int__ equ %b% >>build_datetime.inc

rem set current date and time
powershell -command get-date -format 'yyyy#MM#dd#HH#mm#ss#UTCK'>build_datetime.tmp
for /f "tokens=1,2,3,4,5,6,7 delims=#" %%a in (build_datetime.tmp) do @echo __build_datetime_text__ equ '%%a.%%b.%%c %%d:%%e:%%f %%g'>>build_datetime.inc
del build_datetime.tmp
