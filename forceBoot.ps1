<#
  .SYNOPSIS
    Verify if the user has rebooted in the last X days
    Reboot if computer hasn't been rebooted in Y days
  
  .DESCRIPTION
    Since users SUCK at rebooting their computer, let's make sure that they do it by force
    This script can be attached to a group policy
  
  
  .PARAMETER rebootAlert
    Number of days to pass before beginning to bug the user
    Default : 7 days
  
  .PARAMETER rebootForce
    Number of days before a reboot will be forced
    Default : 14 days
  
  .PARAMETER rebootGrace
    How long the reboot countdown should be
    Default : 15 minutes

  .PARAMETER alertTitle
    The title of the alert window

  .PARAMETER warningText
    The text for the warning popup, it takes to arguments
      {0:n0} for the number of days since the last reboot
      {1:n0} for the number of days (in total) before a reboot is forced
  
  .PARAMETER rebootText
    The text for the popup informing of an incoming reboot, it takes two arguments
      {0:n0} for the number of days since the last reboot
      {1:n0} for the number of minutes before the reboot happens
  
#>

param (
  # number of days before the computer starts nagging
  [int]$rebootAlert = 7,
  # number of days before the computer forces a reboot
  [int]$rebootForce = 14,
  # number of minutes before the reboot happens
  [int]$rebootGrace = 15,
  # title for the window
  [string]$alertTitle = "Manglende genstart",
  # text for the warning popup
  [string]$warningText = "Din computer er ikke blevet genstartet i {0:n0} dage, gem dit arbejde og genstart computeren.`nHvis der går mere end {1:n0} dage siden sidste genstart bliver computeren genstartet automatisk.",
  # text for the reboot popup
  [string]$rebootText = "Din computer er ikke blevet genstartet i {0:n0} dage på trods af gentagne anmodninger om dette.`nDin computer genstarter automatisk om {1:n0} minutter (bemærk denne tæller IKKE ned).`nGem dit arbejde, for når tiden er gået genstarter computeren og lukker automatisk alle programmer uden at gemme."
)


<#
This is where the code starts, please don't update stuff below this comment!
#>
## We need the Windows Script Host Shell for the popup later on
$WShell = New-Object -ComObject Wscript.Shell

## We need the date of the last restart, and todays date
$LastReboot = Get-Date((Get-CimInstance -ClassName win32_operatingsystem).lastbootuptime)
$Today = Get-Date

## We use the time-span function to get the difference between the last reboot and now
## The number is rounded up
$DaysSinceLastBoot = [System.Math]::Ceiling((New-TimeSpan -Start $LastReboot -End $Today).TotalDays)

if($DaysSinceLastBoot -ge $rebootForce) {
  $popupText = ($rebootText -f $DaysSinceLastBoot, $rebootGrace)
  $popupType = 0 + 48 + 4096
  ## the shutdown command, 
  Start-Process -NoNewWindow -FilePath "shutdown.exe" -ArgumentList "/r", "/f", "/d 4:1", ("/t {0:n0}" -f ($rebootGrace * 60))
} elseif($DaysSinceLastBoot -ge $rebootAlert) {
  $popupText = ($warningText -f $DaysSinceLastBoot, $rebootForce)
  $popupType = 0 + 64 + 4096
}

[Void]$WShell.Popup($popupText, 0, $alertTitle, $popupType)

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
Hidden stuff:
  4096 - System modal - lock system until button is pressed
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