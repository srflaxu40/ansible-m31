#Set-ExecutionPolicy Unrestricted

# base url to Jenkins master
$jenkinsserverurl = "http://{{ MASTER_HOSTNAME }}:{{ MASTER_PORT }}/"

Write-Output "Downloading jenkins slave jar "

# in order to avoid updating it manually for Jenkins master updates
$slaveJarSource = $jenkinsserverurl + "jnlpJars/slave.jar"
$slaveJarLocal = "C:\Program Files (x86)\Java\agent.jar"


$wc = New-Object System.Net.WebClient
$wc.DownloadFile($slaveJarSource, $slaveJarLocal)

Write-Output "Executing slave process "
$jnlpSource = $jenkinsserverurl + "computer/{{ AGENT_NAME }}/slave-agent.jnlp"

$ActionParams = @{
    Execute = 'C:\Program Files\Java\jre1.8.0_171\bin\java.exe'
    Argument = "-jar agent.jar -jnlpUrl " + $jnlpSource
    WorkingDirectory = "C:\Program Files (x86)\Java\"
}

$Action = New-ScheduledTaskAction @ActionParams
$Trigger = New-ScheduledTaskTrigger -RandomDelay (New-TimeSpan -Minutes 5) -AtStartup
$Settings = New-ScheduledTaskSettingsSet -DontStopOnIdleEnd -RestartInterval (New-TimeSpan -Minutes 1) -RestartCount 10 -StartWhenAvailable
$Settings.ExecutionTimeLimit = "PT0S"
$Task = New-ScheduledTask -Action $Action -Trigger $Trigger -Settings $Settings

$Task | Register-ScheduledTask -TaskName 'Jenkins JNLP Slave Agent' -User "{{ ansible_user }}" -Password "{{ ansible_password }}"

Clear-Host

Invoke-Command -ScriptBlock {Start-ScheduledTask 'Jenkins JNLP Slave Agent'}
