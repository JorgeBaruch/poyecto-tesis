@echo off
REM This is a mock pdftotext.exe
REM Arguments: -layout -enc UTF-8 "input.pdf" "output.txt"
REM The output file is the last argument

set "outputPath=%~nx4"
echo Mocked PDF content for testing. [[p=1]] Page 1. [[p=2]] Page 2. > "%outputPath%"
exit /b 0