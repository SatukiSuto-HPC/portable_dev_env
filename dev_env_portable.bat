<# : batch script
@echo off
setlocal
cd /d "%~dp0"

echo ========================================================
echo Portable Dev Env Installer (Official Gemini CLI)
echo (VSCode + uv + Git + Official Gemini CLI + Node.js)
echo ========================================================
echo.
echo Running PowerShell script...
echo.

:: Run PowerShell logic
powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Expression (Get-Content '%~f0' | Out-String)"

echo.
echo Done. Press any key to exit.
pause >nul
goto :eof
#>

# ----------------------------------------------------------
# PowerShell Code Section
# ----------------------------------------------------------
$ErrorActionPreference = "Stop"
$RootDir = Get-Location
$VSCodeDir = Join-Path $RootDir "VSCode"
$GitDir = Join-Path $RootDir "Git"
$UvDir = Join-Path $RootDir "uv"
$GeminiDir = Join-Path $RootDir "GeminiCLI"
$NodeDir = Join-Path $RootDir "NodeJS"
$HomeDir = Join-Path $RootDir "home"
$DesktopDir = Join-Path $HomeDir "desktop"
$TempDir = Join-Path $RootDir "temp"

# Enable TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Create Directories
$Dirs = @($RootDir, $TempDir, $GeminiDir, $NodeDir, $HomeDir, $DesktopDir)
foreach ($d in $Dirs) { if (-not (Test-Path $d)) { New-Item -ItemType Directory -Force -Path $d | Out-Null } }

