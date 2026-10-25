# 在 RStudio 中一步一步复现 Blog Post 7

## 1. 下载并打开项目

在 GitHub 仓库点击 Code → Download ZIP，解压后双击 `blogpost7.Rproj`。不要只下载一个 R 文件；保留整个文件夹。

## 2. 安装依赖（首次运行）

在 RStudio Console 运行：

```r
source("scripts/install_packages.R")
```

需要联网下载 CRAN 包。如果提示 Pandoc 不可用，先在 RStudio 中运行；RStudio 一般自带 Pandoc。

## 3. 运行完整分析

```r
source("run.R")
```

看到 `PASS: 9 data checks` 表示数据检查通过。代码读取仓库内的原始 CSV，不需要申请 API key，也不会依赖你电脑上之前保存的 R 工作区。

## 4. 查看数据

```r
d <- read.csv("data/raw/gapminder.csv")
View(d)
```

每行是一个国家在某一年的观测。`gdpPercap` 是人均 GDP；`lifeExp` 是出生时预期寿命；`pop` 是人口。人均 GDP 不是个人工资。

## 5. 打开文章和交互图

在 Finder 中打开 `docs/index.html`，用浏览器阅读正文及两张交互图。也可单独打开 `docs/interactive_plot.html`。

先选 1952，再选 2007；悬停查看具体国家。双击 Africa 图例可只看非洲国家，再切换年份确认筛选仍保留。再次双击可恢复其他组。最终版本没有自动播放按钮。

## 6. 理解三个主要发现

1. 多数国家的整体关系向右上方延伸；国家预期寿命中位数在两个端点间提高。
2. 2007 年 Costa Rica 和 South Africa 人均 GDP 接近，但预期寿命相差约 29.4 年。
3. 在国家轨迹图选择 South Africa：1992–2007 年人均 GDP 上升约 28.3%，预期寿命却下降约 12.5 年。

用 `results/country_cases.csv` 和 `results/article_claims.csv` 核对数值。中位数是各国等权统计，不是按人口加权的全球寿命。

## 7. 理解代码

打开 `scripts/analysis.R`，按以下顺序阅读：检查输入 → 计算结果表 → 创建五个大洲的散点序列 → 用年份滑块更新坐标和悬停文字 → 创建国家下拉图 → 保存 HTML 和运行环境。

对数横轴让等距离表示相同比例的 GDP 变化。固定横纵轴范围，避免切换年份时坐标缩放造成误读。

## 8. 修改文章

修改 `post/template.md` 中的叙述，再运行 `source("run.R")`。不要直接修改生成的 `post/blogpost7.md`，否则重新运行时会覆盖。

`{{crgdp}}` 等占位符由实际计算结果替换。需要写原因解释时，应另找可靠来源；这份分析本身只支持描述性关系，不能证明因果。

## 9. 重新验证

```r
source("scripts/validate_outputs.R")
```

它会核对所有年份和大洲的滑块数据、五条国家轨迹、结果校验值与文章占位符。`evidence/` 的截图记录本次真实操作；修改图表后应重新截图，不能把旧截图当成新测试。

## 10. 发布与提交

仓库保存代码和 evidence；课程还要求一个已发布的博客 URL。可以将 `docs/` 发布为 GitHub Pages，或把文章放在已有博客并嵌入/链接交互图。

如果使用 Pages：仓库 Settings → Pages → Deploy from a branch → main → /docs → Save。以 GitHub 实际显示的部署地址为准；先在浏览器验证交互，再提交博客链接及仓库链接。
