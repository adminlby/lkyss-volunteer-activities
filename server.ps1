# HK Oldies Sing-Along - minimal local HTTP server (no Python, no admin)
# Serves index.html on http://127.0.0.1:8765/
# Close this window to stop the server.

$ErrorActionPreference = "Stop"
$port = 8765
$root = $PSScriptRoot
if (-not $root) { $root = (Get-Location).Path }

$listener = $null
try {
    $listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback, $port)
    $listener.Start()
} catch {
    Write-Host "Cannot start the local server on port $port."
    Write-Host $_.Exception.Message
    Write-Host "The port may be in use. Close other server windows and try again."
    Read-Host "Press Enter to close"
    exit 1
}

Write-Host "HK Oldies Server is running."
Write-Host "Open: http://127.0.0.1:$port/"
Write-Host "Keep this window open while the game is running."
Write-Host "Close this window to stop the server."

function Send-Response($stream, $status, $contentType, [byte[]]$body) {
    $header = "HTTP/1.1 $status`r`n" +
              "Content-Type: $contentType`r`n" +
              "Content-Length: $($body.Length)`r`n" +
              "Cache-Control: no-store`r`n" +
              "Connection: close`r`n`r`n"
    $headerBytes = [System.Text.Encoding]::ASCII.GetBytes($header)
    $stream.Write($headerBytes, 0, $headerBytes.Length)
    if ($body.Length -gt 0) {
        $stream.Write($body, 0, $body.Length)
    }
    $stream.Flush()
}

while ($true) {
    $client = $null
    try {
        $client = $listener.AcceptTcpClient()
        $stream = $client.GetStream()
        $reader = New-Object System.IO.StreamReader($stream, [System.Text.Encoding]::ASCII, $false, 1024, $true)

        $requestLine = $reader.ReadLine()
        if ([string]::IsNullOrEmpty($requestLine)) {
            $client.Close()
            continue
        }

        # Consume HTTP headers
        while ($true) {
            $line = $reader.ReadLine()
            if ($null -eq $line -or $line -eq "") { break }
        }

        $parts = $requestLine.Split(" ")
        $method = $parts[0]
        $rawPath = $parts[1]
        $path = $rawPath.Split("?")[0]

        if (($path -eq "/" -or $path -eq "/index.html") -and $method -ne "POST") {
            $file = Join-Path $root "index.html"
            if (Test-Path -LiteralPath $file) {
                $bytes = [System.IO.File]::ReadAllBytes($file)
                Send-Response $stream "200 OK" "text/html; charset=utf-8" $bytes
            } else {
                $body = [System.Text.Encoding]::UTF8.GetBytes("index.html not found")
                Send-Response $stream "404 Not Found" "text/plain; charset=utf-8" $body
            }
        } else {
            $body = [System.Text.Encoding]::UTF8.GetBytes("Not found")
            Send-Response $stream "404 Not Found" "text/plain; charset=utf-8" $body
        }

        $reader.Close()
        $client.Close()
    } catch {
        if ($client -ne $null) {
            try { $client.Close() } catch {}
        }
    }
}
