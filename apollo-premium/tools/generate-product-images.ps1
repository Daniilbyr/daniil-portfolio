# Локальные JPEG для GitHub Pages (без внешних CDN). Запуск: powershell -File tools/generate-product-images.ps1
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

function Save-Jpeg {
  param([string]$Path, [System.Drawing.Bitmap]$Bitmap, [int]$Quality = 90)
  $dir = Split-Path -Parent $Path
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
  $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
  $ep = New-Object System.Drawing.Imaging.EncoderParameters 1
  $ep.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter ([System.Drawing.Imaging.Encoder]::Quality, [long]$Quality)
  $Bitmap.Save($Path, $codec, $ep)
  $ep.Dispose()
}

function New-LinearBrush {
  param([int]$W, [int]$H, [System.Drawing.Color]$A, [System.Drawing.Color]$B, [float]$Angle = 90)
  $rect = New-Object System.Drawing.RectangleF 0, 0, $W, $H
  [System.Drawing.Drawing2D.LinearGradientBrush]::new($rect, $A, $B, $Angle)
}

$root = Join-Path $PSScriptRoot '..' | Resolve-Path
$img = Join-Path $root 'img'

# --- Hero PDP 900x1050 ---
$b = New-Object System.Drawing.Bitmap 900, 1050
$g = [System.Drawing.Graphics]::FromImage($b)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$brush = New-LinearBrush 900 1050 ([System.Drawing.Color]::FromArgb(255, 240, 242, 245)) ([System.Drawing.Color]::FromArgb(255, 210, 216, 228)) 135
$g.FillRectangle($brush, 0, 0, 900, 1050)
$brush.Dispose()
$path = New-Object System.Drawing.Drawing2D.GraphicsPath
$path.AddEllipse(-120, 200, 1140, 900)
$pb = New-Object System.Drawing.Drawing2D.PathGradientBrush $path
$pb.CenterColor = [System.Drawing.Color]::FromArgb(0, 255, 255, 255)
$pb.SurroundColors = @([System.Drawing.Color]::FromArgb(35, 15, 23, 42))
$g.FillPath($pb, $path)
$pb.Dispose(); $path.Dispose()
$bot = New-Object System.Drawing.Drawing2D.GraphicsPath
$bot.AddClosedCurve(@(
  [System.Drawing.PointF]::new(330, 320), [System.Drawing.PointF]::new(330, 780), [System.Drawing.PointF]::new(360, 820),
  [System.Drawing.PointF]::new(540, 820), [System.Drawing.PointF]::new(570, 780), [System.Drawing.PointF]::new(570, 320),
  [System.Drawing.PointF]::new(520, 280), [System.Drawing.PointF]::new(380, 280)
))
$gb = New-LinearBrush 900 1050 ([System.Drawing.Color]::FromArgb(255, 30, 41, 59)) ([System.Drawing.Color]::FromArgb(255, 15, 23, 42)) 0
$g.FillPath($gb, $bot)
$gb.Dispose()
$shine = New-LinearBrush 900 1050 ([System.Drawing.Color]::FromArgb(90, 255, 255, 255)) ([System.Drawing.Color]::FromArgb(0, 255, 255, 255)) 15
$g.FillRectangle($shine, 400, 300, 80, 480)
$shine.Dispose()
$cap = [System.Drawing.RectangleF]::new(410, 210, 80, 72)
$cb = New-LinearBrush 900 1050 ([System.Drawing.Color]::FromArgb(255, 60, 60, 60)) ([System.Drawing.Color]::FromArgb(255, 10, 10, 10)) 90
$g.FillEllipse($cb, $cap)
$cb.Dispose()
$sh = New-Object System.Drawing.Drawing2D.GraphicsPath
$sh.AddEllipse(210, 920, 480, 48)
$sb = New-Object System.Drawing.Drawing2D.PathGradientBrush $sh
$sb.CenterColor = [System.Drawing.Color]::FromArgb(55, 0, 0, 0)
$sb.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 0, 0, 0))
$g.FillPath($sb, $sh)
$sb.Dispose(); $sh.Dispose()
$g.Dispose()
Save-Jpeg (Join-Path $img 'products\pdp-hero.jpg') $b
$b.Dispose()

