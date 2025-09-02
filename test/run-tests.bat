@echo off
:: Harpo Circuits Test Runner Script for Windows
:: This script runs all circuit tests with proper setup and reporting

setlocal enabledelayedexpansion

echo.
echo ^🚀 Harpo Circuits Test Suite
echo ==================================

:: Check if node_modules exists
if not exist "node_modules" (
    echo ⚠️  Installing dependencies...
    call npm install
)

:: Create test results directory
if not exist "test-results" mkdir test-results

:: Function to check dependencies
call :check_dependencies

:: Get test type argument
set "test_type=%~1"
if "%test_type%"=="" set "test_type=all"

:: Compile circuits before testing
call :compile_circuits

:: Run tests based on type
if "%test_type%"=="unit" (
    call :run_unit_tests
) else if "%test_type%"=="integration" (
    call :run_integration_tests
) else if "%test_type%"=="performance" (
    call :run_performance_tests
) else if "%test_type%"=="all" (
    echo.
    echo ^🎯 Running complete test suite...
    call :run_unit_tests
    call :run_integration_tests
) else if "%test_type%"=="compile" (
    echo Circuit compilation completed.
    goto :end
) else (
    echo ❌ Unknown test type: %test_type%
    echo Usage: %0 [unit^|integration^|performance^|all^|compile]
    exit /b 1
)

:: Summary
echo.
echo ^📊 Test Summary
echo ==================================
echo ^🎉 Test execution completed!
echo Check test-results/ directory for detailed logs

goto :end

:: Function definitions
:check_dependencies
echo.
echo ^🔍 Checking dependencies...
echo -----------------------------------

where circom >nul 2>&1
if errorlevel 1 (
    echo ❌ circom not found. Please install circom first.
    echo Visit: https://docs.circom.io/getting-started/installation/
    exit /b 1
)

where node >nul 2>&1
if errorlevel 1 (
    echo ❌ Node.js not found. Please install Node.js first.
    exit /b 1
)

echo ✅ All dependencies found
goto :eof

:compile_circuits
echo.
echo ^🔧 Compiling test circuits...
echo -----------------------------------

:: Compile utility circuits
if exist "test\circuits\utility" (
    for %%f in (test\circuits\utility\*.circom) do (
        echo Compiling %%~nxf...
        circom "%%f" --r1cs --wasm --sym -o test\circuits\utility\ 2>nul || echo Warning: Failed to compile %%f
    )
)

:: Compile core circuits
if exist "test\circuits\core" (
    for %%f in (test\circuits\core\*.circom) do (
        echo Compiling %%~nxf...
        circom "%%f" --r1cs --wasm --sym -o test\circuits\core\ 2>nul || echo Warning: Failed to compile %%f
    )
)

:: Compile integration circuits
if exist "test\circuits\integration" (
    for %%f in (test\circuits\integration\*.circom) do (
        echo Compiling %%~nxf...
        circom "%%f" --r1cs --wasm --sym -o test\circuits\integration\ 2>nul || echo Warning: Failed to compile %%f
    )
)

echo ✅ Circuit compilation completed
goto :eof

:run_unit_tests
echo.
echo ^🧪 Running Unit tests...
echo -----------------------------------
call npm test > test-results\unit-results.log 2>&1
if errorlevel 1 (
    echo ❌ Unit tests failed
    echo Check test-results\unit-results.log for details
) else (
    echo ✅ Unit tests passed
)
goto :eof

:run_integration_tests
echo.
echo ^🧪 Running Integration tests...
echo -----------------------------------
call npm run test:integration > test-results\integration-results.log 2>&1
if errorlevel 1 (
    echo ❌ Integration tests failed
    echo Check test-results\integration-results.log for details
) else (
    echo ✅ Integration tests passed
)
goto :eof

:run_performance_tests
echo.
echo ^🧪 Running Performance tests...
echo -----------------------------------
call npm run test:performance > test-results\performance-results.log 2>&1
if errorlevel 1 (
    echo ❌ Performance tests failed
    echo Check test-results\performance-results.log for details
) else (
    echo ✅ Performance tests passed
)
goto :eof

:end
endlocal