# openclaw_setup.ps1
# OpenClaw 新设备安装脚本 - Windows 版
# 使用 PowerShell 7 运行

# 需要以管理员权限运行

param(
    [string]$RepoDir = "$env:USERPROFILE\.openclaw\workspace"
)

$REPO_URL = "git@github.com:doublelf/my_claw_remeber.git"
$STARTUP_DIR = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"

function Write-Step {
    param([string]$msg)
    Write-Host "  $msg" -ForegroundColor Cyan
}

function Write-success {
    param([string]$msg)
    Write-Host "  ✅ $msg" -ForegroundColor Green
}

function Write-warn {
    param([string]$msg)
    Write-Host "  ⚠️  $msg" -ForegroundColor Yellow
}

Write-Host "============================================" -ForegroundColor Magenta
Write-Host "  V (OpenClaw) 一键安装脚本 - Windows 版" -ForegroundColor Magenta
Write-Host "============================================" -ForegroundColor Magenta
Write-Host ""

# --- 检测 OpenClaw 是否已安装 ---
Write-Host "🔍 检测 OpenClaw..." -ForegroundColor Yellow
if (Get-Command openclaw -ErrorAction SilentlyContinue) {
    Write-success "OpenClaw 已安装: $(openclaw --version 2>&1 | Select-Object -First 1)"
} else {
    Write-Host "📦 安装 OpenClaw..." -ForegroundColor Yellow
    npm install -g openclaw
    Write-success "OpenClaw 安装完成"
}
Write-Host ""

# --- 检测 git 是否可用 ---
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Git 未安装，请先安装 Git for Windows" -ForegroundColor Red
    Write-Host "   下载地址: https://git-scm.com/download/win" -ForegroundColor Gray
    exit 1
}
Write-Host "✅ Git 已安装: $(git --version)" -ForegroundColor Green
Write-Host ""

# --- 生成 SSH 密钥 ---
$SSH_KEY = "$env:USERPROFILE\.ssh\id_ed25519"
if (Test-Path "$SSH_KEY") {
    Write-Host "🔑 SSH 密钥已存在，跳过生成"
} else {
    Write-Host "🔑 生成 SSH 密钥..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path "$env:USERPROFILE\.ssh" -Force | Out-Null
    ssh-keygen -t ed25519 -C "v@openclaw" -f $SSH_KEY -N ""
    Write-success "SSH 密钥生成完成"
}
Write-Host ""

# --- 打印公钥 ---
Write-Host "============================================" -ForegroundColor Magenta
Write-Host "  请将下面的公钥添加到 GitHub" -ForegroundColor Magenta
Write-Host "============================================" -ForegroundColor Magenta
Write-Host ""
Get-Content "$SSH_KEY.pub"
Write-Host ""
Read-Host "按回车继续（已在 GitHub 添加公钥）"
Write-Host ""

# --- 克隆仓库 ---
if (Test-Path "$RepoDir\.git") {
    Write-Host "📁 工作空间已存在，拉取最新..." -ForegroundColor Yellow
    Set-Location $RepoDir
    git pull origin main
} else {
    Write-Host "📡 克隆 GitHub 仓库..." -ForegroundColor Yellow
    git clone $REPO_URL $RepoDir
}
Write-success "仓库同步完成"
Write-Host ""

# --- 配置脚本路径 ---
Write-Host "⚙️  配置本地路径..." -ForegroundColor Yellow
$saveScript = "$RepoDir\scripts\session_sync\github\save_session.sh"
$readScript = "$RepoDir\scripts\session_sync\github\read_session.sh"

@($saveScript, $readScript) | ForEach-Object {
    if (Test-Path $_) {
        (Get-Content $_) -replace 'REPO_DIR="/home/seeed/my_claw_remeber"', "REPO_DIR=`"$RepoDir`"" | Set-Content $_
        Write-success "已配置: $(Split-Path $_ -Leaf)"
    }
}
Write-Host ""

# --- 创建启动脚本 ---
Write-Host "🚀 创建开机启动脚本..." -ForegroundColor Yellow

$bootScript = "$RepoDir\scripts\session_sync\openclaw_launch.ps1"
$bootContent = @"
# OpenClaw 启动时自动读取会话
`$WScript = New-Object -ComObject WScript.Shell
`$WScript.Popup "V 正在同步会话...", 2, "OpenClaw", 0x40

`$workspaceDir = "$RepoDir"
`$sessionRead = "`$workspaceDir\scripts\session_sync\session_read.sh"

# 使用 Git Bash 执行
`$bashExe = "C:\Program Files\Git\bin\bash.exe"
if (Test-Path `$bashExe) {
    & `$bashExe -c `$sessionRead
} else {
    # 尝试 WSL
    & wsl bash -c `$sessionRead 2>`$null
}
"@

$bootContent | Set-Content $bootScript -Encoding UTF8
Write-success "启动脚本已创建: $bootScript"
Write-Host ""

# --- 添加到 Windows 开机自启 ---
$startupScript = "$STARTUP_DIR\openclaw_v_startup.bat"
$startupBat = "@echo off`ncd /d `"$RepoDir`"\scripts\session_sync`nstart /B bash session_read.sh"
$startupBat | Set-Content $startupScript -Encoding ASCII
Write-success "已添加开机自启: $startupScript"
Write-Host ""

# --- 验证 GitHub 连接 ---
Write-Host "🔍 验证 GitHub 连接..." -ForegroundColor Yellow
try {
    $result = ssh -T git@github.com 2>&1
    if ($result -match "successfully") {
        Write-success "GitHub SSH 连接成功"
    } else {
        Write-warn "GitHub 连接验证失败，请检查公钥是否正确添加"
        Write-Host "   错误信息: $result" -ForegroundColor Gray
    }
} catch {
    Write-warn "SSH 连接失败，请确认 Git Bash 已安装并配置"
}
Write-Host ""

# --- 完成 ---
Write-Host "============================================" -ForegroundColor Magenta
Write-Host "  ✅ 安装完成！" -ForegroundColor Magenta
Write-Host "============================================" -ForegroundColor Magenta
Write-Host ""
Write-Host "启动命令: openclaw gateway" -ForegroundColor Green
Write-Host "开机自动: 已配置，下次开机生效" -ForegroundColor Green
Write-Host ""
