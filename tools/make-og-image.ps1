Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$photoPath = Join-Path $root 'img\hero\Profile.jpg'
$outPath = Join-Path $root 'img\og\og-cover.jpg'

New-Item -ItemType Directory -Force -Path (Split-Path -Parent $outPath) | Out-Null

$W = 1200
$H = 630

$bmp = New-Object System.Drawing.Bitmap($W, $H)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit

# Background gradient
$rect = New-Object System.Drawing.Rectangle(0, 0, $W, $H)
$bg = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    $rect,
    [System.Drawing.ColorTranslator]::FromHtml('#0B1220'),
    [System.Drawing.ColorTranslator]::FromHtml('#1B2337'),
    45.0)
$g.FillRectangle($bg, $rect)

# Accent glow
$glow = New-Object System.Drawing.Drawing2D.GraphicsPath
$glow.AddEllipse(820, -160, 560, 560)
$glowBrush = New-Object System.Drawing.Drawing2D.PathGradientBrush($glow)
$glowBrush.CenterColor = [System.Drawing.Color]::FromArgb(90, 255, 69, 27)
$glowBrush.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 255, 69, 27))
$g.FillPath($glowBrush, $glow)

$glow2 = New-Object System.Drawing.Drawing2D.GraphicsPath
$glow2.AddEllipse(-220, 300, 520, 520)
$glowBrush2 = New-Object System.Drawing.Drawing2D.PathGradientBrush($glow2)
$glowBrush2.CenterColor = [System.Drawing.Color]::FromArgb(70, 255, 179, 36)
$glowBrush2.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 255, 179, 36))
$g.FillPath($glowBrush2, $glow2)

# Profile photo in a circle on the right
$photo = [System.Drawing.Image]::FromFile($photoPath)
$size = 340
$cx = 880
$cy = 145

$side = [Math]::Min($photo.Width, $photo.Height)
$srcX = [int](($photo.Width - $side) / 2)
$srcY = [int](($photo.Height - $side) / 8)
$srcRect = New-Object System.Drawing.Rectangle($srcX, $srcY, $side, $side)

$ringPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(180, 255, 69, 27), 6)
$g.DrawEllipse($ringPen, ($cx - 14), ($cy - 14), ($size + 28), ($size + 28))

$clip = New-Object System.Drawing.Drawing2D.GraphicsPath
$clip.AddEllipse($cx, $cy, $size, $size)
$g.SetClip($clip)
$destRect = New-Object System.Drawing.Rectangle($cx, $cy, $size, $size)
$g.DrawImage($photo, $destRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)
$g.ResetClip()

# Text
$white = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
$accent = New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml('#FF7A4D'))
$muted = New-Object System.Drawing.SolidBrush([System.Drawing.ColorTranslator]::FromHtml('#9AA6BF'))

$fontEyebrow = New-Object System.Drawing.Font('Segoe UI Semibold', 20, [System.Drawing.FontStyle]::Bold)
$fontName = New-Object System.Drawing.Font('Segoe UI', 62, [System.Drawing.FontStyle]::Bold)
$fontRole = New-Object System.Drawing.Font('Segoe UI Semibold', 30, [System.Drawing.FontStyle]::Bold)
$fontStack = New-Object System.Drawing.Font('Segoe UI', 20, [System.Drawing.FontStyle]::Regular)
$fontUrl = New-Object System.Drawing.Font('Segoe UI Semibold', 20, [System.Drawing.FontStyle]::Bold)

$g.DrawString('PORTFOLIO', $fontEyebrow, $accent, 90, 150)
$g.DrawString('Sadam Shah', $fontName, $white, 84, 190)
$g.DrawString('Full Stack Web Developer', $fontRole, $white, 90, 296)
$sep = "  " + [char]0x2022 + "  "
$g.DrawString(("React.js", "Next.js", "TypeScript", "Node.js" -join $sep), $fontStack, $muted, 90, 356)
$g.DrawString(("Laravel", "Python", "SQL", "MongoDB" -join $sep), $fontStack, $muted, 90, 390)

# Bottom bar
$barBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(40, 255, 255, 255))
$g.FillRectangle($barBrush, 90, 452, 620, 2)
$g.DrawString('sadam-shah-portfolio.vercel.app', $fontUrl, $accent, 84, 476)
$g.DrawString('Islamabad, Pakistan', $fontStack, $muted, 90, 516)

$encoder = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
$encParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
$encParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, 92L)
$bmp.Save($outPath, $encoder, $encParams)

$photo.Dispose()
$g.Dispose()
$bmp.Dispose()

Write-Host "Created $outPath"
