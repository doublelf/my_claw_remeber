# OpenClaw setup script - Windows (PowerShell 7)
# Run as Administrator

param(
    [string]$RepoDir = "$env:USERPROFILE\.openclaw\workspace"
)

$REPO_URL = "git@github.com:doublelf/my_claw_remeber.git"
$STARTUP_DIR = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"

function Write-Step($msg) {
    Write-Host "  $msg" -ForegroundColor Cyan
}

function Write-OK($msg) {
    Write-Host "  [OK] $msg" -ForegroundColor Green
}

function Write-WARN($msg) {
    Write-Host "  [WARN] $msg" -ForegroundColor Yellow
}

Write-Host "============================================"
Write-Host "  OpenClaw Setup - Windows"
Write-Host "============================================"
Write-Host ""

# --- 检测 OpenClaw ---
Write-Step "Checking OpenClaw..."
if (Get-Command openclaw -ErrorAction SilentlyContinue) {
    $ver = $(openclaw --version 2>&1 | Select-Object -First 1)
    Write-OK "OpenClaw installed: $ver"
} else {
    Write-Step "Installing OpenClaw..."
    npm install -g openclaw
    Write-OK "OpenClaw installed"
}
Write-Host ""

# --- 检测 Git ---
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] Git not found. Please install Git for Windows first."
    Write-Host "   Download: https://git-scm.com/download/win"
    exit 1
}
Write-OK "Git: $(git --version)"
Write-Host ""

# --- SSH 密钥 (使用 Git Bash) ---
$SSH_KEY = "$env:USERPROFILE\.ssh\id_ed25519"
$GIT_BASH = "C:\Program Files\Git\bin\bash.exe"

if (Test-Path "$SSH_KEY") {
    Write-OK "SSH key exists"
} else {
    Write-Step "Generating SSH key via Git Bash..."
    New-Item -ItemType Directory -Path "$env:USERPROFILE\.ssh" -Force | Out-Null
    $cmd = "`"$GIT_BASH`" -c `"ssh-keygen -t ed25519 -C 'v@openclaw' -f '$SSH_KEY' -q -N ''`""
    Invoke-Expression $cmd
    Write-OK "SSH key generated"
}
Write-Host ""

# --- 打印公钥 ---
if (Test-Path "$SSH_KEY.pub") {
    Write-Host "============================================"
    Write-Host "  Add this public key to GitHub"
    Write-Host "============================================"
    Write-Host ""
    Get-Content "$SSH_KEY.pub"
    Write-Host ""
    Read-Host "Press Enter to continue (after adding key to GitHub)"
} else {
    Write-WARN "SSH key not generated. Please run manually:"
    Write-Host "   $GIT_BASH -c 'ssh-keygen -t ed25519 -C v@openclaw'"
}
Write-Host ""

# --- 克隆仓库 ---
if (Test-Path "$RepoDir\.git") {
    Write-Step "Workspace exists, pulling latest..."
    Set-Location $RepoDir
    git pull origin main
} else {
    Write-Step "Cloning repo..."
    git clone $REPO_URL $RepoDir
}
Write-OK "Repo synced"
Write-Host ""

# --- 配置脚本路径 ---
Write-Step "Configuring paths..."
$saveScript = "$RepoDir\scripts\session_sync\github\save_session.sh"
$readScript = "$RepoDir\scripts\session_sync\github\read_session.sh"

foreach ($script in @($saveScript, $readScript)) {
    if (Test-Path $script) {
        $content = Get-Content $script -Raw
        $content = $content -replace 'REPO_DIR="/home/seeed/my_claw_remeber"', "REPO_DIR=`"$RepoDir`""
        Set-Content -Path $script -Value $content -NoNewline -Encoding UTF8
        Write-OK "Configured: $(Split-Path $script -Leaf)"
    }
}
Write-Host ""

# --- 创建启动脚本 ---
Write-Step "Creating startup script..."
$bootScript = "$RepoDir\scripts\session_sync\openclaw_launch.bat"
$SESSION_READ = "$RepoDir\scripts\session_sync\session_read.sh"

$batContent = "@echo off`n"
$batContent += "if exist `"C:\Program Files\Git\bin\bash.exe`" (`"C:\Program Files\Git\bin\bash.exe`" -c `"bash '$SESSION_READ'`")`n"

Set-Content -Path $bootScript -Value $batContent -Encoding ASCII
Write-OK "Startup script: $bootScript"
Write-Host ""

# --- 添加开机自启 ---
$startupBat = "$STARTUP_DIR\openclaw_v_sync.bat"
$startupContent = "@echo off`ncd /d `"$RepoDir\scripts\session_sync`"`nstart /B bash session_read.sh"
Set-Content -Path $startupBat -Value $startupContent -Encoding ASCII
Write-OK "Startup entry added"
Write-Host ""

# --- 验证 GitHub ---
Write-Step "Testing GitHub SSH..."
try {
    $sshResult = ssh -T git@github.com 2>&1
    if ($sshResult -match "successfully") {
        Write-OK "GitHub SSH connected"
    } else {
        Write-WARN "GitHub SSH failed. Check if public key was added correctly."
        Write-Host "   Result: $sshResult" -ForegroundColor Gray
    }
} catch {
    Write-WARN "SSH connection failed. Make sure Git Bash is installed."
}
Write-Host ""

# --- 完成 ---
Write-Host "============================================"
Write-Host "  DONE"
Write-Host "============================================"
Write-Host ""
Write-Host "  Run: openclaw gateway" -ForegroundColor Green
Write-Host "  Auto-start: configured for next boot" -ForegroundColor Green
Write-Host ""
