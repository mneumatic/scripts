# PowerShell Script
# Author: Michael Neumann

# Variables

$Date = Get-Date -Format "MM-dd-yyyy"
$SevenZip = "C:\Program Files\7-Zip\7z.exe"
$Source = "C:\Users\mneumatic"
$Destination = "G:\Backups\backup_$Date"
$ZipPath = "G:\Backups\backup_$Date"

# Backup for User directory.

echo "Backing up C:\Users\mneumatic"
robocopy $Source $Destination /E /XC /XD .* AppData Downloads "Application Data" Cookies "Local Settings" "My Documents" "My Pictures" "My Videos" "My Music" NetHood PrintHood Recent SendTo "Start Menu" Templates /XA:H /XN /XO /R:1 /W:1

# Backup for ROMs directory. Got to keep those oldies.

robocopy "F:\ROMLibrary" $Destination\ROMLibrary /E /XC

# Compress & delete destination folder after compression

& $SevenZip a -t7z -mx=9 $ZipPath "$Destination\*" 
Remove-Item $Destination -Recurse -Force 
