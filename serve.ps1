# 本地起一个静态服务浏览 1978 武汉瓦片（默认 8099 端口）
# 用法：  .\serve.ps1          # 启动
#         .\serve.ps1 -Stop    # 停止
param([switch]$Stop, [int]$Port = 8099)

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$pattern = "http.server $Port"

$existing = Get-CimInstance Win32_Process -Filter "Name='python.exe'" |
    Where-Object { $_.CommandLine -like "*http.server $Port*" }

if ($Stop) {
    if ($existing) {
        $existing | ForEach-Object { Stop-Process -Id $_.ProcessId -Force }
        "stopped $($existing.Count) server(s) on port $Port"
    } else {
        "no server on port $Port"
    }
    return
}

if ($existing) {
    "already running -> http://127.0.0.1:$Port/"
    return
}

$py = 'C:\Program Files\Python312\python.exe'
if (!(Test-Path $py)) { $py = 'python' }
Start-Process -FilePath $py -ArgumentList '-m', 'http.server', $Port, '--bind', '127.0.0.1', '--directory', $root -WindowStyle Hidden
Start-Sleep -Seconds 2
try {
    $r = Invoke-WebRequest "http://127.0.0.1:$Port/index.html" -TimeoutSec 8 -UseBasicParsing
    "started -> http://127.0.0.1:$Port/  ($($r.StatusCode))"
} catch {
    "started but check failed: $($_.Exception.Message)"
}
