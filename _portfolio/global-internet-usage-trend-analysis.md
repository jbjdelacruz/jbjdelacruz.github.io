---
title: 'Global Internet Usage Trend Analysis'
collection: portfolio
permalink: /portfolio/global-internet-usage-trend-analysis
date: 2022-11-14
last_updated: 2025-08-10
excerpt: "Ranking third out of 1,500+ submissions in the [How Much of the World Has Access to the Internet?](https://www.datacamp.com/competitions/xp-competition-2022?entry=82885366-7c68-4c66-a51d-8c395474b4a7) competition, this report analyzes World Bank data from 1990 to 2019 to investigate global internet accessibility. It highlights countries and regions by usage rates and total users and reveals a strong positive correlation between usage and broadband subscriptions."
venue: 'DataCamp'
categories:
  - R
  - Exploratory
slidesurl: []
images:
  - '/files/global-internet-usage-trend-analysis/images/page-1.png'
  - image: '/files/global-internet-usage-trend-analysis/images/page-2.png'
    link:  'https://www.datacamp.com/competitions/xp-competition-2022?entry=82885366-7c68-4c66-a51d-8c395474b4a7'
# link: 'https://www.datacamp.com/datalab/w/82885366-7c68-4c66-a51d-8c395474b4a7'
# url: 'https://www.datacamp.com/datalab/w/82885366-7c68-4c66-a51d-8c395474b4a7'
thumbnail: '/images/projects/project2-cover.png'
featured: false
doc_type: 'Full Report'
tableau:
  id: 'viz1759080202282'
  url: 'https://public.tableau.com/views/GlobalInternetAccessibility/Dashboard'
  static_img: 'https://public.tableau.com/static/images/Gl/GlobalInternetAccessibility/Dashboard/1.png'
  name: 'GlobalInternetAccessibility/Dashboard'
  width: 1366
  height: 795
---

# Global Internet Usage Trend Analysis

{% include tableau.html tableau=page.tableau %}
This map illustrates the magnitudes of internet usage across the world, represented by the percentage of a population that accessed the Internet during the last quarter of 2019.

## 1. Introduction 
### 1.1. Objectives
This report presents the state of internet accessibility across the world by answering these specific questions:

1. What are the **top five (5) countries** with the **highest internet use** (by population share)? How many **people had internet access** in those countries in **2019**
2. What are the **top five (5) countries** with the **highest internet use** for each of the following **regions**: **Africa Eastern and Southern**, **Africa Western and Central**, **Latin America & Caribbean**, **East Asia & Pacific**, **South Asia**, **North America**, and **European Union**? How do we **describe** these regions' **internet usage over time**?
3. What are the **top five (5) countries** with the **most internet users**?
4. What is the **correlation** between **internet usage** (population share) and **broadband subscriptions** for **2019**?

### 1.2. Libraries & Functions

```R
# Load required packages
library(tidyverse)
library(dplyr)
library(ggplot2)
library(scales)
library(scales) # used for percentage values
library(countrycode) # identify the region of a country

# Create a function for plotting time series in ggplot
plot_series <- function(
    data = NULL,
    x = NULL,
    xlabs = "",
    y = NULL,
    ylabs = "",
    group = NULL,
    title = "",
    title.s = 10,
    by = 10,
    colors = NULL
) {
    
    # Plot
    p <- data %>%
        ggplot(aes(x = !!sym(x), 
                   y = !!sym(y),
                   group = !!sym(group))) + 
        	geom_line(aes(color = !!sym(group)),
                    	  linewidth = 0.65) +
        	geom_point(aes(color = !!sym(group)), 
                           size = 0) +
        	theme(legend.position = "top",
                  legend.justification = -0.12,
                  legend.direction = "horizontal",
                  legend.key.size = unit(0, 'pt'),
                  legend.text = element_text(margin = margin(r = 5, unit = "pt"),
                                             color = "#65707C"),
                  legend.title = element_blank(),
                  legend.key = element_blank(),
                  axis.title = element_text(color = "#65707C",
                                            face = "bold"),
                  axis.text = element_text(color = "#65707C"),
                  axis.line = element_line(colour = "grey",
                                           linewidth = 0.5),
                  panel.grid.major = element_line(color = "grey",
                                                  linetype = "dashed",
                                                  linewidth = 0.25),
                  panel.background = element_blank(),
                  plot.title = element_text(color = "#65707C",
                                            hjust = 0.5,
                                            size = title.s,
                                            face = "bold")
                 ) +
        	labs(x = paste0("\n",xlabs), y = paste0(ylabs,"\n")) +
        	ggtitle(paste0("\n",title,"\n")) +
        	scale_x_continuous(expand = c(0.02, 0),
    						   limits = c(min(data[x]), 2019), 
    						   breaks = seq(min(data[x]), 2019, by = 4)
            ) +
        	scale_y_continuous(expand = c(0, 0),
    						   limits = c(min(data[y]), max(data[y])+4), 
    						   breaks = seq(min(data[y]), max(data[y]+4), by = by)
            ) +
            guides(color = guide_legend(
                       override.aes = list(
                				 shape = 15,
                				 size = 4,
                                 linetype = "blank"
                       )
                   )
            )
    
    if (!is.null(colors)) {
        p <- p + scale_color_manual(values = colors)    
    }

    print(p)
}

# Create a function for plotting bar graphs in ggplot
plot_bar <- function(
    data = NULL,
    group = "",
    xlabs = "",
    num = "",
    ylabs = "",
    title = "",
    title.s = 10
) {
    ggplot(data, aes(y = fct_reorder(!!sym(group), !!sym(num)), x = !!sym(num))) + 
    geom_col(fill = "#6568A0") +
	#coord_flip() +
	geom_text(aes(label = comma_format()(!!sym(num)), y = !!sym(group), x = !!sym(num)),
              hjust = -0.1,
              size = 3.0
    ) +
	theme_minimal() +
	theme(panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          plot.title = element_text(face = "bold", size = title.s)
    ) +
    labs(x = paste0("\n",xlabs), y = paste0(ylabs,"\n")) +
    ggtitle(paste0("\n",title,"\n")) +
	scale_x_continuous(labels = scales::label_number(scale_cut = cut_short_scale()),
                       expand = expansion(mult = c(0.05, 0.30))
    )
}
```

