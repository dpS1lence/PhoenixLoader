@echo off
echo: 
echo:  
echo:  
echo	":Y????!. :J.   ^?   !JJJ?:  ^Y?????. J!    7~ .J: ?~   :J:"  
echo    "!&^:::P5 ~&.   !#  5P^.:7#^ 7&::::: .&&?   GY .&~ ~B7 ^B7"          
echo    "!#    JB ~&^...7#  #!    B? 7#:.... .#!PJ  GJ .#~  :GYG~"    
echo    "!&J??J5~ ~&JJJ?P#  #!    B7 7&J??J~ .&~ 5Y PJ .#~   ?@P    "                        
echo    "!&:.:.   ~&.   !#  #7    #7 7#      .&~  Y5GJ .#~  JG:YP.  "  
echo    "!#.      ~#.   !#  7G?!755. 7&77777..#~   ?@J .#~ YP.  ?G: "   
echo    ".^       .^    .^   .^~~:   .^^^^^^. ^.    ^.  ^..^     ^:  "  
echo:
echo:
echo:
timeout 1 > nul  
echo Injecting...
timeout 2 > nul
setlocal EnableDelayedExpansion

set /a i=0

for /f "tokens=1,2 delims=," %%a in ('tasklist /nh /fo csv') do (
  set /a i+=1
  set "process[!i!].name=%%~na"
  set "process[!i!].id=%%~b"
)

set /p "search=Enter a process name to search for: "

set "found="
for /l %%i in (1,1,%i%) do (
  if /i "!process[%%i].name!"=="%search%" (
    set "found=1"
    echo Process found:
    echo Name: !process[%%i].name!.exe
    echo ID: !process[%%i].id!
    choice /m "Do you want to kill this process? [Y/N]"
    if errorlevel 2 (
        echo Process not killed.
    ) else (
        taskkill /F /PID !process[%%i].id!
        echo Process killed.
    )
  ) else (
    set "name=!process[%%i].name!"
    set "name=!name:.exe=!"
    if /i "!name!"=="%search%" (
      set "found=1"
      echo Process found:
      echo Name: !process[%%i].name!.exe
      echo ID: !process[%%i].id!
      choice /m "Do you want to kill this process? [Y/N]"
      if errorlevel 2 (
          echo Process not killed.
      ) else (
          taskkill /F /PID !process[%%i].id!
          echo Process killed.
      )
    )
  )
)

if not defined found (
  echo Process not found.
)

pause