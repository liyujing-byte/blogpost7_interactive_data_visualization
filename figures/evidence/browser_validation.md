# Final HTML browser validation — 2026-10-25

Method: locally serve `figures/` and operate the actual rendered HTML in the Codex in-app browser. Desktop viewport: 1280 × 900. Screenshots are original browser captures, not recreated illustrations.

| Action | Observed result | Screenshot |
|---|---|---|
| Open main chart | 1952 selected; five continent groups visible; fixed axis labels | `01_main_1952.jpg` |
| Select 2007 on year slider | Label changes to Year: 2007 and country coordinates change | `02_main_2007.jpg` |
| Point at South Africa in 2007 | Tooltip gives South Africa, 2007, Africa, $9,270, 49.3 years and population 43,997,828 | `03_south_africa_hover.jpg` |
| Double-click Africa legend | Only Africa points remain; other legend entries are dimmed | `04_africa_filter_2007.jpg` |
| Select 1952 with Africa isolated | Year changes while Africa-only selection is retained; axes remain fixed | `05_filter_preserved_1952.jpg` |
| Select South Africa in country dropdown | Country label and plotted trajectory change to South Africa | `06_south_africa_trajectory.jpg` |

The final main figure uses a year slider, without animation or Play. An initial animated prototype showed inconsistent legend behavior during testing and was replaced before these final captures. The final slider's five stable traces preserve visibility between year updates. Dropdown case selection and the article's two embedded figures were also opened and inspected. No warning/error entries were returned by the browser log query on the trajectory page.

Limitations: this is local browser validation, not evidence of a GitHub Pages deployment. Screenshot checks do not establish cross-browser compatibility. Use `code/blogpost7_all_process.R` for numerical correspondence of every year/continent and each country trajectory; visual screenshots alone cannot establish that correspondence.

Repository organization update: the validated HTML files and screenshots were moved into `figures/` and `figures/evidence/`. These screenshots document the earlier interaction checks; numerical validation was rerun after the path update.
