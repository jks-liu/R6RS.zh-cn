[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$BuildRoot
)

# Read-only validation for a completed Jekyll output directory.
# This script does not build the site and never invokes TeX or a PDF tool.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $BuildRoot -PathType Container)) {
    throw "Jekyll output directory does not exist: $BuildRoot"
}

$resolvedBuildRoot = (Resolve-Path -LiteralPath $BuildRoot).Path.TrimEnd(
    [IO.Path]::DirectorySeparatorChar,
    [IO.Path]::AltDirectorySeparatorChar
)
$utf8 = [System.Text.UTF8Encoding]::new($false)

$expectedPagePaths = @(
    'index.html',
    'single-page/index.html',
    'preface/index.html',
    'references/index.html',
    'chapters/01/index.html',
    'chapters/02/index.html',
    'chapters/03/index.html',
    'chapters/04/index.html',
    'chapters/05/index.html',
    'chapters/06/index.html',
    'chapters/07/index.html',
    'chapters/08/index.html',
    'chapters/09/index.html',
    'chapters/10/index.html',
    'chapters/11/index.html',
    'appendices/a/index.html',
    'appendices/b/index.html',
    'appendices/c/index.html',
    'appendices/d/index.html',
    'appendices/e/index.html'
)

foreach ($relativePath in $expectedPagePaths) {
    $candidate = Join-Path $resolvedBuildRoot $relativePath
    if (-not (Test-Path -LiteralPath $candidate -PathType Leaf)) {
        throw "Expected rendered page is missing: $relativePath"
    }
}

function Get-PublicPath {
    param([Parameter(Mandatory)][string]$RelativeFilePath)

    $normalized = $RelativeFilePath.Replace([IO.Path]::DirectorySeparatorChar, '/')
    if ($normalized -ceq 'index.html') {
        return '/'
    }
    if ($normalized.EndsWith('/index.html', [StringComparison]::OrdinalIgnoreCase)) {
        return '/' + $normalized.Substring(0, $normalized.Length - 'index.html'.Length)
    }
    return '/' + $normalized
}

function Resolve-OutputFile {
    param([Parameter(Mandatory)][string]$PublicPath)

    $relativePath = [Uri]::UnescapeDataString($PublicPath).TrimStart('/')
    $candidates = [System.Collections.Generic.List[string]]::new()
    if ([string]::IsNullOrEmpty($relativePath)) {
        $candidates.Add((Join-Path $resolvedBuildRoot 'index.html'))
    }
    else {
        $directPath = Join-Path $resolvedBuildRoot $relativePath
        $candidates.Add($directPath)
        $candidates.Add($directPath + '.html')
        $candidates.Add((Join-Path $directPath 'index.html'))
    }

    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate -PathType Leaf) {
            return (Resolve-Path -LiteralPath $candidate).Path
        }
    }
    return $null
}

$htmlFiles = @(Get-ChildItem -LiteralPath $resolvedBuildRoot -Filter '*.html' -File -Recurse)
$checkedLinks = 0
$checkedFragments = 0

