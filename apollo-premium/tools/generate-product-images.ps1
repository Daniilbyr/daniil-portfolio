# Локальные JPEG для GitHub Pages. Запуск из apollo-premium: powershell -File tools/generate-product-images.ps1
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

function Save-Jpeg {
  param([string]$Path, [System.Drawing.Bitmap]$Bitmap, [int]$Quality = 92)
  $dir = Split-Path -Parent $Path
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
  $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
  $ep = New-Object System.Drawing.Imaging.EncoderParameters 1
  $ep.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter ([System.Drawing.Imaging.Encoder]::Quality, [long]$Quality)
  $Bitmap.Save($Path, $codec, $ep)
  $ep.Dispose()
}

function New-LinBrush {
  param([float]$W, [float]$H, [System.Drawing.Color]$A, [System.Drawing.Color]$B, [float]$Angle = 90)
  $rect = New-Object System.Drawing.RectangleF 0, 0, $W, $H
  [System.Drawing.Drawing2D.LinearGradientBrush]::new($rect, $A, $B, $Angle)
}

function Fill-RadialSpot {
  param(
    [System.Drawing.Graphics]$G,
    [float]$Cx, [float]$Cy, [float]$Rx, [float]$Ry,
    [System.Drawing.Color]$Center, [System.Drawing.Color]$Edge
  )
  $path = New-Object System.Drawing.Drawing2D.GraphicsPath
  $path.AddEllipse($Cx - $Rx, $Cy - $Ry, $Rx * 2, $Ry * 2)
  $pgb = New-Object System.Drawing.Drawing2D.PathGradientBrush $path
  $pgb.CenterColor = $Center
  $pgb.SurroundColors = @($Edge)
  $pgb.FocusScales = New-Object System.Drawing.PointF 0.85, 0.85
  $G.FillPath($pgb, $path)
  $pgb.Dispose()
  $path.Dispose()
}

function Fill-Vignette {
  param([System.Drawing.Graphics]$G, [int]$W, [int]$H, [int]$Alpha = 35)
  $path = New-Object System.Drawing.Drawing2D.GraphicsPath
  $path.AddRectangle([System.Drawing.Rectangle]::new(0, 0, $W, $H))
  $pgb = New-Object System.Drawing.Drawing2D.PathGradientBrush $path
  $c = [System.Drawing.Color]::FromArgb($Alpha, 20, 24, 32)
  $pgb.CenterColor = [System.Drawing.Color]::FromArgb(0, 0, 0, 0)
  $pgb.SurroundColors = @($c)
  $pgb.FocusScales = New-Object System.Drawing.PointF 0.35, 0.35
  $G.FillPath($pgb, $path)
  $pgb.Dispose()
  $path.Dispose()
}