# Helper Function
function Download-File {
    param ($Url, $Dest)
    $curlExe = $null
    if (Test-Path $GitDir) {
        $curlExe = Get-ChildItem -Path $GitDir -Filter "curl.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    }
    Write-Host " Downloading..."
    if ($curlExe) {
        $argList = "-L -k -o `"$Dest`" `"$Url`""
        $p = Start-Process -FilePath $curlExe.FullName -ArgumentList $argList -Wait -NoNewWindow -PassThru
        if ($p.ExitCode -ne 0) { throw "curl download failed." }
    } else {
        Invoke-WebRequest -Uri $Url -OutFile $Dest -UseBasicParsing -UserAgent "Mozilla/5.0"
    }
}

# --- 0. Helper Tool: Bootstrap Full 7-Zip ---
Write-Host "[Tool] Checking 7-Zip Engine..." -ForegroundColor Cyan
$7zDir = Join-Path $TempDir "7z_full"
$7zExe = Join-Path $7zDir "7z.exe"

try {
    if (-not (Test-Path $7zExe)) {
        $7zaDir = Join-Path $TempDir "7za_tool"
        $7zaExe = Join-Path $7zaDir "7za.exe"
        if (-not (Test-Path $7zaExe)) {
            $7zApiUrl = "https://api.github.com/repos/ip7z/7zip/releases/latest"
            $7zRelease = Invoke-RestMethod -Uri $7zApiUrl
            $7zAsset = $7zRelease.assets | Where-Object { $_.name -like "*-extra.7z" -or $_.name -like "*-extra.zip" } | Select-Object -First 1
            if (-not $7zAsset) { throw "GitHub API Error: 7-Zip extra not found." }
            $7zPkg = Join-Path $TempDir "7z-extra.7z"
            Invoke-WebRequest -Uri $7zAsset.browser_download_url -OutFile $7zPkg -UseBasicParsing -UserAgent "Mozilla/5.0"
            $7zrUrl = "https://www.7-zip.org/a/7zr.exe"
            $7zrExe = Join-Path $TempDir "7zr.exe"
            Invoke-WebRequest -Uri $7zrUrl -OutFile $7zrExe -UseBasicParsing -UserAgent "Mozilla/5.0"
            Start-Process -FilePath $7zrExe -ArgumentList "x `"$7zPkg`" -o`"$7zaDir`" -y" -Wait -WindowStyle Hidden
            if (Test-Path (Join-Path $7zaDir "x64\7za.exe")) { Copy-Item (Join-Path $7zaDir "x64\7za.exe") $7zaExe -Force }
        }
        $7zPage = Invoke-WebRequest -Uri "https://www.7-zip.org/download.html" -UseBasicParsing
        $matches = [regex]::Matches($7zPage.Content, 'a/(7z[0-9]+-x64\.exe)')
        $installerName = $matches | Select-Object -ExpandProperty Value | Sort-Object | Select-Object -Last 1
        if (-not $installerName) { $installerName = "a/7z2408-x64.exe" }
        $installerUrl = "https://www.7-zip.org/$installerName"
        $installerFile = Join-Path $TempDir "7z-installer.exe"
        Invoke-WebRequest -Uri $installerUrl -OutFile $installerFile -UseBasicParsing -UserAgent "Mozilla/5.0"
        Start-Process -FilePath $7zaExe -ArgumentList "x `"$installerFile`" -o`"$7zDir`" -y" -Wait -WindowStyle Hidden
    }
} catch { Write-Error "Tool Setup Error: $_" }

# --- 1. VS Code ---
Write-Host "[1/4] Checking VS Code..." -ForegroundColor Cyan
if (-not (Test-Path (Join-Path $VSCodeDir "Code.exe"))) {
    try {
        $vscodeUrl = "https://code.visualstudio.com/sha/download?build=stable&os=win32-x64-archive"
        $vscodeZip = Join-Path $TempDir "vscode.zip"
        if (-not (Test-Path $vscodeZip)) { Download-File -Url $vscodeUrl -Dest $vscodeZip }
        Write-Host " Extracting..."
        Expand-Archive -Path $vscodeZip -DestinationPath $VSCodeDir -Force
        New-Item -ItemType Directory -Force -Path (Join-Path $VSCodeDir "data") | Out-Null
        Write-Host " OK" -ForegroundColor Green
    } catch { Write-Error "VS Code Error: $_" }
} else { Write-Host " Skipping." -ForegroundColor Gray }

# --- 2. uv ---
Write-Host "`n[2/4] Checking uv..." -ForegroundColor Cyan
if (-not (Test-Path (Join-Path $UvDir "uv.exe"))) {
    try {
        $uvApiUrl = "https://api.github.com/repos/astral-sh/uv/releases/latest"
        $uvRelease = Invoke-RestMethod -Uri $uvApiUrl
        $uvAsset = $uvRelease.assets | Where-Object { $_.name -like "*x86_64-pc-windows-msvc.zip" } | Select-Object -First 1
        if (-not $uvAsset) { throw "uv asset not found." }
        $uvZip = Join-Path $TempDir "uv.zip"
        if (-not (Test-Path $uvZip)) { Download-File -Url $uvAsset.browser_download_url -Dest $uvZip }
        Write-Host " Extracting..."
        Expand-Archive -Path $uvZip -DestinationPath $TempDir -Force
        $uvExeItem = Get-ChildItem -Path $TempDir -Filter "uv.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
        if (-not (Test-Path $UvDir)) { New-Item -ItemType Directory -Force -Path $UvDir | Out-Null }
        Copy-Item -Path (Join-Path $uvExeItem.Directory.FullName "*") -Destination $UvDir -Recurse -Force
        Write-Host " OK" -ForegroundColor Green
    } catch { Write-Error "uv Error: $_" }
} else { Write-Host " Skipping." -ForegroundColor Gray }

# --- 3. Git ---
Write-Host "`n[3/4] Checking Git..." -ForegroundColor Cyan
if (-not (Test-Path (Join-Path $GitDir "cmd\git.exe"))) {
    try {
        $gitApiUrl = "https://api.github.com/repos/git-for-windows/git/releases/latest"
        $gitRelease = Invoke-RestMethod -Uri $gitApiUrl
        $gitAsset = $gitRelease.assets | Where-Object { $_.name -like "PortableGit-*-64-bit.7z.exe" } | Select-Object -First 1
        $gitExe = Join-Path $TempDir "git.exe"
        if (-not (Test-Path $gitExe)) { Invoke-WebRequest -Uri $gitAsset.browser_download_url -OutFile $gitExe -UseBasicParsing -UserAgent "Mozilla/5.0" }
        Write-Host " Extracting..."
        Start-Process -FilePath $gitExe -ArgumentList "-y", "-o`"$GitDir`"" -PassThru -Wait -WindowStyle Hidden | Out-Null
        Write-Host " OK" -ForegroundColor Green
    } catch { Write-Error "Git Error: $_" }
} else { Write-Host " Skipping." -ForegroundColor Gray }

# --- 4. Official Gemini CLI (from npm) ---
Write-Host "`n[4/4] Checking Official Gemini CLI (@google/gemini-cli)..." -ForegroundColor Cyan
$NodeExe = Join-Path $NodeDir "node.exe"
$NpmCmd = Join-Path $NodeDir "npm.cmd"
$GeminiCmd = Join-Path $GeminiDir "gemini.cmd"

try {
    # Full Node.js Download
    if (-not (Test-Path $NodeExe)) {
        Write-Host " Downloading Node.js (Full)..."
        $nodeUrl = "https://nodejs.org/dist/v22.12.0/node-v22.12.0-win-x64.zip"
        $nodeZip = Join-Path $TempDir "node.zip"
        Download-File -Url $nodeUrl -Dest $nodeZip
        Write-Host " Extracting Node.js..."
        $nodeTemp = Join-Path $TempDir "node_extract"
        if (Test-Path $nodeTemp) { Remove-Item $nodeTemp -Recurse -Force }
        $pArgs = "x `"$nodeZip`" -o`"$nodeTemp`" -y"
        Start-Process -FilePath $7zExe -ArgumentList $pArgs -Wait -WindowStyle Hidden
        $extractedRoot = Get-ChildItem -Path $nodeTemp -Directory | Select-Object -First 1
        if (-not $extractedRoot) { throw "Node.js extract failed" }
        if (Test-Path $NodeDir) { Remove-Item $NodeDir -Recurse -Force }
        Move-Item -Path $extractedRoot.FullName -Destination $NodeDir -Force
        Remove-Item $nodeTemp -Recurse -Force
        Write-Host " Node.js OK" -ForegroundColor Green
    }

    if (-not (Test-Path $GeminiDir)) { New-Item -ItemType Directory -Path $GeminiDir -Force | Out-Null }
    $env:Path = "$NodeDir;$env:Path"
    
    # --- NPM Setup (With Fixes) ---
    if (-not (Test-Path (Join-Path $GeminiDir "node_modules"))) {
        Write-Host " Installing Official Gemini CLI Packages..."
        $npmrcPath = Join-Path $GeminiDir ".npmrc"
        $npmCache = Join-Path $GeminiDir "npm-cache"
        $npmPrefix = Join-Path $GeminiDir "npm-global"

        # FIX: Path separators
        $safeCache = $npmCache -replace "\\", "/"
        $safePrefix = $npmPrefix -replace "\\", "/"
        
        $npmrcContent = "prefix=$safePrefix`ncache=$safeCache"

        # Proxy
        $reg = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
        if ($reg.ProxyEnable -eq 1 -and $reg.ProxyServer) {
             $proxy = if ($reg.ProxyServer -match "=") { $reg.ProxyServer.Split("=")[1] } else { $reg.ProxyServer }
             if (-not ($proxy -match "^http")) { $proxy = "http://$proxy" }
             $npmrcContent += "`nproxy=$proxy`nhttps-proxy=$proxy"
             Write-Host " (Proxy detected)" -ForegroundColor Gray
        }

        Set-Content -Path $npmrcPath -Value $npmrcContent -Encoding UTF8

        # Clean old files
        if (Test-Path (Join-Path $GeminiDir "package.json")) { Remove-Item (Join-Path $GeminiDir "package.json") -Force }
        if (Test-Path (Join-Path $GeminiDir "package-lock.json")) { Remove-Item (Join-Path $GeminiDir "package-lock.json") -Force }
        # Remove old index.js if exists
        if (Test-Path (Join-Path $GeminiDir "index.js")) { Remove-Item (Join-Path $GeminiDir "index.js") -Force }

        Start-Process -FilePath $NpmCmd -ArgumentList "init -y" -WorkingDirectory $GeminiDir -Wait -WindowStyle Hidden
        
        # Install THE OFFICIAL CLI
        $pkgs = "@google/gemini-cli"
        Write-Host " Running npm install (this may take a minute)..."
        Start-Process -FilePath $NpmCmd -ArgumentList "install $pkgs --userconfig `"$npmrcPath`" --no-audit --no-fund" -WorkingDirectory $GeminiDir -Wait -NoNewWindow
        
        Write-Host " Official CLI installed." -ForegroundColor Green
    }

    # Create wrapper shim to call the official CLI binary
    # npm install creates 'node_modules/.bin/gemini.cmd' on Windows
    $cmdContent = "@echo off`r`nsetlocal`r`n" +
                  "set `"PATH=%~dp0..\NodeJS;%PATH%`"`r`n" +
                  "call `"%~dp0node_modules\.bin\gemini.cmd`" %*"
    
    [System.IO.File]::WriteAllText($GeminiCmd, $cmdContent, [System.Text.Encoding]::ASCII)
    Write-Host " OK (Wrapper created)" -ForegroundColor Green

} catch { Write-Error "Gemini Setup Error: $_" }


# --- 5. Create GUI Launcher Files ---
Write-Host "`nCreating GUI Launcher Files..."

if (-not (Test-Path $HomeDir)) { New-Item -ItemType Directory -Force -Path $HomeDir | Out-Null }
$desktopDir = $DesktopDir
if (-not (Test-Path $desktopDir)) { New-Item -ItemType Directory -Force -Path $desktopDir | Out-Null }
$sshDir = Join-Path $HomeDir ".ssh"
if (-not (Test-Path $sshDir)) { New-Item -ItemType Directory -Force -Path $sshDir | Out-Null }

$idRsa = Join-Path $sshDir "id_rsa"
if (-not (Test-Path $idRsa)) {
    Write-Host " Generating SSH keys (for Git)..."
    $sshKeyGen = Join-Path $GitDir "usr\bin\ssh-keygen.exe"
    if (Test-Path $sshKeyGen) {
        $null = Start-Process -FilePath $sshKeyGen -ArgumentList "-t rsa -b 2048 -f `"$idRsa`" -N `"`"" -Wait -WindowStyle Hidden
    }
}

# --- File 1: Menu.ps1 (Simplified) ---
$psPath = Join-Path $RootDir "Menu.ps1"
$psContent = @"
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

`$Root = `$PSScriptRoot
if (-not `$Root) { `$Root = Get-Location }

`$SettingsDir = Join-Path `$Root "VSCode\data\user-data\User"
`$SettingsFile = Join-Path `$SettingsDir "settings.json"
`$GitSshPath = Join-Path `$Root "Git\usr\bin\ssh.exe"
`$ApiKeyFile = Join-Path `$Root "gemini_key.txt"

# Load API Key
`$SavedKey = ""
if (Test-Path `$ApiKeyFile) { `$SavedKey = Get-Content `$ApiKeyFile -Raw }

# --- Proxy Auto-Config ---
if (-not (Test-Path `$SettingsDir)) { New-Item -ItemType Directory -Force -Path `$SettingsDir | Out-Null }
if (Test-Path `$SettingsFile) {
    try { `$json = Get-Content `$SettingsFile -Raw | ConvertFrom-Json } catch { `$json = New-Object PSObject }
} else { `$json = New-Object PSObject }

if (-not `$json.PSObject.Properties["remote.SSH.path"]) { `$json | Add-Member -MemberType NoteProperty -Name "remote.SSH.path" -Value `$GitSshPath } else { `$json."remote.SSH.path" = `$GitSshPath }

`$reg = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
`$proxyServer = `$reg.ProxyServer
`$proxyEnable = `$reg.ProxyEnable
`$DetectedProxy = `$null
`$ProxyStatusText = "No System Proxy"
if (`$proxyEnable -eq 1 -and -not [string]::IsNullOrEmpty(`$proxyServer)) {
    if (`$proxyServer -match "=") { `$DetectedProxy = `$proxyServer } else { `$DetectedProxy = "http://`$proxyServer" }
    `$ProxyStatusText = "Proxy: `$DetectedProxy"
    if (-not `$json.PSObject.Properties["http.proxy"]) { `$json | Add-Member -MemberType NoteProperty -Name "http.proxy" -Value `$DetectedProxy } else { `$json."http.proxy" = `$DetectedProxy }
    `$env:HTTP_PROXY = `$DetectedProxy
    `$env:HTTPS_PROXY = `$DetectedProxy
} else {
    if (`$json.PSObject.Properties["http.proxy"]) { `$json.PSObject.Properties.Remove("http.proxy") }
}
`$json | ConvertTo-Json -Depth 10 | Set-Content `$SettingsFile -Encoding UTF8

# --- GUI FORM ---
`$form = New-Object System.Windows.Forms.Form
`$form.Text = "Portable Dev Env (Official CLI)"
`$form.Size = New-Object System.Drawing.Size(400, 320)
`$form.StartPosition = "CenterScreen"
`$form.FormBorderStyle = "FixedDialog"
`$form.MaximizeBox = `$false

# Title
`$lblTitle = New-Object System.Windows.Forms.Label
`$lblTitle.Text = "Dev Environment"
`$lblTitle.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
`$lblTitle.AutoSize = `$true
`$lblTitle.Location = New-Object System.Drawing.Point(20, 10)
`$form.Controls.Add(`$lblTitle)

`$lblProxy = New-Object System.Windows.Forms.Label
`$lblProxy.Text = `$ProxyStatusText
`$lblProxy.ForeColor = [System.Drawing.Color]::Gray
`$lblProxy.Location = New-Object System.Drawing.Point(22, 35)
`$lblProxy.AutoSize = `$true
`$form.Controls.Add(`$lblProxy)

# --- Group: API Settings ---
`$grpApi = New-Object System.Windows.Forms.GroupBox
`$grpApi.Text = "Gemini API Key"
`$grpApi.Location = New-Object System.Drawing.Point(20, 60)
`$grpApi.Size = New-Object System.Drawing.Size(345, 85)
`$form.Controls.Add(`$grpApi)

`$txtKey = New-Object System.Windows.Forms.TextBox
`$txtKey.Text = `$SavedKey
`$txtKey.Location = New-Object System.Drawing.Point(15, 25)
`$txtKey.Size = New-Object System.Drawing.Size(315, 23)
`$txtKey.PasswordChar = "*"
`$grpApi.Controls.Add(`$txtKey)

`$btnGetKey = New-Object System.Windows.Forms.Button
`$btnGetKey.Text = "[Get API Key] (Google Login)"
`$btnGetKey.Location = New-Object System.Drawing.Point(15, 52)
`$btnGetKey.Size = New-Object System.Drawing.Size(315, 25)
`$btnGetKey.Font = New-Object System.Drawing.Font("Segoe UI", 8)
`$btnGetKey.Add_Click({ Start-Process "https://aistudio.google.com/app/apikey" })
`$grpApi.Controls.Add(`$btnGetKey)

# Function to Save Key and Set Env
`$fnSetEnv = {
    `$k = `$txtKey.Text.Trim()
    if (`$k) {
        [Environment]::SetEnvironmentVariable("GEMINI_API_KEY", `$k, "Process")
        [System.IO.File]::WriteAllText(`$ApiKeyFile, `$k)
    }
}

# --- Group: Tools ---
`$grpTools = New-Object System.Windows.Forms.GroupBox
`$grpTools.Text = "Tools"
`$grpTools.Location = New-Object System.Drawing.Point(20, 155)
`$grpTools.Size = New-Object System.Drawing.Size(345, 100)
`$form.Controls.Add(`$grpTools)

`$btnCode = New-Object System.Windows.Forms.Button
`$btnCode.Text = "VS Code"
`$btnCode.Location = New-Object System.Drawing.Point(15, 30)
`$btnCode.Size = New-Object System.Drawing.Size(150, 40)
`$btnCode.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
`$btnCode.Add_Click({
    & `$fnSetEnv
    Start-Process "code" -ArgumentList "." -WindowStyle Hidden; `$form.Close()
})
`$grpTools.Controls.Add(`$btnCode)

`$btnTerm = New-Object System.Windows.Forms.Button
`$btnTerm.Text = "Terminal (gemini)"
`$btnTerm.Location = New-Object System.Drawing.Point(180, 30)
`$btnTerm.Size = New-Object System.Drawing.Size(150, 40)
`$btnTerm.Add_Click({
    & `$fnSetEnv
    Start-Process "cmd" -ArgumentList "/k echo Portable Terminal. Type 'gemini' to start the official CLI." ; `$form.Close()
})
`$grpTools.Controls.Add(`$btnTerm)

[void] `$form.ShowDialog()
"@
[System.IO.File]::WriteAllText($psPath, $psContent, [System.Text.Encoding]::UTF8)

# --- File 2: Start-DevEnv.bat (Cleaned) ---
$batPath = Join-Path $RootDir "Start-DevEnv.bat"
$batContent = @"
@echo off
cd /d "%~dp0"

set "VSCODE_DIR=%~dp0VSCode"
set "GIT_DIR=%~dp0Git"
set "UV_DIR=%~dp0uv"
set "GEMINI_DIR=%~dp0GeminiCLI"
set "NODE_DIR=%~dp0NodeJS"
set "HOME=%~dp0home"
set "USERPROFILE=%~dp0home"
set "PATH=%VSCODE_DIR%\bin;%GIT_DIR%\cmd;%UV_DIR%;%GEMINI_DIR%;%NODE_DIR%;%PATH%"

powershell -NoProfile -ExecutionPolicy Bypass -File "Menu.ps1"
if %errorlevel% neq 0 pause
"@
[System.IO.File]::WriteAllText($batPath, $batContent, [System.Text.Encoding]::ASCII)

Write-Host "COMPLETED! Run 'Start-DevEnv.bat'." -ForegroundColor Yellow