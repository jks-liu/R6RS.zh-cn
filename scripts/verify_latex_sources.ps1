[CmdletBinding()]
param()

# This is deliberately a static source check. It never invokes TeX, Make,
# latexmk, pdflatex, xelatex, lualatex, or any PDF-producing command.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$documentRoot = Join-Path $repositoryRoot 'latex/document'
$utf8 = [System.Text.UTF8Encoding]::new($false)
$reportFiles = @(
    'r6rs.tex', 'intro.tex', 'struct.tex', 'mustard.tex', 'numbers.tex',
    'lex.tex', 'basic.tex', 'entry.tex', 'library.tex', 'programs.tex',
    'syntax.tex', 'expansion.tex', 'base.tex', 'semantics.tex', 'derived.tex',
    'repository.tex', 'example.tex', 'changes.tex'
)

function Remove-TeXCommentsAndVerb {
    param([Parameter(Mandatory)][string]$Content)

    $withoutComments = [regex]::Replace($Content, '(?m)(?<!\\)%.*$', '')
    return [regex]::Replace($withoutComments, '\\verb(?<delimiter>[^A-Za-z0-9\s]).*?\k<delimiter>', '')
}

function Assert-BalancedBraces {
    param(
        [Parameter(Mandatory)][string]$Content,
        [Parameter(Mandatory)][string]$RelativePath
    )

    $depth = 0
    for ($characterIndex = 0; $characterIndex -lt $Content.Length; $characterIndex++) {
        $character = $Content[$characterIndex]
        if ($character -ne '{' -and $character -ne '}') {
            continue
        }

        $backslashCount = 0
        for ($lookBehind = $characterIndex - 1; $lookBehind -ge 0 -and $Content[$lookBehind] -eq '\'; $lookBehind--) {
            $backslashCount++
        }
        if (($backslashCount % 2) -eq 1) {
            continue
        }

        if ($character -eq '{') {
            $depth++
        }
        else {
            $depth--
            if ($depth -lt 0) {
                throw "Closing brace appears before its opening brace in $RelativePath."
            }
        }
    }

    if ($depth -ne 0) {
        throw "Unbalanced TeX braces in $RelativePath (remaining depth: $depth)."
    }
}

function Assert-BalancedEnvironments {
    param(
        [Parameter(Mandatory)][string]$Content,
        [Parameter(Mandatory)][string]$RelativePath
    )

    $stack = [System.Collections.Generic.Stack[string]]::new()
    $environmentTokens = [regex]::Matches($Content, '\\(?<operation>begin|end)\{(?<name>[^{}]+)\}')
    foreach ($token in $environmentTokens) {
        $operation = $token.Groups['operation'].Value
        $name = $token.Groups['name'].Value
        if ($operation -eq 'begin') {
            $stack.Push($name)
            continue
        }
        if ($stack.Count -eq 0) {
            throw "Environment '$name' closes without opening in $RelativePath."
        }
        $openedName = $stack.Pop()
        if ($openedName -cne $name) {
            throw "Environment '$openedName' closes as '$name' in $RelativePath."
        }
    }
    if ($stack.Count -ne 0) {
        throw "Environment '$($stack.Peek())' is not closed in $RelativePath."
    }
}

foreach ($relativePath in $reportFiles) {
    $filePath = Join-Path $documentRoot $relativePath
    if (-not [System.IO.File]::Exists($filePath)) {
        throw "Missing report source: latex/document/$relativePath"
    }
    $content = [System.IO.File]::ReadAllText($filePath, $utf8)
    $structuralContent = Remove-TeXCommentsAndVerb -Content $content
    if ($structuralContent -match '<!--|-->') {
        throw "Raw HTML comment syntax remains in latex/document/$relativePath."
    }
    if ($structuralContent -match '(?m)^\s*~~~(?:\s+[a-z0-9_-]+)?\s*$') {
        throw "Markdown fence remains in latex/document/$relativePath."
    }
    if ($structuralContent -match '\[[^\]\r\n]+\]\(https?://') {
        throw "Markdown link remains in latex/document/$relativePath."
    }

    Assert-BalancedBraces -Content $structuralContent -RelativePath $relativePath
    Assert-BalancedEnvironments -Content $structuralContent -RelativePath $relativePath
}

$requiredText = @{
    'r6rs.tex'       = @('\clearchaptergroupstar{附录}', '\chapter{形式语义}', '\renewcommand{\bibname}{参考文献}')
    'base.tex'       = @('\chapter{基本库', '\section{尾调用和尾上下文')
    'semantics.tex'  = @('\section{引用}', '\section{规范不足（Underspecification）}')
    'derived.tex'    = @('\chapter{衍生形式的定义示例}')
    'repository.tex' = @('\chapter{附加材料}')
    'example.tex'    = @('\chapter{示例}')
    'changes.tex'    = @('\chapter{语言的变化}')
    'lex.tex'        = @('\subsection{缩写（Abbreviations）}')
    'entry.tex'      = @('\section{等价的条目}')
}

foreach ($relativePath in $requiredText.Keys) {
    $content = [System.IO.File]::ReadAllText((Join-Path $documentRoot $relativePath), $utf8)
    foreach ($requiredFragment in $requiredText[$relativePath]) {
        if (-not $content.Contains($requiredFragment)) {
            throw "Expected translated fragment is missing from ${relativePath}: $requiredFragment"
        }
    }
}

$generatorPath = Join-Path $documentRoot 'tex-translate.ss'
$generatorContent = [System.IO.File]::ReadAllText($generatorPath, $utf8)
foreach ($requiredFragment in @(
    '\\textrm{(否则)}',
    '\\textbf{未知: }',
    '\\textbf{未捕获的异常: }',
    '\\textrm{[不可变点对指针]}',
    '\\textrm{[可变点对指针]}',
    '\\textrm{不是一个数字}',
    '\\textbf{未捕获异常: }'
)) {
    if (-not $generatorContent.Contains($requiredFragment)) {
        throw "Expected web-derived generator fragment is missing: $requiredFragment"
    }
}

$modelPath = Join-Path $repositoryRoot 'latex/model/r6rs.scm'
$modelContent = [System.IO.File]::ReadAllText($modelPath, $utf8)
foreach ($requiredFragment in @(
    '过程的等价',
    '上下文期待一个值，接受到~a',
    '未定义的结果'
)) {
    if (-not $modelContent.Contains($requiredFragment)) {
        throw "Expected web-derived model fragment is missing: $requiredFragment"
    }
}

Write-Host "Static LaTeX verification passed for $($reportFiles.Count) report files and the figure generator sources; no PDF was compiled."
