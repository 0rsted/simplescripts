<#
  .SYNOPSIS
    Verify if the user has rebooted in the last X days
    Reboot if computer hasn't been rebooted in Y days
  
  .DESCRIPTION
    Since users SUCK at rebooting their computer, let's make sure that they do it by force
    There are three values that can be changed, rebootAlert, rebootForce, rebootGrace
    rebootAlert is the number of days that start the reminder
    rebootForce is the number of days that initiates a reboot
    rebootGrace is the number of minutes they have to shut down everything before the reboot

#>

# number of days before users start getting a popup informing them they should reboot
$rebootAlert = 7

# number of days before the computer forces a reboot
$rebootForce = 14

# number of minutes before the reboot happens
$rebootGrace = 15

# text for the warning popup
$warningText = "Din computer er ikke blevet genstartet i {0} dage, gem dit arbejde og genstart computeren.`nHvis der går mere end {1} dage siden sidste genstart bliver computeren genstartet automatisk."

# text for the reboot popup
$rebootText = "Din computer er ikke blevet genstartet i {0} dage på trods af gentagne anmodninger om dette.`nDin computer genstarter automatisk om {1} minutter (bemærk denne tæller IKKE ned).`nGem dit arbejde, for når tiden er gået er der intet at gøre."


<#
This is where the code starts, please don't update stuff below this comment!
#>
$WShell = New-Object -ComObject Wscript.Shell

$LastReboot = Get-Date((Get-CimInstance -ClassName win32_operatingsystem | Select-Object lastbootuptime).lastbootuptime)
$Today = Get-Date

$DaysSinceLastBoot = [System.Math]::Ceiling((New-TimeSpan -Start $LastReboot -End $Today).TotalDays)

$output = $WShell.Popup(($warningText -f $DaysSinceLastBoot, $rebootForce))

<#
WShell.popup (Text, SecondsToWait, Title, Type)

Types : 
  0 — only  OK button
  1 — OK and Cancel
  2 — Stop, Retry, and Skip
  3 — Yes, No, and Cancel
  4 — Yes and No
  5 — Retry and Cancel
Icon (also a type):
  16 — Stop icon
  32 — Question icon
  48 — Exclamation icon
  64 — Information icon
To add an icon, just add the two numbers together 
eg : "yes and no" and "question icon": 4+32 (or 36, same effect)

Returns : 
 -1 — timeout
  1 — OK button
  2 — Cancel button
  3 — Stop button
  4 — Retry button
  5 — Skip button
  6 — Yes button
  7 — No button
#>

Write-Output $output

