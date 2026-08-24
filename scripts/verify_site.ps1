[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$generatorPath = Join-Path $PSScriptRoot 'generate_chapters.ps1'
$utf8 = [System.Text.UTF8Encoding]::new($false)

& $generatorPath -Check

$generatedFiles = @(
    (Join-Path $repositoryRoot 'preface.md')
    (Join-Path $repositoryRoot 'references.md')
) + @(
    Get-ChildItem (Join-Path $repositoryRoot 'chapters') -Filter '*.md' -File |
        Sort-Object Name |
        Select-Object -ExpandProperty FullName
) + @(
    Get-ChildItem (Join-Path $repositoryRoot 'appendices') -Filter '*.md' -File |
        Sort-Object Name |
        Select-Object -ExpandProperty FullName
)

if ($generatedFiles.Count -ne 18) {
    throw "Expected 18 generated reading pages; found $($generatedFiles.Count)."
}

$pagesByPermalink = @{}
foreach ($filePath in $generatedFiles) {
    $content = [System.IO.File]::ReadAllText($filePath, $utf8)
    if ($content -notmatch '(?s)\A---\n(?<frontMatter>.*?)\n---\n') {
        throw "Missing or malformed front matter: $filePath"
    }
    $frontMatter = $Matches.frontMatter
    if ($frontMatter -notmatch '(?m)^permalink:\s+(?<url>/\S+/)$') {
        throw "Missing pretty permalink: $filePath"
    }
    $permalink = $Matches.url
    if ($pagesByPermalink.ContainsKey($permalink)) {
        throw "Duplicate permalink '$permalink'."
    }
    $pagesByPermalink[$permalink] = $filePath

    if ($content -match '\[\^\d+\]') {
        throw "Unconverted footnote citation in $filePath"
    }
    if ($content -match '\]\(#[A-Za-z0-9-]+\)') {
        throw "Unconverted local fragment link in $filePath"
    }

    $fenceCount = ([regex]::Matches($content, '(?m)^~~~(?:\s+[a-z0-9_-]+)?\s*$')).Count
    if (($fenceCount % 2) -ne 0) {
        throw "Unbalanced fenced code block in $filePath"
    }
}

$dataPath = Join-Path $repositoryRoot '_data/r6rs_pages.yml'
$dataContent = [System.IO.File]::ReadAllText($dataPath, $utf8)
$navigationUrls = @([regex]::Matches($dataContent, '(?m)^\s+url:\s+(?<url>/\S+/)$') | ForEach-Object {
    $_.Groups['url'].Value
})
if ($navigationUrls.Count -ne 18) {
    throw "Expected 18 navigation entries; found $($navigationUrls.Count)."
}
foreach ($navigationUrl in $navigationUrls) {
    if (-not $pagesByPermalink.ContainsKey($navigationUrl)) {
        throw "Navigation URL has no generated page: $navigationUrl"
    }
}

foreach ($filePath in $generatedFiles) {
    $content = [System.IO.File]::ReadAllText($filePath, $utf8)
    $fragmentLinks = [regex]::Matches(
        $content,
        '\]\(\{\{ ''(?<route>/[^'']+/)'' \| relative_url \}\}#(?<anchor>[A-Za-z0-9-]+)\)'
    )
    foreach ($fragmentLink in $fragmentLinks) {
        $route = $fragmentLink.Groups['route'].Value
        $anchor = $fragmentLink.Groups['anchor'].Value
        if (-not $pagesByPermalink.ContainsKey($route)) {
            throw "Fragment link points to an unknown route: $route#$anchor"
        }
        $targetContent = [System.IO.File]::ReadAllText($pagesByPermalink[$route], $utf8)
        $escapedAnchor = [regex]::Escape($anchor)
        $headingId = '\{#' + $escapedAnchor + '\}'
        $attributeId = '(?m)^\{:[^\r\n}]*#' + $escapedAnchor + '(?:\s|\})'
        if ($targetContent -notmatch $headingId -and $targetContent -notmatch $attributeId) {
            throw "Missing fragment target: $route#$anchor"
        }
    }
}

$referenceContent = [System.IO.File]::ReadAllText((Join-Path $repositoryRoot 'references.md'), $utf8)
foreach ($filePath in $generatedFiles) {
    $content = [System.IO.File]::ReadAllText($filePath, $utf8)
    $citations = [regex]::Matches($content, '#ref-(?<id>\d+)">')
    foreach ($citation in $citations) {
        $identifier = $citation.Groups['id'].Value
        if ($referenceContent -notmatch ('id="ref-' + [regex]::Escape($identifier) + '"')) {
            throw "Citation target #ref-$identifier is missing."
        }
    }
}

$configContent = [System.IO.File]::ReadAllText((Join-Path $repositoryRoot '_config.yml'), $utf8)
if ($configContent -notmatch '(?m)^highlighter:\s+rouge\s*$') {
    throw 'GitHub Pages must be configured to use Rouge.'
}

$layoutContent = [System.IO.File]::ReadAllText(
    (Join-Path $repositoryRoot '_includes/themes/twitter/default.html'),
    $utf8
)
if ($layoutContent -match 'cdn\.mathjax\.org') {
    throw 'The retired MathJax CDN is still referenced.'
}
if ($layoutContent -notmatch 'mathjax/2\.7\.9/MathJax\.js') {
    throw 'The pinned MathJax 2.7.9 loader is missing.'
}

$singlePageContent = [System.IO.File]::ReadAllText((Join-Path $repositoryRoot 'single-page.md'), $utf8)
foreach ($requiredAnchor in @('s11-4-5', 's11-4-6', 's11-4-7', 'Fa-2a', 'Fa-2b')) {
    if ($singlePageContent -notmatch ('#' + [regex]::Escape($requiredAnchor) + '(?:\s|\})')) {
        throw "The single-page view is missing #$requiredAnchor."
    }
}

if ($singlePageContent -match '\]\(/r6rs-translation-experience/') {
    throw 'A broken translation-experience URL with a trailing slash remains.'
}

$chapterOneContent = [System.IO.File]::ReadAllText((Join-Path $repositoryRoot 'chapters/01.md'), $utf8)
if ($chapterOneContent -notmatch '(?m)^# \*\*语言描述\*\*') {
    throw 'The translated language-description group heading is missing from chapter 1.'
}

$appendixAContent = [System.IO.File]::ReadAllText((Join-Path $repositoryRoot 'appendices/a.md'), $utf8)
if ($appendixAContent -notmatch '(?m)^# 附录 \{#APPENDICES\}$') {
    throw 'The translated appendices group heading is missing from appendix A.'
}

$styleContent = [System.IO.File]::ReadAllText(
    (Join-Path $repositoryRoot 'assets/themes/twitter/css/r6rs.css'),
    $utf8
)
if ($styleContent -notmatch '(?s)\.r6rs-document pre code,.*?white-space:\s*pre;') {
    throw 'The Bootstrap pre-wrap override for report code blocks is missing.'
}

Write-Host 'Site verification passed: generated content, navigation, citations, fragments, fences, Rouge, and MathJax.'
