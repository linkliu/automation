$ovpn_dir = "D:\MyProject\mybat\vpnconf"
$auth_file = "D:\MyProject\mybat\auth.txt"
$log_file = "D:\MyProject\mybat\temp.log"

foreach ($ovpn_file in Get-ChildItem -Path $ovpn_dir -Filter *.ovpn) {
  Write-Host "Trying $($ovpn_file.Name)"
  Remove-Item $log_file -ErrorAction SilentlyContinue
  $process = Start-Process -FilePath "C:\Program Files\OpenVPN\bin\openvpn.exe" -ArgumentList "--config $ovpn_file --auth-user-pass $auth_file --connect-timeout 10 --connect-retry-max 3 " -NoNewWindow -PassThru -RedirectStandardOutput $log_file
  $connected = $false
  while (!$process.HasExited) {
    $content = Get-Content $log_file
    if ($content -match "Initialization Sequence Completed") {
      $connected = $true
      Write-Host "Connected successfully!"
      break
    }
    Start-Sleep -Milliseconds 1000
  }
  if ($connected) {
    $inputStr = Read-Host "Type 'stop' to terminate the program"
    if ($inputStr.Equals("stop")) {
      $killProcess = Get-Process -Name *openvpn*
      if ($killProcess) {
        Stop-Process -Name "openvpn" -Force
      }
      break
    }
  }
  if (!$connected) {
    Write-Host "Configurations failed"
    $killProcess = Get-Process -Name *openvpn*
    if ($killProcess) {
      Stop-Process -Name "openvpn" -Force
    }
    Start-Sleep -Seconds 5
  }
}

