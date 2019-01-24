@echo off
setlocal EnableDelayedExpansion EnableExtensions
color 0E
::Укажите свои расширения здесь
set Ext=*.jpg *.mov *.nef
::--------------------------------------------------------------------------------- 
chcp 1251 >nul
set TEXTTITLE=Скрипт для сортировки фотографий по дате создания 
set TEXTFROM="Укажите исходную папку   "
set TEXTTO="Укажите папку назначения "
set TEXTSIZE=Общий обьем
set TEXTNUM=Всего файлов
set TEXTEND=Работа завершена
set TEXTFAIL=Обнаружен дубль. Файл пропущен!
set TEXTINC=Файл с таким именем существует, переименование в
chcp 866 >nul
::--------------------------------------------------------------------------------- 
echo             ***                   ***  
echo             *      Photo Sorter     *   
echo             ***                   ***
echo.
echo %TEXTTITLE%
echo.
set /p x=%TEXTFROM% < nul
call :GetFolder From
if not defined From exit /B
echo - %From%
::--------------------------------------------------------------------------------- 
set /p x=%TEXTTO% < nul
call :GetFolder To
if not defined To exit /B
echo - %To%
if not exist "%To%" md "%To%"
::--------------------------------------------------------------------------------- 
chcp 1251>nul& set LanguageFlag=true

echo.
call set St="!From!\%%ext: =","!From!\%%"

for /F "delims=" %%A in ('dir /B /S /A-D %St%') do (
  if defined LanguageFlag (chcp 866>nul& Set LanguageFlag=)
  if "!curFolder!" neq "%%~dpA" (echo Текущая папка %%~dpA & set curFolder=%%~dpA)
  for /F %%D in ("%%~tA") do set ToReal=%%D
	set Year=!ToReal:~-4!
	set Month=!ToReal:~3,2!
	set Day=!ToReal:~0,2!
	set ToReal=%To%\!Year!-!Month!-!Day!
	set /a Sz=%%~zA/1024
	set /a Num=Num+1
	set /a Fsz=Fsz+Sz
	echo  - %%~nxA !Sz!Kb  -^>  !ToReal!
  if not exist "!ToReal!" md "!ToReal!"
	::set NewName=
  call :GetEmptyNameMod "!ToReal!" "%%A" NewName
	::echo GetEmptyNameMod %errorlevel% !NewName!
  if not errorlevel 1 (copy /-Y "%%A" "!ToReal!\!NewName!">nul) else (echo %TEXTFAIL%)
)
chcp 866 >nul
echo.
echo %TEXTNUM%: %Num%
set /a Fsz=Fsz/1024
echo %TEXTSIZE%: %Fsz%Mb
echo %TEXTEND%
pause>nul
color
goto :eof
::--------------------------------------------------------------------------------- 
:GetEmptyNameMod %1-Folder %2-FullFileName %3-Var.Return %4-Optional.System.Num
::echo %~1 %~2 %~3 %~4
if "%~4"=="" (
    	Set "NewFileName=%~nx2"
	) else (
	set "NewFileName=%~n2(%~4)%~x2"
	echo %TEXTINC% !NewFileName!
 	)
if exist "%~1\%NewFileName%" (
      fc /b "%~1\%NewFileName%" "%~2">nul && Exit /B 1
      Set Num=%~4
      Set /A Num+=1
      Call :GetEmptyNameMod "%~1" "%~2" "%~3" "!Num!"
) else (
    Set "%~3=%NewFileName%"
    Exit /B 0
)
Exit /B 0
::--------------------------------------------------------------------------------- 
:GetFolder %1-var.Where.Save.FolderName
chcp 1251 >nul
for /f "usebackq delims=" %%i in (
    `@"%systemroot%\system32\mshta.exe" "javascript:var objShellApp = new ActiveXObject('Shell.Application');var Folder = objShellApp.BrowseForFolder(0, 'Выберите папку',1,0);try {new ActiveXObject('Scripting.FileSystemObject').GetStandardStream(1).Write(Folder.Self.Path)};catch (e){};close();" ^
    1^|more`
) do set %~1=%%i
chcp 866 >nul
Exit /B