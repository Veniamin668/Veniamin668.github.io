@echo off
:: =============================================================
:: PROJECT: OMEGA_SPEED (E8400 + 3GB RAM + HD4850 + SSD)
:: RIGHTS: TRUSTEDINSTALLER | GOAL: PURE HARDWARE ACCESS
:: =============================================================

echo [+] 1. Фиксация ассоциаций (Броня от багов)...
reg add "HKLM\SOFTWARE\Classes\.exe" /ve /t REG_SZ /d "exefile" /f
reg add "HKLM\SOFTWARE\Classes\exefile\shell\open\command" /ve /t REG_SZ /d "\"%%1\" %%*" /f
reg add "HKLM\SOFTWARE\Classes\.bat" /ve /t REG_SZ /d "batfile" /f
reg add "HKLM\SOFTWARE\Classes\batfile\shell\open\command" /ve /t REG_SZ /d "\"%%1\" %%*" /f
reg add "HKLM\SOFTWARE\Classes\.reg" /ve /t REG_SZ /d "regfile" /f
reg add "HKLM\SOFTWARE\Classes\regfile\shell\open\command" /ve /t REG_SZ /d "regedit.exe \"%%1\"" /f

echo [+] 2. Оптимизация SSD (120GB) и Питания...
powercfg -h off
powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
fsutil behavior set disableDeleteNotify NTFS 0
fsutil behavior set disable8dot3 1
fsutil behavior set disablelastaccess 1
fsutil behavior set mftzone 2

echo [+] 3. Настройка СТАТИЧЕСКОГО Свопа (4GB)...
wmic computersystem where name="%computername%" set AutomaticManagedPagefile=False >nul 2>&1
wmic pagefilesetting where name="C:\\pagefile.sys" set InitialSize=4096,MaximumSize=4096 >nul 2>&1

echo [+] 4. Глубокий буст CPU E8400 и ОЗУ...
:: Схлопываем svchost (Экономия процессов)
reg add "HKLM\SYSTEM\CurrentControlSet\Control" /v "SvcHostSplitThresholdInKB" /t REG_DWORD /d 4294967295 /f
:: Отключение Spectre/Meltdown (Буст E8400)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverride" /t REG_DWORD /d 3 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "FeatureSettingsOverrideMask" /t REG_DWORD /d 3 /f
:: Ядро всегда в ОЗУ, высокий приоритет
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d 38 /f

echo [+] 5. Тюнинг ATI HD 4850 и Графики (Анимации ОСТАЮТСЯ)...
:: Отключение ULPS (стабильные частоты)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "EnableUlps" /t REG_DWORD /d 0 /f
:: Отключение прозрачности (Acrylic)
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "EnableTransparency" /t REG_DWORD /d 0 /f
:: Твики отклика мыши и клавы
reg add "HKCU\Control Panel\Mouse" /v "MouseSpeed" /t REG_SZ /d "0" /f
reg add "HKCU\Control Panel\Desktop" /v "MenuShowDelay" /t REG_SZ /d "0" /f

echo [+] 6. Аннигиляция МУСОРНЫХ служб (Максимальный список)...
:: UWP (AppX) - во "Вручную", остальное - ВЫКЛ.
set "manual=AppXSvc StateRepository ClipSVC LicenseManager"
for %%s in (%manual%) do (sc config %%s start= demand >nul 2>&1)

set "junk=WSearch SysMain PcaSvc WerSvc wscsvc WinDefend Sense Spooler RemoteRegistry MapsBroker SensorService SensorDataService SCardSvr RetailDemo wlidsvc WiaRpc WinRM WpdUpdt SENS Netlogon BITS sihsvc DiagTrack DPS UsoSvc wuauserv WaaSMedicSvc"
for %%s in (%junk%) do (
    sc stop %%s >nul 2>&1
    sc config %%s start= disabled >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%s" /v "Start" /t REG_DWORD /d 4 /f >nul 2>&1
)

echo [+] 7. Отключение "Защиты от эксплойтов" (Вместо PowerShell команды)...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v "MitigationOptions" /t REG_QWORD /d 2222222222222 /f >nul 2>&1

echo [+] 8. Чистка планировщика...
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" /v "MaintenanceDisabled" /t REG_DWORD /d 1 /f
schtasks /delete /tn "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /f >nul 2>&1
schtasks /delete /tn "Microsoft\Windows\Device Information\Device" /f >nul 2>&1
schtasks /delete /tn "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" /f >nul 2>&1

:: Устанавливаем лимит для лога Системы (1024 КБ)
wevtutil sl System /ms:1048576 /rt:false
:: Устанавливаем лимит для лога Приложений (1024 КБ)
wevtutil sl Application /ms:1048576 /rt:false
:: Устанавливаем лимит для лога Безопасности (1024 КБ)
wevtutil sl Security /ms:1048576 /rt:false

:: нахер mitigations 2
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v FeatureSettingsOverride /t REG_DWORD /d 3 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v FeatureSettingsOverrideMask /t REG_DWORD /d 3 /f
echo =============================================================
echo СИСТЕМА ФАРШИРОВАНА! Ошибки пофиксены.
echo Анимации на месте, скорость на пределе.
echo ЖМИ КЛАВИШУ И В РЕБУТ!
pause
