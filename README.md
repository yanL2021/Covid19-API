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

``` r
match_country_name <- function (name){
  #get the list of available countries
  countries <- fromJSON("https://api.covid19api.com/countries")
  country_names<-countries$Country
  name_all <- countries[grep(paste(name,collapse="|"), country_names,ignore.case=TRUE),]
  return(name_all)
}
```

## `Total cases`

Total confirmed cases and deaths today from selected countries, sorted
by confirmed cases from high to low.

``` r
summary_total <- function(country = "all"){
     # Get data from the summary endpoint
    summary <- fromJSON("https://api.covid19api.com/summary")
     # Select the data part from JSON
    all <- summary$Countries
    
    if (country[1] != "all"){
   
    # match input country names to get their unique Slug name
    country_slug <- match_country_name(country)$Slug
  
    if(length(country_slug) == 0){
      message <- paste("ERROR: Argument for country was not found.",
                       "Try summary_total('all') to find the country you're looking for.")
      stop(message)
    }
    else {
      # Filter the selected countries
      select_country <- all %>% 
      filter(Slug %in% country_slug) %>% 
      select(Country,TotalConfirmed,TotalDeaths,Date) %>% 
      mutate(Date = as_date(Date)) %>% 
      arrange(desc(TotalConfirmed))
    }
  }
  
  else {
    select_country <- all %>% 
      select(Country,TotalConfirmed,TotalDeaths,Date) %>% 
      mutate(Date = as_date(Date)) %>% 
      arrange(desc(TotalConfirmed))
  }
  return(select_country)
}
```

## `New cases`

New cases and death by days in a given period of one country, enter
start and end date as YYYY-MM-DD.

``` r
new_period <- function(country,start,end){
  
  # match input country names to get their unique Slug name
  country_slug <- match_country_name(country)$Slug
  
  
  # Error message for invalid input of country names
  if(length(country_slug) == 0){
    message <- paste("ERROR: Argument for country was not found. Try summary_total('all') to find the country you're looking for:",
                     )
    stop(message)
  }
  
  # if country name has multiple hits, ask the user select one from the list of possible county names
  else if(length(country_slug) >1){
    message <- paste("ERROR: Argument for country was not unique.",
                     "Please select one from the list:",
                     paste(grep(country, country_names,ignore.case=TRUE,value=TRUE),collapse = '; '))
    stop(message)
  }
  
  else {
    # Get data from the country endpoint
    all_days <- fromJSON(paste("https://api.covid19api.com/total/country", country_slug,sep = "/"))
    
    period <- all_days %>% 
      select(Country, Confirmed, Deaths, Date) %>% 
      mutate(Date = as_date(Date)) %>% 
      filter(Date >= ymd(start)-1  & Date <= end ) %>% 
      mutate(new_case = Confirmed - lag(Confirmed)) %>% 
      mutate(new_death = Deaths - lag(Deaths)) %>% 
      slice(-1L) %>% 
      select(Country,Date,new_case,new_death)
  }

  return(period)
}
```

## `Average`

Calculate the average new case number in the past n days from the day of
first case until today. The default n is

``` r
new_average <- function(country, window=7){
  
  # match input country names to get their unique Slug name
  country_slug <- match_country_name(country)$Slug
  
  # Error message for invalid input of country names
  if(length(country_slug) == 0){
    message <- paste("ERROR: Argument for country was not found. Try summary_total('all') to find the country you're looking for:",
    )
    stop(message)
  }
  
  # if country name has multiple hits, ask the user select one from the list of possible county names
  else if(length(country_slug) >1){
    message <- paste("ERROR: Argument for country was not unique.",
                     "Please select one from the list:",
                     paste(grep(country, country_names,ignore.case=TRUE,value=TRUE),collapse = '; '))
    stop(message)
  }
  
  else {
    # Get data from the country endpoint from day one
    from_dayone <- fromJSON(paste("https://api.covid19api.com/total/dayone/country", country_slug,sep = "/"))
    
    average <- from_dayone  %>% 
      select(Country, Confirmed, Deaths, Date) %>% 
      mutate(Date = as_date(Date)) %>% 
      mutate(new_case_average = (Confirmed - lag(Confirmed,window))/window) %>% 
      mutate(new_death_average = (Deaths - lag(Deaths,window))/window) %>% 
      select(Country,Date,new_case_average,new_death_average) %>% 
      filter(!is.na(new_case_average))
  }
  
  return(average)
}
```

