# TINA JARVIS - 一键构建 APK
# 在 Windows PowerShell 运行

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "🚀 TINA JARVIS - 本地构建 APK" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# 检查 Flutter
Write-Host "[步骤 1/5] 检查 Flutter 环境..." -ForegroundColor Yellow
$flutterCmd = "D:\Projects\flutter\bin\flutter.bat"

if (-not (Test-Path $flutterCmd)) {
    Write-Host "❌ Flutter 未找到: $flutterCmd" -ForegroundColor Red
    Write-Host "请确认 Flutter 已安装在 D:\Projects\flutter" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Flutter 已找到" -ForegroundColor Green

# 获取 Flutter 版本
& $flutterCmd --version | Select-Object -First 3 | ForEach-Object { Write-Host "   $_" -ForegroundColor Gray }

# 进入项目目录
$projectDir = "D:\Projects\FlutterApps\tina_jarvis"
if (-not (Test-Path $projectDir)) {
    Write-Host "❌ 项目目录不存在: $projectDir" -ForegroundColor Red
    exit 1
}

Set-Location $projectDir
Write-Host "✅ 进入项目目录: $projectDir" -ForegroundColor Green

# 清理
Write-Host ""
Write-Host "[步骤 2/5] 清理项目..." -ForegroundColor Yellow
& $flutterCmd clean
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️ 清理警告 (继续)..." -ForegroundColor Yellow
}

# 获取依赖
Write-Host ""
Write-Host "[步骤 3/5] 获取依赖 (可能需要几分钟)..." -ForegroundColor Yellow
& $flutterCmd pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ 获取依赖失败" -ForegroundColor Red
    Write-Host "常见原因:" -ForegroundColor Yellow
    Write-Host "  - 网络问题" -ForegroundColor White
    Write-Host "  - pubspec.yaml 格式错误" -ForegroundColor White
    exit 1
}
Write-Host "✅ 依赖获取成功" -ForegroundColor Green

# 构建 APK
Write-Host ""
Write-Host "[步骤 4/5] 构建 APK (可能需要 3-5 分钟)..." -ForegroundColor Yellow
Write-Host "   ⏳ 正在构建，请耐心等待..." -ForegroundColor Gray

$startTime = Get-Date

# 运行构建并捕获输出
$output = & $flutterCmd build apk --debug --verbose 2>&1
$exitCode = $LASTEXITCODE
$endTime = Get-Date
$duration = ($endTime - $startTime).TotalMinutes

if ($exitCode -eq 0) {
    # 检查 APK 是否存在
    $apkPath = "$projectDir\build\app\outputs\flutter-apk\app-debug.apk"
    
    if (Test-Path $apkPath) {
        $apkSize = (Get-Item $apkPath).Length / 1MB
        
        Write-Host ""
        Write-Host "==========================================" -ForegroundColor Green
        Write-Host "✅🎉 APK 构建成功! 🎉✅" -ForegroundColor Green
        Write-Host "==========================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "📦 APK 位置:" -ForegroundColor Cyan
        Write-Host "   $apkPath" -ForegroundColor White
        Write-Host ""
        Write-Host "📊 文件大小: $([math]::Round($apkSize, 2)) MB" -ForegroundColor Cyan
        Write-Host "⏱️  构建用时: $([math]::Round($duration, 2)) 分钟" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "📱 安装到手机:" -ForegroundColor Yellow
        Write-Host "   cd D:\Projects\FlutterApps\tina_jarvis" -ForegroundColor White
        Write-Host "   flutter install" -ForegroundColor White
        Write-Host ""
        Write-Host "📤 安装 APK:" -ForegroundColor Yellow
        Write-Host "   adb install -r $apkPath" -ForegroundColor White
        Write-Host ""
        Write-Host "==========================================" -ForegroundColor Green
        
        # 打开文件管理器到 APK 位置
        $apkFolder = Split-Path $apkPath -Parent
        Write-Host ""
        $openFolder = Read-Host "是否打开 APK 所在文件夹? (y/n)"
        if ($openFolder -eq "y" -or $openFolder -eq "Y") {
            Start-Process explorer.exe $apkFolder
        }
        
    } else {
        Write-Host ""
        Write-Host "⚠️ 构建成功但 APK 未找到" -ForegroundColor Yellow
        Write-Host "检查 build\app\outputs\flutter-apk\ 目录" -ForegroundColor White
    }
} else {
    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Red
    Write-Host "❌ 构建失败 (退出码: $exitCode)" -ForegroundColor Red
    Write-Host "==========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "🔍 错误详情:" -ForegroundColor Yellow
    
    # 查找关键错误行
    $errorLines = $output | Select-String -Pattern "error|Error|FAIL|exception|FAILURE" -CaseSensitive:$false | Select-Object -Last 20
    
    if ($errorLines) {
        $errorLines | ForEach-Object { Write-Host "   $_" -ForegroundColor Red }
    } else {
        Write-Host "   (详细错误未捕获，查看完整输出)" -ForegroundColor Gray
        $output | Select-Object -Last 50 | ForEach-Object { Write-Host "   $_" -ForegroundColor Gray }
    }
    
    Write-Host ""
    Write-Host "💡 常见解决方案:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. flutter clean" -ForegroundColor White
    Write-Host "2. 删除 pubspec.lock 后 flutter pub get" -ForegroundColor White
    Write-Host "3. 检查 Android SDK 配置: flutter doctor -v" -ForegroundColor White
    Write-Host "4. 更新依赖版本" -ForegroundColor White
    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Red
}

Write-Host ""
Write-Host "按任意键退出..."
[void][System.Console]::ReadKey($true)
