$root = "C:\Users\matt-\adventure-works-dashboard"
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:8742/")
$listener.Start()
Write-Output "Serving $root on http://localhost:8742/"
$mime = @{ ".html"="text/html"; ".js"="application/javascript"; ".css"="text/css"; ".json"="application/json"; ".png"="image/png"; ".svg"="image/svg+xml" }
while ($listener.IsListening) {
  $ctx = $listener.GetContext()
  $path = $ctx.Request.Url.LocalPath.TrimStart('/')
  if ([string]::IsNullOrEmpty($path)) { $path = "index.html" }
  $file = Join-Path $root $path
  if (Test-Path $file -PathType Leaf) {
    $bytes = [System.IO.File]::ReadAllBytes($file)
    $ext = [System.IO.Path]::GetExtension($file).ToLower()
    if ($mime.ContainsKey($ext)) { $ctx.Response.ContentType = $mime[$ext] }
    $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
  } else {
    $ctx.Response.StatusCode = 404
  }
  $ctx.Response.Close()
}