### 1.3. Datasets
The following datasets are part of **[The World Bank's World Development Indicators (WDI)](https://databank.worldbank.org/source/world-development-indicators).**

```R
# Read data from CSV files
internet <- read_csv('data/internet.csv', show_col_types = FALSE)
people <- read_csv('data/people.csv', show_col_types = FALSE)
broadband <- read_csv('data/broadband.csv', show_col_types = FALSE)
```

#### 1.3.1. Internet

|Variable        |Description	                                                                        |
|:---------------|:-------------------------------------------------------------------------------------|                
| *Entity*         | Name of the country, region, or group                                                |
| *Code*           | Unique id for the country (null for other entities)                                  |
| *Year*           | Year from 1990 to 2019                                                               |
| *Internet_Usage* | Share of the entity's population who have used the internet in the last three months |

```R
# View the 'internet' dataset
head(internet)
tail(internet)
```

<table class="dataframe">
<!-- <caption>A tibble: 6 × 4</caption> -->
<thead>
	<tr><th scope=col>Entity</th><th scope=col>Code</th><th scope=col>Year</th><th scope=col>Internet_Usage</th></tr>
	<!-- <tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th></tr> -->
</thead>
<tbody>
	<tr><td>Afghanistan</td><td>AFG</td><td>1990</td><td>0</td></tr>
	<tr><td>Afghanistan</td><td>AFG</td><td>1991</td><td>0</td></tr>
	<tr><td>Afghanistan</td><td>AFG</td><td>1992</td><td>0</td></tr>
	<tr><td>Afghanistan</td><td>AFG</td><td>1993</td><td>0</td></tr>
	<tr><td>Afghanistan</td><td>AFG</td><td>1994</td><td>0</td></tr>
	<tr><td>Afghanistan</td><td>AFG</td><td>1995</td><td>0</td></tr>
</tbody>
</table>

<table class="dataframe">
<!-- <caption>A tibble: 6 × 4</caption> -->
<thead>
	<tr><th scope=col>Entity</th><th scope=col>Code</th><th scope=col>Year</th><th scope=col>Internet_Usage</th></tr>
	<!-- <tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th></tr> -->
</thead>
<tbody>
	<tr><td>Zimbabwe</td><td>ZWE</td><td>2012</td><td>12.00000</td></tr>
	<tr><td>Zimbabwe</td><td>ZWE</td><td>2013</td><td>15.50000</td></tr>
	<tr><td>Zimbabwe</td><td>ZWE</td><td>2014</td><td>16.36474</td></tr>
	<tr><td>Zimbabwe</td><td>ZWE</td><td>2015</td><td>22.74282</td></tr>
	<tr><td>Zimbabwe</td><td>ZWE</td><td>2016</td><td>23.11999</td></tr>
	<tr><td>Zimbabwe</td><td>ZWE</td><td>2017</td><td>27.05549</td></tr>
</tbody>
</table>

#### 1.3.2. People

|Variable                |Description	                                                                                     |
|:-----------------------|:--------------------------------------------------------------------------------------------------|     
| *Entity*  | Name of the country, region, or group                                                                   |
| *Code*    | Unique id for the country (null for other entities)                                                     |
| *Year*    | Year from 1990 to 2020                                                                                  |
| *Users*   | Number of people who have used the internet in the last three months for that country, region, or group |


```R
# View the 'people' dataset
head(people)
tail(people)
```

<table class="dataframe">
<!-- <caption>A tibble: 6 × 4</caption> -->
<thead>
	<tr><th scope=col>Entity</th><th scope=col>Code</th><th scope=col>Year</th><th scope=col>Users</th></tr>
	<!-- <tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th></tr> -->
</thead>
<tbody>
	<tr><td>Afghanistan</td><td>AFG</td><td>1990</td><td>0</td></tr>
	<tr><td>Afghanistan</td><td>AFG</td><td>1991</td><td>0</td></tr>
	<tr><td>Afghanistan</td><td>AFG</td><td>1992</td><td>0</td></tr>
	<tr><td>Afghanistan</td><td>AFG</td><td>1993</td><td>0</td></tr>
	<tr><td>Afghanistan</td><td>AFG</td><td>1994</td><td>0</td></tr>
	<tr><td>Afghanistan</td><td>AFG</td><td>1995</td><td>0</td></tr>
</tbody>
</table>

<table class="dataframe">
<!-- <caption>A tibble: 6 × 4</caption> -->
<thead>
	<tr><th scope=col>Entity</th><th scope=col>Code</th><th scope=col>Year</th><th scope=col>Users</th></tr>
	<!-- <tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th></tr> -->
</thead>
<tbody>
	<tr><td>Zimbabwe</td><td>ZWE</td><td>2015</td><td>3219232</td></tr>
	<tr><td>Zimbabwe</td><td>ZWE</td><td>2016</td><td>3341464</td></tr>
	<tr><td>Zimbabwe</td><td>ZWE</td><td>2017</td><td>3599269</td></tr>
	<tr><td>Zimbabwe</td><td>ZWE</td><td>2018</td><td>3763048</td></tr>
	<tr><td>Zimbabwe</td><td>ZWE</td><td>2019</td><td>3854006</td></tr>
	<tr><td>Zimbabwe</td><td>ZWE</td><td>2020</td><td>4591211</td></tr>
</tbody>
</table>

#### 1.3.3. Broadband

|Variable                |Description	                                                                                     |
|:-----------------------|:--------------------------------------------------------------------------------------------------|     
| *Entity*                | Name of the country, region, or group                                                             |
| *Code*                   | Unique id for the country (null for other entities)                                               |
| *Year*                   | Year from 1998 to 2020                                                                            |
| *Broadband_Subscriptions* | Number of fixed subscriptions to high-speed internet at downstream speeds >= 256 kbit/s for that country, region, or group |

```R
# View the 'broadband' dataset
head(broadband)
tail(broadband)
```

<table class="dataframe">
<!-- <caption>A tibble: 6 × 4</caption> -->
<thead>
	<tr><th scope=col>Entity</th><th scope=col>Code</th><th scope=col>Year</th><th scope=col>Broadband_Subscriptions</th></tr>
	<!-- <tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th></tr> -->
</thead>
<tbody>
	<tr><td>Afghanistan</td><td>AFG</td><td>2004</td><td>0.000808843</td></tr>
	<tr><td>Afghanistan</td><td>AFG</td><td>2005</td><td>0.000857557</td></tr>
	<tr><td>Afghanistan</td><td>AFG</td><td>2006</td><td>0.001891571</td></tr>
	<tr><td>Afghanistan</td><td>AFG</td><td>2007</td><td>0.001844982</td></tr>
	<tr><td>Afghanistan</td><td>AFG</td><td>2008</td><td>0.001803604</td></tr>
	<tr><td>Afghanistan</td><td>AFG</td><td>2009</td><td>0.003521770</td></tr>
</tbody>
</table>

<table class="dataframe">
<!-- <caption>A tibble: 6 × 4</caption> -->
<thead>
	<tr><th scope=col>Entity</th><th scope=col>Code</th><th scope=col>Year</th><th scope=col>Broadband_Subscriptions</th></tr>
	<!-- <tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th></tr> -->
</thead>
<tbody>
	<tr><td>Zimbabwe</td><td>ZWE</td><td>2015</td><td>1.187053</td></tr>
	<tr><td>Zimbabwe</td><td>ZWE</td><td>2016</td><td>1.217633</td></tr>
	<tr><td>Zimbabwe</td><td>ZWE</td><td>2017</td><td>1.315694</td></tr>
	<tr><td>Zimbabwe</td><td>ZWE</td><td>2018</td><td>1.406322</td></tr>
	<tr><td>Zimbabwe</td><td>ZWE</td><td>2019</td><td>1.395818</td></tr>
	<tr><td>Zimbabwe</td><td>ZWE</td><td>2020</td><td>1.368916</td></tr>
</tbody>
</table>

## 2. Results and Discussion
### 2.1. Countries with the Highest Internet Use by Population Share
Based on the most recent **2019 data**, **four** of the **top five countries** with the highest internet usage by population share are located in the [**Middle East**](https://worldpopulationreview.com/country-rankings/middle-east-countries). These countries are **Bahrain, Qatar, Kuwait, and the United Arab Emirates (UAE)**.

```R
# Top 5 countries with the highest internet use by population share
top_five_internet_use <- internet %>%
    group_by(Entity) %>% 
	filter(Year == 2019) %>%
    arrange(desc(Internet_Usage)) %>%
    ungroup() %>%
    top_n(5, Internet_Usage) %>%
	mutate(Internet_Usage = label_percent(accuracy = 0.01)(Internet_Usage/100)) %>%
	select(c("Entity", "Internet_Usage")) %>%
	rename(Country = Entity)
```

<table class="dataframe">
<!-- <caption>A tibble: 5 × 2</caption> -->
<thead>
	<tr><th scope=col>Country</th><th scope=col>Internet_Usage</th></tr>
	<!-- <tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th></tr> -->
</thead>
<tbody>
	<tr><td>Bahrain             </td><td>99.70%</td></tr>
	<tr><td>Qatar               </td><td>99.65%</td></tr>
	<tr><td>Kuwait              </td><td>99.54%</td></tr>
	<tr><td>United Arab Emirates</td><td>99.15%</td></tr>
	<tr><td>Denmark             </td><td>98.05%</td></tr>
</tbody>
</table>

```R
# Top 5 countries with the highest internet use by population share
top_five_internet_use <- internet %>%
    group_by(Entity) %>% 
	filter(Year == 2019) %>%
    arrange(desc(Internet_Usage)) %>%
    ungroup() %>%
    top_n(5, Internet_Usage) %>%
	mutate(Internet_Usage = label_percent(accuracy = 0.01)(Internet_Usage/100)) %>%
	select(c("Entity", "Internet_Usage")) %>%
	rename(Country = Entity)

# Subset data for plot
plotData_top_five_internet_use <- internet %>% filter(Entity %in% top_five_internet_use$Country)

# Plot time series
plot_series(
    data = plotData_top_five_internet_use,
    x = "Year",
    xlabs = "Year",
    y = "Internet_Usage",
    ylabs = "Internet Usage (%)",
    group = "Entity",
    title = "Internet Usage Trends in Top Countries, 2019",
    title.s = 12,
    colors = c("#443A83", "#31688E", "#21918D", "#35B779", "#8FD744")
)
```

![Internet Usage Trends in Top Countries, 2019](/files/global-internet-usage-trend-analysis/images/notebook_7_1.png){: .align-center}

### 2.2. Top Countries' Number of Internet Users, 2019
Among these countries, the **United Arab Emirates (UAE)** had the **highest number of internet users** in 2019.

```R
# Number of internet users in 2019 of the countries with the highest internet use by population share
top_five_internet_users_2019 <- people %>% 
  filter(Entity %in% top_five_internet_use$Country, Year == 2019) %>%
  arrange(desc(Users)) %>% 
  mutate(Users = comma_format()(Users)) %>%
  select(c("Entity", "Users")) %>%
  rename(Country = Entity, Number_of_Internet_Users = Users)

# Subset data for plot
barData_top_five_internet_users_2019 <- people %>%
  filter(Entity %in% top_five_internet_users_2019$Country, Year == 2019) %>%
  arrange(desc(Users)) %>%
  select(c("Entity", "Users"))

# Plot bar graph
plot_bar(
    data = barData_top_five_internet_users_2019, #NULL,
    group = "Entity",
    xlabs = "Number of Internet Users",
    num = "Users",
    ylabs ="",
    title = "Top Countries by Number of Internet Users, 2019",
    title.s = 12
)
```

![Top Countries by Number of Internet Users, 2019](/files/global-internet-usage-trend-analysis/images/notebook_9_0.png){: .align-center}
    
### 2.3. Regional Leaders in Internet Usage

- The countries with the highest internet usage by population share in their respective regions are **Seychelles** (Africa Eastern and Southern), **Cape Verde** (Africa Western and Central), **Aruba** (Latin America & Caribbean), **South Korea** (East Asia & Pacific), **Maldives** (South Asia), **Bermuda** (North America), and **Luxembourg** (European Union).

- Notably, these countries are **generally not the largest** in terms of **[land area](https://www.worldometers.info/geography/largest-countries-in-the-world/)** when compared to others.

_**Note**: The **2017 data** was used for this comparison because it was the **most recent year** with the **most available country data**._


```R
# The 'region' destination (7 Regions as defined in the World Bank Development Indicators) was used for Latin America & Caribbean, East Asia & Pacific, South Asia, and North America.
code_region <- distinct(data.frame( Code = (internet %>% filter(Code != 'null'))$Code, 
               		Region = countrycode((internet %>% filter(Code != 'null'))$Code, 
                  		'wb', 'region')), Code, .keep_all = TRUE) %>% 
				  		filter(Code != 'OWID_WRL') %>%
			     		mutate(Region = ifelse(Code == 'OWID_KOS', 'Europe & Central Asia', Region)) 

# The 'region23' destination (23 Regions as used to be in the World Bank Development Indicators) was used for Africa Eastern and Southern and Africa Western and Central.
code_region23 <- distinct(data.frame(Code = (internet %>% filter(Code != 'null'))$Code, 
                 	Region = countrycode((internet %>% filter(Code != 'null'))$Code, 
                  		'wb', 'region23')), Code, .keep_all = TRUE) %>%
				  		filter(Code != 'OWID_WRL') %>%
			     		mutate(Region = ifelse(Code == 'OWID_KOS', 'Southern Europe', Region)) 

# Join 'Code' from 'internet' to 'code_region' and 'code_region23' tables to identify a country's region
internet_with_region <- merge(internet, code_region, by = 'Code', all = TRUE)
internet_with_region23 <- merge(internet, code_region23, by = 'Code', all = TRUE)

# The country Kosovo was not matched**, so its regions(https://data.worldbank.org/country/XK) was inputted manually. 
# The row with a Code = 'OWID_WRL' for World was excluded in the analysis.
# Since EU codes are incompatible, a different coding approach was used.
```

#### 2.3.1. Africa Eastern and Southern

```R
# Top five countries
top_five_internet_use_aes <- internet_with_region23 %>%
    group_by(Entity) %>% 
  filter(Year == 2017, Region %in% c('Eastern Africa', 'Southern Africa')) %>%
    arrange(desc(Internet_Usage)) %>%
    ungroup() %>%
    top_n(5, Internet_Usage) %>%
  mutate(Internet_Usage = label_percent(accuracy = 0.01)(Internet_Usage/100)) %>%
  select(c("Entity", "Internet_Usage")) %>%
  rename(Country = Entity)
```

<table class="dataframe">
<!-- <caption>A tibble: 5 × 2</caption> -->
<thead>
  <tr><th scope=col>Country</th><th scope=col>Internet_Usage</th></tr>
  <!-- <tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th></tr> -->
</thead>
<tbody>
  <tr><td>Seychelles  </td><td>58.77%</td></tr>
  <tr><td>South Africa</td><td>56.17%</td></tr>
  <tr><td>Djibouti    </td><td>55.68%</td></tr>
  <tr><td>Mauritius   </td><td>55.40%</td></tr>
  <tr><td>Botswana    </td><td>41.41%</td></tr>
</tbody>
</table>

```R
# Subset data for plot
plotData_top_five_aes <- internet %>% filter(Entity %in% top_five_internet_use_aes$Country) 

# Plot time series
plot_series(
    data = plotData_top_five_aes,
    x = "Year",
    xlabs = "\nYear",
    y = "Internet_Usage",
    ylabs = "Internet Usage (%)\n",
    group = "Entity",
    title = "Internet Usage Trends in Top East and South African Countries, 2017",
    title.s = 12,
    by = 5,
    colors = c("#443A83", "#31688E", "#21918D", "#35B779", "#8FD744")
)
```

![Internet Usage Trends in Top East and South African Countries, 2017](/files/global-internet-usage-trend-analysis/images/notebook_13_1.png){: .align-center}

#### 2.3.2. Africa Western and Central 

```R
# Top five countries
top_five_internet_use_awc <- internet_with_region23 %>%
    group_by(Entity) %>% 
  filter(Year == 2017, Region %in% c('Western Africa', 'Middle Africa')) %>%
    arrange(desc(Internet_Usage)) %>%
    ungroup() %>%
    top_n(5, Internet_Usage) %>%
  mutate(Internet_Usage = label_percent(accuracy = 0.01)(Internet_Usage/100)) %>%
  select(c("Entity", "Internet_Usage")) %>%
  rename(Country = Entity)
```

<table class="dataframe">
<!-- <caption>A tibble: 5 × 2</caption> -->
<thead>
  <tr><th scope=col>Country</th><th scope=col>Internet_Usage</th></tr>
  <!-- <tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th></tr> -->
</thead>
<tbody>
  <tr><td>Cape Verde           </td><td>57.16%</td></tr>
  <tr><td>Gabon                </td><td>50.32%</td></tr>
  <tr><td>Cote d'Ivoire        </td><td>43.84%</td></tr>
  <tr><td>Ghana                </td><td>37.88%</td></tr>
  <tr><td>Sao Tome and Principe</td><td>29.93%</td></tr>
</tbody>
</table>

```R
# Subset data for plot
plotData_top_five_awc <- internet %>% filter(Entity %in% top_five_internet_use_awc$Country) 

# Plot time series
plot_series(
    data = plotData_top_five_awc,
    x = "Year",
    xlabs = "Year",
    y = "Internet_Usage",
    ylabs = "Internet Usage (%)",
    group = "Entity",
    title = "Internet Usage Trends in Top West and Central African Countries, 2017",
    title.s = 12,
    by = 5,
    colors = c("#443A83", "#31688E", "#21918D", "#35B779", "#8FD744")
)
```
    
![Internet Usage Trends in Top West and Central African Countries, 2017](/files/global-internet-usage-trend-analysis/images/notebook_15_1.png){: .align-center}

#### 2.3.3. Latin America & Caribbean 

```R
# Top five countries
top_five_internet_use_lac <- internet_with_region %>%
    distinct(Internet_Usage, .keep_all = TRUE) %>%
    group_by(Entity) %>% 
	filter(Year == 2017, Region == 'Latin America & Caribbean') %>%
    arrange(desc(Internet_Usage)) %>%
    ungroup() %>%
    top_n(5, Internet_Usage) %>%
	mutate(Internet_Usage = label_percent(accuracy = 0.01)(Internet_Usage/100)) %>%
	select(c("Entity", "Internet_Usage")) %>%
	rename(Country = Entity)
```

<table class="dataframe">
<!-- <caption>A tibble: 5 × 2</caption> -->
<thead>
	<tr><th scope=col>Country</th><th scope=col>Internet_Usage</th></tr>
	<!-- <tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th></tr> -->
</thead>
<tbody>
	<tr><td>Aruba                </td><td>97.17%</td></tr>
	<tr><td>Chile                </td><td>82.33%</td></tr>
	<tr><td>Barbados             </td><td>81.76%</td></tr>
	<tr><td>Cayman Islands       </td><td>81.07%</td></tr>
	<tr><td>Saint Kitts and Nevis</td><td>80.71%</td></tr>
</tbody>
</table>

```R
# Subset data for plot
plotData_top_five_lac <- internet %>% filter(Entity %in% top_five_internet_use_lac$Country) 

# Plot time series
plot_series(
    data = plotData_top_five_lac,
    x = "Year",
    xlabs = "Year",
    y = "Internet_Usage",
    ylabs = "Internet Usage (%)",
    group = "Entity",
    title = "Internet Usage Trends in Top Latin American and Caribbean Countries, 2017",
    title.s = 12,
    by = 10,
    colors = c("#443A83", "#31688E", "#21918D", "#35B779", "#8FD744")
)
```

![Internet Usage Trends in Top Latin American and Caribbean Countries, 2017](/files/global-internet-usage-trend-analysis/images/notebook_17_1.png){: .align-center}

#### 2.3.4. East Asia & Pacific 

```R
# Top five countries
top_five_internet_use_eap <- internet_with_region %>%
    distinct(Internet_Usage, .keep_all = TRUE) %>%
    group_by(Entity) %>% 
  filter(Year == 2017, Region == 'East Asia & Pacific') %>%
    arrange(desc(Internet_Usage)) %>%
    ungroup() %>%
    top_n(5, Internet_Usage) %>%
  mutate(Internet_Usage = label_percent(accuracy = 0.01)(Internet_Usage/100)) %>%
  select(c("Entity", "Internet_Usage")) %>%
  rename(Country = Entity)
```

<table class="dataframe">
<!-- <caption>A tibble: 5 × 2</caption> -->
<thead>
  <tr><th scope=col>Country</th><th scope=col>Internet_Usage</th></tr>
  <!-- <tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th></tr> -->
</thead>
<tbody>
  <tr><td>South Korea</td><td>95.07%</td></tr>
  <tr><td>Brunei     </td><td>94.87%</td></tr>
  <tr><td>Japan      </td><td>91.73%</td></tr>
  <tr><td>New Zealand</td><td>90.81%</td></tr>
  <tr><td>Hong Kong  </td><td>89.42%</td></tr>
</tbody>
</table>

```R
# Subset data for plot
plotData_top_five_eap <- internet %>% filter(Entity %in% top_five_internet_use_eap$Country) 

# Plot time series
plot_series(
    data = plotData_top_five_eap,
    x = "Year",
    xlabs = "Year",
    y = "Internet_Usage",
    ylabs = "Internet Usage (%)",
    group = "Entity",
    title = "Internet Usage Trends in Top East Asian and Pacific Countries, 2017",
    title.s = 12,
    by = 10,
    colors = c("#443A83", "#31688E", "#21918D", "#35B779", "#8FD744")
)
```

![Internet Usage Trends in Top East Asian and Pacific Countries, 2017](/files/global-internet-usage-trend-analysis/images/notebook_19_1.png){: .align-center}

#### 2.3.5. South Asia 

```R
# Top five countries
top_five_internet_use_sa <- internet_with_region %>%
    distinct(Internet_Usage, .keep_all = TRUE) %>%
    group_by(Entity) %>% 
  filter(Year == 2017, Region == 'South Asia') %>%
    arrange(desc(Internet_Usage)) %>%
    ungroup() %>%
    top_n(5, Internet_Usage) %>%
  mutate(Internet_Usage = label_percent(accuracy = 0.01)(Internet_Usage/100)) %>%
  select(c("Entity", "Internet_Usage")) %>%
  rename(Country = Entity)
```

<table class="dataframe">
<!-- <caption>A tibble: 5 × 2</caption> -->
<thead>
  <tr><th scope=col>Country</th><th scope=col>Internet_Usage</th></tr>
  <!-- <tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th></tr> -->
</thead>
<tbody>
  <tr><td>Maldives   </td><td>63.19%</td></tr>
  <tr><td>Sri Lanka  </td><td>34.11%</td></tr>
  <tr><td>Nepal      </td><td>21.40%</td></tr>
  <tr><td>Pakistan   </td><td>17.11%</td></tr>
  <tr><td>Afghanistan</td><td>11.45%</td></tr>
</tbody>
</table>


```R
# Subset data for plot
plotData_top_five_sa <- internet %>% filter(Entity %in% top_five_internet_use_sa$Country) 

# Plot time series
plot_series(
    data = plotData_top_five_sa,
    x = "Year",
    xlabs = "Year",
    y = "Internet_Usage",
    ylabs = "Internet Usage (%)",
    group = "Entity",
    title = "Internet Usage Trends in Top South Asian Countries, 2017",
    title.s = 12,
    by = 5,
    colors = c("#443A83", "#31688E", "#21918D", "#35B779", "#8FD744")
)
```

![Internet Usage Trends in Top South Asian Countries, 2017](/files/global-internet-usage-trend-analysis/images/notebook_21_1.png){: .align-center}
    
#### 2.3.6. North America

```R
# Top countries
top_internet_use_na <- internet_with_region %>%
    distinct(Internet_Usage, .keep_all = TRUE) %>%
    group_by(Entity) %>% 
  filter(Year == 2017, Region == 'North America') %>%
    arrange(desc(Internet_Usage)) %>%
    ungroup() %>%
    top_n(5, Internet_Usage) %>%
  mutate(Internet_Usage = label_percent(accuracy = 0.01)(Internet_Usage/100)) %>%
  select(c("Entity", "Internet_Usage")) %>%
  rename(Country = Entity)
```

<table class="dataframe">
<!-- <caption>A tibble: 3 × 2</caption> -->
<thead>
  <tr><th scope=col>Country</th><th scope=col>Internet_Usage</th></tr>
  <!-- <tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th></tr> -->
</thead>
<tbody>
  <tr><td>Bermuda      </td><td>98.37%</td></tr>
  <tr><td>Canada       </td><td>92.70%</td></tr>
  <tr><td>United States</td><td>87.27%</td></tr>
</tbody>
</table>

```R
# Subset data for plot
plotData_top_na <- internet %>% filter(Entity %in% top_internet_use_na$Country) 

# Plot time series
plot_series(
    data = plotData_top_na,
    x = "Year",
    xlabs = "Year",
    y = "Internet_Usage",
    ylabs = "Internet Usage (%)",
    group = "Entity",
    title = "Internet Usage Trends in Top North American Countries, 2017",
    title.s = 12,
    by = 10,
    colors = c("#443A83", "#21918D", "#8FD744")
)
```

![Internet Usage Trends in Top North American Countries, 2017](/files/global-internet-usage-trend-analysis/images/notebook_23_1.png){: .align-center}

#### 2.3.7. European Union

```R
# EU country codes
EUCodes <- data.frame(
  Code = c('AUT', 'BEL', 'BGR', 'HRV', 'CYP', 'CZE', 'DNK', 'EST', 'FIN', 'FRA', 'DEU', 'GRC', 'HUN',	'IRL', 'ITA', 'LVA', 'LTU', 'LUX', 'MLT', 'NLD', 'POL', 'PRT', 'ROU', 'SVK', 'SVN', 'ESP', 'SWE'),
  Region = replicate(27, 'European Union')
)

# https://www23.statcan.gc.ca/imdb/p3VD.pl?Function=getVD&TVD=141329
# This list was used for the country codes. As of writing, there are only twenty-seven (27) members (https://european-union.europa.eu/principles-countries-history/country-profiles_en), which means that United Kingdom was excluded from after formally leaving in 2020 (https://www.ema.europa.eu/en/about-us/history-ema/brexit-united-kingdoms-withdrawal-european-union).

# Join 'Code' from the internet and EUCodes tables to identify a country's region 
internet_eu <- merge(internet, EUCodes, by = 'Code', all = TRUE) %>%
  filter(Region == 'European Union')

# Top five countries
top_five_internet_use_eu <- internet_eu %>%
    distinct(Internet_Usage, .keep_all = TRUE) %>%
    group_by(Entity) %>% 
  filter(Year == 2017, Region == 'European Union') %>%
    arrange(desc(Internet_Usage)) %>%
    ungroup() %>%
    top_n(5, Internet_Usage) %>%
  mutate(Internet_Usage = label_percent(accuracy = 0.01)(Internet_Usage/100)) %>%
  select(c("Entity", "Internet_Usage")) %>%
  rename(Country = Entity)
```

<table class="dataframe">
<!-- <caption>A tibble: 5 × 2</caption> -->
<thead>
  <tr><th scope=col>Country</th><th scope=col>Internet_Usage</th></tr>
  <!-- <tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th></tr> -->
</thead>
<tbody>
  <tr><td>Luxembourg </td><td>97.36%</td></tr>
  <tr><td>Denmark    </td><td>97.10%</td></tr>
  <tr><td>Netherlands</td><td>93.20%</td></tr>
  <tr><td>Sweden     </td><td>93.01%</td></tr>
  <tr><td>Estonia    </td><td>88.10%</td></tr>
</tbody>
</table>

```R
# Subset data for plot
plotData_top_five_eu <- internet %>% filter(Entity %in% top_five_internet_use_eu$Country) 

# Plot time series
plot_series(
    data = plotData_top_five_eu,
    x = "Year",
    xlabs = "Year",
    y = "Internet_Usage",
    ylabs = "Internet Usage (%)",
    group = "Entity",
    title = "Internet Usage Trends in Top European Union Countries, 2017",
    title.s = 12,
    by = 10,
    colors = c("#443A83", "#31688E", "#21918D", "#35B779", "#8FD744")
)
```

![Internet Usage Trends in Top European Union Countries, 2017](/files/global-internet-usage-trend-analysis/images/notebook_25_1.png){: .align-center}

### 2.4. Internet Usage by Region

```R
# Top five countries per region
highlights <- rbind(
    top_five_internet_use_aes %>% mutate(Region="Africa Eastern and Southern"),
    top_five_internet_use_awc %>% mutate(Region="Africa Western and Central"),
    top_five_internet_use_lac %>% mutate(Region="Latin America & Caribbean"),
    top_five_internet_use_eap %>% mutate(Region="East Asia & Pacific"), 
    top_five_internet_use_sa %>% mutate(Region="South Asia"),
    top_three_internet_use_na %>% mutate(Region="North America"),
    top_five_internet_use_eu %>% mutate(Region="European Union")
)

# Top country per region
top_countries <- highlights %>%
    group_by(Region) %>%
    top_n(1, Internet_Usage)

# Internet usages of regions of interest
internet_regionsOfInterest <- rbind(
    internet_with_region %>% 
      filter(Region %in% c('Latin America & Caribbean', 
                             'East Asia & Pacific', 
                             'South Asia', 
                             'North America')),
    internet_with_region23 %>% 
      filter(Region %in% c('Eastern Africa', 
                             'Southern Africa', 
                             'Western Africa',  
                             'Middle Africa')) %>%
        mutate(Region = ifelse(Region %in% c('Eastern Africa','Southern Africa'),
                                'Africa Eastern and Southern', 'Africa Western and Central')),
    internet_eu
)

# Most recent data for the 'Africa Western and Central' region
most_recent_awc <- internet %>%
  filter(Year == 2015, Entity == 'Africa Western and Central')

# Seven regions' internet usages in 2017
internetUsage_regions <- internet %>%
  filter(Year == 2017, Entity %in% internet_regionsOfInterest$Region) %>%
  bind_rows(most_recent_awc) %>%
  mutate(Internet_Usage = label_percent(accuracy = 0.01)(Internet_Usage/100)) %>%
  select(c("Entity", "Internet_Usage")) %>%
  rename (Region = Entity) %>%
  arrange(desc(Internet_Usage))
```

<table class="dataframe">
<!-- <caption>A tibble: 7 × 2</caption> -->
<thead>
  <tr><th scope=col>Region</th><th scope=col>Internet_Usage</th></tr>
  <!-- <tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th></tr> -->
</thead>
<tbody>
  <tr><td>North America              </td><td>87.83%</td></tr>
  <tr><td>European Union             </td><td>78.68%</td></tr>
  <tr><td>Latin America & Caribbean  </td><td>62.47%</td></tr>
  <tr><td>East Asia & Pacific        </td><td>54.93%</td></tr>
  <tr><td>South Asia                 </td><td>29.50%</td></tr>
  <tr><td>Africa Western and Central </td><td>25.57%</td></tr>
  <tr><td>Africa Eastern and Southern</td><td>21.28%</td></tr>
</tbody>
</table>

```R
# Subset data for plot
plotData_region_internet <- internet %>% filter(Entity %in% internet_regionsOfInterest$Region)

# Plot time series
plot_series(
    data = plotData_region_internet,
    x = "Year",
    xlabs = "Year",
    y = "Internet_Usage",
    ylabs = "Internet Usage (in %)",
    group = "Entity",
    title = "Internet Usage Trends in Seven Global Regions",
    title.s = 13,
    by = 10,
    colors = c("#472D7B", "#3B528B", "#2C728E", "#21918D", "#28AE80", "#72D077", "#ACDC35")
)
```

![Internet Usage Trends in Seven Global Regions](/files/global-internet-usage-trend-analysis/images/notebook_27_1.png){: .align-center}

### 2.5. Countries with the Most Internet Users
Based on the **[World Population Review](https://worldpopulationreview.com/countries)**, all of these countries are among the **top ten most populous nations**, with **four** of them also ranking in the **top five** (excluding Brazil).

```R
# Top five countries
top_five_internet_users <- people %>%
    group_by(Entity) %>% 
  filter(Year == max(Year), Code != 'null', Entity != 'World') %>%
    arrange(desc(Users)) %>%
    ungroup() %>%
    top_n(5, Users) %>%
  select(c("Entity", "Users"))

# Plot bar graph
plot_bar(
    data = top_five_internet_users,
    group = "Entity",
    xlabs = "Number of Internet Users",
    num = "Users",
    ylabs = "",
    title = "Top Five Countries by Number of Internet Users",
    title.s = 13
)
```
![Top Five Countries by Number of Internet Users](/files/global-internet-usage-trend-analysis/images/notebook_29_0.png){: .align-center}
    
### 2.6. Relationship Between Internet Usage & Broadband Subscriptions, 2019

- The correlational analysis revealed a **[moderately high positive correlation](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3576830/table/T1/?report=objectonly)** ($$r = 0.56$$) between **internet usage** and **broadband subscriptions** in **2019**, which is statistically significant at a **0.01 level** ($$p = 4.914e^{-07}$$), allowing us to reject the null hypothesis of no correlation.
- We are at least **99% confident** that the true correlation coefficient ($$ρ$$) lies within the range of **0.3730** to **0.7018**. 
- This positive relationship is also visually apparent in the scatter plot below.

```R
# Join 'internet' and 'broadband' tables
internet_and_broadband_2019 <- internet %>% 
  inner_join(broadband, by = c("Entity", "Code", "Year")) %>%
    filter(Year == 2019)

# Perform a Pearson correlation test
pearson_corr <- data.frame(
  Correlation_Coefficient = cor.test(internet_and_broadband_2019$Internet_Usage,
                        internet_and_broadband_2019$Broadband_Subscriptions,
                        method = "pearson")$estimate,
  P=cor.test(internet_and_broadband_2019$Internet_Usage,
                     internet_and_broadband_2019$Broadband_Subscriptions,
                     method = "pearson")$p.value,
  CI_Lower=(cor.test(internet_and_broadband_2019$Internet_Usage,
                       internet_and_broadband_2019$Broadband_Subscriptions,
                       method = "pearson")$conf.int)[1],
  CI_Upper=(cor.test(internet_and_broadband_2019$Internet_Usage,
                       internet_and_broadband_2019$Broadband_Subscriptions,
                       method = "pearson")$conf.int)[2]	
)
rownames(pearson_corr) <- "Value"

```
<table class="dataframe">
<!-- <caption>A data.frame: 1 × 4</caption> -->
<thead>
  <tr><th></th><th scope=col>Correlation_Coefficient</th><th scope=col>P</th><th scope=col>CI_Lower</th><th scope=col>CI_Upper</th></tr>
  <!-- <tr><th></th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th></tr> -->
</thead>
<tbody>
  <tr><th scope=row>Value</th><td>0.5590077</td><td>4.913904e-07</td><td>0.3730323</td><td>0.7017988</td></tr>
</tbody>
</table>

```R
# Plot scatter points
scatter_for_corr <- ggplot(internet_and_broadband_2019, aes(x = Internet_Usage, y = Broadband_Subscriptions)) +
  geom_point(color = "#8486B3", size = 2.5) +
    theme(legend.position = "top",
        legend.justification = -0.12,
        legend.direction = "horizontal",
        legend.key.size = unit(0, 'pt'),
        legend.text = element_text(margin = margin(r = 5, unit = "pt"), color = "#65707C"),
        legend.title = element_blank(),
        legend.key = element_blank(),
        axis.title = element_text(color = "#65707C", face = "bold"),
        axis.text = element_text(color = "#65707C"),
        axis.line = element_line(colour = "grey", linewidth = 0.5),
        panel.grid.major = element_line(color = "grey", linetype = "dashed", linewidth = 0.25),
        panel.background = element_blank(),
        plot.title = element_text(color = "#65707C",
                                  hjust = 0.5,
                                  size = 12,
                                  face = "bold")
        ) +
  labs(x = '\nInternet Usage (%)', y = 'Broadband Subscriptions\n') +
  ggtitle("\nInternet Usage vs. Broadband Subscriptions, 2019\n") +
  scale_x_continuous(expand = c(0.00, 0),
                       limits = c(0, 110), 
                       breaks = seq(0, 100, by = 20)) +
  scale_y_continuous(expand = c(0.00, 0),
                       limits = c(0, 50),
                       breaks = seq(0, 50, by = 5))
```

![Internet Usage vs. Broadband Subscriptions, 2019](/files/global-internet-usage-trend-analysis/images/notebook_31_1.png){: .align-center}

## 3. Conclusion
Based on the data and results of the analyses, the following conclusions can be drawn about the global state of internet accessibility:

* The **highest internet usage** by population share worldwide is concentrated in several **Middle Eastern countries**.
* **Western regions** experienced a **significantly quicker growth in internet accessibility** compared to their eastern counterparts.
* The **countries with the highest internet usage** within a region are **not necessarily those with the largest land areas**.
* Conversely, the **most populous countries** tend to have the **greatest total number of internet users**.

* In **2019**, **countries with a higher percentage of internet users** in their population also had a corresponding increase in **fixed broadband subscriptions** (at downstream speeds of 256 kbit/s or more).