foreach ($htmlFile in $htmlFiles) {
    $content = [System.IO.File]::ReadAllText($htmlFile.FullName, $utf8)
    $relativeFilePath = $htmlFile.FullName.Substring($resolvedBuildRoot.Length).TrimStart(
        [IO.Path]::DirectorySeparatorChar,
        [IO.Path]::AltDirectorySeparatorChar
    )
    $publicPath = Get-PublicPath -RelativeFilePath $relativeFilePath

    if ($content.Contains('{{ ') -or $content.Contains('{%')) {
        throw "Unrendered Liquid syntax remains in $relativeFilePath."
    }
    if ($content -match 'cdn\.mathjax\.org') {
        throw "The retired MathJax CDN remains in $relativeFilePath."
    }
    $linkContent = [regex]::Replace($content, '(?s)<!--.*?-->', '')
    if ($linkContent -match '(?i)(?:href|src)="/r6rs-translation-experience/') {
        throw "A rendered link still uses the broken translation-experience path in $relativeFilePath."
    }

    $attributeMatches = [regex]::Matches(
        $linkContent,
        '(?i)\b(?:href|src)="(?<url>[^"]+)"'
    )
    foreach ($attributeMatch in $attributeMatches) {
        $rawUrl = [Net.WebUtility]::HtmlDecode($attributeMatch.Groups['url'].Value)
        if ([string]::IsNullOrWhiteSpace($rawUrl) -or
            $rawUrl -match '^(?:mailto:|tel:|javascript:|data:)' -or
            $rawUrl -match '^(?:https?:)?//') {
            continue
        }

        $baseUri = [Uri]::new('https://r6rs.local' + $publicPath)
        $resolvedUri = [Uri]::new($baseUri, $rawUrl)
        if ($resolvedUri.Host -cne 'r6rs.local') {
            continue
        }

        $targetFile = Resolve-OutputFile -PublicPath $resolvedUri.AbsolutePath
        if ($null -eq $targetFile) {
            throw "Missing local target from ${relativeFilePath}: $rawUrl"
        }
        $checkedLinks++

        $fragment = [Uri]::UnescapeDataString($resolvedUri.Fragment.TrimStart('#'))
        if ([string]::IsNullOrEmpty($fragment) -or
            -not $targetFile.EndsWith('.html', [StringComparison]::OrdinalIgnoreCase)) {
            continue
        }

        $targetContent = [System.IO.File]::ReadAllText($targetFile, $utf8)
        $escapedFragment = [regex]::Escape([Net.WebUtility]::HtmlEncode($fragment))
        $fragmentPattern = '(?i)\b(?:id|name)=["'']' + $escapedFragment + '["'']'
        $rootIndexPath = Join-Path $resolvedBuildRoot 'index.html'
        if ($targetContent -notmatch $fragmentPattern -and
            $targetFile.Equals($rootIndexPath, [StringComparison]::OrdinalIgnoreCase) -and
            $targetContent -match 'window\.location\.hash' -and
            $targetContent -match '/single-page/') {
            $targetContent = [System.IO.File]::ReadAllText(
                (Join-Path $resolvedBuildRoot 'single-page/index.html'),
                $utf8
            )
        }
        if ($targetContent -notmatch $fragmentPattern) {
            throw "Missing fragment target from ${relativeFilePath}: $rawUrl"
        }
        $checkedFragments++
    }
}

$rootContent = [System.IO.File]::ReadAllText(
    (Join-Path $resolvedBuildRoot 'index.html'),
    $utf8
)
if ($rootContent -notmatch '<html lang="zh-CN">' -or
    $rootContent -notmatch 'class="r6rs-chapter-grid"') {
    throw 'The rendered chapter directory is missing its language or grid markup.'
}

$chapterContent = [System.IO.File]::ReadAllText(
    (Join-Path $resolvedBuildRoot 'chapters/11/index.html'),
    $utf8
)
$configPosition = $chapterContent.IndexOf('type="text/x-mathjax-config"', [StringComparison]::Ordinal)
$loaderPosition = $chapterContent.IndexOf('mathjax/2.7.9/MathJax.js', [StringComparison]::Ordinal)
if ($configPosition -lt 0 -or $loaderPosition -le $configPosition) {
    throw 'MathJax configuration is missing or is loaded after MathJax.'
}

$referencesContent = [System.IO.File]::ReadAllText(
    (Join-Path $resolvedBuildRoot 'references/index.html'),
    $utf8
)
if ($referencesContent -notmatch '<ol class="r6rs-bibliography">') {
    throw 'The rendered ordered bibliography is missing.'
}

Write-Host "Built-site verification passed for $($htmlFiles.Count) HTML files, $checkedLinks local links, and $checkedFragments fragments."
