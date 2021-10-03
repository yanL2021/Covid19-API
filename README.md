Interacting with APIs: Covid19api
================
Yan Liu
2021/9/30

-   [Requirements](#requirements)
-   [API Interaction Functions](#api-interaction-functions)
    -   [`Find country names`](#find-country-names)
    -   [`Total cases`](#total-cases)
    -   [`New cases`](#new-cases)
    -   [`Average`](#average)
-   [Data Exploration](#data-exploration)

This document is a vignette to show how to retrieve data from an
[API](https://covid19api.com/). To demonstrate, I’ll be interacting with
the API. I’m going to build a few functions to interact with some of the
endpoints and explore some of the data I can retrieve.

# Requirements

To use the functions for interacting with the NHL API, I used the
following packages:

-   [`tidyverse`](https://www.tidyverse.org/): tons of useful features
    for data manipulation and visualization
-   [`jsonlite`](https://cran.r-project.org/web/packages/jsonlite/): API
    interaction

In addition to those packages, I used the following packages in the rest
of the document:

-   [`httr`](https://cran.r-project.org/web/packages/cowplot/index.html):
    extra functionality for `ggplot2`
-   [`rmarkdown`](https://cran.r-project.org/web/packages/imager/):
    loading in images
-   [`lubridate`](https://cran.r-project.org/web/packages/broom/vignettes/broom.html):
    tidying up a regression output for display
-   [`countrycode`](https://cran.r-project.org/web/packages/knitr/index.html):
    displaying tables in a markdown friendly way
-   [`rworldmap`](https://cran.r-project.org/web/packages/imager/):
    loading in images

# API Interaction Functions

Here is where I define the functions to interact with the [Country
Names](https://api.covid19api.com/countries) and [Covid cases
summary](https://api.covid19api.com/summary) as well as some helper
functions.

## `Find country names`

Pattern match of country names. Multiple names can be a input as a
vector.

## `Total cases`

Total confirmed cases and deaths today from selected countries, sorted
by confirmed cases from high to low.

## `New cases`

New cases and death by days in a given period of one country, enter
start and end date as YYYY-MM-DD.

## `Average`

Calculate the average new case number in the past n days from the day of
first case until today. The default n is

# Data Exploration

Now that we can interact with a few of the endpoints of the Covid API,
let’s get some data from them.

Bar plot comparing total cases in different countries
![](README_files/figure-gfm/unnamed-chunk-2-1.png)<!-- -->

Total cases per 1000 people in all countries all over the world

    ## Warning in countrycode_convert(sourcevar = sourcevar, origin = origin, destination = dest, : Some values were not matched unambiguously: AN, XK

draw a world heat map of total confirmed cases per 1000 people

    ## 191 codes from your data successfully matched countries in the map
    ## 1 codes from your data failed to match with a country code in the map
    ## 50 codes from the map weren't represented in your data

![](README_files/figure-gfm/unnamed-chunk-4-1.png)<!-- --> draw a world
heat map of mortality rate

    ## 191 codes from your data successfully matched countries in the map
    ## 1 codes from your data failed to match with a country code in the map
    ## 50 codes from the map weren't represented in your data

![](README_files/figure-gfm/unnamed-chunk-5-1.png)<!-- --> Distribution
of total confirmed cases per 1000 people for each country

    ## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.

    ## Warning: Removed 4 rows containing non-finite values (stat_bin).

![](README_files/figure-gfm/unnamed-chunk-6-1.png)<!-- --> compare new
cases per day in a given period (2021-08-1 to 2021-08-30) among
different countries
![](README_files/figure-gfm/unnamed-chunk-7-1.png)<!-- --> scatter plot
of new cases over a period with 7-day average smooth line in one country
![](README_files/figure-gfm/unnamed-chunk-8-1.png)<!-- --> \# Wrap-Up

To summarize everything I did in this vignette, I built functions to
interact with some of the Covid-19 API endpoints, retrieved some of the
data, and explored it using tables, numerical summaries, and data
visualization.

I found some unsurprising things, like shots per game and shooting
percentage are related to win percentage. I also found some surprising
(to me) things, namely penalty minutes per game has a quadratic
relationship with win percentage.

Most importantly, I hope my code helps you with interacting with APIs!
