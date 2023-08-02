# Import scheduled task to refresh ConfigMgr client MPs when ZPA changes ClientAlwaysOnInternet setting
$taskXml = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.4" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Date>2023-03-03T16:26:40.9577715</Date>
    <Author>silvermarkg</Author>
    <Description>Triggers the 'Refresh Default MP Task' schedule when Zscaler Private Access changes the value of HKLM\Software\Microsoft\CCM\Security\ClientAlwaysOnInternet. This ensures the ConfigMgr client updates its location (Intranet/Internet) as soon as possible.</Description>
    <URI>\Refresh ConfigMgr Client Location</URI>
  </RegistrationInfo>
  <Principals>
    <Principal id="Author">
      <UserId>S-1-5-18</UserId>
    </Principal>
  </Principals>
  <Settings>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>true</StopIfGoingOnBatteries>
    <ExecutionTimeLimit>PT1H</ExecutionTimeLimit>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <IdleSettings>
      <StopOnIdleEnd>true</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <UseUnifiedSchedulingEngine>true</UseUnifiedSchedulingEngine>
  </Settings>
  <Triggers>
    <EventTrigger>
      <Subscription>&lt;QueryList&gt;&lt;Query Id="0" Path="Security"&gt;&lt;Select Path="Security"&gt;*[System[Provider[@Name='Microsoft-Windows-Security-Auditing'] and Task = 12801 and (band(Keywords,9007199254740992)) and (EventID=4657)]] and *[EventData[Data[@Name='ObjectName'] and (Data='\REGISTRY\MACHINE\SOFTWARE\Microsoft\CCM\Security')]] and *[EventData[Data[@Name='ObjectValueName'] and (Data='ClientAlwaysOnInternet')]]
&lt;/Select&gt;&lt;/Query&gt;&lt;/QueryList&gt;</Subscription>
    </EventTrigger>
  </Triggers>
  <Actions Context="Author">
    <Exec>
      <Command>powershell.exe</Command>
      <Arguments>-NoProfile -NonInteractive -WindowStyle Hidden -Command "&amp; {Invoke-CimMethod -Namespace root\ccm -ClassName sms_client -MethodName TriggerSchedule -Arguments @{sScheduleID='{00000000-0000-0000-0000-000000000023}'}}"</Arguments>
    </Exec>
  </Actions>
</Task>
"@

Register-ScheduledTask -Xml $taskXml -TaskName "Refresh ConfigMgr Client Location" -TaskPath '\'
$task = Get-ScheduledTask -TaskName "Refresh ConfigMgr Client Location" -TaskPath '\' -ErrorAction SilentlyContinue
if ($task) {
  Exit 0
}
else {
  Exit 1
}
