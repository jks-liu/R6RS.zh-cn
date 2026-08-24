# R6RS 简体中文规范整理简报

## 完成内容

- 将原单页规范移到 `single-page.md`，保留 `/single-page/` 单页视图；新增首页目录，并按前言、11 个正文大章、5 个附录和参考文献生成 18 个分页。分页内容由脚本从单页源按边界原样切分，避免维护两份译文。
- 修复 GitHub Pages 上的代码高亮、数学公式加载顺序、失效锚点和内部链接，并为代码、表格及长公式增加响应式横向滚动。旧的根路径片段链接会转到单页中的对应位置。
- 将网页中尚未进入 PDF 的译文补入 LaTeX 主报告，包括第 11 章后半部分、形式语义及其余附录；语义图中的可见文字也与网页版本同步。
- 为新版 LaTeX/CJK 与 `hyperref` 修复参考文献标题和 `#|`、`|#` 索引项的排版兼容问题。正文显示内容没有因此改变。
- 将发现的疑似笔误单独记录在 `TRANSLATION_NOTES.md`，没有修改网页或 PDF 中的译文。

## 保留的脚本

- `scripts/generate_chapters.ps1`：从 `single-page.md` 生成或核对分页。
- `scripts/verify_site.ps1`：核对分页内容、导航、引用、锚点、代码块、Rouge 和 MathJax。
- `scripts/verify_built_site.ps1`：检查 Jekyll 构建结果中的本地链接和片段。
- `scripts/verify_browser_layout.mjs`：用浏览器检查移动端溢出、代码样式、侧栏和公式渲染，并保存截图。
- `scripts/verify_latex_sources.ps1`：静态检查网页与 LaTeX 内容的覆盖关系及基本结构。
- `scripts/build_pdf.ps1`：生成语义图、参考文献和索引，并完整编译主 PDF；默认寻找 `C:\texlive`，也可用 `-TexLiveRoot` 和 `-RacketRoot` 指定工具位置。

所有 PowerShell 脚本均保存为带 BOM 的 UTF-8，兼容 PowerShell 7 和 Windows PowerShell 5。

## 验证结果

- 18 个分页与单页源核对通过；发布态 Jekyll 构建成功。
- 构建后的 26 个 HTML、1009 个本地链接和 362 个片段链接全部通过检查。
- 320/375 像素移动端及桌面端浏览器检查通过；长公式均被滚动容器约束，最终 MathJax 输出正常。
- LaTeX 静态检查通过；`scripts/build_pdf.ps1` 完整运行成功。
- 最终 `latex/document/r6rs.pdf` 为 83 页、1,501,401 字节，未解析文献引用和交叉引用均为 0；已抽查封面、正文、形式语义、参考文献和索引页面。

PDF 使用原工程的 pdfLaTeX/CJK 字体方案，页面显示正常；这套旧字体的字符映射会使 `pdftotext` 对部分拉丁字符和数字提取不准确，但不影响阅读和打印。

## 处理原则

本次只调整网站结构、链接、CSS/模板、LaTeX 标记和构建流程。所有规范译文均以网页单页版本为准，没有纠正错别字或改写措辞。