# --- Card Slate 800x800 ---
$b = New-Object System.Drawing.Bitmap 800, 800
$g = [System.Drawing.Graphics]::FromImage($b)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$brush = New-LinearBrush 800 800 ([System.Drawing.Color]::FromArgb(255, 248, 250, 252)) ([System.Drawing.Color]::FromArgb(255, 203, 213, 225)) 160
$g.FillRectangle($brush, 0, 0, 800, 800)
$brush.Dispose()
$bot = New-Object System.Drawing.Drawing2D.GraphicsPath
$bot.AddClosedCurve(@(
  [System.Drawing.PointF]::new(260, 220), [System.Drawing.PointF]::new(260, 560), [System.Drawing.PointF]::new(290, 620),
  [System.Drawing.PointF]::new(510, 620), [System.Drawing.PointF]::new(540, 560), [System.Drawing.PointF]::new(540, 220),
  [System.Drawing.PointF]::new(500, 180), [System.Drawing.PointF]::new(300, 180)
))
$gb = New-LinearBrush 800 800 ([System.Drawing.Color]::FromArgb(255, 226, 232, 240)) ([System.Drawing.Color]::FromArgb(255, 148, 163, 184)) 5
$g.FillPath($gb, $bot)
$gb.Dispose()
$pump = [System.Drawing.RectangleF]::new(360, 120, 80, 72)
$pb = New-LinearBrush 800 800 ([System.Drawing.Color]::FromArgb(255, 51, 65, 85)) ([System.Drawing.Color]::FromArgb(255, 15, 23, 42)) 90
$g.FillEllipse($pb, $pump)
$pb.Dispose()
$g.Dispose()
Save-Jpeg (Join-Path $img 'products\card-slate.jpg') $b
$b.Dispose()

# --- Card beard 800x800 ---
$b = New-Object System.Drawing.Bitmap 800, 800
$g = [System.Drawing.Graphics]::FromImage($b)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$brush = New-LinearBrush 800 800 ([System.Drawing.Color]::FromArgb(255, 250, 245, 235)) ([System.Drawing.Color]::FromArgb(255, 220, 200, 170)) 145
$g.FillRectangle($brush, 0, 0, 800, 800)
$brush.Dispose()
$bot = New-Object System.Drawing.Drawing2D.GraphicsPath
$bot.AddClosedCurve(@(
  [System.Drawing.PointF]::new(310, 240), [System.Drawing.PointF]::new(310, 540), [System.Drawing.PointF]::new(340, 590),
  [System.Drawing.PointF]::new(460, 590), [System.Drawing.PointF]::new(490, 540), [System.Drawing.PointF]::new(490, 240),
  [System.Drawing.PointF]::new(450, 200), [System.Drawing.PointF]::new(350, 200)
))
$gb = New-LinearBrush 800 800 ([System.Drawing.Color]::FromArgb(255, 180, 83, 9)) ([System.Drawing.Color]::FromArgb(255, 120, 53, 15)) 45
$g.FillPath($gb, $bot)
$gb.Dispose()
$liq = New-LinearBrush 800 800 ([System.Drawing.Color]::FromArgb(200, 251, 191, 36)) ([System.Drawing.Color]::FromArgb(40, 253, 224, 71)) 90
$g.FillEllipse($liq, 330, 320, 140, 160)
$liq.Dispose()
$g.Dispose()
Save-Jpeg (Join-Path $img 'products\card-beard.jpg') $b
$b.Dispose()

