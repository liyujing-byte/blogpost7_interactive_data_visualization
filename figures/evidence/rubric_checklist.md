# Assignment evidence map

Evidence supports review; it does not promise a grade. Screenshots are supplementary; only the live HTML demonstrates interactivity.

| Criterion | Evidence |
|---|---|
| 1. Question and motivation | Article opening; README research question |
| 2. Clear explanation | Article data/methods and instructions; documented R code |
| 3. Interpretation and takeaway | Three empirical patterns and article conclusion |
| 4. Data and presentation | `data/raw/SOURCES.md`, labeled figures and hover units |
| 5. Repository organization | Folder structure and README replication instructions |
| 6. Reproducible coding | `code/run.R`; computed CSVs; numerical placeholders inserted by code; checksums and session info |
| 7. Plotly addressing a substantive question | `figures/interactive_plot.html` and `figures/country_trajectories.html` |
| 8. Correct, usable interaction | Browser validation record and original interaction screenshots |
| 9. Value beyond a static graph | Year changes, named country identification, continent filters, full selected-country trajectories |
| 10. Discussion of revealed patterns | Article median comparison, Costa Rica/South Africa comparison, South Africa reversal |

## Evidence types

- `data_checks.csv`: nine actual input assertions; execution stops if any fails.
- `run.log`: captured output of successful R execution; a locale startup warning, if present, is recorded rather than hidden.
- `data_result_checksums.csv`: MD5 integrity checks for input and numerical output files; these are integrity identifiers, not security signatures.
- `main_plot_spec.json`, `trajectory_plot_spec.json`: actual serialized Plotly specifications.
- `article_word_count.txt`: approximate prose count, including headings.
- Browser screenshots: authentic captures from the locally served final HTML, after interacting with actual controls.
- `browser_validation.md`: exact actions and observed results, separate from structural checks.

The page files are prepared for publication, but repository upload alone does not establish that a published blog or GitHub Pages deployment exists.
