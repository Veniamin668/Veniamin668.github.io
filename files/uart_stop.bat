@echo off
echo [*] Ожидание подключения UniBoss Tiger T603 на этапе бутанимации...

:WAIT_ADB
:: Ждем, пока adb-демон на телефоне поднимет статус root
adb root >nul 2>&1
adb shell getenforce >nul 2>&1
if errorlevel 1 (
    goto WAIT_ADB
)

echo [+] ADB Root пойман! Запуск бесконечного цикла глушения...

:LOOP
:: 1. Выключаем строгий режим безопасности на лету
adb shell setenforce 0 >nul 2>&1

:: 2. Вырубаем спам ядра (тот самый JEITA-драйвер батареи со скрина)
adb shell "echo 0 > /proc/sys/kernel/printk" >nul 2>&1

:: 3. Циклично шлем сигналы смерти службам логирования и консоли
adb shell setprop ctl.stop logd >nul 2>&1
adb shell setprop ctl.stop console >nul 2>&1
adb shell setprop ctl.stop setup_console >nul 2>&1

:: 4. Вбиваем правильный синтаксис false в упрямые свойства Unisoc
adb shell setprop persist.sys.uart.status false >nul 2>&1
adb shell setprop persist.vendor.uart.status false >nul 2>&1
adb shell setprop persist.vendor.serial.debug 0 >nul 2>&1


:: 6. Очищаем буфер, чтобы eMMC от YMTC не лагала
adb shell logcat -c >nul 2>&1

:: 5. Передергиваем USB-конфиг, чтобы заставить шторку схлопнуться
adb shell setprop sys.usb.config none >nul 2>&1
adb shell setprop sys.usb.config mtp,adb >nul 2>&1

:: Проверяем, заглохла ли служба консоли
for /f "tokens=*" %%i in ('adb shell getprop init.svc.console') do set STATUS=%%i
echo [*] Текущий статус консоли: %STATUS%

:: Если служба все еще сопротивляется, продолжаем спамить команды
if "%STATUS%"=="running" (
    goto LOOP
)

echo [===>] ПОБЕДА! UART и логи успешно задушены на этапе загрузки!
pause
