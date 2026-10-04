# study-timer.html を http://localhost:8765/ で配信する簡易サーバー（追加インストール不要）
$ErrorActionPreference = 'Stop'
$port = 8765
$url  = "http://localhost:$port/"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$file = Join-Path $root 'study-timer.html'

if (-not (Test-Path $file)) {
    Write-Host "study-timer.html が見つかりません。serve.ps1 と同じフォルダに置いてください: $file" -ForegroundColor Red
    Read-Host 'Enterキーで閉じます'
    exit 1
}

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($url)
try {
    $listener.Start()
} catch {
    Write-Host "サーバーを起動できませんでした（ポート $port が使用中の可能性があります）: $($_.Exception.Message)" -ForegroundColor Red
    Read-Host 'Enterキーで閉じます'
    exit 1
}

Write-Host "起動しました: $url"
Write-Host 'このウィンドウを閉じるとサーバーが止まります。タイマーを使う間は開いたままにしてください。'
Write-Host '(終了するときは、このウィンドウを閉じるか Ctrl+C)'

try { Start-Process 'chrome' $url } catch { Start-Process $url }

try {
    while ($listener.IsListening) {
        $ctx  = $listener.GetContext()
        $path = $ctx.Request.Url.AbsolutePath
        if ($path -eq '/' -or $path -eq '/study-timer.html') {
            $bytes = [System.IO.File]::ReadAllBytes($file)   # 毎回読み直すので編集後は再読み込みするだけ
            $ctx.Response.ContentType = 'text/html; charset=utf-8'
            $ctx.Response.ContentLength64 = $bytes.Length
            $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
        } else {
            $ctx.Response.StatusCode = 404
        }
        $ctx.Response.Close()
    }
} finally {
    $listener.Stop()
}