# --- Card grey 800x800 ---
$b = New-Object System.Drawing.Bitmap 800, 800
$g = [System.Drawing.Graphics]::FromImage($b)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$brush = New-LinearBrush 800 800 ([System.Drawing.Color]::FromArgb(255, 232, 236, 242)) ([System.Drawing.Color]::FromArgb(255, 148, 163, 184)) 120
$g.FillRectangle($brush, 0, 0, 800, 800)
$brush.Dispose()
$bot = New-Object System.Drawing.Drawing2D.GraphicsPath
$bot.AddClosedCurve(@(
  [System.Drawing.PointF]::new(280, 200), [System.Drawing.PointF]::new(280, 580), [System.Drawing.PointF]::new(310, 640),
  [System.Drawing.PointF]::new(490, 640), [System.Drawing.PointF]::new(520, 580), [System.Drawing.PointF]::new(520, 200),
  [System.Drawing.PointF]::new(470, 160), [System.Drawing.PointF]::new(330, 160)
))
$gb = New-LinearBrush 800 800 ([System.Drawing.Color]::FromArgb(255, 51, 65, 85)) ([System.Drawing.Color]::FromArgb(255, 15, 23, 42)) 0
$g.FillPath($gb, $bot)
$gb.Dispose()
$shine = New-LinearBrush 800 800 ([System.Drawing.Color]::FromArgb(100, 255, 255, 255)) ([System.Drawing.Color]::FromArgb(0, 100, 116, 139)) 20
$g.FillRectangle($shine, 360, 220, 70, 380)
$shine.Dispose()
$g.Dispose()
Save-Jpeg (Join-Path $img 'products\card-grey.jpg') $b
$b.Dispose()

function Draw-Mosaic1([System.Drawing.Graphics]$g) {
  $w, $h = 400, 400
  $brush = New-LinearBrush $w $h ([System.Drawing.Color]::FromArgb(255, 232, 235, 240)) ([System.Drawing.Color]::FromArgb(255, 180, 190, 205)) 55
  $g.FillRectangle($brush, 0, 0, $w, $h)
  $brush.Dispose()
  $g.FillEllipse([System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(60, 148, 163, 184)), 80, 80, 240, 240)
  $g.FillEllipse([System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(45, 100, 116, 139)), 140, 140, 120, 120)
}
function Draw-Mosaic2([System.Drawing.Graphics]$g) {
  $w, $h = 400, 400
  $brush = New-LinearBrush $w $h ([System.Drawing.Color]::FromArgb(255, 241, 245, 249)) ([System.Drawing.Color]::FromArgb(255, 200, 210, 220)) 315
  $g.FillRectangle($brush, 0, 0, $w, $h)
  $brush.Dispose()
  $g.FillRectangle([System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(120, 203, 213, 225)), 72, 108, 256, 184)
  $g.FillRectangle([System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(90, 148, 163, 184)), 96, 132, 208, 136)
}
function Draw-Mosaic3([System.Drawing.Graphics]$g) {
  $w, $h = 400, 400
  $brush = New-LinearBrush $w $h ([System.Drawing.Color]::FromArgb(255, 248, 250, 252)) ([System.Drawing.Color]::FromArgb(255, 210, 220, 230)) 90
  $g.FillRectangle($brush, 0, 0, $w, $h)
  $brush.Dispose()
  $p = New-Object System.Drawing.Drawing2D.GraphicsPath
  $p.AddPolygon(@(
    [System.Drawing.Point]::new(80, 300), [System.Drawing.Point]::new(200, 100), [System.Drawing.Point]::new(320, 300)
  ))
  $g.FillPath([System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(70, 148, 163, 184)), $p)
  $p.Dispose()
}

foreach ($pair in @(
  @{ n = 'footer\mosaic-1.jpg'; d = { param($gr) Draw-Mosaic1 $gr } }
  @{ n = 'footer\mosaic-2.jpg'; d = { param($gr) Draw-Mosaic2 $gr } }
  @{ n = 'footer\mosaic-3.jpg'; d = { param($gr) Draw-Mosaic3 $gr } }
)) {
  $b = New-Object System.Drawing.Bitmap 400, 400
  $g = [System.Drawing.Graphics]::FromImage($b)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  & $pair.d $g
  $g.Dispose()
  Save-Jpeg (Join-Path $img $pair.n) $b
  $b.Dispose()
}

Write-Host "OK -> $img"
Get-ChildItem -Recurse $img -File | ForEach-Object { Write-Host $_.FullName ([math]::Round($_.Length / 1KB, 1)) 'KB' }
