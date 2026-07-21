@echo off
sc config AudioSRV start= auto
net start AudioSRV
sc config WlanSvc start= auto
net start WlanSvc
sc config Themes start= auto
net start Themes

reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Reliability" /v "ShutdownReasonOn" /t REG_DWORD /d 0 /f

pause
