Get-WmiObject -Class Win32_volume -Filter 'DriveType=5' | Set-WmiInstance -Arguments @{DriveLetter='Z:'} 