function Draw-BottleSilhouette {
  param(
    [System.Drawing.Graphics]$G,
    [float]$Cx, [float]$BaseY,
    [float]$Scale = 1,
    [hashtable]$Palette
  )
  $G.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $s = $Scale
  # Тень под флаконом
  $sh = New-Object System.Drawing.Drawing2D.GraphicsPath
  $sh.AddEllipse($Cx - 140 * $s, $BaseY + 20 * $s, 280 * $s, 36 * $s)
  $sb = New-Object System.Drawing.Drawing2D.PathGradientBrush $sh
  $sb.CenterColor = [System.Drawing.Color]::FromArgb(90, 15, 20, 30)
  $sb.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 0, 0, 0))
  $G.FillPath($sb, $sh)
  $sb.Dispose(); $sh.Dispose()

  # Крышка / спрей
  $capW = 88 * $s; $capH = 44 * $s
  $capTop = $BaseY - 380 * $s
  $cap = New-Object System.Drawing.Drawing2D.GraphicsPath
  $cap.AddArc($Cx - $capW / 2, $capTop, $capW, $capH * 0.9, 180, 180)
  $cap.AddLine($Cx + $capW / 2, $capTop + $capH * 0.45, $Cx + $capW / 2 - 8 * $s, $capTop + $capH)
  $cap.AddLine($Cx - $capW / 2 + 8 * $s, $capTop + $capH, $Cx - $capW / 2, $capTop + $capH * 0.45)
  $cap.CloseFigure()
  $cb = New-LinBrush 800 800 $Palette.CapA $Palette.CapB 90
  $G.FillPath($cb, $cap)
  $cb.Dispose()
  $cap.Dispose()

  # Горлышко
  $G.FillRectangle(
    [System.Drawing.SolidBrush]::new($Palette.Neck),
    $Cx - 36 * $s, $capTop + $capH - 4 * $s, 72 * $s, 28 * $s
  )

  # Корпус флакона
  $body = New-Object System.Drawing.Drawing2D.GraphicsPath
  $w = 78 * $s; $t = $capTop + $capH + 20 * $s; $bot = $BaseY - 8 * $s
  $body.AddBezier(
    [System.Drawing.PointF]::new($Cx - $w, $t),
    [System.Drawing.PointF]::new($Cx - $w - 8 * $s, $t + 120 * $s),
    [System.Drawing.PointF]::new($Cx - $w - 6 * $s, $bot - 40 * $s),
    [System.Drawing.PointF]::new($Cx - 62 * $s, $bot)
  )
  $body.AddBezier(
    [System.Drawing.PointF]::new($Cx - 62 * $s, $bot),
    [System.Drawing.PointF]::new($Cx - 20 * $s, $bot + 18 * $s),
    [System.Drawing.PointF]::new($Cx + 20 * $s, $bot + 18 * $s),
    [System.Drawing.PointF]::new($Cx + 62 * $s, $bot)
  )
  $body.AddBezier(
    [System.Drawing.PointF]::new($Cx + 62 * $s, $bot),
    [System.Drawing.PointF]::new($Cx + $w + 6 * $s, $bot - 40 * $s),
    [System.Drawing.PointF]::new($Cx + $w + 8 * $s, $t + 120 * $s),
    [System.Drawing.PointF]::new($Cx + $w, $t)
  )
  $body.CloseFigure()
  $bb = New-LinBrush 800 800 $Palette.GlassL $Palette.GlassR 0
  $G.FillPath($bb, $body)
  $bb.Dispose()

  # Блик стекла
  $hi = New-Object System.Drawing.Drawing2D.GraphicsPath
  $hi.AddPolygon(@(
    [System.Drawing.PointF]::new($Cx - 48 * $s, $t + 40 * $s),
    [System.Drawing.PointF]::new($Cx - 22 * $s, $t + 35 * $s),
    [System.Drawing.PointF]::new($Cx - 18 * $s, $bot - 50 * $s),
    [System.Drawing.PointF]::new($Cx - 44 * $s, $bot - 20 * $s)
  ))
  $hb = New-LinBrush 800 800 ([System.Drawing.Color]::FromArgb(180, 255, 255, 255)) ([System.Drawing.Color]::FromArgb(0, 255, 255, 255)) 95
  $G.FillPath($hb, $hi)
  $hb.Dispose()
  $hi.Dispose()

  # Тонкая кромка справа
  $edge = New-Object System.Drawing.Drawing2D.GraphicsPath
  $edge.AddPolygon(@(
    [System.Drawing.PointF]::new($Cx + 52 * $s, $t + 50 * $s),
    [System.Drawing.PointF]::new($Cx + 70 * $s, $t + 80 * $s),
    [System.Drawing.PointF]::new($Cx + 58 * $s, $bot - 25 * $s),
    [System.Drawing.PointF]::new($Cx + 44 * $s, $bot - 8 * $s)
  ))
  $eb = New-LinBrush 800 800 ([System.Drawing.Color]::FromArgb(0, 255, 255, 255)) ([System.Drawing.Color]::FromArgb(120, 200, 210, 230)) 110
  $G.FillPath($eb, $edge)
  $eb.Dispose()
  $edge.Dispose()

  $body.Dispose()
}

$root = Join-Path $PSScriptRoot '..' | Resolve-Path
$img = Join-Path $root 'img'
$W800 = 800
$H800 = 800

