[CmdletBinding()]
param(
    [switch]$Check
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$sourcePath = Join-Path $repositoryRoot 'single-page.md'
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
$sourceLines = [System.IO.File]::ReadAllLines($sourcePath, $utf8NoBom)

function Find-SourceLine {
    param([Parameter(Mandatory)][string]$Text)

    $matches = @(for ($lineNumber = 0; $lineNumber -lt $sourceLines.Length; $lineNumber++) {
        if ($sourceLines[$lineNumber] -ceq $Text) {
            $lineNumber
        }
    })

    if ($matches.Count -ne 1) {
        throw "Expected exactly one source line '$Text'; found $($matches.Count)."
    }

    return $matches[0]
}

function Join-SourceRange {
    param(
        [Parameter(Mandatory)][int]$Start,
        [Parameter(Mandatory)][int]$End
    )

    if ($Start -lt 0 -or $End -gt $sourceLines.Length -or $Start -ge $End) {
        throw "Invalid source range [$Start, $End)."
    }

    return (($sourceLines[$Start..($End - 1)] -join "`n").TrimEnd())
}

$citationNumbers = @{
    '24' = '1';  '22' = '2';  '23' = '3';  '14' = '4';  '26' = '5'
    '20' = '6';  '21' = '7';  '12' = '8';  '25' = '9';  '8'  = '10'
    '11' = '11'; '1'  = '12'; '28' = '13'; '3'  = '14'; '13' = '15'
    '27' = '16'; '5'  = '17'; '16' = '18'; '15' = '19'; '2'  = '20'
    '6'  = '21'; '9'  = '22'; '4'  = '23'; '7'  = '24'; '18' = '25'
    '10' = '26'; '29' = '27'; '19' = '28'; '17' = '29'
}

function Get-AnchorRoute {
    param([Parameter(Mandatory)][string]$Anchor)

    if ($Anchor -match '^s(?<chapter>\d+)-') {
        $chapter = [int]$Matches.chapter
        return ('/chapters/{0:D2}/' -f $chapter)
    }

    if ($Anchor -match '^(Aa|Fa|p63-)') {
        return '/appendices/a/'
    }

    if ($Anchor -ceq 'Ab') {
        return '/appendices/b/'
    }

    throw "No chapter route is defined for anchor '#$Anchor'."
}

function Convert-ChapterFormatting {
    param([Parameter(Mandatory)][string]$Body)

    $converted = [regex]::Replace(
        $Body,
        '\[\^(?<id>\d+)\]',
        {
            param($citationMatch)
            $identifier = $citationMatch.Groups['id'].Value
            if (-not $citationNumbers.ContainsKey($identifier)) {
                throw "No display number is defined for citation [^$identifier]."
            }

            $referenceBase = '{{ ' + "'/references/'" + ' | relative_url }}'
            return '<sup class="citation"><a href="' + $referenceBase +
                '#ref-' + $identifier + '">' + $citationNumbers[$identifier] + '</a></sup>'
        }
    )

    $converted = [regex]::Replace(
        $converted,
        '\]\(#(?<anchor>[A-Za-z0-9-]+)\)',
        {
            param($anchorMatch)
            $anchor = $anchorMatch.Groups['anchor'].Value
            $route = Get-AnchorRoute -Anchor $anchor
            $liquidRoute = '{{ ' + "'$route'" + ' | relative_url }}'
            return '](' + $liquidRoute + '#' + $anchor + ')'
        }
    )

    if ($converted -match '\[\^\d+\]') {
        throw 'At least one footnote citation was not converted.'
    }

    return $converted
}

$coverStart = Find-SourceLine '<center><font size="4">M</font>ICHAEL <font size="4">S</font>PERBER</center>'
$contentsStart = Find-SourceLine '# 目录 <!-- CONTENTS -->'
$overviewStart = Find-SourceLine '# 概述 <!-- INTRODUCTION -->'
$languageStart = Find-SourceLine '# **语言描述** <!-- DESCRIPTION OF THE LANGUAGE -->'
$chapter01Start = Find-SourceLine '# 1. <!-- Overview of -->Scheme概论'
$chapter02Start = Find-SourceLine '# 2. 需求等级 <!-- Requirement levels -->'
$chapter03Start = Find-SourceLine '# 3. 数字（Numbers）'
$chapter04Start = Find-SourceLine '# 4. 词汇语法（Lexical syntax）<!-- and -->和数据语法（datum syntax）'
$chapter05Start = Find-SourceLine '# 5. 语义概念 <!-- Semantic concepts -->'
$chapter06Start = Find-SourceLine '# 6. 条目格式（Entry format）'
$chapter07Start = Find-SourceLine '# 7. 库 <!-- Libraries -->'
$chapter08Start = Find-SourceLine '# 8. 顶层程序 <!-- Top-level programs -->'
$chapter09Start = Find-SourceLine '# 9. 基本语法 <!-- Primitive syntax -->'
$chapter10Start = Find-SourceLine '# 10. 扩展过程 <!-- Expansion process -->'
$chapter11Start = Find-SourceLine '# 11. 基本库 <!-- Base library -->'
$appendicesStart = Find-SourceLine '# 附录 {#APPENDICES}'
$appendixAStart = Find-SourceLine '# 附录A. 形式语义 {#Aa}'
$appendixBStart = Find-SourceLine '# 附录B. 衍生形式的定义示例 {#Ab}'
$appendixCStart = Find-SourceLine '# 附录C. 附加材料 {#Ac}'
$appendixDStart = Find-SourceLine '# 附录D. 示例 {#Ad}'
$appendixEStart = Find-SourceLine '# 附录E. 语言的变化 {#Ae}'
$referencesStart = Find-SourceLine '# 参考文献 <!-- REFERENCES -->'

$prefaceBody = (Join-SourceRange -Start $coverStart -End $contentsStart) + "`n`n" +
    (Join-SourceRange -Start $overviewStart -End $languageStart)

$pageDefinitions = @(
    [pscustomobject]@{ Key = 'preface';    Title = '摘要与概述';                    Permalink = '/preface/';      File = 'preface.md';       Body = $prefaceBody },
    [pscustomobject]@{ Key = 'chapter-01'; Title = '1. Scheme概论';                 Permalink = '/chapters/01/';  File = 'chapters/01.md';   Body = (Join-SourceRange $languageStart $chapter02Start) },
    [pscustomobject]@{ Key = 'chapter-02'; Title = '2. 需求等级';                    Permalink = '/chapters/02/';  File = 'chapters/02.md';   Body = (Join-SourceRange $chapter02Start $chapter03Start) },
    [pscustomobject]@{ Key = 'chapter-03'; Title = '3. 数字（Numbers）';             Permalink = '/chapters/03/';  File = 'chapters/03.md';   Body = (Join-SourceRange $chapter03Start $chapter04Start) },
    [pscustomobject]@{ Key = 'chapter-04'; Title = '4. 词汇语法和数据语法';           Permalink = '/chapters/04/';  File = 'chapters/04.md';   Body = (Join-SourceRange $chapter04Start $chapter05Start) },
    [pscustomobject]@{ Key = 'chapter-05'; Title = '5. 语义概念';                    Permalink = '/chapters/05/';  File = 'chapters/05.md';   Body = (Join-SourceRange $chapter05Start $chapter06Start) },
    [pscustomobject]@{ Key = 'chapter-06'; Title = '6. 条目格式（Entry format）';     Permalink = '/chapters/06/';  File = 'chapters/06.md';   Body = (Join-SourceRange $chapter06Start $chapter07Start) },
    [pscustomobject]@{ Key = 'chapter-07'; Title = '7. 库';                          Permalink = '/chapters/07/';  File = 'chapters/07.md';   Body = (Join-SourceRange $chapter07Start $chapter08Start) },
    [pscustomobject]@{ Key = 'chapter-08'; Title = '8. 顶层程序';                    Permalink = '/chapters/08/';  File = 'chapters/08.md';   Body = (Join-SourceRange $chapter08Start $chapter09Start) },
    [pscustomobject]@{ Key = 'chapter-09'; Title = '9. 基本语法';                    Permalink = '/chapters/09/';  File = 'chapters/09.md';   Body = (Join-SourceRange $chapter09Start $chapter10Start) },
    [pscustomobject]@{ Key = 'chapter-10'; Title = '10. 扩展过程';                   Permalink = '/chapters/10/';  File = 'chapters/10.md';   Body = (Join-SourceRange $chapter10Start $chapter11Start) },
    [pscustomobject]@{ Key = 'chapter-11'; Title = '11. 基本库';                     Permalink = '/chapters/11/';  File = 'chapters/11.md';   Body = (Join-SourceRange $chapter11Start $appendicesStart) },
    [pscustomobject]@{ Key = 'appendix-a'; Title = '附录A. 形式语义';                Permalink = '/appendices/a/'; File = 'appendices/a.md';  Body = (Join-SourceRange $appendicesStart $appendixBStart) },
    [pscustomobject]@{ Key = 'appendix-b'; Title = '附录B. 衍生形式的定义示例';      Permalink = '/appendices/b/'; File = 'appendices/b.md';  Body = (Join-SourceRange $appendixBStart $appendixCStart) },
    [pscustomobject]@{ Key = 'appendix-c'; Title = '附录C. 附加材料';                Permalink = '/appendices/c/'; File = 'appendices/c.md';  Body = (Join-SourceRange $appendixCStart $appendixDStart) },
    [pscustomobject]@{ Key = 'appendix-d'; Title = '附录D. 示例';                    Permalink = '/appendices/d/'; File = 'appendices/d.md';  Body = (Join-SourceRange $appendixDStart $appendixEStart) },
    [pscustomobject]@{ Key = 'appendix-e'; Title = '附录E. 语言的变化';              Permalink = '/appendices/e/'; File = 'appendices/e.md';  Body = (Join-SourceRange $appendixEStart $referencesStart) }
)

$footnoteDefinitions = @{}
for ($lineNumber = $referencesStart + 1; $lineNumber -lt $sourceLines.Length; $lineNumber++) {
    if ($sourceLines[$lineNumber] -match '^\[\^(?<id>\d+)\]:\s+(?<text>.*)$') {
        $footnoteDefinitions[$Matches.id] = $Matches.text
    }
}

$citationOrder = @('24', '22', '23', '14', '26', '20', '21', '12', '25', '8', '11', '1', '28', '3', '13', '27', '5', '16', '15', '2', '6', '9', '4', '7', '18', '10', '29', '19', '17')
$referenceLines = [System.Collections.Generic.List[string]]::new()
$referenceLines.Add('# 参考文献 <!-- REFERENCES -->')
$referenceLines.Add('')
foreach ($identifier in $citationOrder) {
    if (-not $footnoteDefinitions.ContainsKey($identifier)) {
        throw "Reference [^$identifier] is missing from the source document."
    }
    $referenceLines.Add('1. <span id="ref-' + $identifier + '"></span>' + $footnoteDefinitions[$identifier])
}
$referenceLines.Add('{: .r6rs-bibliography}')

$pageDefinitions += [pscustomobject]@{
    Key = 'references'
    Title = '参考文献'
    Permalink = '/references/'
    File = 'references.md'
    Body = ($referenceLines -join "`n")
}

for ($pageIndex = 0; $pageIndex -lt $pageDefinitions.Count; $pageIndex++) {
    $page = $pageDefinitions[$pageIndex]
    $frontMatter = [System.Collections.Generic.List[string]]::new()
    $frontMatter.Add('---')
    $frontMatter.Add('layout: r6rs')
    $frontMatter.Add("title: '$($page.Title.Replace("'", "''"))'")
    $frontMatter.Add("title_plain: '$($page.Title.Replace("'", "''")) — R6RS简体中文翻译'")
    $frontMatter.Add("permalink: $($page.Permalink)")
    $frontMatter.Add('r6rs: true')
    $frontMatter.Add("chapter_key: $($page.Key)")

    if ($pageIndex -gt 0) {
        $previousPage = $pageDefinitions[$pageIndex - 1]
        $frontMatter.Add("previous_url: $($previousPage.Permalink)")
        $frontMatter.Add("previous_title: '$($previousPage.Title.Replace("'", "''"))'")
    }
    if ($pageIndex -lt $pageDefinitions.Count - 1) {
        $nextPage = $pageDefinitions[$pageIndex + 1]
        $frontMatter.Add("next_url: $($nextPage.Permalink)")
        $frontMatter.Add("next_title: '$($nextPage.Title.Replace("'", "''"))'")
    }
    $frontMatter.Add('---')

    $generatedNotice = '<!-- 由 scripts/generate_chapters.ps1 从 single-page.md 生成；正文修改请在单页源文件中进行。 -->'
    $formattedBody = Convert-ChapterFormatting -Body $page.Body
    $output = ($frontMatter -join "`n") + "`n`n" + $generatedNotice + "`n`n" + $formattedBody + "`n"

    $targetPath = Join-Path $repositoryRoot $page.File
    $targetDirectory = Split-Path -Parent $targetPath
    if ($Check) {
        if (-not [System.IO.File]::Exists($targetPath)) {
            throw "Generated page is missing: $($page.File)"
        }
        $existingOutput = [System.IO.File]::ReadAllText($targetPath, $utf8NoBom)
        if ($existingOutput -cne $output) {
            throw "Generated page is stale or was edited directly: $($page.File)"
        }
        Write-Host "Verified $($page.File)"
    }
    else {
        [System.IO.Directory]::CreateDirectory($targetDirectory) | Out-Null
        [System.IO.File]::WriteAllText($targetPath, $output, $utf8NoBom)
        Write-Host "Generated $($page.File)"
    }
}

if ($Check) {
    Write-Host "Verified $($pageDefinitions.Count) generated pages against single-page.md."
}
else {
    Write-Host "Generated $($pageDefinitions.Count) pages from single-page.md without compiling TeX."
}
