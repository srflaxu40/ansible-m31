Set-ExecutionPolicy Unrestricted

# base url to Jenkins master
$jenkinsserverurl = "http://{{ MASTER_HOSTNAME }}:{{ MASTER_PORT }}/"


$vmname = (Get-Culture).TextInfo.ToTitleCase($env:computername.tolower())

# authenticate with Jenkins service user + API-token - since we don't know the '-secret'
# $apiToken="jenkins_user:1234abcdefab56c7d890de1f2a345b67"

Write-Output "Downloading jenkins slave jar "

# in order to avoid updating it manually for Jenkins master updates
$slaveJarSource = $jenkinsserverurl + "jnlpJars/slave.jar"
$slaveJarLocal = "C:\Program Files (x86)\Java\agent.jar"


$wc = New-Object System.Net.WebClient
$wc.DownloadFile($slaveJarSource, $slaveJarLocal)

Write-Output "Executing slave process "
$jnlpSource = $jenkinsserverurl+"computer/{{ AGENT_NAME }}/slave-agent.jnlp"

# & java -jar $slaveJarLocal -jnlpCredentials $apiToken -jnlpUrl $jnlpSource -noCertificateCheck


Write-Output "Connect "
& java -jar $slaveJarLocal -jnlpUrl $jnlpSource -noCertificateCheck