# ========== Card: Slate (холодный студийный) ==========
$b = New-Object System.Drawing.Bitmap 800, 800
$g = [System.Drawing.Graphics]::FromImage($b)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$bg = New-LinBrush $W800 $H800 `
  ([System.Drawing.Color]::FromArgb(255, 242, 244, 248)) `
  ([System.Drawing.Color]::FromArgb(255, 216, 222, 232)) 165
$g.FillRectangle($bg, 0, 0, 800, 800)
$bg.Dispose()
Fill-RadialSpot $g 400 280 420 320 `
  ([System.Drawing.Color]::FromArgb(38, 255, 255, 255)) `
  ([System.Drawing.Color]::FromArgb(0, 245, 248, 252))
Draw-BottleSilhouette $g 400 620 1 @{
  CapA = [System.Drawing.Color]::FromArgb(255, 52, 52, 58)
  CapB = [System.Drawing.Color]::FromArgb(255, 18, 18, 22)
  Neck = [System.Drawing.Color]::FromArgb(255, 28, 30, 36)
  GlassL = [System.Drawing.Color]::FromArgb(255, 55, 65, 82)
  GlassR = [System.Drawing.Color]::FromArgb(255, 22, 28, 42)
}
Fill-Vignette $g 800 800 28
$g.Dispose()
Save-Jpeg (Join-Path $img 'products\card-slate.jpg') $b
$b.Dispose()

# ========== Card: Beard (тёплый янтарь / уход) ==========
$b = New-Object System.Drawing.Bitmap 800, 800
$g = [System.Drawing.Graphics]::FromImage($b)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$bg = New-LinBrush $W800 $H800 `
  ([System.Drawing.Color]::FromArgb(255, 252, 246, 236)) `
  ([System.Drawing.Color]::FromArgb(255, 232, 210, 185)) 140
$g.FillRectangle($bg, 0, 0, 800, 800)
$bg.Dispose()
Fill-RadialSpot $g 400 260 380 300 `
  ([System.Drawing.Color]::FromArgb(45, 255, 248, 235)) `
  ([System.Drawing.Color]::FromArgb(0, 252, 238, 220))
