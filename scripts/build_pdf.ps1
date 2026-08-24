[CmdletBinding()]
param(
    [string]$TexLiveRoot = 'C:\texlive',
    [string]$RacketRoot
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$documentDir = Join-Path $repoRoot 'latex\document'

function Remove-BuildArtifact {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    $target = [IO.Path]::GetFullPath((Join-Path $documentDir $Name))
    $resolvedDocumentDir = [IO.Path]::GetFullPath($documentDir)
    if (-not $target.StartsWith($resolvedDocumentDir, [StringComparison]::OrdinalIgnoreCase)) {
        throw "构建产物 $Name 不在预期目录中。"
    }
    if (Test-Path -LiteralPath $target) {
        Remove-Item -LiteralPath $target -Force
    }
}

function Resolve-Tool {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [string[]]$Candidates = @()
    )

    $command = Get-Command $Name -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    foreach ($candidate in $Candidates) {
        if ($candidate -and (Test-Path -LiteralPath $candidate -PathType Leaf)) {
            return (Resolve-Path -LiteralPath $candidate).Path
        }
    }

    throw "找不到构建工具 $Name。"
}

function Invoke-BuildTool {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath,
        [Parameter(Mandatory = $true)]
        [string[]]$ToolArguments,
        [Parameter(Mandatory = $true)]
        [string]$Description
    )

    Write-Host "==> $Description"
    $toolOutput = @(& $FilePath @ToolArguments 2>&1)
    $exitCode = $LASTEXITCODE
    if ($exitCode -ne 0) {
        $toolOutput | Select-Object -Last 100 | ForEach-Object { Write-Host $_ }
        throw "$Description 失败，退出码 $exitCode。"
    }

    $summary = @($toolOutput | Select-String -Pattern 'Writing file|Output written|Warning|written' | Select-Object -Last 25)
    if ($summary.Count -gt 0) {
        $summary | ForEach-Object { Write-Host $_ }
    }
}

$texCandidates = @(
    (Join-Path $TexLiveRoot 'bin\windows'),
    (Get-ChildItem -LiteralPath $TexLiveRoot -Directory -ErrorAction SilentlyContinue |
        Sort-Object Name -Descending |
        ForEach-Object { Join-Path $_.FullName 'bin\windows' })
)

function Get-TexCandidates {
    param([string]$Executable)
    return @($texCandidates | ForEach-Object { Join-Path $_ $Executable })
}

$pdflatex = Resolve-Tool -Name 'pdflatex' -Candidates (Get-TexCandidates 'pdflatex.exe')
$bibtex = Resolve-Tool -Name 'bibtex' -Candidates (Get-TexCandidates 'bibtex.exe')
$makeindex = Resolve-Tool -Name 'makeindex' -Candidates (Get-TexCandidates 'makeindex.exe')

$racketCandidates = @()
if ($RacketRoot) {
    $racketCandidates += Join-Path $RacketRoot 'mzscheme.exe'
}
$racketSearchRoots = @(
    (Join-Path $env:ProgramFiles 'Racket'),
    (Join-Path $env:LOCALAPPDATA 'Programs\Racket'),
    (Join-Path $env:LOCALAPPDATA 'Temp\r6rs-racket-tools')
) | Where-Object { $_ }
foreach ($searchRoot in $racketSearchRoots) {
    $racketCandidates += Join-Path $searchRoot 'mzscheme.exe'
    if (Test-Path -LiteralPath $searchRoot -PathType Container) {
        $racketCandidates += Get-ChildItem -LiteralPath $searchRoot -Directory -ErrorAction SilentlyContinue |
            Sort-Object Name -Descending |
            ForEach-Object { Join-Path $_.FullName 'mzscheme.exe' }
    }
}
$mzscheme = Resolve-Tool -Name 'mzscheme' -Candidates $racketCandidates

Push-Location $documentDir
try {
    Remove-BuildArtifact -Name 'r6rs.bbl'
    Remove-BuildArtifact -Name 'r6rs.ind'
    Remove-BuildArtifact -Name 'r6rs-report-lib.idx'

    Invoke-BuildTool -FilePath $mzscheme -ToolArguments @('-qu', 'tex-translate.ss') -Description '生成形式语义图'
    Invoke-BuildTool -FilePath $pdflatex -ToolArguments @('-interaction=nonstopmode', '-halt-on-error', '-file-line-error', 'r6rs-lib.tex') -Description '生成库报告交叉引用数据'
    Invoke-BuildTool -FilePath $pdflatex -ToolArguments @('-interaction=nonstopmode', '-halt-on-error', '-file-line-error', 'r6rs.tex') -Description '生成主报告辅助数据'

    Invoke-BuildTool -FilePath $mzscheme -ToolArguments @('-f', 'frob-lib-index.scm') -Description '合并主报告与库报告索引数据'
    Invoke-BuildTool -FilePath $bibtex -ToolArguments @('r6rs') -Description '生成参考文献'
    Invoke-BuildTool -FilePath $makeindex -ToolArguments @('-s', 'r6rs.mst', '-c', 'r6rs.idx', 'r6rs-report-lib.idx') -Description '生成索引'

    1..2 | ForEach-Object {
        Invoke-BuildTool -FilePath $pdflatex -ToolArguments @('-interaction=nonstopmode', '-halt-on-error', '-file-line-error', 'r6rs.tex') -Description "主报告收敛编译（第 $_ 轮）"
    }

    $log = Get-Content -LiteralPath 'r6rs.log' -Raw
    if ($log -match 'LaTeX Warning: (Citation|Reference) .+ undefined') {
        throw '主报告仍有未解析的引用。'
    }
    if ($log -match 'Rerun to get cross-references right|Label\(s\) may have changed') {
        throw '主报告仍要求再次编译。'
    }

    $pdf = Get-Item -LiteralPath 'r6rs.pdf'
    Write-Host "PDF 构建完成：$($pdf.FullName)（$($pdf.Length) 字节）"
}
finally {
    Pop-Location
}
