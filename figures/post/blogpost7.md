# Does Higher Income Always Go with Longer Lives?

Countries with higher GDP per capita often have longer life expectancies. But does this association describe every country, and does economic growth always coincide with improvements in longevity? An interactive view lets us investigate both the broad relationship and cases that a single snapshot can hide. I compare countries over time rather than treating national income as a complete measure of well-being.

## Data and approach

I use the historical excerpt distributed with the gapminder R package: 142 countries observed every five years from 1952 to 2007, for 1,704 country-year observations. This is a historical sample, not a current global census. GDP per capita is reported in inflation-adjusted US dollars in the package documentation; life expectancy is measured at birth in years. GDP per capita measures national output per person, not household income. The script checks missing values, positive GDP and unique country-year records before creating the figures.

Each dot represents one country, with color indicating continent. The horizontal axis uses a logarithmic scale, so equal distances represent equal GDP ratios rather than equal dollar differences. Axis ranges remain fixed across years. Countries receive equal marker sizes; population is available on hover. The chart therefore compares country outcomes without visually weighting large populations more heavily.

## Explore the interactive chart

Drag the year slider to compare observations. Hover over a dot to identify its country and read its GDP per capita, life expectancy and population. Click a continent in the legend to hide or restore it; double-click to isolate a continent. These controls let readers investigate specific observations and regional differences without placing every country label on one crowded static figure.

## Three patterns to investigate

First, the cloud generally slopes upward: higher GDP per capita is associated with longer life expectancy. Moving between early and late years also reveals substantial improvements in longevity across much of the sample. Median life expectancy across the 142 countries rises from 45.1 years in 1952 to 71.9 in 2007. These are unweighted country medians, not population-weighted global life expectancy estimates. The slider makes the changing distribution visible while keeping the measurement scales constant.

Second, similar GDP does not guarantee similar longevity. In 2007, Costa Rica's GDP per capita is approximately $9,645, compared with $9,270 in South Africa. Yet their life expectancies are 78.8 and 49.3 years, respectively: a 29.4-year difference. Hovering identifies the countries behind this large vertical separation. Filtering continents can then help readers see whether these observations resemble other countries in their respective regions. This comparison shows why a country's position relative to the overall pattern deserves attention.

## Follow a country

The supplementary dropdown traces five selected countries through all twelve observations. Select South Africa and hover over successive points. Between 1992 and 2007, its GDP per capita increases by 28.3%, while life expectancy falls from 61.9 to 49.3 years, a decline of 12.5 years. This third pattern distinguishes a cross-country association from a country's trajectory. A 2007-only chart would show the endpoint but conceal the reversal. The selected countries are illustrative cases, not a random subsample or a formal test.

## What can we conclude?

These comparisons are descriptive. They do not estimate the causal effect of GDP on longevity or establish why particular countries differ. National averages conceal inequalities within countries, and five-year observations can miss short-lived changes. The filtered historical sample also excludes countries without complete records. Although the package identifies GDP as inflation-adjusted US dollars, its help page does not specify the price base; I retain its published units and avoid interpreting these values as present-day dollars.

The central takeaway is that GDP per capita provides useful context for health outcomes, but it does not determine them completely. Interactive identification and time comparisons reveal both substantial differences at similar economic levels and trajectories that depart from the overall association.

## Interactive figures and sources

[Open the main interactive chart](../interactive_plot.html) | [Open country trajectories](../country_trajectories.html)

Data: [gapminder R package documentation](https://jennybc.github.io/gapminder/reference/gapminder.html), [Gapminder](https://www.gapminder.org/data/).

[Code, input data and reproducibility evidence](https://github.com/liyujing-byte/blogpost7_interactive_data_visualization).