# Data Exploration

Now that we can interact with a few of the endpoints of the Covid API,
let’s get some data from them.

Bar plot comparing total cases in different countries

``` r
ds_total <- summary_total(country=c("United States of America", "Russia","Brazil","United Kingdom"))
p1 <-ggplot(data=ds_total, aes(x=Country, y=TotalConfirmed)) +
  geom_bar(stat="identity")
p1
```

![](README_files/figure-gfm/unnamed-chunk-2-1.png)<!-- -->

Total cases per 1000 people in all countries all over the world

``` r
#get the list of available countries
countries <- fromJSON("https://api.covid19api.com/countries")
# Get population data in 2017 from world bank
pop<-world_bank_pop %>% 
  filter(indicator=='SP.POP.TOTL') %>% 
  select(country,'2017') %>% 
  rename(population='2017')

# Merge with country names from API 
countries_pop <- countries %>% 
  mutate(iso3c = countrycode(countries$ISO2,origin="iso2c",destination = "iso3c")) %>% 
  left_join(pop, by = c("iso3c" = "country"))

# Merge with total cases data
total_all <- summary_total('all')

total_all_pop <- total_all %>% 
  left_join(countries_pop,by="Country") %>% 
  mutate(cases_per1k = TotalConfirmed/population) %>% 
  mutate(mortality=TotalDeaths/TotalConfirmed*100) 
```

draw a world heat map of total confirmed cases per 1000 people

``` r
joinData <- joinCountryData2Map( total_all_pop ,
                                 joinCode = "ISO2",
                                 nameJoinColumn = "ISO2")
```

    ## 191 codes from your data successfully matched countries in the map
    ## 1 codes from your data failed to match with a country code in the map
    ## 50 codes from the map weren't represented in your data

``` r
mapCountryData( joinData, nameColumnToPlot="cases_per1k", addLegend=T )
```

![](README_files/figure-gfm/unnamed-chunk-4-1.png)<!-- --> draw a world
heat map of mortality rate

``` r
joinData <- joinCountryData2Map( total_all_pop ,
                                 joinCode = "ISO2",
                                 nameJoinColumn = "ISO2")
```

    ## 191 codes from your data successfully matched countries in the map
    ## 1 codes from your data failed to match with a country code in the map
    ## 50 codes from the map weren't represented in your data

``` r
mapCountryData( joinData, nameColumnToPlot="mortality", addLegend=T )
```

![](README_files/figure-gfm/unnamed-chunk-5-1.png)<!-- --> Distribution
of total confirmed cases per 1000 people for each country

``` r
p2 <- ggplot(total_all_pop, aes(x=cases_per1k)) + 
  geom_histogram()
p2
```

![](README_files/figure-gfm/unnamed-chunk-6-1.png)<!-- --> compare new
cases per day in a given period (2021-08-1 to 2021-08-30) among
different countries

``` r
start="2021-08-01"
end="2021-08-30"

new_case_country1 <- new_period("France",start,end)
new_case_country2 <- new_period("united kingdom",start,end)
new_case_country3 <- new_period("spain",start,end)

country_list = mget(ls(pattern = "new_case_country"))
new_cases_all<-bind_rows(country_list)

p3 <- ggplot(new_cases_all, aes(x=Country, y=new_case)) + 
  geom_boxplot()
p3
```

![](README_files/figure-gfm/unnamed-chunk-7-1.png)<!-- --> scatter plot
of new cases over a period with 7-day average smooth line in one country

``` r
new_case <- new_case_country2 <- new_period("united kingdom",start="2021-05-01",end="2021-09-01")
new_ave <- new_average("United Kingdom")
new_all <- left_join(new_case,new_ave,by= c("Country", "Date"))


p4 <- ggplot(new_all,aes(x=Date)) +
  geom_point(aes(y=new_case))+
  geom_line(aes(y=new_case_average),colour='red') + 
  xlab("")
p4
```

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