# Янтарная тень
$sh = New-Object System.Drawing.Drawing2D.GraphicsPath
$sh.AddEllipse(210, 600, 380, 42)
$sb = New-Object System.Drawing.Drawing2D.PathGradientBrush $sh
$sb.CenterColor = [System.Drawing.Color]::FromArgb(70, 120, 72, 48)
$sb.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 0, 0, 0))
$g.FillPath($sb, $sh)
$sb.Dispose(); $sh.Dispose()
# Упрощённый флакон янтарный
$s = 1; $Cx = 400; $BaseY = 615
$capTop = $BaseY - 360 * $s
$capW = 76 * $s; $capH = 40 * $s
$cap = New-Object System.Drawing.Drawing2D.GraphicsPath
$cap.AddArc($Cx - $capW / 2, $capTop, $capW, $capH * 0.85, 180, 180)
$cap.AddLine($Cx + $capW / 2, $capTop + $capH * 0.4, $Cx + 34 * $s, $capTop + $capH)
$cap.AddLine($Cx - 34 * $s, $capTop + $capH, $Cx - $capW / 2, $capTop + $capH * 0.4)
$cap.CloseFigure()
$cb = New-LinBrush $W800 $H800 ([System.Drawing.Color]::FromArgb(255, 92, 58, 36)) ([System.Drawing.Color]::FromArgb(255, 48, 28, 18)) 90
$g.FillPath($cb, $cap)
$cb.Dispose()
$cap.Dispose()
$g.FillRectangle([System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(255, 120, 62, 38)), $Cx - 30 * $s, $capTop + $capH - 2, 60 * $s, 24 * $s)
$body = New-Object System.Drawing.Drawing2D.GraphicsPath
$w = 70 * $s; $t = $capTop + $capH + 18 * $s; $bot = $BaseY - 6 * $s
$body.AddBezier(
  [System.Drawing.PointF]::new($Cx - $w, $t),
  [System.Drawing.PointF]::new($Cx - $w - 6, $t + 110 * $s),
  [System.Drawing.PointF]::new($Cx - $w, $bot - 35 * $s),
  [System.Drawing.PointF]::new($Cx - 56 * $s, $bot)
)
$body.AddBezier(
  [System.Drawing.PointF]::new($Cx - 56 * $s, $bot),
  [System.Drawing.PointF]::new($Cx - 18 * $s, $bot + 14 * $s),
  [System.Drawing.PointF]::new($Cx + 18 * $s, $bot + 14 * $s),
  [System.Drawing.PointF]::new($Cx + 56 * $s, $bot)
)
$body.AddBezier(
  [System.Drawing.PointF]::new($Cx + 56 * $s, $bot),
  [System.Drawing.PointF]::new($Cx + $w, $bot - 35 * $s),
  [System.Drawing.PointF]::new($Cx + $w + 6, $t + 110 * $s),
  [System.Drawing.PointF]::new($Cx + $w, $t)
)
$body.CloseFigure()
$amb = New-LinBrush $W800 $H800 ([System.Drawing.Color]::FromArgb(255, 214, 140, 52)) ([System.Drawing.Color]::FromArgb(255, 140, 72, 22)) 20
$g.FillPath($amb, $body)
$amb.Dispose()
$oil = New-LinBrush $W800 $H800 ([System.Drawing.Color]::FromArgb(200, 255, 214, 120)) ([System.Drawing.Color]::FromArgb(60, 255, 200, 80)) 90
$g.FillEllipse($oil, $Cx - 48, $t + 120, 96, 118)
$oil.Dispose()
$hi = New-Object System.Drawing.Drawing2D.GraphicsPath
$hi.AddPolygon(@(
  [System.Drawing.PointF]::new($Cx - 42 * $s, $t + 35 * $s),
  [System.Drawing.PointF]::new($Cx - 20 * $s, $t + 30 * $s),
  [System.Drawing.PointF]::new($Cx - 16 * $s, $bot - 45 * $s),
  [System.Drawing.PointF]::new($Cx - 38 * $s, $bot - 18 * $s)
))
$hb = New-LinBrush $W800 $H800 ([System.Drawing.Color]::FromArgb(160, 255, 255, 245)) ([System.Drawing.Color]::FromArgb(0, 255, 220, 160)) 100
$g.FillPath($hb, $hi)
$hb.Dispose()
$hi.Dispose()
$body.Dispose()
Fill-Vignette $g 800 800 22
$g.Dispose()
Save-Jpeg (Join-Path $img 'products\card-beard.jpg') $b
$b.Dispose()

# ========== Card: Grey (матовое стекло / минимализм) ==========
$b = New-Object System.Drawing.Bitmap 800, 800
$g = [System.Drawing.Graphics]::FromImage($b)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$bg = New-LinBrush $W800 $H800 `
  ([System.Drawing.Color]::FromArgb(255, 248, 249, 252)) `
  ([System.Drawing.Color]::FromArgb(255, 198, 206, 218)) 125
$g.FillRectangle($bg, 0, 0, 800, 800)
$bg.Dispose()
Fill-RadialSpot $g 400 300 400 280 `
  ([System.Drawing.Color]::FromArgb(35, 255, 255, 255)) `
  ([System.Drawing.Color]::FromArgb(0, 235, 238, 245))
Draw-BottleSilhouette $g 400 625 1 @{
  CapA = [System.Drawing.Color]::FromArgb(255, 180, 186, 198)
  CapB = [System.Drawing.Color]::FromArgb(255, 110, 118, 132)
  Neck = [System.Drawing.Color]::FromArgb(255, 150, 156, 168)
  GlassL = [System.Drawing.Color]::FromArgb(255, 210, 214, 224)
  GlassR = [System.Drawing.Color]::FromArgb(255, 120, 128, 148)
}
Fill-Vignette $g 800 800 25
$g.Dispose()
Save-Jpeg (Join-Path $img 'products\card-grey.jpg') $b
$b.Dispose()

