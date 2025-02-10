@echo off
cls

REM ====================================================================
REM Benchmark models via ollama via evaluation rate in tokens per second
REM ====================================================================
REM  * Copyright (c) 2012-2025 Savoir Technologies, Inc.
REM  *
REM  * Licensed under the Apache License, Version 2.0 (the "License");
REM  * you may not use this file except in compliance with the License.
REM  * You may obtain a copy of the License at
REM  *
REM  *      http://www.apache.org/licenses/LICENSE-2.0
REM  *
REM  * Unless required by applicable law or agreed to in writing, software
REM  * distributed under the License is distributed on an "AS IS" BASIS,
REM  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
REM  * See the License for the specific language governing permissions and
REM  * limitations under the License.

REM **** Get number of times to run model. ****
set /p num=The number of times you want to run Ollama models: 
if "%num%"=="" (
    echo Please provide a number of runs as an argument.
    exit /b 1
)
echo:
echo Please choose from the available Ollama models:
ollama list

REM **** choose our model ****
echo:
set /p model=Enter Model:
if "%model%"=="" (
    echo Please provide your selection.
    exit /b 1
)

echo:
REM **** Setup our Command ****
set "command=ollama run --verbose %model% Why is the sky blue?"

REM **** Run our performance test. ****
echo Running Ollama model %model% %num% times...
echo:

set result=0
for /l %%i in (1, 1, %num%) do (

    REM **** Do for loop for output processing. ****
    %command% >NUL 2>test-verbose-out.txt
    FIND "eval rate:" test-verbose-out.txt | FINDSTR "eval rate:" > test-eval-rates.txt

    REM **** Note: batch files do not handle fractions ****
    for /f "skip=1 tokens=3" %%G IN (test-eval-rates.txt) DO (
        @echo Eval Rate: %%G tokens/s
        set /a result+=%%G 2>NUL
    )
    del test-verbose-out.txt
    del test-eval-rates.txt
)

echo:
REM **** Get our average run time ****
set /a average=%result% / %num%
echo Average Eval Rate: %average% tokens/s 

echo Done running Ollama models.
