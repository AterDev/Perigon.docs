[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$docsRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$contentRoot = Join-Path $docsRoot 'Content'

if (-not (Test-Path -LiteralPath $contentRoot)) {
    throw "Documentation content directory not found: $contentRoot"
}

$errors = [System.Collections.Generic.List[string]]::new()
$markdownFiles = Get-ChildItem -LiteralPath $contentRoot -Recurse -File -Filter '*.md'

function Add-ValidationError {
    param([string]$Message)
    $script:errors.Add($Message)
}

function Get-LineNumber {
    param(
        [string]$Text,
        [int]$Index
    )

    return (($Text.Substring(0, $Index) -split "`n").Count)
}

$webInfoPath = Join-Path $docsRoot 'webinfo.json'
$templatePackageVersion = $null
$aspireVersion = $null
if (-not (Test-Path -LiteralPath $webInfoPath)) {
    Add-ValidationError "Documentation metadata not found: $webInfoPath"
}
else {
    try {
        $webInfo = Get-Content -LiteralPath $webInfoPath -Raw | ConvertFrom-Json -ErrorAction Stop
        $perigonInfo = @($webInfo.DocInfos | Where-Object { $_.Name -eq 'Perigon' }) | Select-Object -First 1
        $templatePackageVersion = [string]$perigonInfo.TemplatePackageVersion
        $aspireVersion = [string]$perigonInfo.AspireVersion
        if ([string]::IsNullOrWhiteSpace($templatePackageVersion) -or [string]::IsNullOrWhiteSpace($aspireVersion)) {
            Add-ValidationError "Perigon DocInfo must declare TemplatePackageVersion and AspireVersion in $webInfoPath"
        }
    }
    catch {
        Add-ValidationError ("{0}: invalid documentation metadata ({1})" -f $webInfoPath, $_.Exception.Message)
    }
}

$linkPattern = '(?<!\!)\[[^\]]*\]\((?<target>[^)\s]+)(?:\s+"[^"]*")?\)'
foreach ($file in $markdownFiles) {
    $text = Get-Content -LiteralPath $file.FullName -Raw

    $fenceCount = ([regex]::Matches($text, '(?m)^\s*```')).Count
    if ($fenceCount % 2 -ne 0) {
        Add-ValidationError ("{0}: unmatched fenced code block" -f $file.FullName)
    }

    # Validate executable-looking snippets that can be checked without running
    # external services. This catches malformed JSON and broken PowerShell
    # syntax while leaving C#/shell examples for the template build/CI jobs.
    $codeBlocks = [regex]::Matches($text, '(?ms)^```(?<language>[A-Za-z0-9_-]+)\s*\r?\n(?<body>.*?)^```\s*$')
    foreach ($block in $codeBlocks) {
        $language = $block.Groups['language'].Value.ToLowerInvariant()
        $body = $block.Groups['body'].Value
        $line = Get-LineNumber $text $block.Index

        if ($language -eq 'json' -and $body.TrimStart() -match '^[\[{]') {
            try {
                $null = $body | ConvertFrom-Json -ErrorAction Stop
            }
            catch {
                Add-ValidationError ("{0}:{1}: invalid JSON code block ({2})" -f $file.FullName, $line, $_.Exception.Message)
            }
        }
        elseif ($language -in @('powershell', 'pwsh') -and $body -notmatch '<[^>\r\n]+>') {
            $tokens = $null
            $parseErrors = $null
            [System.Management.Automation.Language.Parser]::ParseInput($body, [ref]$tokens, [ref]$parseErrors) | Out-Null
            foreach ($parseError in $parseErrors) {
                Add-ValidationError ("{0}:{1}: invalid PowerShell code block ({2})" -f $file.FullName, $line, $parseError.Message)
            }
        }
    }

    foreach ($match in [regex]::Matches($text, $linkPattern)) {
        $target = $match.Groups['target'].Value.Trim('<', '>')
        if ($target -match '^(?i)(https?:|mailto:|data:|javascript:|#)') {
            continue
        }

        $pathPart = ($target -split '[#?]', 2)[0]
        if ([string]::IsNullOrWhiteSpace($pathPart)) {
            continue
        }

        try {
            $decodedPath = [Uri]::UnescapeDataString($pathPart).Replace('/', [IO.Path]::DirectorySeparatorChar)
            $resolvedPath = [IO.Path]::GetFullPath([IO.Path]::Combine($file.DirectoryName, $decodedPath))
        }
        catch {
            Add-ValidationError ("{0}:{1}: invalid link '{2}'" -f $file.FullName, (Get-LineNumber $text $match.Index), $target)
            continue
        }

        if (-not (Test-Path -LiteralPath $resolvedPath)) {
            Add-ValidationError ("{0}:{1}: broken relative link '{2}'" -f $file.FullName, (Get-LineNumber $text $match.Index), $target)
        }
    }
}

$stalePatterns = @(
    'perigon-minapi',
    'AddNpmApp',
    '使用AppHost配置开发环境\.md',
    '自定义工具\.md'
)
foreach ($pattern in $stalePatterns) {
    $matches = rg --line-number --glob '*.md' -- "$pattern" $contentRoot 2>$null
    foreach ($match in $matches) {
        Add-ValidationError ("stale documentation token: $match")
    }
}

$requiredSnippets = @{
    'docs/Perigon/zh-CN/10.0/快速入门.md' = @("dotnet new install Perigon.templates --version $templatePackageVersion", 'ApiStandard', 'MiniApi')
    'docs/Perigon/en-US/10.0/Quick-Start.md' = @("dotnet new install Perigon.templates --version $templatePackageVersion", 'ApiStandard', 'MiniApi')
    'docs/Perigon/zh-CN/10.0/项目模板/ApiStandard快速入门.md' = @('dotnet new perigon-webapi', 'aspire start --non-interactive', 'tests/UnitTest/UnitTest.csproj', 'Category=Integration')
    'docs/Perigon/zh-CN/10.0/项目模板/MiniApi快速入门.md' = @('dotnet new perigon-miniapi', 'dotnet publish src/Services/ApiService/ApiService.csproj', '/openapi/v1.json', 'Category=Integration')
    'docs/Perigon/en-US/10.0/Project-Templates/ApiStandard-Quick-Start.md' = @('dotnet new perigon-webapi', 'aspire start --non-interactive', 'tests/UnitTest/UnitTest.csproj', 'Category=Integration')
    'docs/Perigon/en-US/10.0/Project-Templates/MiniApi-Quick-Start.md' = @('dotnet new perigon-miniapi', 'dotnet publish src/Services/ApiService/ApiService.csproj', '/openapi/v1.json', 'Category=Integration')
}
foreach ($entry in $requiredSnippets.GetEnumerator()) {
    $path = Join-Path $contentRoot $entry.Key
    if (-not (Test-Path -LiteralPath $path)) {
        Add-ValidationError "required guide missing: $path"
        continue
    }

    $text = Get-Content -LiteralPath $path -Raw
    foreach ($snippet in $entry.Value) {
        if ($text.IndexOf($snippet, [StringComparison]::OrdinalIgnoreCase) -lt 0) {
            Add-ValidationError ("{0}: required command or route missing '{1}'" -f $path, $snippet)
        }
    }
}

$versionPages = @(
    (Join-Path $contentRoot 'docs/Perigon/zh-CN/10.0/项目模板/版本特性.md'),
    (Join-Path $contentRoot 'docs/Perigon/en-US/10.0/Project-Templates/Version-Features.md')
)
foreach ($page in $versionPages) {
    if (-not (Test-Path -LiteralPath $page)) {
        Add-ValidationError "version mapping page missing: $page"
        continue
    }

    $text = Get-Content -LiteralPath $page -Raw
    if ($text -notmatch [regex]::Escape($templatePackageVersion)) {
        Add-ValidationError ("{0}: template package version {1} is not documented" -f $page, $templatePackageVersion)
    }
    if ($text -notmatch [regex]::Escape($aspireVersion)) {
        Add-ValidationError ("{0}: Aspire version {1} is not documented" -f $page, $aspireVersion)
    }
}

if ($errors.Count -gt 0) {
    $errors | ForEach-Object { Write-Error $_ }
    throw "Documentation validation failed with $($errors.Count) error(s)."
}

Write-Host ("Documentation validation passed: {0} Markdown files checked." -f $markdownFiles.Count)