# ========== Footer mosaics ==========
function Draw-MosaicLux1([System.Drawing.Graphics]$G) {
  $w, $h = 400, 400
  $bg = New-LinBrush $w $h ([System.Drawing.Color]::FromArgb(255, 245, 242, 248)) ([System.Drawing.Color]::FromArgb(255, 218, 210, 228)) 45
  $G.FillRectangle($bg, 0, 0, $w, $h)
  $bg.Dispose()
  Fill-RadialSpot $G 120 100 180 160 ([System.Drawing.Color]::FromArgb(50, 255, 240, 250)) ([System.Drawing.Color]::FromArgb(0, 240, 230, 245))
  Fill-RadialSpot $G 300 280 200 180 ([System.Drawing.Color]::FromArgb(40, 230, 220, 245)) ([System.Drawing.Color]::FromArgb(0, 220, 210, 235))
  $G.FillEllipse([System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(35, 148, 120, 160)), 130, 140, 140, 140)
  $G.FillEllipse([System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(28, 100, 90, 120)), 180, 190, 90, 90)
}

function Draw-MosaicLux2([System.Drawing.Graphics]$G) {
  $w, $h = 400, 400
  $bg = New-LinBrush $w $h ([System.Drawing.Color]::FromArgb(255, 236, 240, 246)) ([System.Drawing.Color]::FromArgb(255, 175, 188, 205)) 200
  $G.FillRectangle($bg, 0, 0, $w, $h)
  $bg.Dispose()
  $p = New-Object System.Drawing.Drawing2D.GraphicsPath
  $p.AddPolygon(@(
    [System.Drawing.Point]::new(40, 320), [System.Drawing.Point]::new(200, 60), [System.Drawing.Point]::new(360, 320)
  ))
  $tb = New-LinBrush $w $h ([System.Drawing.Color]::FromArgb(120, 255, 255, 255)) ([System.Drawing.Color]::FromArgb(30, 180, 195, 215)) 95
  $G.FillPath($tb, $p)
  $tb.Dispose()
  $p.Dispose()
  $G.FillRectangle([System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(45, 80, 92, 110)), 88, 200, 224, 8)
}

function Draw-MosaicLux3([System.Drawing.Graphics]$G) {
  $w, $h = 400, 400
  $bg = New-LinBrush $w $h ([System.Drawing.Color]::FromArgb(255, 252, 250, 248)) ([System.Drawing.Color]::FromArgb(255, 228, 224, 218)) 90
  $G.FillRectangle($bg, 0, 0, $w, $h)
  $bg.Dispose()
  Fill-RadialSpot $G 200 200 220 200 ([System.Drawing.Color]::FromArgb(55, 255, 255, 255)) ([System.Drawing.Color]::FromArgb(0, 240, 236, 232))
  for ($i = 0; $i -lt 4; $i++) {
    $a = 18 - $i * 4
    $G.FillEllipse([System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb($a, 90, 95, 110)), 60 + $i * 28, 100 + $i * 22, 280 - $i * 40, 200 - $i * 30)
  }
}

foreach ($pair in @(
  @{ n = 'footer\mosaic-1.jpg'; d = { param($gr) Draw-MosaicLux1 $gr } }
  @{ n = 'footer\mosaic-2.jpg'; d = { param($gr) Draw-MosaicLux2 $gr } }
  @{ n = 'footer\mosaic-3.jpg'; d = { param($gr) Draw-MosaicLux3 $gr } }
)) {
  $bm = New-Object System.Drawing.Bitmap 400, 400
  $gr = [System.Drawing.Graphics]::FromImage($bm)
  $gr.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  & $pair.d $gr
  $gr.Dispose()
  Save-Jpeg (Join-Path $img $pair.n) $bm
  $bm.Dispose()
}

Write-Host "OK -> $img"
Get-ChildItem -Recurse $img -File | ForEach-Object { Write-Host $_.FullName ([math]::Round($_.Length / 1KB, 1)) 'KB' }
