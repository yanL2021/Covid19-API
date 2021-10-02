Interacting with APIs: Covid19api
================
Yan Liu
2021/9/30

-   [Requirements](#requirements)
-   [API Interaction Functions](#api-interaction-functions)
    -   [`Find country names`](#find-country-names)
    -   [`Total cases`](#total-cases)
    -   [`New cases`](#new-cases)
-   [Data Exploration](#data-exploration)

This document is a vignette to show how to retrieve data from an
[API](https://covid19api.com/). To demonstrate, I’ll be interacting with
the API. I’m going to build a few functions to interact with some of the
endpoints and explore some of the data I can retrieve.

As a note, some of these functions return data at a team level. Some of
the APIs use the franchise ID number, while some use the most recent
team ID to select a specific team’s endpoint. For that reason, if you
use any of my functions I recommend supplying a full team name
(e.g. `"Montréal Canadiens"`). My functions will decode them to the
appropriate ID number.

# Requirements

To use the functions for interacting with the NHL API, I used the
following packages:

-   [`tidyverse`](https://www.tidyverse.org/): tons of useful features
    for data manipulation and visualization
-   [`jsonlite`](https://cran.r-project.org/web/packages/jsonlite/): API
    interaction

In addition to those packages, I used the following packages in the rest
of the document:

-   [`cowplot`](https://cran.r-project.org/web/packages/cowplot/index.html):
    extra functionality for `ggplot2`
-   [`imager`](https://cran.r-project.org/web/packages/imager/): loading
    in images
-   [`broom`](https://cran.r-project.org/web/packages/broom/vignettes/broom.html):
    tidying up a regression output for display
-   [`knitr`](https://cran.r-project.org/web/packages/knitr/index.html):
    displaying tables in a markdown friendly way

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

# Data Exploration

Now that we can interact with a few of the endpoints of the Covid API,
let’s get some data from them.
