---
title: "Manhattan's Urban Forestry Report, 2015"
collection: portfolio
permalink: /portfolio/manhattans-urban-forestry-report-2015
date: 2023-01-01
last_updated: 2025-07-30
venue: 'DataCamp'
categories:
  - R
  - Tableau
slidesurl: '/files/manhattans-urban-forestry-report-2015/slides.pdf'
images:
  - '/files/manhattans-urban-forestry-report-2015/images/page-1.png'
  - '/files/manhattans-urban-forestry-report-2015/images/page-2.png'
  - '/files/manhattans-urban-forestry-report-2015/images/page-3.png'
  - '/files/manhattans-urban-forestry-report-2015/images/page-4.png'
  - '/files/manhattans-urban-forestry-report-2015/images/page-5.png'
  - '/files/manhattans-urban-forestry-report-2015/images/page-6.png'
  - image: '/files/manhattans-urban-forestry-report-2015/images/page-7.png'
    link: 'https://public.tableau.com/app/profile/jbjdelacruz/viz/NYCURBANPLANNINGFORESTRYREPORT2015/Dashboard'
  - '/files/manhattans-urban-forestry-report-2015/images/page-8.png'
  - image: '/files/manhattans-urban-forestry-report-2015/images/page-9.png'
    link: 'https://www.datacamp.com/competitions/city-tree-species?entry=ba331d65-5607-4c69-adb4-406663585edc'
link: 'https://www.datacamp.com/datalab/w/ba331d65-5607-4c69-adb4-406663585edc'
url: 'https://www.datacamp.com/datalab/w/ba331d65-5607-4c69-adb4-406663585edc'
thumbnail: '/images/projects/project4-cover.png'
featured: true
doc_type: 'Full Report'
# tableau:
#   id: "viz1758103536624"
#   url: "https://public.tableau.com/app/profile/jbjdelacruz/viz/NYCURBANPLANNINGFORESTRYREPORT2015/Dashboard"
#   static_img: "https://public.tableau.com/static/images/NY/NYCURBANPLANNINGFORESTRYREPORT2015/Dashboard/1.png"
#   name: "NYCURBANPLANNINGFORESTRYREPORT2015/Dashboard"
#   width: 600
#   height: 337.5
---

This analysis of census data on more than 60,000 street trees across Manhattan won first place in [Which Tree Species Should the City Plant?](https://www.datacamp.com/competitions/city-tree-species?entry=ba331d65-5607-4c69-adb4-406663585edc) competition. It evaluates spatial distribution, biological characteristics, and biodiversity while ranking species by median trunk diameter and health index, presenting evidence-based recommendations for future tree planting.

<!-- # Manhattan's Urban Forestry Report, 2015

<img src="cover.png" alt="" title=""/>

## 1. Introduction 

The urban design team believes that tree size (in terms of trunk diameter) and health are the most desirable characteristics of city trees. In order to help the planning department improve the quantity and quality of trees in New York City, our organization is advised to provide a data analysis report.

### 1.1. Objectives
The main objective of this report is to profile Manhattan's tree population and species by different attributes using summary statistics, visualizations, and textual explanations. Specifically, it aims to:

1.	Describe all censused trees by their spatial and biological characteristics.
2.	Map the tree profile of the neighborhoods. 
3.	Illustrate the biodiversity and biology of the tree species in Manhattan. 
4.	Determine tree species with the best traits.

### 1.2. Libraries & Data Used

```R
# Load pre-installed, required packages
library(tidyverse)
library(dplyr)
library(ggplot2)
library(sf)
library(geojsonsf)
library(scales)
library(remotes)
library(rwantshue) # For generating random color scheme
library(ggfun) # For round rectangle borders and backgrounds in ggplots
library(ggchicklet) # For bar charts with rounded corners
```

The following data sets come from the City of New York [NYC Open Data](https://opendata.cityofnewyork.us/data/).

#### Trees

A [data set](https://data.cityofnewyork.us/Environment/2015-Street-Tree-Census-Tree-Data/uvpi-gqnh) based on the "TreesCount! 2015 Street Tree Census, conducted by volunteers and staff organized by NYC Parks & Recreation and partner organizations. Tree data collected includes tree species, diameter and perception of health. Accompanying blockface data is available indicating status of data collection and data release citywide". 

See the list of variables and their descriptions [here](https://i.ibb.co/vPxVhHS/tbl-of-vars-desc1.jpg).

```R
# Read the 'trees' data set from the CSV file
trees <- read_csv("data/trees.csv", show_col_types=FALSE) %>%
  mutate(spc_common = str_to_sentence(spc_common))
```

#### Neighborhoods

A [data set](https://data.cityofnewyork.us/City-Government/NTA-map/d3qk-pfyz) based on the "boundaries of Neighborhood Tabulation Areas as created by the NYC Department of City Planning using whole census tracts from the $2010$ Census as building blocks. These aggregations of census tracts are subsets of New York City's $55$ Public Use Microdata Areas (PUMAs)."

See the list of variables and their descriptions [here](https://i.ibb.co/g7G3TCt/tbl-of-vars-desc2.jpg).

```R
# Read the 'neighborhoods' data set from the SHP file
neighborhoods <- st_read("data/nta.shp", quiet=TRUE) %>% 
  dplyr::select(boroname, ntacode, ntaname, geometry, shape_area)

# Create a merged data frame for the 'trees' and 'neighborhoods' data sets
merged_trees_and_neighborhoods <- trees %>%
  full_join(neighborhoods, by = c("nta"="ntacode", "nta_name"="ntaname"))
```

## Executive Summary

Using the data available and findings of the analyses, the tree population and species of Manhattan, New York City, can be summarized as follows:
- Greater numbers of trees are most likely to be found in neighborhoods with larger plots of land.
- The majority of the trees in Manhattan are on-curb, with only a few that are offset from the curb.
- The majority of the trees in Manhattan are alive and in fair to good health, while only a small number are dead and in poor health.
- Although specific root, trunk, and branch problems are not of significant concerns, few of the trees are affected by paving stones in the tree bed (a kind of root problem) as well as other unspecified trunk and branch problems.
- Manhattan has a rich and diverse set of tree species. 
- The species recommendation for tree planting in Manhattan's streets is a combination of some of the borough's highly and averagely abundant species that have shown favorable qualities of size and health. Specifically, the top five recommended species are as follows:

  1. Siberian elm
  2. Willow oak
  3. Honeylocust
  4. American elm
  5. Pin oak

## Results & Discussion

### Tree Population

Using descriptive and spatial analyses, the following information outlines the location and physical attributes of all Manhattan trees in $2015$ with a population size ($N$) of $64,229$:

#### Spatial

**Tree Locations by Neighborhood:**

While trees seem to cover much each of Manhattan's $28$ neighborhoods, some of the southern ones, including MN13, MN17, MN24, MN25, MN27, MN28, and MN50, have empty areas. Interestingly, four of these aforementioned neighborhoods (indicated by *) are among the top ten in terms of land size, which are:

 1. Hudson Yards-Chelsea-Flatiron-Union Square (MN13)
 2. Upper West Side (MN12)
 3. Midtown-Midtown South (MN17)
 4. Central Harlem North-Polo Grounds (MN03)
 5. West Village (MN23)
 6. SoHo-TriBeCa-Civic Center-Little Italy (MN24)
 7. East Harlem North (MN34)
 8. Lower East Side (MN28)
 9. Washington Heights South (MN36)
10. Washington Heights North (MN35)


```R
# Top 10 NTAs in terms of land size 
top_nta_area <- neighborhoods %>%
  filter(boroname == "Manhattan", ntacode != "MN99") %>%
  arrange(desc(shape_area)) %>%
  slice(1:10)
```

```R
# Tree count per neighborhood
nbh_tree_cnts <- merged_trees_and_neighborhoods %>%
  filter(boroname == "Manhattan", nta != "MN99") %>%
  group_by(nta, nta_name) %>%
  summarize(number_of_trees = n(), .groups="keep") %>%
  arrange(desc(number_of_trees)) %>%
  ungroup() %>%
  mutate(proportion = round(number_of_trees/sum(number_of_trees), digits = 4))

# Species richness per neighborhood
nbh_rchns <- trees %>%
  filter(!(spc_common=="null")) %>%
  group_by(nta, nta_name) %>%
  summarize(richness = n_distinct(spc_common), .groups="keep") %>%
  arrange(desc(richness)) %>%
  ungroup()

# Data for maps
nbhs_map <- nbh_tree_cnts %>%
  full_join(neighborhoods, c("nta"="ntacode", "nta_name"="ntaname")) %>% 
  full_join(nbh_rchns, c("nta", "nta_name")) %>%
  mutate(borough = substr(nta, 1, 2),
         nta_code_and_name = paste(nta, nta_name, sep=": "),
         nta_and_tree_cnt = ifelse(number_of_trees < 1000, 
                                   paste(nta,  " - ", "   ", prettyNum(number_of_trees,big.mark=","), " : ", nta_name, sep=""),
                                   paste(nta,  " - ", prettyNum(number_of_trees, big.mark=","), " : ", nta_name, sep="")
         ),
         nta_and_rchns = paste(nta,  " - ", prettyNum(richness, big.mark=","),
                               " : ", nta_name, sep="")
  ) %>%
  st_as_sf %>%
  st_transform("+proj=longlat +ellps=intl +no_defs +type=crs") 

# Colorize the NTAs
color_scheme <- iwanthue(seed=1234, force_init=TRUE)
nta_colors <- color_scheme$hex(nrow(nbhs_map %>%  filter(borough == "MN")))

# Data of tree locations 
tree_locs <- trees %>%
  st_as_sf(coords = c("longitude", "latitude"), crs=4326) %>%
  st_transform("+proj=longlat +ellps=intl +no_defs +type=crs")


# Map of tree locations by neighborhood
tree_locs_map_plot <- ggplot() + 
  geom_sf(data = nbhs_map,
          fill="#E8EAED", color="grey") +
  stat_sf_coordinates(data = tree_locs, 
                      aes(color = paste(nta, nta_name, sep=": ")),
                      size=0.001
  ) +
  stat_sf_coordinates(data = nbhs_map %>% filter(borough=="MN", nta!="MN99"),
                      color="grey25", size=0.25) +
  geom_sf(data = nbhs_map %>% filter(borough=="MN", nta!="MN99"),
          color="grey25",
          alpha=0.1) + 
  theme(legend.position = c(0.024, 0.5),
        legend.justification=0.0,
        legend.key.width = unit(2.5, 'mm'),
        legend.key.height = unit(1.8, 'mm'), 
        legend.direction="vertical",
        legend.background= element_roundrect(r = grid::unit(0.02, "snpc"),
                                             fill=alpha("#FFFFFF", 0.90)),
        legend.key = element_rect(fill=NA),
        legend.text = element_text(margin = margin(r=5, unit="pt"),
                                   color="#65707C",
                                   family="sans serif"),
        legend.title = element_text(face="bold",
                                    color="#65707C",
                                    size=8.5,
                                    family="sans serif"),
        axis.title = element_text(color="#65707C",
                                  face="bold",
                                  family="sans serif"),
        axis.text = element_text(color="#65707C",
                                 size=7,
                                 family="sans serif"),
        axis.text.x = element_text(angle=90,
                                   vjust=0.5,
                                   hjust=1),
        axis.line = element_line(colour="grey",
                                 linewidth=0.5),
        panel.grid.major = element_line(color="grey",
                                        linetype="dashed",
                                        linewidth=0.25),
        panel.border = element_rect(color="grey40",
                                    fill=NA),  
        panel.spacing = unit(2, "lines"),
        panel.background  = element_roundrect(r = grid::unit(0.001, "snpc"),
                                              fill=alpha("#9CC0F9", 1)),
    rect = element_rect(fill = "transparent"),
        plot.title = element_text(color="#65707C",
                                  vjust=10,
                                  size=14,
                                  family="sans serif")) +
  labs(x="", y="", color="    Code: Name") +
  ggtitle("Fig. 1: Map of the Tree Locations by Neighborhood in Manhattan") +
  scale_x_continuous(limits = c(-74.25, -73.89), 
                     breaks = seq(-74.25, -73.89, by=0.02)) +
  scale_y_continuous(limits = c(40.68, 40.88), 
                     breaks = seq(40.68, 40.88, by=0.02)) +
  guides(color = guide_legend(ncol=1,
                              override.aes = list(shape=15,
                                                  size=2.5
                              ))) +
  ggrepel::geom_text_repel(data = nbhs_map %>% filter(borough == "MN", nta != "MN99"),
                            aes(label = nta, geometry = geometry),
                            stat="sf_coordinates",
                            min.segment.length=0,
                            size=2,
                            label.size=NA,
                fontface="bold"
              ) +
  coord_sf(xlim = c(-74.25, -73.89), ylim = c(40.68, 40.88)) +
  scale_color_manual(values = nta_colors)
```

<img src="documentation/tree_locs_map_plot.png" alt="" title=""/>

**Tree Counts by Neighborhood:**

In terms of the number of trees, the top ten neighborhoods are:
 
 1. Upper West Side (MN12)<br/>
 2. Upper East Side-Carnegie Hill (MN40)<br/>
 3. West Village (MN23) <br/>
 4. Central Harlem North-Polo Grounds (MN03) <br/>
 5. Hudson Yards-Chelsea-Flatiron-Union Square (MN13) <br/>
 6. Washington Heights South (MN36)<br/>
 7. Morningside Heights (MN09)<br/>
 8. Central Harlem South (MN11)<br/>
 9. Washington Heights North (MN35) <br/>
10. East Harlem North (MN34)

Seven of which are part of the ten largest.


```R
# Table for Top 10 Tree-Producing Neighborhoods
for_table_nbh_tree_cnts <- nbh_tree_cnts %>%
  slice(1:10) %>%
  rownames_to_column("rank") %>%
  mutate(number_of_trees = prettyNum(number_of_trees, big.mark=","),
           percentage = label_percent(accuracy=0.01)(proportion)) %>%
  select(-proportion)

# Order by number of trees
nbhs_map$nta_and_tree_cnt <- factor(
    nbhs_map$nta_and_tree_cnt,
       levels = nbhs_map$nta_and_tree_cnt,
       ordered=TRUE
)

# Map of NTAs' tree counts
nbhs_tree_cnts_map_plot <- ggplot() + 
  geom_sf(data = nbhs_map %>% filter(borough != "MN" | nta == "MN99"),
            fill="#E8EAED", color="grey") +
  geom_sf(data = nbhs_map %>% filter(borough == "MN", nta != "MN99"),
            aes(fill = number_of_trees,
                color = nta_and_tree_cnt
           )) + 
    stat_sf_coordinates(data = nbhs_map %>% filter(nta %in% for_table_nbh_tree_cnts$nta),
                        color="grey25", size=0.5) +
    theme(legend.position = #c(0.7, 0.8),
          c(0.369, 0.5), 
          #c(0.025, 0.5),
          legend.justification=0.0,
          legend.key.width = unit(2.5, 'mm'),
        legend.key.height = unit(1.8, 'mm'), 
          legend.direction="vertical",
          legend.background = element_roundrect(r = grid::unit(0.02, "snpc"),
                                               fill = alpha("#FFFFFF", 0.90)),
          legend.key = element_rect(fill=NA),
          legend.text = element_text(margin = margin(r=5, unit="pt"),
                                     size=7.9,
                                   color="#65707C",
                                     family="sans serif"),
          legend.title = element_text(face="bold",
                                      color="#65707C",
                                      size=8.5,
                                      family="sans serif"),
          axis.title = element_text(color="#65707C",
                                    face="bold",
                                    family="sans serif"),
          axis.text = element_text(color="#65707C",
                                   size=7,
                                   family="sans serif"),
          axis.text.x = element_text(angle=90,
                                     vjust=0.5,
                                     hjust=1),
          axis.line = element_line(colour="grey",
                                   linewidth=0.5),
          panel.grid.major = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.25),
          panel.border = element_rect(color="grey40",
                                      fill=NA),  
          panel.spacing = unit(2, "lines"),
          panel.background  = element_roundrect(r = grid::unit(0.001, "snpc"),
                                               fill = alpha("#9CC0F9", 1)),
      rect = element_rect(fill = "transparent"),
          plot.title = element_text(color="#65707C",
                                    vjust=10,
                                    size=14,
                                    family="sans serif")) +
     labs(x="", y="", color="   Code - Number of trees : Name"
             ) +
     ggtitle("Fig. 2: Map of the Number of Trees in Manhattan's Neighborhoods") +
  scale_x_continuous(expand = c(0.01, 0),
                       limits = c(-74.04, -73.64), 
                       breaks = seq(-74.04, -73.64, by=0.02)) +
  scale_y_continuous(expand = c(0.01, 0),
                       limits = c(40.68, 40.88), 
                       breaks = seq(40.68, 40.88, by=0.02)) +
  scale_color_manual(values = replicate(28, "grey25")) +
  scale_fill_gradient2(low = muted("499F78"),
                         high = muted("#216968")) +
  ggrepel::geom_text_repel(data = nbhs_map %>% filter(nta %in% for_table_nbh_tree_cnts$nta),
                              aes(label = nta, geometry = geometry),
                              stat="sf_coordinates",
                              min.segment.length=0,
                              label.size=NA,
                              alpha=0.5,
                  fontface="bold"
               ) +
  coord_sf(xlim = c(-74.04, -73.64), ylim = c(40.68, 40.88))     #-74.28, -73.88

# Extract NTA fill colors
color_scheme_2 <- as.data.frame(ggplot_build(nbhs_tree_cnts_map_plot)$data[[2]])$fill

nbhs_tree_cnts_map_plot1 <- nbhs_tree_cnts_map_plot +
  guides(fill = "none",
           color = guide_legend(ncol=1,
                                override.aes = list(color = NA,
                                                    fill = color_scheme_2,
                                                    linewidth=0))
          )
```


```R
nbh_tree_cnts %>%
  slice(1:10) %>%
  rownames_to_column("rank") %>%
  mutate(number_of_trees = prettyNum(number_of_trees, big.mark=","),
          percentage = label_percent(accuracy=0.01)(proportion)) %>%
  select(-proportion)
```


<table class="dataframe">
<thead>
  <tr><th scope=col>rank</th><th scope=col>nta</th><th scope=col>nta_name</th><th scope=col>number_of_trees</th><th scope=col>percentage</th></tr>
</thead>
<tbody>
  <tr><td>1 </td><td>MN12</td><td>Upper West Side                           </td><td>5,807</td><td>9.04%</td></tr>
  <tr><td>2 </td><td>MN40</td><td>Upper East Side-Carnegie Hill             </td><td>4,616</td><td>7.19%</td></tr>
  <tr><td>3 </td><td>MN23</td><td>West Village                              </td><td>3,801</td><td>5.92%</td></tr>
  <tr><td>4 </td><td>MN03</td><td>Central Harlem North-Polo Grounds         </td><td>3,469</td><td>5.40%</td></tr>
  <tr><td>5 </td><td>MN13</td><td>Hudson Yards-Chelsea-Flatiron-Union Square</td><td>2,931</td><td>4.56%</td></tr>
  <tr><td>6 </td><td>MN36</td><td>Washington Heights South                  </td><td>2,924</td><td>4.55%</td></tr>
  <tr><td>7 </td><td>MN09</td><td>Morningside Heights                       </td><td>2,704</td><td>4.21%</td></tr>
  <tr><td>8 </td><td>MN11</td><td>Central Harlem South                      </td><td>2,643</td><td>4.11%</td></tr>
  <tr><td>9 </td><td>MN35</td><td>Washington Heights North                  </td><td>2,612</td><td>4.07%</td></tr>
  <tr><td>10</td><td>MN34</td><td>East Harlem North                         </td><td>2,505</td><td>3.90%</td></tr>
</tbody>
</table>

<img src="documentation/nbhs_tree_cnts_map_plot.png" alt="" title=""/>

**Trees by Curb Location:** 

Majority or $93.31\%$ ($59,932$) of the tree beds are located on curb, while the remaining $6.69\%$ $(4,297)$ are located offset from curb.


```R
# Tree count per location in relation to curb
number_of_trees_per_curb_loc <- merged_trees_and_neighborhoods %>%
  filter(str_detect(nta, "MN") & !(nta == "MN99")) %>%
  group_by(curb_loc) %>%
  summarize(number_of_trees = n()) %>%
  arrange(desc(number_of_trees)) %>%
    mutate(percentage = label_percent(accuracy=0.01)(number_of_trees/length(merged_trees_and_neighborhoods$tree_id)))

# HTML Table for Curb Location
#kable(number_of_trees_per_curb_loc,
#      caption = "This is the caption.",
#      label = "tables", format = "html", booktabs = TRUE) 

on_curb_stat <- number_of_trees_per_curb_loc %>%
    mutate(proportion = number_of_trees/sum(number_of_trees)) %>% 
  filter(proportion == max(abs(proportion)))

# Create a pie chart for the curb location
curb_loc_stacked_bar_plot <- ggplot(number_of_trees_per_curb_loc) + 
  geom_chicklet(aes(x="", y = number_of_trees/sum(number_of_trees),
                      fill = curb_loc), 
                  radius = grid::unit(0.75, "mm"),
                  position="stack") +
  coord_flip() +
  theme(legend.position="right",
          legend.justification="top",
          legend.direction="vertical",
          legend.key.size = unit(0, 'pt'),
          #legend.key = element_rect(fill = NA),
          legend.text = element_text(margin = margin(r = 4, unit = "pt"),
                                     color = "#65707C",
                                     family="sans serif"),
          legend.title = element_text(color = "#65707C",
                                      face="bold",
                                      size = 9,
                                      family="sans serif"),
      axis.title.x = element_text(color="#65707C",
                                    face="bold",
                                    family="sans serif"),
      axis.title.y = element_blank(),
          axis.text = element_blank(),
          axis.line = element_blank(),
          axis.ticks = element_blank(),
          panel.grid.minor = element_blank(),
          panel.grid.major = element_blank(),
          panel.background = element_blank(),
      rect = element_rect(fill = "transparent"),
          plot.subtitle = element_text(color="#65707C",
                                    hjust=0.25,
                                    size=10,
                                    family="sans serif"),
          plot.title = element_text(color="#65707C",
                                    hjust=-0.15,
                                    size=14,
                                    family="sans serif"),
      plot.margin = unit(c(0,1,0,1), "cm")) +	
  scale_fill_manual(values = c("#875826",
                                 "#10401B")) + 
  ggtitle("\nFig. 3: Proportional Stacked Bar Graph of Tree Bed Location ",
            subtitle="  (in relation to the Curb)\n") +
  labs(y="\n%  \n(Number of trees)\n", fill="Location:  ") +
    guides(fill = guide_legend(nrow=2,
                               reverse=TRUE,
                               override.aes = list(shape = 15,
                                                   size = 4))) +
  scale_x_discrete(expand = c(0.01, 0)) +
  geom_text(data = on_curb_stat,
                             aes(label = paste(label_percent(accuracy=0.01)(proportion),
                                       "\n (", prettyNum(number_of_trees,
                                                  big.mark=","),")",
                                       sep=""),
                                 x = "",
                                 y = 0.50 * proportion - 0.075),
                            size=5, color="white", hjust=1)
```


```R
# Export plot as PNG
ggsave(
  plot = curb_loc_stacked_bar_plot,
  filename = "documentation/curb_loc_stacked_bar_plot.png",
  bg = "transparent"
)
```

    [1m[22mSaving 7 x 7 in image


<img src="documentation/curb_loc_stacked_bar_plot.png" alt="" title=""/>

**Trees' Curb Location by Neigborhood:**

Twenty neighborhoods have at least $90\%$ of their trees being on curb, while $27$ have at least $75\%$. The ten neighborhoods with the highest percentage of trees located on-curb are:
 1. East Village (MN22)<br/>
 2. Manhattanville (MN06)<br/>
 3. Gramercy (MN21)<br/>
 4. West Village (MN23)<br/>
 5. Hudson Yards-Chelsea-Flatiron-Union Square (MN13)<br/>
 6. Yorkville (MN32)<br/>
 7. Clinton (MN15)<br/>
 8. Washington Heights North (MN35)<br/>
 9. Lenox Hill-Roosevelt Island (MN31)<br/>
10. East Harlem North (MN34)

Only Stuyvesant Town-Cooper Village has the majority of its trees being offset from curb. Including it, the neighborhoods with the highest percentage of trees located offset from curb are:

 1. Stuyvesant Town-Cooper Village (MN50)<br/>
 2. Battery Park City-Lower Manhattan (MN25)<br/>
 3. Chinatown (MN27)<br/>
 4. Morningside Heights (MN09)<br/>
 5. East Harlem South (MN33)<br/>
 6. Lower East Side (MN28)<br/>
 7. SoHo-TriBeCa-Civic Center-Little Italy (MN24)<br/>
 8. Upper West Side (MN12)<br/>
 9. Lincoln Square (MN14)<br/>
10. Upper East Side-Carnegie Hill (MN40)


```R
#########################################
#### Characteristics by Neighborhood ####
#########################################

## Location ##

# Location in relation with the curb 
nta_curb_loc <- as.data.frame.matrix(table(trees$nta, trees$curb_loc)) %>%
  rename_with( ~ paste0(.x, "_loc"))

## Biology ##

# Species
nta_spc <- as.data.frame.matrix(table(trees$nta, trees$spc_common))

# Tree size (in terms of trunk diameter)
nta_tree_dbh <- as.data.frame.matrix(table(trees$nta, trees$tree_dbh)) %>%
  rename_with( ~ paste0(.x, "_tree_dbh"))

# Status and health 
nta_status <- as.data.frame.matrix(table(trees$nta, trees$status)) %>%
  rename_with( ~ paste0(.x, "_status"))
nta_health <- as.data.frame.matrix(table(trees$nta, trees$health)) %>%
  rename_with( ~ paste0(.x, "_health"))

# Root problems
nta_root_stone <- as.data.frame.matrix(table(trees$nta, trees$root_stone)) %>%
  rename_with( ~ paste0(.x, "_root_stone"))
nta_root_grate <- as.data.frame.matrix(table(trees$nta, trees$root_grate)) %>%
  rename_with( ~ paste0(.x, "_root_grate"))
nta_root_other <- as.data.frame.matrix(table(trees$nta, trees$root_other)) %>%
  rename_with( ~ paste0(.x, "_root_other"))

# Trunk problems
nta_trunk_wire <- as.data.frame.matrix(table(trees$nta, trees$trunk_wire)) %>%
  rename_with( ~ paste0(.x, "_trunk_wire"))
nta_trnk_light <- as.data.frame.matrix(table(trees$nta, trees$trnk_light)) %>%
  rename_with( ~ paste0(.x, "_trnk_light"))
nta_trnk_other <- as.data.frame.matrix(table(trees$nta, trees$trnk_other)) %>%
  rename_with( ~ paste0(.x, "_trnk_other"))

# Branch problems
nta_brch_light <- as.data.frame.matrix(table(trees$nta, trees$brch_light)) %>%
  rename_with( ~ paste0(.x, "_brch_light"))
nta_brch_shoe <- as.data.frame.matrix(table(trees$nta, trees$brch_shoe)) %>%
  rename_with( ~ paste0(.x, "_brch_shoe"))
nta_brch_other <- as.data.frame.matrix(table(trees$nta, trees$brch_other)) %>%
  rename_with( ~ paste0(.x, "_brch_other"))

# Table of biological attributes per species
nta_bio <- bind_cols(list(nta_tree_dbh,
                          nta_status,
                          nta_health,
                          nta_root_stone,
                          nta_root_grate,
                          nta_root_other,
                          nta_trunk_wire,
                          nta_trnk_light,
                          nta_trnk_other,
                          nta_brch_light,
                          nta_brch_shoe,
                          nta_brch_other)) %>%
  rownames_to_column("nta")
```


```R
# Curb location per neighborhood
curb_loc_per_nbh <- merged_trees_and_neighborhoods %>% 
  filter(str_detect(nta, "MN") & !(nta == "MN99")) %>%
  group_by(nta, nta_name, curb_loc) %>%
  summarize(number_of_trees=n(), .groups="keep") %>%
  group_by(nta) %>%
  mutate(proportion = number_of_trees/sum(number_of_trees),
           percentage = label_percent(accuracy=0.01)(proportion)) %>%
  arrange(desc(proportion)) %>%
  ungroup()

# Higher between OnCurb and OffsetFromCurb per neighborhood
oncurb_vs_offset_per_nbh <- curb_loc_per_nbh %>% 
  group_by(nta) %>%
  filter(proportion == max(abs(proportion)))

# Order by NTA
curb_loc_per_nbh$nta_name <- factor(
    curb_loc_per_nbh$nta_name,
       levels = rev(unique(curb_loc_per_nbh$nta_name)),
       ordered=TRUE
)

# Table of Top 10 NTAs with the highest % of on-curb-located trees
top_on_curb <- curb_loc_per_nbh %>%
  filter(curb_loc=="OnCurb") %>%
  top_n(10, proportion) %>%
  arrange(desc(proportion)) %>%
    rownames_to_column("rank") %>%
  rename(number_of_on_curb_trees = number_of_trees)

# HTML Table of Top 10 NTAs with the highest % of on-curb-located trees
#kable(top_on_curb %>% 
#      	 select(rank, nta, nta_name, number_of_on_curb_trees, percentage),
#      caption = " ",
#      label = "tables", format = "html", booktabs = TRUE) 

curb_loc_per_nbh_stacked_bar_plot <- ggplot(curb_loc_per_nbh) + 
  geom_chicklet(aes(x = nta_name, y = proportion*100, fill = curb_loc), 
                  radius = grid::unit(0.75, "mm"), position="stack") +
  coord_flip() +
  theme(legend.position="right",
          legend.justification="top",
          legend.direction="vertical",
          legend.key.size = unit(0, "pt"),
          legend.key = element_rect(fill=NA),
          legend.text = element_text(margin = margin(r = 4, unit = "pt"),
                                     color="#65707C",
                                     family="sans serif"),
          legend.title = element_text(color="#65707C",
                                      face="bold",
                                      size=9,
                                      family="sans serif"),
      axis.title = element_text(color="#65707C",
                                    face="bold",
                                    family="sans serif"),
          axis.text.x = element_text(color="#65707C",
                                   size=6,
                                   family="sans serif"),
          axis.text.y = element_text(color="#65707C",
                                   size=10,
                                   family="sans serif"),
          axis.line = element_line(colour="grey",
                                   linewidth=0.5),
          panel.grid.major = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.25),
          panel.background = element_blank(),
          plot.subtitle = element_text(color="#65707C",
                                    hjust=5.38,
                                    size=10,
                                    family="sans serif"),
          plot.title = element_text(color = "#65707C",
                                    hjust = 0.709,
                                    size= 12.2,
                                    family = "sans serif")) +
  scale_fill_manual(values = c("#875826",
                                 "#10401B")) +     
  ggtitle("\nFig. 4: Proportional Stacked Bar Graph of Each Neighborhood's Tree Bed Location",
            subtitle="               (in relation to the Curb)\n") +
  labs(x="\nNTA name \n", y="\nNTA code - % of on trees\n", fill="Location: ") +
    guides(fill = guide_legend(ncol=1,
                               reverse=TRUE,
                               override.aes = list(shape = 15,
                                                   size = 4))) +
  scale_y_continuous(expand = c(0.01, 0),
                       breaks = seq(0, 100, by=10)) +
  ggrepel::geom_text_repel(data = oncurb_vs_offset_per_nbh,
                             aes(label = paste(nta, " - ", 
                                               label_percent(accuracy=0.01)(proportion),
                                       sep=""),
                                 x = nta_name,
                                 y = ifelse(nta=="MN50", 100*proportion+22,
                                            100*proportion-22)),
                             size=2.2, color="white", hjust=1)

#curb_loc_per_nbh %>%
#	arrange(desc(curb_loc), desc(proportion)) %>%
#	mutate(number_of_trees = prettyNum(number_of_trees, big.mark=",")) %>%
#	select(-proportion)
```

<img src="documentation/curb_loc_per_nbh_stacked_bar_plot.png" alt="" title=""/>

#### Biological
**Size:** In terms of trunk diameter, the mean size of the tree population (red line in Fig. 5) is $8.6312$ inches, with a standard deviation of $5.5906$. Furthermore, its distribution is positively skewed, implying that the majority of trees have trunk diameters closer to the lower bound. In this case, we can use the median (blue line) of $8$ inches (with an IQR of $7$) as a better measure of central tendency (and spread).


```R
defaultW <- getOption("warn")
options(warn=-1)

# Summary statistics of the trunk diameter
tree_dbh_stats <- data.frame(N = length(trees$tree_dbh),
                 mean = mean(trees$tree_dbh),
                             sd = sd(trees$tree_dbh),
                             min = min(trees$tree_dbh),
                             first_quartile = quantile(trees$tree_dbh, probs = 0.25),
                             median = median(trees$tree_dbh),
                             second_quartile = quantile(trees$tree_dbh, probs = 0.75),
                             max = max(trees$tree_dbh))
row.names(tree_dbh_stats) <- "tree_dbh" 

# HTML Table for Tree Size
#kable(tree_dbh_stats %>%
#	mutate_if(is.numeric, list(~prettyNum(., big.mark=",")))
#     "html", caption = "Table _: Summary statistics of the tree diameter")

# Density curve for 'tree_dbh'
tree_dbh_dist_plot <- ggplot(trees, aes(x = tree_dbh)) + 
  geom_histogram(aes(y = after_stat(density)),
                   binwidth=1.1,
                   color=1,
                   fill="#5FBD5F") +
  geom_density(linewidth=0.85,
                 linetype=1,
                 colour = muted("5FBD5F"),
                 alpha=0.5) +

# Plot mean and median
geom_vline(aes(xintercept = mean(tree_dbh)), col="red", size=0.6) +
geom_vline(aes(xintercept = median(tree_dbh)), col="blue", size=0.6) +

     theme(axis.title = element_text(color="#65707C",
                                    face="bold",
                                    family="sans serif"),
          axis.text = element_text(color="#65707C",
                                   size=12,
                                   family="sans serif"),
          axis.line = element_line(colour="grey",
                                   linewidth=0.5),
          panel.grid.major = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.25),
          panel.background = element_blank(),
          plot.subtitle = element_text(color="#65707C",
                                    hjust=0.15,
                                    size=10,
                                    family="sans serif"),
          plot.title = element_text(color="#65707C",
                                    hjust=0.20,
                                    size=14,
                                    family="sans serif")) +
  ggtitle("\nFig. 5: Distribution of the Trunk Diameter") +
  labs(x="\nTrunk diameter in inches\n", y="\nDensity\n",
         subtitle="                (measured at 54 inches above the ground)\n") +
  scale_x_continuous(expand = c(0.01, 0), 
                       limits = c(0, 105),
                       breaks = seq(0, 105, by=10)) +
  scale_y_continuous(expand = c(0.01, 0),
                       limits = c(0, 0.12), 
                       breaks = seq(0, 0.12, by=0.02))
#tree_dbh_stats %>%
#	mutate_if(is.numeric, list(~round(., digits=4))) %>%
#	mutate_if(is.numeric, list(~prettyNum(., big.mark=",")))

options(warn = defaultW)
```


```R
ggsave("dbh_dist.png", plot = tree_dbh_dist_plot, width = 6, height = 4, dpi = 300)
```

    Warning message:
    “[1m[22mRemoved 5 rows containing non-finite outside the scale range (`stat_bin()`).”
    Warning message:
    “[1m[22mRemoved 5 rows containing non-finite outside the scale range
    (`stat_density()`).”
    Warning message:
    “[1m[22mRemoved 3 rows containing missing values or values outside the scale range
    (`geom_bar()`).”


<img src="documentation/tree_dbh_dist_plot.png" alt="" title=""/>

**Health-Related:** Nearly all of the trees in Manhattan have an "Alive" status, and majority are in a "Good" health condition. On the other hand, the minority of trees have problems with their roots, trunks, and branches. The most notable among these respective tree parts are caused by paving stones in the tree bed; trunk problems other than by wires/ropes and installed lighting; and branch problems other than by lights/wires and shoes.


```R
# Status and health 
pop_status <- as.data.frame(table(trees$status)) %>%
  mutate(attribute = "status", proportion = Freq/sum(Freq)) %>%
  rename(category = Var1, number_of_trees = Freq) %>%
  select(attribute, everything())
pop_health <- as.data.frame(table(trees$health)) %>%
  mutate(attribute = "health", proportion = Freq/sum(Freq)) %>%
  rename(category = Var1, number_of_trees = Freq) %>%
  select(attribute, everything()) %>%
  arrange(desc(proportion))

# Root problems
pop_root_stone <- as.data.frame(table(trees$root_stone)) %>%
  mutate(attribute = "root_stone", proportion = Freq/sum(Freq)) %>%
  rename(category = Var1, number_of_trees = Freq) %>%
  select(attribute, everything())
pop_root_grate <- as.data.frame(table(trees$root_grate)) %>%
  mutate(attribute = "root_grate", proportion = Freq/sum(Freq)) %>%
  rename(category = Var1, number_of_trees = Freq) %>%
  select(attribute, everything())
pop_root_other <- as.data.frame(table(trees$root_other)) %>%
  mutate(attribute = "root_other", proportion = Freq/sum(Freq)) %>%
  rename(category = Var1, number_of_trees = Freq) %>%
  select(attribute, everything())

# Trunk problems
pop_trunk_wire <- as.data.frame(table(trees$trunk_wire)) %>%
  mutate(attribute = "trunk_wire", proportion = Freq/sum(Freq)) %>%
  rename(category = Var1, number_of_trees = Freq) %>%
  select(attribute, everything())
pop_trnk_light <- as.data.frame(table(trees$trnk_light)) %>%
  mutate(attribute = "trnk_light", proportion = Freq/sum(Freq)) %>%
  rename(category = Var1, number_of_trees = Freq) %>%
  select(attribute, everything())
pop_trnk_other <- as.data.frame(table(trees$trnk_other)) %>%
  mutate(attribute = "trnk_other", proportion = Freq/sum(Freq)) %>%
  rename(category = Var1, number_of_trees = Freq) %>%
  select(attribute, everything())

# Branch problems
pop_brch_light <- as.data.frame(table(trees$brch_light)) %>%
  mutate(attribute = "brch_light", proportion = Freq/sum(Freq)) %>%
  rename(category = Var1, number_of_trees = Freq) %>%
  select(attribute, everything())
pop_brch_shoe <- as.data.frame(table(trees$brch_shoe)) %>%
  mutate(attribute = "brch_shoe", proportion = Freq/sum(Freq)) %>%
  rename(category = Var1, number_of_trees = Freq) %>%
  select(attribute, everything())
pop_brch_other <- as.data.frame(table(trees$brch_other)) %>%
  mutate(attribute = "brch_other", proportion = Freq/sum(Freq)) %>%
  rename(category = Var1, number_of_trees = Freq) %>%
  select(attribute, everything())

# Tree population's attributes
pop_attributes <- bind_rows(pop_status,
                            pop_health,
                            pop_root_stone,
                            pop_root_grate,
                            pop_root_other,
                            pop_trunk_wire,
                            pop_trnk_light,
                            pop_trnk_other,
                            pop_brch_light,
                            pop_brch_shoe,
                            pop_brch_other) %>%
                  mutate(percentage = label_percent(accuracy = 0.01)(proportion))  				  
```


```R
# Highest category per attribute
pop_attributes_highest_per_category <- pop_attributes %>%
  group_by(attribute) %>%
  filter(proportion == max(abs(proportion)))

# Order by attributes 
pop_attributes$attribute <- factor(
    pop_attributes$attribute,
       levels = rev(unique(pop_attributes$attribute)),
       ordered=TRUE
)

# Order by categories 
pop_attributes$category <- factor(
    pop_attributes$category,
       levels = c("Dead", "Alive", "Fair", "Poor", "Good", "Yes", "No"),
       ordered=TRUE
)

pop_attributes_stacked_bar_plot <- ggplot(pop_attributes) + 
  geom_chicklet(aes(x = attribute, y = proportion*100, fill = category), 
                  radius = grid::unit(0.75, "mm"), position="stack") +
  coord_flip() +
  theme(legend.position = "right",
          legend.justification="top",
          legend.direction="vertical",
          legend.key.size = unit(0, "pt"),
          legend.key = element_rect(fill = NA),
          legend.text = element_text(margin = margin(r = 4, unit = "pt"),
                                     color = "#65707C",
                                     family="sans serif"),
          legend.title = element_text(color = "#65707C",
                                      face = "bold",
                                      size = 9,
                                      family="sans serif"),
      axis.title = element_text(color="#65707C",
                                    face="bold",
                                    family="sans serif"),
          axis.text = element_text(color="#65707C",
                                   size=12,
                                   family="sans serif"),
          axis.line = element_line(colour="grey",
                                   linewidth=0.5),
          panel.grid.major = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.25),
          panel.background = element_blank(),
          plot.title = element_text(color = "#65707C",
                                    hjust = 0.715,
                                    size= 13.75,
                                    family = "sans serif")) +
  scale_x_discrete(labels=c("Other problems (branch)",
                              "Shoes (branch)",
                              "Lights or wires (branch) ",
                              "Other problems (trunk)",
                              "Lighting installed (trunk)",
                              "Wires or rope (trunk)",
                              "Other problems (root)",
                              "Metal grates (root)",
                              "Paving stones (root)",
                              "Health",
                              "Status"))+
  scale_fill_manual(values = c("grey40",
                                 "#10401B",
                                 "#89E7B3",
                 "#40C17E",
                                 "#1F9153",
                                 "#9F2305",
                                 "#4E7A61"),
                     labels = c("Dead", "Alive", "Poor",  "Fair", "Good", "Yes", "No")) +
  ggtitle("\nFig. 6: Proportional Stacked Bar Graph of the Tree Population's Attributes\n") +
  labs(x="\nAttribute \n", y="\n%  \n(Number of trees) \n", fill="Category: ") +
    guides(fill = guide_legend(ncol=1,
                               override.aes = list(shape = 15,
                                                   size = 4))) +
  scale_y_continuous(expand = c(0.01, 0),
                       breaks = seq(0, 100, by=10)) +
  ggrepel::geom_text_repel(data = pop_attributes_highest_per_category,
                             aes(label = paste(percentage,
                                       "\n (", prettyNum(number_of_trees,
                                                  big.mark=","),")",
                                       sep=""),
                                 x = attribute,
                                 y = 100*proportion-20),
                             size=3, color="white", hjust=1)

#pop_attributes %>%
#	mutate(number_of_trees = prettyNum(number_of_trees, big.mark=",")) %>%
#	select(-proportion)
```


```R
pop_attributes_stacked_bar_plot
```

    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_stringMetric, as.graphicsAnnot(x$label)):
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call(C_textBounds, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call.graphics(C_text, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call.graphics(C_text, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call.graphics(C_text, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call.graphics(C_text, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call.graphics(C_text, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call.graphics(C_text, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call.graphics(C_text, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call.graphics(C_text, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call.graphics(C_text, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call.graphics(C_text, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call.graphics(C_text, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call.graphics(C_text, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call.graphics(C_text, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call.graphics(C_text, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call.graphics(C_text, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call.graphics(C_text, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call.graphics(C_text, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call.graphics(C_text, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call.graphics(C_text, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call.graphics(C_text, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call.graphics(C_text, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call.graphics(C_text, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call.graphics(C_text, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call.graphics(C_text, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call.graphics(C_text, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call.graphics(C_text, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call.graphics(C_text, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call.graphics(C_text, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call.graphics(C_text, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call.graphics(C_text, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call.graphics(C_text, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call.graphics(C_text, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call.graphics(C_text, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call.graphics(C_text, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call.graphics(C_text, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call.graphics(C_text, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call.graphics(C_text, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call.graphics(C_text, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”
    Warning message in grid.Call.graphics(C_text, as.graphicsAnnot(x$label), x$x, x$y, :
    “font family 'sans serif' not found in PostScript font database”



    
![png](notebook_files/notebook_27_1.png)
    



```R
trees %>%
  summarize(total_number_of_censused_trees = n())

trees %>%
  group_by(spc_common) %>%
  summarize(number_of_trees_per_species = n()) %>%
  filter(!is.na(spc_common)) %>%
  summarize(number_of_identified_species = n())

trees %>%
  filter(is.na(spc_common)) %>%
  summarize(number_of_trees_with_unidentified_species = n()) %>%
  mutate(number_of_trees_with_identified_species = nrow(trees) - number_of_trees_with_unidentified_species) 
```


<table class="dataframe">
<caption>A tibble: 1 × 1</caption>
<thead>
  <tr><th scope=col>total_number_of_censused_trees</th></tr>
  <tr><th scope=col>&lt;int&gt;</th></tr>
</thead>
<tbody>
  <tr><td>64229</td></tr>
</tbody>
</table>




<table class="dataframe">
<caption>A tibble: 1 × 1</caption>
<thead>
  <tr><th scope=col>number_of_identified_species</th></tr>
  <tr><th scope=col>&lt;int&gt;</th></tr>
</thead>
<tbody>
  <tr><td>128</td></tr>
</tbody>
</table>




<table class="dataframe">
<caption>A tibble: 1 × 2</caption>
<thead>
  <tr><th scope=col>number_of_trees_with_unidentified_species</th><th scope=col>number_of_trees_with_identified_species</th></tr>
  <tr><th scope=col>&lt;int&gt;</th><th scope=col>&lt;int&gt;</th></tr>
</thead>
<tbody>
  <tr><td>1801</td><td>62428</td></tr>
</tbody>
</table>




```R
nbh_spc_long <- nta_spc %>%
  rownames_to_column("nta") %>% 
  pivot_longer(cols = 2:129, 
                 names_to = "spc_common",
                 values_to = "number_of_trees") %>%
  inner_join(trees %>% select(nta, nta_name) %>% distinct(nta, nta_name), by = "nta")

top_spc_per_nbh <- nbh_spc_long %>%
  group_by(nta) %>%
  top_n(1, number_of_trees) %>%
  arrange(nta, desc(number_of_trees)) %>%
  select(contains("nta"), everything()) %>%
  mutate(percentage = label_percent(accuracy=0.01)(
           number_of_trees/length(trees$tree_id)))

top_spc_per_nbh_short <- top_spc_per_nbh %>%
  group_by(spc_common) %>% 
    mutate(nta = paste0(nta, collapse = ", "),
           nta_name = paste0(nta_name, collapse = ", ")) %>%
  count(nta, nta_name, spc_common) %>%
  arrange(desc(n)) %>%
    select(nta, nta_name, spc_common, n) %>%
  mutate(percentage = label_percent(accuracy=0.01)(n/28)) %>% 
  rename(number_of_nta = n, most_common_spc = spc_common) 

# HTML Table for the counts of neighborhood for the most common species
#kable(top_spc_per_nbh_short,
#   "html", caption = " ")

#Counts of neighborhood for the most common species
spc_in_top_ten_per_nbh <- nbh_spc_long %>%
  group_by(nta) %>%
  top_n(10, number_of_trees) %>%
  arrange(nta, desc(number_of_trees)) %>%
  select(contains("nta"), everything()) %>%
  ungroup() %>%
  count(spc_common) %>%
  mutate(percentage = label_percent(accuracy=0.01)(n/28)) %>% 
  arrange(desc(n)) %>%   
  rename(number_of_nta = n)
```


```R
####################################
#### Characteristics by species ####
####################################

## Location ##

# Location in relation with the curb 
spc_curb_loc <- as.data.frame.matrix(table(trees$spc_common, trees$curb_loc)) %>%
  rename_with( ~ paste0(.x, "_loc"))

## Biology ##

# Tree size (in terms of trunk diameter)
spc_tree_dbh <- as.data.frame.matrix(table(trees$spc_common, trees$tree_dbh)) %>%
  rename_with( ~ paste0(.x, "_tree_dbh"))

# Status and health 
spc_status <- as.data.frame.matrix(table(trees$spc_common, trees$status)) #%>%
  #rename_with( ~ paste0(.x, "_status"))
spc_health <- as.data.frame.matrix(table(trees$spc_common, trees$health)) #%>%
  #rename_with( ~ paste0(.x, "_health"))

# Root problems
spc_root_stone <- as.data.frame.matrix(table(trees$spc_common, trees$root_stone)) %>%
  rename_with( ~ paste0(.x, "_root_stone"))
spc_root_grate <- as.data.frame.matrix(table(trees$spc_common, trees$root_grate)) %>%
  rename_with( ~ paste0(.x, "_root_grate"))
spc_root_other <- as.data.frame.matrix(table(trees$spc_common, trees$root_other)) %>%
  rename_with( ~ paste0(.x, "_root_other"))

# Trunk problems
spc_trunk_wire <- as.data.frame.matrix(table(trees$spc_common, trees$trunk_wire)) %>%
  rename_with( ~ paste0(.x, "_trunk_wire"))
spc_trnk_light <- as.data.frame.matrix(table(trees$spc_common, trees$trnk_light)) %>%
  rename_with( ~ paste0(.x, "_trnk_light"))
spc_trnk_other <- as.data.frame.matrix(table(trees$spc_common, trees$trnk_other)) %>%
  rename_with( ~ paste0(.x, "_trnk_other"))

# Branch problems
spc_brch_light <- as.data.frame.matrix(table(trees$spc_common, trees$brch_light)) %>%
  rename_with( ~ paste0(.x, "_brch_light"))
spc_brch_shoe <- as.data.frame.matrix(table(trees$spc_common, trees$brch_shoe)) %>%
  rename_with( ~ paste0(.x, "_brch_shoe"))
spc_brch_other <- as.data.frame.matrix(table(trees$spc_common, trees$brch_other)) %>%
  rename_with( ~ paste0(.x, "_brch_other"))
```


```R
trees %>% group_by(spc_common) %>% filter(spc_common != 'null') %>% count() %>% ungroup() %>% mutate(perc=round(n*100/sum(n),2)) %>% arrange(desc(n))
```


<table class="dataframe">
<caption>A tibble: 128 × 3</caption>
<thead>
  <tr><th scope=col>spc_common</th><th scope=col>n</th><th scope=col>perc</th></tr>
  <tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;dbl&gt;</th></tr>
</thead>
<tbody>
  <tr><td>Honeylocust        </td><td>13176</td><td>21.11</td></tr>
  <tr><td>Callery pear       </td><td> 7297</td><td>11.69</td></tr>
  <tr><td>Ginkgo             </td><td> 5859</td><td> 9.39</td></tr>
  <tr><td>Pin oak            </td><td> 4584</td><td> 7.34</td></tr>
  <tr><td>Sophora            </td><td> 4453</td><td> 7.13</td></tr>
  <tr><td>London planetree   </td><td> 4122</td><td> 6.60</td></tr>
  <tr><td>Japanese zelkova   </td><td> 3596</td><td> 5.76</td></tr>
  <tr><td>Littleleaf linden  </td><td> 3333</td><td> 5.34</td></tr>
  <tr><td>American elm       </td><td> 1698</td><td> 2.72</td></tr>
  <tr><td>American linden    </td><td> 1583</td><td> 2.54</td></tr>
  <tr><td>Northern red oak   </td><td> 1143</td><td> 1.83</td></tr>
  <tr><td>Willow oak         </td><td>  889</td><td> 1.42</td></tr>
  <tr><td>Cherry             </td><td>  869</td><td> 1.39</td></tr>
  <tr><td>Chinese elm        </td><td>  785</td><td> 1.26</td></tr>
  <tr><td>Green ash          </td><td>  770</td><td> 1.23</td></tr>
  <tr><td>Swamp white oak    </td><td>  681</td><td> 1.09</td></tr>
  <tr><td>Silver linden      </td><td>  541</td><td> 0.87</td></tr>
  <tr><td>Crab apple         </td><td>  437</td><td> 0.70</td></tr>
  <tr><td>Golden raintree    </td><td>  359</td><td> 0.58</td></tr>
  <tr><td>Red maple          </td><td>  356</td><td> 0.57</td></tr>
  <tr><td>Sawtooth oak       </td><td>  353</td><td> 0.57</td></tr>
  <tr><td>Kentucky coffeetree</td><td>  348</td><td> 0.56</td></tr>
  <tr><td>Norway maple       </td><td>  290</td><td> 0.46</td></tr>
  <tr><td>Black locust       </td><td>  259</td><td> 0.41</td></tr>
  <tr><td>White oak          </td><td>  241</td><td> 0.39</td></tr>
  <tr><td>Sweetgum           </td><td>  227</td><td> 0.36</td></tr>
  <tr><td>Hawthorn           </td><td>  219</td><td> 0.35</td></tr>
  <tr><td>Shingle oak        </td><td>  205</td><td> 0.33</td></tr>
  <tr><td>Dawn redwood       </td><td>  199</td><td> 0.32</td></tr>
  <tr><td>English oak        </td><td>  197</td><td> 0.32</td></tr>
  <tr><td>⋮</td><td>⋮</td><td>⋮</td></tr>
  <tr><td>Two-winged silverbell</td><td>8</td><td>0.01</td></tr>
  <tr><td>American larch       </td><td>7</td><td>0.01</td></tr>
  <tr><td>Eastern hemlock      </td><td>7</td><td>0.01</td></tr>
  <tr><td>Southern red oak     </td><td>7</td><td>0.01</td></tr>
  <tr><td>Crimson king maple   </td><td>6</td><td>0.01</td></tr>
  <tr><td>European beech       </td><td>6</td><td>0.01</td></tr>
  <tr><td>Himalayan cedar      </td><td>6</td><td>0.01</td></tr>
  <tr><td>Arborvitae           </td><td>5</td><td>0.01</td></tr>
  <tr><td>Bigtooth aspen       </td><td>5</td><td>0.01</td></tr>
  <tr><td>Crepe myrtle         </td><td>5</td><td>0.01</td></tr>
  <tr><td>Pitch pine           </td><td>5</td><td>0.01</td></tr>
  <tr><td>Blue spruce          </td><td>4</td><td>0.01</td></tr>
  <tr><td>Black pine           </td><td>3</td><td>0.00</td></tr>
  <tr><td>Cockspur hawthorn    </td><td>3</td><td>0.00</td></tr>
  <tr><td>Norway spruce        </td><td>3</td><td>0.00</td></tr>
  <tr><td>Pine                 </td><td>3</td><td>0.00</td></tr>
  <tr><td>Virginia pine        </td><td>3</td><td>0.00</td></tr>
  <tr><td>Boxelder             </td><td>2</td><td>0.00</td></tr>
  <tr><td>Douglas-fir          </td><td>2</td><td>0.00</td></tr>
  <tr><td>European alder       </td><td>2</td><td>0.00</td></tr>
  <tr><td>Quaking aspen        </td><td>2</td><td>0.00</td></tr>
  <tr><td>Scots pine           </td><td>2</td><td>0.00</td></tr>
  <tr><td>Osage-orange         </td><td>1</td><td>0.00</td></tr>
  <tr><td>Persian ironwood     </td><td>1</td><td>0.00</td></tr>
  <tr><td>Pignut hickory       </td><td>1</td><td>0.00</td></tr>
  <tr><td>Red horse chestnut   </td><td>1</td><td>0.00</td></tr>
  <tr><td>Red pine             </td><td>1</td><td>0.00</td></tr>
  <tr><td>Smoketree            </td><td>1</td><td>0.00</td></tr>
  <tr><td>Spruce               </td><td>1</td><td>0.00</td></tr>
  <tr><td>White pine           </td><td>1</td><td>0.00</td></tr>
</tbody>
</table>



<img src="documentation/pop_attributes_stacked_bar_plot.png" alt="" title=""/>

### Tree Species
Using spatial, descriptive, and correlation analyses, the following information outlines the biodiversity, biology, and ranking in terms of desirable traits of the tree species in Manhattan:
#### Biodiversity
##### Richness
Richness is referred to as the number of species within a defined region. With respect to Manhattan, ${128}$ species were identified among ${N_{I} =62,428}$ trees, while the remaining ${N_{U} = 1,801}$ have species which are unidentified in the census. In terms of the neighborhoods, the ten with the highest richness (of identified species) are:

 1. Washington Heights North (MN35)<br/>
 2. Lower East Side (MN28)<br/>
 3. Washington Heights South (MN36)<br/>
 4. West Village (MN23)<br/>
 5. Central Harlem North-Polo Grounds (MN03)<br/>
 6. Hamilton Heights (MN04)<br/>
 7. Upper West Side (MN12)<br/>
 8. Upper East Side-Carnegie Hill (MN40)<br/>
 9. Central Harlem South (MN11)<br/>
10. East Village (MN22)


```R
defaultW <- getOption("warn")
options(warn=-1)

# Top 10 NTAs with the highest species richness
top_ten_nbh_rchns <- nbh_rchns %>%
  slice(1:10) %>%
  rownames_to_column("rank")

# HTML Table for Top 10 Most Abundant Species
#kable(for_table_nbh_rchns, 
#      caption = " ",
#      label = "tables", format = "html", booktabs = TRUE)

# Order by richness
nbhs_map$nta_and_rchns <- factor(
    nbhs_map$nta_and_rchns,
       levels = (nbhs_map %>% arrange(desc(richness)))$nta_and_rchns,
       ordered = TRUE
)

# Map of NTAs' richness
nbh_rchns_map_plot <- ggplot() + 
  geom_sf(data = nbhs_map %>% filter(borough != "MN" | nta == "MN99"),
            fill="#E8EAED", color="grey") +
  geom_sf(data = nbhs_map %>% filter(borough == "MN", nta != "MN99"),
            aes(fill = richness,
                color = nta_and_rchns
               )
           ) + 
    stat_sf_coordinates(data = nbhs_map %>% filter(borough == "MN", nta != "MN99") %>%
                        inner_join(nbh_rchns, by = c("nta", "nta_name")) %>%
                          filter(nta %in% top_ten_nbh_rchns$nta),
                        color="grey25", size = 0.5) +
    theme(legend.position = c(0.3518, 0.5), 
          legend.justification=0.0,
          legend.key.width = unit(2.5, 'mm'),
        legend.key.height = unit(1.8, 'mm'), 
          legend.direction="vertical",
          legend.background = element_roundrect(r = grid::unit(0.02, "snpc"),
                                               fill = alpha("#FFFFFF", 0.90)),
          legend.key = element_rect(fill=NA),
          legend.text = element_text(margin = margin(r=5, unit="pt"),
                                   color="#65707C",
                                     family="sans serif"),
          legend.title = element_text(face="bold",
                                      color="#65707C",
                                      size=8.5,
                                      family="sans serif"),
          axis.title = element_text(color="#65707C",
                                    face="bold",
                                    family="sans serif"),
          axis.text = element_text(color="#65707C",
                                   size=7,
                                   family="sans serif"),
          axis.text.x = element_text(angle=90,
                                     vjust=0.5,
                                     hjust=1),
          axis.line = element_line(colour="grey",
                                   linewidth=0.5),
          panel.grid.major = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.25),
          
          panel.border = element_rect(color="grey40",
                                      fill=NA),  
          panel.spacing = unit(2, "lines"),
          panel.background  = element_roundrect(r = grid::unit(0.001, "snpc"),
                                               fill = alpha("#9CC0F9", 1)),
          plot.title = element_text(color="#65707C",
                                    hjust=1.8,
                                    vjust=10,
                                    size=14,
                                    family="sans serif")) +
     labs(x="", y="", color="    Code - Richnesss : Name"
             ) +
     ggtitle("Fig. 7: Map of Tree Species Richness of Manhattan's Neighborhoods") +
  scale_x_continuous(expand = c(0.01, 0),
                       limits = c(-74.04, -73.64), 
                       breaks = seq(-74.04, -73.64, by=0.02)) +
  scale_y_continuous(expand = c(0.01, 0),
                       limits = c(40.68, 40.88), 
                       breaks = seq(40.68, 40.88, by=0.02)) +
  scale_color_manual(values = replicate(28, "grey25")) +
  scale_fill_gradient2(low = "#E3EDE5",
                         high = "#068409") +
  ggrepel::geom_label_repel(data = nbhs_map %>% filter(nta %in% top_ten_nbh_rchns$nta),
                              aes(label = nta, geometry = geometry),
                              stat="sf_coordinates",
                              min.segment.length=0,
                              label.size=NA,
                              alpha=0.5) +
  coord_sf(xlim = c(-74.04, -73.64), ylim = c(40.68, 40.88))     

# Extract NTA fill colors
color_scheme_3 <- as.data.frame(ggplot_build(nbh_rchns_map_plot)$data[[2]])$fill

nbh_rchns_map_plot2 <- nbh_rchns_map_plot +
  guides(fill = "none",
           color = guide_legend(ncol=1,
                                override.aes = list(color = NA,
                                                    fill = color_scheme_3,
                                                    linewidth=0))
          )

options(warn = defaultW)
```


```R
top_ten_nbh_rchns
```


<table class="dataframe">
<caption>A tibble: 10 × 4</caption>
<thead>
  <tr><th scope=col>rank</th><th scope=col>nta</th><th scope=col>nta_name</th><th scope=col>richness</th></tr>
  <tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;int&gt;</th></tr>
</thead>
<tbody>
  <tr><td>1 </td><td>MN35</td><td>Washington Heights North         </td><td>81</td></tr>
  <tr><td>2 </td><td>MN28</td><td>Lower East Side                  </td><td>78</td></tr>
  <tr><td>3 </td><td>MN36</td><td>Washington Heights South         </td><td>77</td></tr>
  <tr><td>4 </td><td>MN23</td><td>West Village                     </td><td>76</td></tr>
  <tr><td>5 </td><td>MN03</td><td>Central Harlem North-Polo Grounds</td><td>75</td></tr>
  <tr><td>6 </td><td>MN04</td><td>Hamilton Heights                 </td><td>73</td></tr>
  <tr><td>7 </td><td>MN12</td><td>Upper West Side                  </td><td>73</td></tr>
  <tr><td>8 </td><td>MN40</td><td>Upper East Side-Carnegie Hill    </td><td>73</td></tr>
  <tr><td>9 </td><td>MN11</td><td>Central Harlem South             </td><td>71</td></tr>
  <tr><td>10</td><td>MN22</td><td>East Village                     </td><td>68</td></tr>
</tbody>
</table>



<img src="documentation/nbh_rchns_map_plot2.png" alt="" title=""/>

##### Abundance

In this context, abundance is defined as the number of Manhattan trees per species, while relative abundance is the share of trees a certain species has in relation to the total number of trees in Manhattan. Among the $128$ and other unidentified tree species in Manhattan, the ten most abundant are:
 1. Honeylocust<br/>
 2. Callery pea<br/>
 3. Ginkgo<br/>
 4. Pin oak<br/>
 5. Sophora<br/>
 6. London planetree<br/>
 7. Japanese zelkova<br/>
 8. Littleleaf linden<br/>
 9. American elm<br/>
10. American linden


```R
spc_abd %>% mutate(round(relative_abundance*100,2))
```


    Error: object 'spc_abd' not found
    Traceback:


    1. mutate(., round(relative_abundance * 100, 2))

    2. .handleSimpleError(function (cnd) 
     . {
     .     watcher$capture_plot_and_output()
     .     cnd <- sanitize_call(cnd)
     .     watcher$push(cnd)
     .     switch(on_error, continue = invokeRestart("eval_continue"), 
     .         stop = invokeRestart("eval_stop"), error = NULL)
     . }, "object 'spc_abd' not found", base::quote(eval(expr, envir)))



```R
# Species abundance and relative abundance
spc_abd <- trees %>% 
  filter(spc_common != "null") %>%
  group_by(spc_common) %>%
  summarize(abundance = n()) %>%  
  ungroup() %>%
  mutate(relative_abundance = abundance/sum(abundance)) %>%
  arrange(desc(abundance))

# Table for Top 10 Most Abundant Species
for_table_spc_abd <- spc_abd %>%
  slice(1:10) %>%
  rownames_to_column("rank") %>%
  mutate(abundance = prettyNum(abundance,big.mark=","),
           perc_relative_abundance = label_percent(accuracy=0.01)(relative_abundance))

# HTML Table for Top 10 Most Abundant Species
#kable(for_table_spc_abd, 
#      caption = " ",
#      label = "tables", format = "html", booktabs = TRUE)

# Bar graph for Top 25 tree species
top_species_bar_plot <- ggplot(spc_abd %>% slice(1:25)) + 
  geom_chicklet(aes(x = fct_reorder(spc_common,
                                    abundance),
                      y = abundance), 
                  fill="#10401B",
                  radius = grid::unit(1, "mm"), position="stack") +
  coord_flip() +
  theme(legend.position="none",
          axis.title = element_text(color = "#65707C",
                                    face="bold",
                                    family="sans serif"),
          axis.text = element_text(color = "#65707C",
                                   size=12,
                                   family="sans serif"),
          axis.title.x = element_text(margin=margin(20,0,10,0)),
          axis.title.y = element_text(margin=margin(0,20,0,10)),
          axis.line = element_line(colour = "grey",
                                   linewidth = 0.5),
          panel.grid.major = element_line(color = "grey",
                                          linetype="dashed",
                                          linewidth=0.25),
          panel.background = element_blank(),
          plot.title = element_text(color = "#65707C",
                                    hjust = 1.03,
                                    vjust = 4,
                                    size= 14,
                                    family = "sans serif",
                                    margin=margin(0,0,20,0))) +
  ggtitle("
\nFig. 8: Bar Graph of the 25 Most Abundant Tree Species in Manhattan ") +
  labs(x="Common name of the species", y="Abundance (% relative abundance)") +
  scale_y_continuous(expand = c(0.01, 0), limits = c(0,13500),
                      breaks = seq(0, 13500, by=2000)) +
  geom_text(aes(label = paste(prettyNum(abundance, big.mark=","),
                                " (", label_percent(accuracy=0.01)(relative_abundance),")",
                                sep=""),
                                 x = spc_common,
                                 y = ifelse(between(rank(desc(abundance)),3,10), abundance-807.5,
                                           ifelse(between(rank(desc(abundance)),2,2), abundance-880,
                                           ifelse(between(rank(desc(abundance)),1,1), abundance-980,
                                           ifelse(between(rank(desc(abundance)),11,11), abundance+770,
                                           abundance+670)))),
                  color = ifelse(between(rank(desc(abundance)),1,10), "white",
                                           "#65707C")),
              size = 2) +
scale_color_manual(values=c("#65707C","white"))

#spc_abd %>%
#mutate(abundance = prettyNum(abundance,big.mark=","),
#         perc_relative_abundance = label_percent(accuracy=0.01)(relative_abundance)) %>%select(-relative_abundance)
```

<img src="documentation/top_species_bar_plot.png" alt="" title=""/>

You can see in more details using the table below the species and their abundances (and relative abundances) with respect to the neighborhoods they belong to:


```R
spc_abd_nbh <- nbh_spc_long %>%
  group_by(nta, nta_name) %>%
  filter(!(number_of_trees == 0)) %>%
  rename(abundance_wrt_nta = number_of_trees) %>%
  select(starts_with("nta"), spc_common, everything()) %>%
  mutate(relative_abundance_wrt_nta = label_percent(accuracy=0.01)(abundance_wrt_nta/sum(abundance_wrt_nta))) %>% 
  arrange(nta, desc(abundance_wrt_nta)) %>%
  ungroup()

spc_abd_nbh
```


<table class="dataframe">
<caption>A tibble: 1664 × 5</caption>
<thead>
  <tr><th scope=col>nta</th><th scope=col>nta_name</th><th scope=col>spc_common</th><th scope=col>abundance_wrt_nta</th><th scope=col>relative_abundance_wrt_nta</th></tr>
  <tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;chr&gt;</th></tr>
</thead>
<tbody>
  <tr><td>MN01</td><td>Marble Hill-Inwood</td><td>Japanese zelkova    </td><td>225</td><td>15.65%</td></tr>
  <tr><td>MN01</td><td>Marble Hill-Inwood</td><td>Honeylocust         </td><td>175</td><td>12.17%</td></tr>
  <tr><td>MN01</td><td>Marble Hill-Inwood</td><td>Sophora             </td><td>131</td><td>9.11% </td></tr>
  <tr><td>MN01</td><td>Marble Hill-Inwood</td><td>Ginkgo              </td><td>115</td><td>8.00% </td></tr>
  <tr><td>MN01</td><td>Marble Hill-Inwood</td><td>Pin oak             </td><td>110</td><td>7.65% </td></tr>
  <tr><td>MN01</td><td>Marble Hill-Inwood</td><td>Littleleaf linden   </td><td>104</td><td>7.23% </td></tr>
  <tr><td>MN01</td><td>Marble Hill-Inwood</td><td>Callery pear        </td><td> 74</td><td>5.15% </td></tr>
  <tr><td>MN01</td><td>Marble Hill-Inwood</td><td>American linden     </td><td> 61</td><td>4.24% </td></tr>
  <tr><td>MN01</td><td>Marble Hill-Inwood</td><td>American elm        </td><td> 48</td><td>3.34% </td></tr>
  <tr><td>MN01</td><td>Marble Hill-Inwood</td><td>Northern red oak    </td><td> 48</td><td>3.34% </td></tr>
  <tr><td>MN01</td><td>Marble Hill-Inwood</td><td>London planetree    </td><td> 46</td><td>3.20% </td></tr>
  <tr><td>MN01</td><td>Marble Hill-Inwood</td><td>Sawtooth oak        </td><td> 29</td><td>2.02% </td></tr>
  <tr><td>MN01</td><td>Marble Hill-Inwood</td><td>Silver linden       </td><td> 26</td><td>1.81% </td></tr>
  <tr><td>MN01</td><td>Marble Hill-Inwood</td><td>Swamp white oak     </td><td> 19</td><td>1.32% </td></tr>
  <tr><td>MN01</td><td>Marble Hill-Inwood</td><td>Green ash           </td><td> 18</td><td>1.25% </td></tr>
  <tr><td>MN01</td><td>Marble Hill-Inwood</td><td>Norway maple        </td><td> 17</td><td>1.18% </td></tr>
  <tr><td>MN01</td><td>Marble Hill-Inwood</td><td>Willow oak          </td><td> 17</td><td>1.18% </td></tr>
  <tr><td>MN01</td><td>Marble Hill-Inwood</td><td>Shingle oak         </td><td> 13</td><td>0.90% </td></tr>
  <tr><td>MN01</td><td>Marble Hill-Inwood</td><td>Sassafras           </td><td> 12</td><td>0.83% </td></tr>
  <tr><td>MN01</td><td>Marble Hill-Inwood</td><td>Tulip-poplar        </td><td> 11</td><td>0.76% </td></tr>
  <tr><td>MN01</td><td>Marble Hill-Inwood</td><td>Cherry              </td><td> 10</td><td>0.70% </td></tr>
  <tr><td>MN01</td><td>Marble Hill-Inwood</td><td>Common hackberry    </td><td>  9</td><td>0.63% </td></tr>
  <tr><td>MN01</td><td>Marble Hill-Inwood</td><td>Dawn redwood        </td><td>  8</td><td>0.56% </td></tr>
  <tr><td>MN01</td><td>Marble Hill-Inwood</td><td>Red maple           </td><td>  8</td><td>0.56% </td></tr>
  <tr><td>MN01</td><td>Marble Hill-Inwood</td><td>American hophornbeam</td><td>  7</td><td>0.49% </td></tr>
  <tr><td>MN01</td><td>Marble Hill-Inwood</td><td>Black walnut        </td><td>  7</td><td>0.49% </td></tr>
  <tr><td>MN01</td><td>Marble Hill-Inwood</td><td>Chinese tree lilac  </td><td>  7</td><td>0.49% </td></tr>
  <tr><td>MN01</td><td>Marble Hill-Inwood</td><td>Empress tree        </td><td>  7</td><td>0.49% </td></tr>
  <tr><td>MN01</td><td>Marble Hill-Inwood</td><td>Eastern hemlock     </td><td>  6</td><td>0.42% </td></tr>
  <tr><td>MN01</td><td>Marble Hill-Inwood</td><td>Japanese snowbell   </td><td>  5</td><td>0.35% </td></tr>
  <tr><td>⋮</td><td>⋮</td><td>⋮</td><td>⋮</td><td>⋮</td></tr>
  <tr><td>MN40</td><td>Upper East Side-Carnegie Hill </td><td>Hedge maple          </td><td>  1</td><td>0.02% </td></tr>
  <tr><td>MN40</td><td>Upper East Side-Carnegie Hill </td><td>Horse chestnut       </td><td>  1</td><td>0.02% </td></tr>
  <tr><td>MN40</td><td>Upper East Side-Carnegie Hill </td><td>Japanese maple       </td><td>  1</td><td>0.02% </td></tr>
  <tr><td>MN40</td><td>Upper East Side-Carnegie Hill </td><td>Japanese snowbell    </td><td>  1</td><td>0.02% </td></tr>
  <tr><td>MN40</td><td>Upper East Side-Carnegie Hill </td><td>Mulberry             </td><td>  1</td><td>0.02% </td></tr>
  <tr><td>MN40</td><td>Upper East Side-Carnegie Hill </td><td>Pagoda dogwood       </td><td>  1</td><td>0.02% </td></tr>
  <tr><td>MN40</td><td>Upper East Side-Carnegie Hill </td><td>Paper birch          </td><td>  1</td><td>0.02% </td></tr>
  <tr><td>MN40</td><td>Upper East Side-Carnegie Hill </td><td>Southern red oak     </td><td>  1</td><td>0.02% </td></tr>
  <tr><td>MN40</td><td>Upper East Side-Carnegie Hill </td><td>Two-winged silverbell</td><td>  1</td><td>0.02% </td></tr>
  <tr><td>MN50</td><td>Stuyvesant Town-Cooper Village</td><td>Honeylocust          </td><td>279</td><td>63.70%</td></tr>
  <tr><td>MN50</td><td>Stuyvesant Town-Cooper Village</td><td>London planetree     </td><td> 81</td><td>18.49%</td></tr>
  <tr><td>MN50</td><td>Stuyvesant Town-Cooper Village</td><td>Japanese zelkova     </td><td> 11</td><td>2.51% </td></tr>
  <tr><td>MN50</td><td>Stuyvesant Town-Cooper Village</td><td>Sophora              </td><td> 11</td><td>2.51% </td></tr>
  <tr><td>MN50</td><td>Stuyvesant Town-Cooper Village</td><td>Ginkgo               </td><td>  6</td><td>1.37% </td></tr>
  <tr><td>MN50</td><td>Stuyvesant Town-Cooper Village</td><td>Pin oak              </td><td>  6</td><td>1.37% </td></tr>
  <tr><td>MN50</td><td>Stuyvesant Town-Cooper Village</td><td>American linden      </td><td>  5</td><td>1.14% </td></tr>
  <tr><td>MN50</td><td>Stuyvesant Town-Cooper Village</td><td>Callery pear         </td><td>  5</td><td>1.14% </td></tr>
  <tr><td>MN50</td><td>Stuyvesant Town-Cooper Village</td><td>Common hackberry     </td><td>  5</td><td>1.14% </td></tr>
  <tr><td>MN50</td><td>Stuyvesant Town-Cooper Village</td><td>Littleleaf linden    </td><td>  5</td><td>1.14% </td></tr>
  <tr><td>MN50</td><td>Stuyvesant Town-Cooper Village</td><td>Swamp white oak      </td><td>  5</td><td>1.14% </td></tr>
  <tr><td>MN50</td><td>Stuyvesant Town-Cooper Village</td><td>Kentucky coffeetree  </td><td>  4</td><td>0.91% </td></tr>
  <tr><td>MN50</td><td>Stuyvesant Town-Cooper Village</td><td>American elm         </td><td>  3</td><td>0.68% </td></tr>
  <tr><td>MN50</td><td>Stuyvesant Town-Cooper Village</td><td>Northern red oak     </td><td>  3</td><td>0.68% </td></tr>
  <tr><td>MN50</td><td>Stuyvesant Town-Cooper Village</td><td>White oak            </td><td>  3</td><td>0.68% </td></tr>
  <tr><td>MN50</td><td>Stuyvesant Town-Cooper Village</td><td>Amur maackia         </td><td>  1</td><td>0.23% </td></tr>
  <tr><td>MN50</td><td>Stuyvesant Town-Cooper Village</td><td>Amur maple           </td><td>  1</td><td>0.23% </td></tr>
  <tr><td>MN50</td><td>Stuyvesant Town-Cooper Village</td><td>Green ash            </td><td>  1</td><td>0.23% </td></tr>
  <tr><td>MN50</td><td>Stuyvesant Town-Cooper Village</td><td>Sawtooth oak         </td><td>  1</td><td>0.23% </td></tr>
  <tr><td>MN50</td><td>Stuyvesant Town-Cooper Village</td><td>Shingle oak          </td><td>  1</td><td>0.23% </td></tr>
  <tr><td>MN50</td><td>Stuyvesant Town-Cooper Village</td><td>Tree of heaven       </td><td>  1</td><td>0.23% </td></tr>
</tbody>
</table>



##### Diversity
To describe the overall species diversity in Manhattan, a quantitative measure called Simpson's Diversity Index $(SDI)$ is used, which takes into account the species richness and evenness (or the distribution of abundance across the tree species in a community). The formula is given by:

<div align="center">
    
${D} = {1- \frac{\sum \limits _{i=1} ^{128} n_{i}({n_{i}-1})} {N_{I}({N_{I}-1})} } $

</div>
<br/>

where ${D}$ = Simpson's Diversity Index $(SDI)$;<br/>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;${n_{i}}$ = ${i^{th}}$ species abundance;<br/>
           &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;${N_{I}}$ = number of trees with identified species = ${62,428}$ 
           
With that, the computed $SDI$ value is $0.909$. This means that there is a very high diversity of tree species in Manhattan, and the chance of distinct species among two randomly selected trees from a sample is $90.9\%$. 


```R
# Simpson's Diversity Index (SDI)
mnh_sdi <- spc_abd %>%
  filter(!is.na(spc_common)) %>%
   select(-relative_abundance) %>%
   mutate(numerator = abundance*(abundance-1)) %>%
   summarize(SDI = 1-(sum(numerator)/(sum(abundance)*(sum(abundance)-1))),
               number_of_trees = sum(abundance),
               richness = n())
```

#### Biology

**Size:** Tree sizes of the species were compared through their median trunk diameter at breast height $(DBH)$. 

Fig. 9 shows the Top 25 largest species in terms of this metric:


```R
# The table below shows each species' summary statistics and is arranged by descending median $dbh$, while 

# Summary statistics of species' tree dbh
spc_tree_dbh_stats <- trees %>% 
  group_by(spc_common) %>%
  filter(!is.na(spc_common), !is.na(tree_dbh)) %>%
  summarize(abundance = n(),
              mean_tree_dbh = mean(tree_dbh),
              sd_tree_dbh = sd(tree_dbh),
              min_tree_dbh = min(tree_dbh),
              first_quartile_tree_dbh = quantile(tree_dbh, probs=0.25),
              median_tree_dbh = median(tree_dbh),
              third_quartile_tree_dbh = quantile(tree_dbh, probs=0.75),
              max_tree_dbh = max(tree_dbh))  %>%
  arrange(desc(median_tree_dbh))

# Top 25 species in terms of median dbh
top_spc_tree_dbh_stats <- spc_tree_dbh_stats #%>%
  #filter out species with abundances less than the median abundances
#filter(abundance >= median(abundance)) %>%
#select(spc_common, abundance, median_tree_dbh, everything())

# Bar graph for Top 30 tree species
top_spc_dbh_plot <- ggplot(top_spc_tree_dbh_stats %>% slice(1:25)) + 
  geom_chicklet(aes(x = fct_reorder(spc_common,
                                    median_tree_dbh),
                      y = median_tree_dbh), 
                  fill="#10401B",
                  radius = grid::unit(1, "mm"), position="stack") +
  coord_flip() +
  theme(axis.title = element_text(color = "#65707C",
                                    face="bold",
                                    family="sans serif"),
          axis.text = element_text(color = "#65707C",
                                   size=12,
                                   family="sans serif"),
          axis.title.x = element_text(margin=margin(20,0,10,0)),
          axis.title.y = element_text(margin=margin(0,20,0,10)),
          axis.line = element_line(colour = "grey",
                                   linewidth = 0.5),
          panel.grid.major = element_line(color = "grey",
                                          linetype="dashed",
                                          linewidth=0.25),
          panel.background = element_blank(),
          plot.title = element_text(color="#65707C",
                                    hjust=1.13,
                                    size=14,
                                    family="sans serif"),
          plot.subtitle = element_text(color="#65707C",
                                    hjust=2.02,
                                    size=10,
                                    family="sans serif")) +   
  ggtitle("\nFig. 9: Bar Graph of the Top 25 Largest Tree Species in Manhattan",
            subtitle="(in terms of median trunk diameter at breast height (DBH) of 54 inches)\n") +
  labs(x="\nCommon name of the species\n", y="Trunk diameter in inches\n") +
  scale_y_continuous(expand = c(0.01, 0),
                       limits = c(0, 15.5),
                       breaks = seq(0, 15.5, by=3)) +
  geom_text(aes(label = median_tree_dbh,
                                 x = spc_common,
                                 y = median_tree_dbh-0.4),
              size = 3, color = "white")

#spc_tree_dbh_stats %>% mutate_if(is.numeric, #list(~prettyNum(., big.mark=","))) %>% select(spc_common, abundance, #median_tree_dbh, everything())

#summary(lm(spc_tree_dbh_stats$abundance~spc_tree_dbh_stats$median_tree_dbh))
#shapiro.test(lm(spc_tree_dbh_stats$abundance~spc_tree_dbh_stats$median_tree_dbh)$residuals)
#abd_dbh_corr <- cor(spc_tree_dbh_stats$abundance, spc_tree_dbh_stats$median_tree_dbh, method="kendall")
#abd_dbh_corr
```

<img src="documentation/top_spc_dbh_plot.png" alt="" title=""/>

**Health-Related**: Out of the $128$ species that have been identified, $127$ have $100\%$ of their trees being alive, while the remaining one, honeylocust, has $99.99\%$. As for the health, a numerical value called health index $(HI)$ was computed for each species. This was done by assigning a number, ${j} ∈ \{1,2,3\}$, to the categories of "$Poor$", "$Fair$", and "$Good$" health, respectively, and then using the formula:

<div align="center">
    
${HI_{i}} =  \frac {\sum \limits _{j=1} ^{3} j{a}_{j}}{3 n_{i}} $
    
</div>
<br/>
    
where ${HI_{i}}$ = health index of the $i^{th}$ species;<br/>
               &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;${a_{j}}$ = species abundance with respect to the $j^{th}$ health category;<br/>
           &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;${n_{i}}$ =  ${i^{th}}$ species abundance
 
Fig. 10 shows the $25$ species with the highest $HI$ value as well as the distribution of their relative abundances across health categories.


```R
# Status per species
spc_status <- trees %>% 
  filter(!(is.na(spc_common) | is.na(spc_common))) %>%
  group_by(spc_common, status) %>%
  summarize(number_of_trees = n(), .groups="keep") %>%
  group_by(spc_common) %>%
  mutate(proportion_wrt_spc = number_of_trees/sum(number_of_trees),
           percentage_wrt_spc = label_percent(accuracy=0.01)(proportion_wrt_spc)) %>%
  arrange(proportion_wrt_spc) %>%
  select(-proportion_wrt_spc) %>%
  ungroup()
```


```R
# Health per species
spc_health <- trees %>% 
  filter(!is.na(spc_common), !is.na(health)) %>%
  group_by(spc_common, health) %>%
  summarize(number_of_trees = n(), .groups="keep") %>%
  group_by(spc_common) %>%
  mutate(proportion = number_of_trees/sum(number_of_trees),
           percentage = label_percent(accuracy=0.01)(proportion),
           health = as.factor(health)) %>%
  arrange(spc_common, desc(proportion)) %>%
  ungroup()


spc_health_index <- spc_health %>%
  group_by(spc_common) %>%
  mutate(health_score = ifelse(health=="Good", 3*number_of_trees,
                                 ifelse(health=="Fair", 2*number_of_trees,
                                        1*number_of_trees)),
          health_index = sum(health_score)/(3*sum(number_of_trees))) %>%
  ungroup() %>%
  select(spc_common, number_of_trees, health_index) %>%
  group_by(spc_common) %>%
  mutate(number_of_trees = sum(number_of_trees)) %>%
  distinct(spc_common, number_of_trees, health_index) %>%
  arrange(desc(health_index)) %>%
  ungroup() %>%
  rename(abundance = number_of_trees)

for_graph_top_spc_health <- spc_health %>%
  filter(spc_common %in% (
        spc_health_index %>%
        #filter out species with abundances less than the median abundances
#filter(abundance >= median(spc_tree_dbh_stats$abundance)) %>% 
                              top_n(25, health_index))$spc_common) %>%
  arrange(desc(proportion))

# Order health per species
for_graph_top_spc_health$health <- factor(
    for_graph_top_spc_health$health,
    levels = c("Poor", "Fair", "Good"),
    ordered = TRUE
)

# Order species by proportion of 'Good' health
for_graph_top_spc_health$spc_common <- factor(
    for_graph_top_spc_health$spc_common,
    levels = rev((for_graph_top_spc_health %>% filter(health == "Good"))$spc_common),
    ordered = TRUE
)

top_spc_health_highest <- for_graph_top_spc_health %>% 
  group_by(spc_common) %>%
  filter(proportion == max(abs(proportion)))

top_spc_health_stacked_bar_plot <- ggplot(for_graph_top_spc_health) + 
  geom_chicklet(aes(x = spc_common, y = proportion*100, fill = health), 
                  radius = grid::unit(0.75, "mm"), position="stack") +
  coord_flip() +
  theme(legend.position = "right",
          legend.justification="top",
          legend.direction="vertical",
          legend.key.size = unit(0, 'pt'),
          legend.key = element_rect(fill = NA),
          legend.text = element_text(margin = margin(r = 4, unit = "pt"),
                                     color = "#65707C",
                                     family="sans serif"),
          legend.title = element_text(color = "#65707C",
                                      face="bold",
                                      size = 9,
                                      family="sans serif"),
      axis.title = element_text(color="#65707C",
                                    face="bold",
                                    family="sans serif"),
          axis.text.x = element_text(color="#65707C",
                                   size=6,
                                   family="sans serif"),
          axis.text.y = element_text(color="#65707C",
                                   size=10,
                                   family="sans serif"),
          axis.line = element_line(colour="grey",
                                   linewidth=0.5),
          panel.grid.major = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.25),
          panel.background = element_blank(),
          plot.subtitle = element_text(color="#65707C",
                                    hjust=-2.07,
                                    size=10,
                                    family="sans serif"),
          plot.title = element_text(color = "#65707C",
                                    hjust = 0.74,
                                    size= 12,
                                    family = "sans serif")) +
  scale_fill_manual(values = c("#89E7B3",
                 "#40C17E",
                                 "#1F9153")) +     
  ggtitle("\nFig. 10: Proportional Stacked Bar Graph of the Top 25 Healthiest Tree Species",
            subtitle="               (in terms of health index (HI) value)\n") +
  labs(x="\nCommon name of the species\n", y="\n% relative abundance\n", fill="Health: ") +
    guides(fill = guide_legend(ncol=1,
                               override.aes = list(shape = 15,
                                                   size = 4))) +
  scale_y_continuous(expand = c(0.01, 0),
                       breaks = seq(0, 100, by=10)) +
  ggrepel::geom_text_repel(data = top_spc_health_highest %>% 
                              inner_join(spc_health_index, by="spc_common"),
                             aes(label = paste("HI: ", round(health_index, digits=2),
                                               ", Good: ", label_percent(
                                                   accuracy=0.01)(proportion), sep=""),
                                 x = spc_common,
                                 y = ifelse(proportion==1, 100*proportion-21.5,
                                            100*proportion-22)),
                             size=2.2, color="white", hjust=1)

#spc_health_index
#summary(lm(spc_health_index$abundance~spc_health_index$health_index))
#shapiro.test(lm(spc_health_index$abundance~spc_health_index$health_index)$residuals)
#abd_hi_corr <- cor(spc_health_index$abundance, spc_health_index$health_index, method="kendall")
#abd_hi_corr
```

<img src="documentation/top_spc_health_stacked_bar_plot.png" alt="" title=""/>

Paving stones as well as other trunk and branch problems also affect major tree parts (root, trunk, and branch) the most at a species level, similar to what is observed in the analysis of tree population.

Figs. 11 to 13 show the top 25 species with the highest percentage of their trees having at least one problem for each tree part.


```R
# For root problems' graph
spc_root_problems <- trees %>%
  select(spc_common, root_stone:root_other) %>%
  filter(spc_common != "null",
           if_all(-spc_common, ~ .x != "null")) %>%
  mutate(across(root_stone:root_other, ~ ifelse(.x == "Yes", 1, 0)),
           None = ifelse(root_stone == 0 &
                         root_grate == 0 &
                         root_other == 0, 1, 0)) %>%
  group_by(spc_common) %>%
  summarize(none = 100*sum(None)/n(),
              root_stone = 100*sum(root_stone)/n(),
              root_grate = 100*sum(root_grate)/n(),
              root_other = 100*sum(root_other)/n()) %>%
  rename(`Common name of the species` = spc_common,
           `''Paving stones` = root_stone,
           `'Metal grates` = root_grate,
           `Others` = root_other) %>% 
  ungroup() %>%
  filter(rank((none)) <= 25) %>%
  arrange((none)) %>%
    mutate_if(is.numeric, ~(round(., digits = 2))) %>%
  pivot_longer(cols = c(3:5), 
                 names_to = "Root problem",
                 values_to = "% of trees")
spc_root_problems
```


<table class="dataframe">
<caption>A tibble: 69 × 4</caption>
<thead>
  <tr><th scope=col>Common name of the species</th><th scope=col>none</th><th scope=col>Root problem</th><th scope=col>% of trees</th></tr>
  <tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;dbl&gt;</th></tr>
</thead>
<tbody>
  <tr><td>White pine       </td><td> 0.00</td><td>''Paving stones</td><td>100.00</td></tr>
  <tr><td>White pine       </td><td> 0.00</td><td>'Metal grates  </td><td>  0.00</td></tr>
  <tr><td>White pine       </td><td> 0.00</td><td>Others         </td><td>  0.00</td></tr>
  <tr><td>European beech   </td><td>16.67</td><td>''Paving stones</td><td> 50.00</td></tr>
  <tr><td>European beech   </td><td>16.67</td><td>'Metal grates  </td><td>  0.00</td></tr>
  <tr><td>European beech   </td><td>16.67</td><td>Others         </td><td> 50.00</td></tr>
  <tr><td>Tartar maple     </td><td>16.67</td><td>''Paving stones</td><td> 66.67</td></tr>
  <tr><td>Tartar maple     </td><td>16.67</td><td>'Metal grates  </td><td>  0.00</td></tr>
  <tr><td>Tartar maple     </td><td>16.67</td><td>Others         </td><td> 16.67</td></tr>
  <tr><td>Southern magnolia</td><td>26.32</td><td>''Paving stones</td><td> 57.89</td></tr>
  <tr><td>Southern magnolia</td><td>26.32</td><td>'Metal grates  </td><td>  0.00</td></tr>
  <tr><td>Southern magnolia</td><td>26.32</td><td>Others         </td><td> 21.05</td></tr>
  <tr><td>Norway spruce    </td><td>33.33</td><td>''Paving stones</td><td>  0.00</td></tr>
  <tr><td>Norway spruce    </td><td>33.33</td><td>'Metal grates  </td><td>  0.00</td></tr>
  <tr><td>Norway spruce    </td><td>33.33</td><td>Others         </td><td> 66.67</td></tr>
  <tr><td>Katsura tree     </td><td>42.11</td><td>''Paving stones</td><td> 28.95</td></tr>
  <tr><td>Katsura tree     </td><td>42.11</td><td>'Metal grates  </td><td> 21.05</td></tr>
  <tr><td>Katsura tree     </td><td>42.11</td><td>Others         </td><td>  7.89</td></tr>
  <tr><td>Tree of heaven   </td><td>45.19</td><td>''Paving stones</td><td> 43.27</td></tr>
  <tr><td>Tree of heaven   </td><td>45.19</td><td>'Metal grates  </td><td>  1.92</td></tr>
  <tr><td>Tree of heaven   </td><td>45.19</td><td>Others         </td><td> 12.50</td></tr>
  <tr><td>Sassafras        </td><td>47.06</td><td>''Paving stones</td><td> 35.29</td></tr>
  <tr><td>Sassafras        </td><td>47.06</td><td>'Metal grates  </td><td>  0.00</td></tr>
  <tr><td>Sassafras        </td><td>47.06</td><td>Others         </td><td> 23.53</td></tr>
  <tr><td>Boxelder         </td><td>50.00</td><td>''Paving stones</td><td> 50.00</td></tr>
  <tr><td>Boxelder         </td><td>50.00</td><td>'Metal grates  </td><td>  0.00</td></tr>
  <tr><td>Boxelder         </td><td>50.00</td><td>Others         </td><td>  0.00</td></tr>
  <tr><td>Cucumber magnolia</td><td>50.00</td><td>''Paving stones</td><td> 16.67</td></tr>
  <tr><td>Cucumber magnolia</td><td>50.00</td><td>'Metal grates  </td><td> 33.33</td></tr>
  <tr><td>Cucumber magnolia</td><td>50.00</td><td>Others         </td><td> 33.33</td></tr>
  <tr><td>⋮</td><td>⋮</td><td>⋮</td><td>⋮</td></tr>
  <tr><td>Ohio buckeye       </td><td>58.33</td><td>''Paving stones</td><td>29.17</td></tr>
  <tr><td>Ohio buckeye       </td><td>58.33</td><td>'Metal grates  </td><td> 0.00</td></tr>
  <tr><td>Ohio buckeye       </td><td>58.33</td><td>Others         </td><td>12.50</td></tr>
  <tr><td>Empress tree       </td><td>58.82</td><td>''Paving stones</td><td>41.18</td></tr>
  <tr><td>Empress tree       </td><td>58.82</td><td>'Metal grates  </td><td> 0.00</td></tr>
  <tr><td>Empress tree       </td><td>58.82</td><td>Others         </td><td> 0.00</td></tr>
  <tr><td>Cornelian cherry   </td><td>59.26</td><td>''Paving stones</td><td> 3.70</td></tr>
  <tr><td>Cornelian cherry   </td><td>59.26</td><td>'Metal grates  </td><td>33.33</td></tr>
  <tr><td>Cornelian cherry   </td><td>59.26</td><td>Others         </td><td> 3.70</td></tr>
  <tr><td>Crepe myrtle       </td><td>60.00</td><td>''Paving stones</td><td>40.00</td></tr>
  <tr><td>Crepe myrtle       </td><td>60.00</td><td>'Metal grates  </td><td> 0.00</td></tr>
  <tr><td>Crepe myrtle       </td><td>60.00</td><td>Others         </td><td> 0.00</td></tr>
  <tr><td>Eastern cottonwood </td><td>60.00</td><td>''Paving stones</td><td>30.00</td></tr>
  <tr><td>Eastern cottonwood </td><td>60.00</td><td>'Metal grates  </td><td> 0.00</td></tr>
  <tr><td>Eastern cottonwood </td><td>60.00</td><td>Others         </td><td>20.00</td></tr>
  <tr><td>Black walnut       </td><td>60.61</td><td>''Paving stones</td><td>39.39</td></tr>
  <tr><td>Black walnut       </td><td>60.61</td><td>'Metal grates  </td><td> 3.03</td></tr>
  <tr><td>Black walnut       </td><td>60.61</td><td>Others         </td><td> 0.00</td></tr>
  <tr><td>Japanese tree lilac</td><td>62.02</td><td>''Paving stones</td><td>22.48</td></tr>
  <tr><td>Japanese tree lilac</td><td>62.02</td><td>'Metal grates  </td><td> 8.53</td></tr>
  <tr><td>Japanese tree lilac</td><td>62.02</td><td>Others         </td><td>10.85</td></tr>
  <tr><td>Honeylocust        </td><td>62.15</td><td>''Paving stones</td><td>25.50</td></tr>
  <tr><td>Honeylocust        </td><td>62.15</td><td>'Metal grates  </td><td> 6.28</td></tr>
  <tr><td>Honeylocust        </td><td>62.15</td><td>Others         </td><td>10.66</td></tr>
  <tr><td>Japanese hornbeam  </td><td>64.52</td><td>''Paving stones</td><td>25.81</td></tr>
  <tr><td>Japanese hornbeam  </td><td>64.52</td><td>'Metal grates  </td><td> 3.23</td></tr>
  <tr><td>Japanese hornbeam  </td><td>64.52</td><td>Others         </td><td> 9.68</td></tr>
  <tr><td>Green ash          </td><td>65.45</td><td>''Paving stones</td><td>26.88</td></tr>
  <tr><td>Green ash          </td><td>65.45</td><td>'Metal grates  </td><td> 1.04</td></tr>
  <tr><td>Green ash          </td><td>65.45</td><td>Others         </td><td> 8.83</td></tr>
</tbody>
</table>




```R
# For trunk problems' graph
spc_trunk_problems <- trees %>%
  select(spc_common, trunk_wire:trnk_other) %>%
  filter(spc_common != "null",
           if_all(-spc_common, ~ .x != "null")) %>%
  mutate(across(trunk_wire:trnk_other, ~ ifelse(.x == "Yes", 1, 0)),
           None = ifelse(trunk_wire == 0 &
                         trnk_light == 0 &
                         trnk_other == 0, 1, 0)) %>%
  group_by(spc_common) %>%
  summarize(none = 100*sum(None)/n(),
              trunk_wire = 100*sum(trunk_wire)/n(),
              trnk_light = 100*sum(trnk_light)/n(),
              trnk_other = 100*sum(trnk_other)/n()) %>%
  rename(`Common name of the species` = spc_common,
           `''Wires or rope` = trunk_wire,
           `'Lighting installed` = trnk_light,
           `Others` = trnk_other) %>% 
  ungroup() %>%
  filter(rank((none)) <= 25) %>%
  arrange((none)) %>%
    mutate_if(is.numeric, ~(round(., digits = 2))) %>%
  pivot_longer(cols = c(3:5), 
                 names_to = "Trunk problem",
                 values_to = "% of trees")
spc_trunk_problems
```


<table class="dataframe">
<caption>A tibble: 75 × 4</caption>
<thead>
  <tr><th scope=col>Common name of the species</th><th scope=col>none</th><th scope=col>Trunk problem</th><th scope=col>% of trees</th></tr>
  <tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;dbl&gt;</th></tr>
</thead>
<tbody>
  <tr><td>Tartar maple      </td><td>41.67</td><td>''Wires or rope    </td><td> 0.00</td></tr>
  <tr><td>Tartar maple      </td><td>41.67</td><td>'Lighting installed</td><td> 0.00</td></tr>
  <tr><td>Tartar maple      </td><td>41.67</td><td>Others             </td><td>58.33</td></tr>
  <tr><td>Oklahoma redbud   </td><td>44.44</td><td>''Wires or rope    </td><td>11.11</td></tr>
  <tr><td>Oklahoma redbud   </td><td>44.44</td><td>'Lighting installed</td><td> 0.00</td></tr>
  <tr><td>Oklahoma redbud   </td><td>44.44</td><td>Others             </td><td>44.44</td></tr>
  <tr><td>Horse chestnut    </td><td>63.64</td><td>''Wires or rope    </td><td>18.18</td></tr>
  <tr><td>Horse chestnut    </td><td>63.64</td><td>'Lighting installed</td><td> 0.00</td></tr>
  <tr><td>Horse chestnut    </td><td>63.64</td><td>Others             </td><td>18.18</td></tr>
  <tr><td>Cockspur hawthorn </td><td>66.67</td><td>''Wires or rope    </td><td>33.33</td></tr>
  <tr><td>Cockspur hawthorn </td><td>66.67</td><td>'Lighting installed</td><td> 0.00</td></tr>
  <tr><td>Cockspur hawthorn </td><td>66.67</td><td>Others             </td><td> 0.00</td></tr>
  <tr><td>Crimson king maple</td><td>66.67</td><td>''Wires or rope    </td><td> 0.00</td></tr>
  <tr><td>Crimson king maple</td><td>66.67</td><td>'Lighting installed</td><td> 0.00</td></tr>
  <tr><td>Crimson king maple</td><td>66.67</td><td>Others             </td><td>33.33</td></tr>
  <tr><td>Paperbark maple   </td><td>66.67</td><td>''Wires or rope    </td><td> 0.00</td></tr>
  <tr><td>Paperbark maple   </td><td>66.67</td><td>'Lighting installed</td><td> 0.00</td></tr>
  <tr><td>Paperbark maple   </td><td>66.67</td><td>Others             </td><td>33.33</td></tr>
  <tr><td>Hedge maple       </td><td>69.57</td><td>''Wires or rope    </td><td> 4.35</td></tr>
  <tr><td>Hedge maple       </td><td>69.57</td><td>'Lighting installed</td><td> 0.00</td></tr>
  <tr><td>Hedge maple       </td><td>69.57</td><td>Others             </td><td>26.09</td></tr>
  <tr><td>Japanese snowbell </td><td>73.33</td><td>''Wires or rope    </td><td> 0.00</td></tr>
  <tr><td>Japanese snowbell </td><td>73.33</td><td>'Lighting installed</td><td> 0.00</td></tr>
  <tr><td>Japanese snowbell </td><td>73.33</td><td>Others             </td><td>26.67</td></tr>
  <tr><td>Pond cypress      </td><td>75.00</td><td>''Wires or rope    </td><td> 0.00</td></tr>
  <tr><td>Pond cypress      </td><td>75.00</td><td>'Lighting installed</td><td> 0.00</td></tr>
  <tr><td>Pond cypress      </td><td>75.00</td><td>Others             </td><td>25.00</td></tr>
  <tr><td>Silver maple      </td><td>77.46</td><td>''Wires or rope    </td><td> 8.45</td></tr>
  <tr><td>Silver maple      </td><td>77.46</td><td>'Lighting installed</td><td> 0.00</td></tr>
  <tr><td>Silver maple      </td><td>77.46</td><td>Others             </td><td>14.08</td></tr>
  <tr><td>⋮</td><td>⋮</td><td>⋮</td><td>⋮</td></tr>
  <tr><td>Tulip-poplar     </td><td>82.35</td><td>''Wires or rope    </td><td> 0.00</td></tr>
  <tr><td>Tulip-poplar     </td><td>82.35</td><td>'Lighting installed</td><td> 0.00</td></tr>
  <tr><td>Tulip-poplar     </td><td>82.35</td><td>Others             </td><td>17.65</td></tr>
  <tr><td>Paper birch      </td><td>82.98</td><td>''Wires or rope    </td><td> 2.13</td></tr>
  <tr><td>Paper birch      </td><td>82.98</td><td>'Lighting installed</td><td> 0.00</td></tr>
  <tr><td>Paper birch      </td><td>82.98</td><td>Others             </td><td>14.89</td></tr>
  <tr><td>European beech   </td><td>83.33</td><td>''Wires or rope    </td><td> 0.00</td></tr>
  <tr><td>European beech   </td><td>83.33</td><td>'Lighting installed</td><td> 0.00</td></tr>
  <tr><td>European beech   </td><td>83.33</td><td>Others             </td><td>16.67</td></tr>
  <tr><td>Mimosa           </td><td>83.33</td><td>''Wires or rope    </td><td>16.67</td></tr>
  <tr><td>Mimosa           </td><td>83.33</td><td>'Lighting installed</td><td> 0.00</td></tr>
  <tr><td>Mimosa           </td><td>83.33</td><td>Others             </td><td> 0.00</td></tr>
  <tr><td>Green ash        </td><td>84.16</td><td>''Wires or rope    </td><td> 3.77</td></tr>
  <tr><td>Green ash        </td><td>84.16</td><td>'Lighting installed</td><td> 0.39</td></tr>
  <tr><td>Green ash        </td><td>84.16</td><td>Others             </td><td>12.21</td></tr>
  <tr><td>Dawn redwood     </td><td>84.92</td><td>''Wires or rope    </td><td> 2.01</td></tr>
  <tr><td>Dawn redwood     </td><td>84.92</td><td>'Lighting installed</td><td> 0.00</td></tr>
  <tr><td>Dawn redwood     </td><td>84.92</td><td>Others             </td><td>13.57</td></tr>
  <tr><td>Japanese hornbeam</td><td>85.48</td><td>''Wires or rope    </td><td> 4.84</td></tr>
  <tr><td>Japanese hornbeam</td><td>85.48</td><td>'Lighting installed</td><td> 1.61</td></tr>
  <tr><td>Japanese hornbeam</td><td>85.48</td><td>Others             </td><td> 8.06</td></tr>
  <tr><td>Eastern hemlock  </td><td>85.71</td><td>''Wires or rope    </td><td> 0.00</td></tr>
  <tr><td>Eastern hemlock  </td><td>85.71</td><td>'Lighting installed</td><td> 0.00</td></tr>
  <tr><td>Eastern hemlock  </td><td>85.71</td><td>Others             </td><td>14.29</td></tr>
  <tr><td>Southern red oak </td><td>85.71</td><td>''Wires or rope    </td><td> 0.00</td></tr>
  <tr><td>Southern red oak </td><td>85.71</td><td>'Lighting installed</td><td> 0.00</td></tr>
  <tr><td>Southern red oak </td><td>85.71</td><td>Others             </td><td>14.29</td></tr>
  <tr><td>Sweetgum         </td><td>86.78</td><td>''Wires or rope    </td><td> 2.64</td></tr>
  <tr><td>Sweetgum         </td><td>86.78</td><td>'Lighting installed</td><td> 0.44</td></tr>
  <tr><td>Sweetgum         </td><td>86.78</td><td>Others             </td><td>10.13</td></tr>
</tbody>
</table>




```R
# For branch problems' graph
brch_trunk_problems <- trees %>%
  select(spc_common, brch_light:brch_other) %>%
  filter(spc_common != "null",
           if_all(-spc_common, ~ .x != "null")) %>%
  mutate(across(brch_light:brch_other, ~ ifelse(.x == "Yes", 1, 0)),
           None = ifelse(brch_light == 0 &
                         brch_shoe == 0 &
                         brch_other == 0, 1, 0)) %>%
  group_by(spc_common) %>%
  summarize(none = 100*sum(None)/n(),
              brch_light = 100*sum(brch_light)/n(),
              brch_shoe = 100*sum(brch_shoe)/n(),
              brch_other = 100*sum(brch_other)/n()) %>%
  rename(`Common name of the species` = spc_common,
           `''Lights or wires ` = brch_light,
           `'Shoes` = brch_shoe,
           `Others` = brch_other) %>% 
  ungroup() %>%
  filter(rank((none)) <= 25) %>%
  arrange((none)) %>%
    mutate_if(is.numeric, ~(round(., digits = 2))) %>%
  pivot_longer(cols = c(3:5), 
                 names_to = "Branch problem",
                 values_to = "% of trees")
brch_trunk_problems
```


<table class="dataframe">
<caption>A tibble: 75 × 4</caption>
<thead>
  <tr><th scope=col>Common name of the species</th><th scope=col>none</th><th scope=col>Branch problem</th><th scope=col>% of trees</th></tr>
  <tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;dbl&gt;</th></tr>
</thead>
<tbody>
  <tr><td>Boxelder          </td><td>50.00</td><td>''Lights or wires </td><td> 0.00</td></tr>
  <tr><td>Boxelder          </td><td>50.00</td><td>'Shoes            </td><td> 0.00</td></tr>
  <tr><td>Boxelder          </td><td>50.00</td><td>Others            </td><td>50.00</td></tr>
  <tr><td>Crimson king maple</td><td>50.00</td><td>''Lights or wires </td><td> 0.00</td></tr>
  <tr><td>Crimson king maple</td><td>50.00</td><td>'Shoes            </td><td> 0.00</td></tr>
  <tr><td>Crimson king maple</td><td>50.00</td><td>Others            </td><td>50.00</td></tr>
  <tr><td>European alder    </td><td>50.00</td><td>''Lights or wires </td><td> 0.00</td></tr>
  <tr><td>European alder    </td><td>50.00</td><td>'Shoes            </td><td> 0.00</td></tr>
  <tr><td>European alder    </td><td>50.00</td><td>Others            </td><td>50.00</td></tr>
  <tr><td>Tartar maple      </td><td>50.00</td><td>''Lights or wires </td><td> 8.33</td></tr>
  <tr><td>Tartar maple      </td><td>50.00</td><td>'Shoes            </td><td> 0.00</td></tr>
  <tr><td>Tartar maple      </td><td>50.00</td><td>Others            </td><td>50.00</td></tr>
  <tr><td>Maple             </td><td>67.57</td><td>''Lights or wires </td><td>10.81</td></tr>
  <tr><td>Maple             </td><td>67.57</td><td>'Shoes            </td><td> 0.00</td></tr>
  <tr><td>Maple             </td><td>67.57</td><td>Others            </td><td>21.62</td></tr>
  <tr><td>Southern magnolia </td><td>68.42</td><td>''Lights or wires </td><td> 0.00</td></tr>
  <tr><td>Southern magnolia </td><td>68.42</td><td>'Shoes            </td><td> 0.00</td></tr>
  <tr><td>Southern magnolia </td><td>68.42</td><td>Others            </td><td>31.58</td></tr>
  <tr><td>Sassafras         </td><td>70.59</td><td>''Lights or wires </td><td> 5.88</td></tr>
  <tr><td>Sassafras         </td><td>70.59</td><td>'Shoes            </td><td> 0.00</td></tr>
  <tr><td>Sassafras         </td><td>70.59</td><td>Others            </td><td>29.41</td></tr>
  <tr><td>Turkish hazelnut  </td><td>70.59</td><td>''Lights or wires </td><td> 0.00</td></tr>
  <tr><td>Turkish hazelnut  </td><td>70.59</td><td>'Shoes            </td><td> 0.00</td></tr>
  <tr><td>Turkish hazelnut  </td><td>70.59</td><td>Others            </td><td>29.41</td></tr>
  <tr><td>American beech    </td><td>72.73</td><td>''Lights or wires </td><td> 4.55</td></tr>
  <tr><td>American beech    </td><td>72.73</td><td>'Shoes            </td><td> 0.00</td></tr>
  <tr><td>American beech    </td><td>72.73</td><td>Others            </td><td>22.73</td></tr>
  <tr><td>Paperbark maple   </td><td>73.33</td><td>''Lights or wires </td><td> 0.00</td></tr>
  <tr><td>Paperbark maple   </td><td>73.33</td><td>'Shoes            </td><td> 0.00</td></tr>
  <tr><td>Paperbark maple   </td><td>73.33</td><td>Others            </td><td>26.67</td></tr>
  <tr><td>⋮</td><td>⋮</td><td>⋮</td><td>⋮</td></tr>
  <tr><td>Arborvitae        </td><td>80.00</td><td>''Lights or wires </td><td> 0.00</td></tr>
  <tr><td>Arborvitae        </td><td>80.00</td><td>'Shoes            </td><td> 0.00</td></tr>
  <tr><td>Arborvitae        </td><td>80.00</td><td>Others            </td><td>20.00</td></tr>
  <tr><td>Crepe myrtle      </td><td>80.00</td><td>''Lights or wires </td><td> 0.00</td></tr>
  <tr><td>Crepe myrtle      </td><td>80.00</td><td>'Shoes            </td><td> 0.00</td></tr>
  <tr><td>Crepe myrtle      </td><td>80.00</td><td>Others            </td><td>20.00</td></tr>
  <tr><td>Eastern cottonwood</td><td>80.00</td><td>''Lights or wires </td><td> 0.00</td></tr>
  <tr><td>Eastern cottonwood</td><td>80.00</td><td>'Shoes            </td><td> 0.00</td></tr>
  <tr><td>Eastern cottonwood</td><td>80.00</td><td>Others            </td><td>20.00</td></tr>
  <tr><td>Silver birch      </td><td>80.00</td><td>''Lights or wires </td><td>20.00</td></tr>
  <tr><td>Silver birch      </td><td>80.00</td><td>'Shoes            </td><td> 0.00</td></tr>
  <tr><td>Silver birch      </td><td>80.00</td><td>Others            </td><td> 0.00</td></tr>
  <tr><td>Sugar maple       </td><td>81.25</td><td>''Lights or wires </td><td> 2.08</td></tr>
  <tr><td>Sugar maple       </td><td>81.25</td><td>'Shoes            </td><td> 0.00</td></tr>
  <tr><td>Sugar maple       </td><td>81.25</td><td>Others            </td><td>16.67</td></tr>
  <tr><td>Cornelian cherry  </td><td>81.48</td><td>''Lights or wires </td><td> 3.70</td></tr>
  <tr><td>Cornelian cherry  </td><td>81.48</td><td>'Shoes            </td><td> 0.00</td></tr>
  <tr><td>Cornelian cherry  </td><td>81.48</td><td>Others            </td><td>14.81</td></tr>
  <tr><td>Horse chestnut    </td><td>81.82</td><td>''Lights or wires </td><td> 0.00</td></tr>
  <tr><td>Horse chestnut    </td><td>81.82</td><td>'Shoes            </td><td> 0.00</td></tr>
  <tr><td>Horse chestnut    </td><td>81.82</td><td>Others            </td><td>18.18</td></tr>
  <tr><td>Amur maple        </td><td>83.33</td><td>''Lights or wires </td><td> 0.00</td></tr>
  <tr><td>Amur maple        </td><td>83.33</td><td>'Shoes            </td><td> 0.00</td></tr>
  <tr><td>Amur maple        </td><td>83.33</td><td>Others            </td><td>16.67</td></tr>
  <tr><td>European beech    </td><td>83.33</td><td>''Lights or wires </td><td> 0.00</td></tr>
  <tr><td>European beech    </td><td>83.33</td><td>'Shoes            </td><td> 0.00</td></tr>
  <tr><td>European beech    </td><td>83.33</td><td>Others            </td><td>16.67</td></tr>
  <tr><td>Callery pear      </td><td>83.92</td><td>''Lights or wires </td><td> 2.32</td></tr>
  <tr><td>Callery pear      </td><td>83.92</td><td>'Shoes            </td><td> 0.11</td></tr>
  <tr><td>Callery pear      </td><td>83.92</td><td>Others            </td><td>14.13</td></tr>
</tbody>
</table>



#### Ranking
As suggested by the urban design team, tree size and health are used to determine which species have the most desirable characteristics. The two metrics used are health index $(HI)$ and median trunk diameter at breast height $(DBH)$ of $54$ inches, respectively. 

With that, it is confirmed through a correlation analysis that they have a [high to very high positive](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3576830/table/T1/?report=objectonly) correlation. This means that an increase in median trunk diameter is associated to an increase in the health index of a species. Below are the results of the correlation tests using three methods:


```R
spearman_corr <- data.frame(
    test_stat=cor.test(spc_health_index$health_index, spc_tree_dbh_stats$median_tree_dbh,
         method = "spearman", exact = FALSE)$statistic,
    corr_coeff=cor.test(spc_health_index$health_index, spc_tree_dbh_stats$median_tree_dbh,
         method = "spearman", exact = FALSE)$estimate,
    p_value=cor.test(spc_health_index$health_index, spc_tree_dbh_stats$median_tree_dbh,
         method = "spearman", exact = FALSE)$p.value)

kendall_corr <- data.frame(
    test_stat=cor.test(spc_health_index$health_index, spc_tree_dbh_stats$median_tree_dbh,
         method = "kendall", exact = FALSE)$statistic,
    corr_coeff=cor.test(spc_health_index$health_index, spc_tree_dbh_stats$median_tree_dbh,
         method = "kendall", exact = FALSE)$estimate,
    p_value=cor.test(spc_health_index$health_index, spc_tree_dbh_stats$median_tree_dbh,
         method = "kendall", exact = FALSE)$p.value)

pearson_corr <- data.frame(
    test_stat=cor.test(spc_health_index$health_index, spc_tree_dbh_stats$median_tree_dbh)$statistic,
    corr_coeff=cor.test(spc_health_index$health_index, spc_tree_dbh_stats$median_tree_dbh)$estimate,
    p_value=cor.test(spc_health_index$health_index, spc_tree_dbh_stats$median_tree_dbh)$p.value)

corr_coeffs <- spearman_corr %>%
    mutate(method = "Spearman") %>%
  bind_rows(kendall_corr %>%
                mutate(method = "Kendall"), 
              pearson_corr %>%
                mutate(method = "Pearson")) %>%
  select(method, everything()) %>%
  mutate(p_value = formatC(p_value, format = "e", digits = 4))

rownames(corr_coeffs) <- 1:nrow(corr_coeffs)

# HTML Table for correlation results
#kable(corr_coeffs, 
#      caption = " ",#
#      label = "tables", format = "html", booktabs = TRUE)
```


```R
corr_coeffs %>%
  mutate_if(is.numeric, list(~round(., digits=4))) %>%
  mutate_if(is.numeric, list(~prettyNum(., big.mark=",")))
```


<table class="dataframe">
<caption>A data.frame: 3 × 4</caption>
<thead>
  <tr><th></th><th scope=col>method</th><th scope=col>test_stat</th><th scope=col>corr_coeff</th><th scope=col>p_value</th></tr>
  <tr><th></th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th></tr>
</thead>
<tbody>
  <tr><th scope=row>1</th><td>Spearman</td><td>4,759.501</td><td>0.9864</td><td>1.2123e-100</td></tr>
  <tr><th scope=row>2</th><td>Kendall </td><td>14.7812  </td><td>0.9361</td><td>1.9379e-49 </td></tr>
  <tr><th scope=row>3</th><td>Pearson </td><td>15.4671  </td><td>0.8093</td><td>6.6475e-31 </td></tr>
</tbody>
</table>



To determine species ranking, the sum of ranks for health index and median trunk diameter was computed to quantify each species' overall rank relative to others. 

Additionally, two ranking systems were produced. The first encompassed all $128$ species. The second, however, adjusted for abundance by including only species with tree counts of at least $29$, representing the median species abundance.

Figures 14 and 15 provide [dashboard](https://public.tableau.com/app/profile/jbjdelacruz/viz/NYCURBANPLANNINGFORESTRYREPORT2015/Dashboard) snapshots illustrating the results from both ranking systems.


```R
# spc_first_ranking <- spc_health_index %>%
# 	select(spc_common, abundance, health_index) %>%
# 	inner_join(trees %>% 
#                group_by(spc_common) %>%
#                filter(spc_common != "null", health != "null") %>%
#                summarize(abundance = n(),
#                          median_tree_dbh = median(tree_dbh)),
#     	by=c("spc_common", "abundance")) %>%
# 	mutate(dbh_rank = percent_rank(median_tree_dbh),
# 		   hi_rank = percent_rank(health_index),
# 		   ps = (dbh_rank+hi_rank)/2) %>%
# 	arrange(desc(ps))

# spc_first_ranking

spc_first_ranking <- spc_health_index %>%
  select(spc_common, abundance, health_index) %>%
  inner_join(trees %>% 
               group_by(spc_common) %>%
               filter(spc_common != "null", health != "null") %>%
               summarize(abundance = n(),
                         median_tree_dbh = median(tree_dbh)),
      by=c("spc_common", "abundance")) %>%
  mutate(abd_rank = rank(desc(abundance)),
       hi_rank = rank(desc(health_index)),
       dbh_rank = rank(desc(median_tree_dbh)),
       rank_sum = (hi_rank + dbh_rank)/2) %>%
  arrange(rank_sum)

spc_second_ranking <- spc_health_index %>%
  select(spc_common, abundance, health_index) %>%
  inner_join(trees %>% 
               group_by(spc_common) %>%
               filter(spc_common != "null", health != "null") %>%
               summarize(abundance = n(),
                         median_tree_dbh = median(tree_dbh)),
      by=c("spc_common", "abundance")) %>%
# Filter out species with abundances less than the median abundances
  filter(abundance >= median(spc_tree_dbh_stats$abundance)
          ) %>% 
mutate(abd_rank = rank(desc(abundance)),
       hi_rank = rank(desc(health_index)),
          dbh_rank = rank(desc(median_tree_dbh)),
       rank_sum = (hi_rank + dbh_rank)) %>%
  arrange(rank_sum)

## Top species by rank sums (health index and median tree dbh)

#spc_first_ranking %>%
#select(spc_common, abundance, rank_sum, everything())

#spc_second_ranking %>%
#select(spc_common, abundance, #rank_sum, everything())

# For graphs
spc_first_ranking_long <- spc_first_ranking %>%
  rename(`Common name of the species` = spc_common,
           `Health index` = health_index,
           `Median trunk dbh` = median_tree_dbh) %>%
  pivot_longer(cols = c(3:4), 
                 names_to = "Measurement",
                 values_to = "Value")

spc_second_ranking_long <- spc_second_ranking %>%
  rename(`Common name of the species` = spc_common,
           `Health index` = health_index,
           `Median trunk dbh` = median_tree_dbh) %>%
  pivot_longer(cols = c(3:4), 
                 names_to = "Measurement",
                 values_to = "Value")


#spc_second_ranking_long$`Common name of the species` <- factor(
#    spc_second_ranking_long$`Common name of the species`,
#	levels = (spc_second_ranking)$spc_common,
    #ordered = TRUE
#)

# Tree size and Health 
top_spc_first_ranking <- spc_first_ranking_long %>%
  arrange(rank_sum) %>%
  filter(`Common name of the species` %in% (spc_first_ranking %>% slice(1:10))$spc_common)

top_spc_second_ranking <- spc_second_ranking_long %>%
  arrange(rank_sum) %>%
  filter(`Common name of the species` %in% (spc_second_ranking %>% slice(1:10))$spc_common)


# Tree size
top_dbh_spc <- spc_second_ranking_long %>%
  arrange(desc(Measurement)) %>%
  filter(Measurement == "Median trunk dbh",
           `Common name of the species` %in% (spc_second_ranking %>% slice(1:10))$spc_common)

# Health
top_hi_spc <- spc_second_ranking_long %>%
  arrange(desc(Measurement)) %>%
  rename(`Health index` = Value) %>%
  filter(`Measurement` == "Health index",
           `Common name of the species` %in% (spc_second_ranking %>% slice(1:10))$spc_common) 

spc_first_ranking_long %>%
  select(-(abd_rank))
```


<table class="dataframe">
<caption>A tibble: 256 × 7</caption>
<thead>
  <tr><th scope=col>Common name of the species</th><th scope=col>abundance</th><th scope=col>hi_rank</th><th scope=col>dbh_rank</th><th scope=col>rank_sum</th><th scope=col>Measurement</th><th scope=col>Value</th></tr>
  <tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;dbl&gt;</th></tr>
</thead>
<tbody>
  <tr><td>Smoketree         </td><td>    1</td><td> 6.5</td><td> 8.0</td><td> 7.25</td><td>Health index    </td><td> 1.0000000</td></tr>
  <tr><td>Smoketree         </td><td>    1</td><td> 6.5</td><td> 8.0</td><td> 7.25</td><td>Median trunk dbh</td><td>11.0000000</td></tr>
  <tr><td>Black maple       </td><td>   10</td><td>13.0</td><td> 8.0</td><td>10.50</td><td>Health index    </td><td> 0.9666667</td></tr>
  <tr><td>Black maple       </td><td>   10</td><td>13.0</td><td> 8.0</td><td>10.50</td><td>Median trunk dbh</td><td>11.0000000</td></tr>
  <tr><td>Amur cork tree    </td><td>    8</td><td>14.0</td><td> 8.0</td><td>11.00</td><td>Health index    </td><td> 0.9583333</td></tr>
  <tr><td>Amur cork tree    </td><td>    8</td><td>14.0</td><td> 8.0</td><td>11.00</td><td>Median trunk dbh</td><td>11.0000000</td></tr>
  <tr><td>Siberian elm      </td><td>  156</td><td>23.0</td><td> 8.0</td><td>15.50</td><td>Health index    </td><td> 0.9316239</td></tr>
  <tr><td>Siberian elm      </td><td>  156</td><td>23.0</td><td> 8.0</td><td>15.50</td><td>Median trunk dbh</td><td>11.0000000</td></tr>
  <tr><td>Pitch pine        </td><td>    5</td><td> 6.5</td><td>26.5</td><td>16.50</td><td>Health index    </td><td> 1.0000000</td></tr>
  <tr><td>Pitch pine        </td><td>    5</td><td> 6.5</td><td>26.5</td><td>16.50</td><td>Median trunk dbh</td><td> 8.0000000</td></tr>
  <tr><td>Red horse chestnut</td><td>    1</td><td> 6.5</td><td>26.5</td><td>16.50</td><td>Health index    </td><td> 1.0000000</td></tr>
  <tr><td>Red horse chestnut</td><td>    1</td><td> 6.5</td><td>26.5</td><td>16.50</td><td>Median trunk dbh</td><td> 8.0000000</td></tr>
  <tr><td>Willow oak        </td><td>  889</td><td>21.0</td><td>13.0</td><td>17.00</td><td>Health index    </td><td> 0.9366329</td></tr>
  <tr><td>Willow oak        </td><td>  889</td><td>21.0</td><td>13.0</td><td>17.00</td><td>Median trunk dbh</td><td>10.0000000</td></tr>
  <tr><td>Honeylocust       </td><td>13175</td><td>20.0</td><td>19.5</td><td>19.75</td><td>Health index    </td><td> 0.9387223</td></tr>
  <tr><td>Honeylocust       </td><td>13175</td><td>20.0</td><td>19.5</td><td>19.75</td><td>Median trunk dbh</td><td> 9.0000000</td></tr>
  <tr><td>American elm      </td><td> 1698</td><td>36.0</td><td> 4.0</td><td>20.00</td><td>Health index    </td><td> 0.9185316</td></tr>
  <tr><td>American elm      </td><td> 1698</td><td>36.0</td><td> 4.0</td><td>20.00</td><td>Median trunk dbh</td><td>12.0000000</td></tr>
  <tr><td>Pin oak           </td><td> 4584</td><td>27.0</td><td>19.5</td><td>23.25</td><td>Health index    </td><td> 0.9282286</td></tr>
  <tr><td>Pin oak           </td><td> 4584</td><td>27.0</td><td>19.5</td><td>23.25</td><td>Median trunk dbh</td><td> 9.0000000</td></tr>
  <tr><td>Tree of heaven    </td><td>  104</td><td>39.0</td><td> 8.0</td><td>23.50</td><td>Health index    </td><td> 0.9134615</td></tr>
  <tr><td>Tree of heaven    </td><td>  104</td><td>39.0</td><td> 8.0</td><td>23.50</td><td>Median trunk dbh</td><td>11.0000000</td></tr>
  <tr><td>White ash         </td><td>   50</td><td>33.0</td><td>15.0</td><td>24.00</td><td>Health index    </td><td> 0.9200000</td></tr>
  <tr><td>White ash         </td><td>   50</td><td>33.0</td><td>15.0</td><td>24.00</td><td>Median trunk dbh</td><td> 9.5000000</td></tr>
  <tr><td>Black locust      </td><td>  259</td><td>37.0</td><td>13.0</td><td>25.00</td><td>Health index    </td><td> 0.9176319</td></tr>
  <tr><td>Black locust      </td><td>  259</td><td>37.0</td><td>13.0</td><td>25.00</td><td>Median trunk dbh</td><td>10.0000000</td></tr>
  <tr><td>Black walnut      </td><td>   33</td><td>34.0</td><td>19.5</td><td>26.75</td><td>Health index    </td><td> 0.9191919</td></tr>
  <tr><td>Black walnut      </td><td>   33</td><td>34.0</td><td>19.5</td><td>26.75</td><td>Median trunk dbh</td><td> 9.0000000</td></tr>
  <tr><td>Sophora           </td><td> 4453</td><td>35.0</td><td>19.5</td><td>27.25</td><td>Health index    </td><td> 0.9187813</td></tr>
  <tr><td>Sophora           </td><td> 4453</td><td>35.0</td><td>19.5</td><td>27.25</td><td>Median trunk dbh</td><td> 9.0000000</td></tr>
  <tr><td>⋮</td><td>⋮</td><td>⋮</td><td>⋮</td><td>⋮</td><td>⋮</td><td>⋮</td></tr>
  <tr><td>Turkish hazelnut   </td><td> 17</td><td>103.5</td><td> 87.0</td><td> 95.25</td><td>Health index    </td><td>0.7843137</td></tr>
  <tr><td>Turkish hazelnut   </td><td> 17</td><td>103.5</td><td> 87.0</td><td> 95.25</td><td>Median trunk dbh</td><td>4.0000000</td></tr>
  <tr><td>Tulip-poplar       </td><td> 34</td><td>112.0</td><td> 87.0</td><td> 99.50</td><td>Health index    </td><td>0.7647059</td></tr>
  <tr><td>Tulip-poplar       </td><td> 34</td><td>112.0</td><td> 87.0</td><td> 99.50</td><td>Median trunk dbh</td><td>4.0000000</td></tr>
  <tr><td>Common hackberry   </td><td>170</td><td> 87.0</td><td>113.0</td><td>100.00</td><td>Health index    </td><td>0.8352941</td></tr>
  <tr><td>Common hackberry   </td><td>170</td><td> 87.0</td><td>113.0</td><td>100.00</td><td>Median trunk dbh</td><td>3.0000000</td></tr>
  <tr><td>Maple              </td><td> 37</td><td>117.0</td><td> 87.0</td><td>102.00</td><td>Health index    </td><td>0.7027027</td></tr>
  <tr><td>Maple              </td><td> 37</td><td>117.0</td><td> 87.0</td><td>102.00</td><td>Median trunk dbh</td><td>4.0000000</td></tr>
  <tr><td>Himalayan cedar    </td><td>  6</td><td> 90.0</td><td>125.5</td><td>107.75</td><td>Health index    </td><td>0.8333333</td></tr>
  <tr><td>Himalayan cedar    </td><td>  6</td><td> 90.0</td><td>125.5</td><td>107.75</td><td>Median trunk dbh</td><td>2.0000000</td></tr>
  <tr><td>Sassafras          </td><td> 17</td><td>103.5</td><td>113.0</td><td>108.25</td><td>Health index    </td><td>0.7843137</td></tr>
  <tr><td>Sassafras          </td><td> 17</td><td>103.5</td><td>113.0</td><td>108.25</td><td>Median trunk dbh</td><td>3.0000000</td></tr>
  <tr><td>Kentucky yellowwood</td><td> 18</td><td>109.0</td><td>113.0</td><td>111.00</td><td>Health index    </td><td>0.7777778</td></tr>
  <tr><td>Kentucky yellowwood</td><td> 18</td><td>109.0</td><td>113.0</td><td>111.00</td><td>Median trunk dbh</td><td>3.0000000</td></tr>
  <tr><td>Norway spruce      </td><td>  3</td><td>109.0</td><td>113.0</td><td>111.00</td><td>Health index    </td><td>0.7777778</td></tr>
  <tr><td>Norway spruce      </td><td>  3</td><td>109.0</td><td>113.0</td><td>111.00</td><td>Median trunk dbh</td><td>3.0000000</td></tr>
  <tr><td>Horse chestnut     </td><td> 11</td><td>114.0</td><td>113.0</td><td>113.50</td><td>Health index    </td><td>0.7575758</td></tr>
  <tr><td>Horse chestnut     </td><td> 11</td><td>114.0</td><td>113.0</td><td>113.50</td><td>Median trunk dbh</td><td>3.0000000</td></tr>
  <tr><td>Pagoda dogwood     </td><td> 18</td><td>115.0</td><td>113.0</td><td>114.00</td><td>Health index    </td><td>0.7407407</td></tr>
  <tr><td>Pagoda dogwood     </td><td> 18</td><td>115.0</td><td>113.0</td><td>114.00</td><td>Median trunk dbh</td><td>3.0000000</td></tr>
  <tr><td>Paperbark maple    </td><td> 15</td><td>120.5</td><td>113.0</td><td>116.75</td><td>Health index    </td><td>0.6666667</td></tr>
  <tr><td>Paperbark maple    </td><td> 15</td><td>120.5</td><td>113.0</td><td>116.75</td><td>Median trunk dbh</td><td>3.0000000</td></tr>
  <tr><td>Spruce             </td><td>  1</td><td>120.5</td><td>113.0</td><td>116.75</td><td>Health index    </td><td>0.6666667</td></tr>
  <tr><td>Spruce             </td><td>  1</td><td>120.5</td><td>113.0</td><td>116.75</td><td>Median trunk dbh</td><td>3.0000000</td></tr>
  <tr><td>Eastern hemlock    </td><td>  7</td><td>126.0</td><td>113.0</td><td>119.50</td><td>Health index    </td><td>0.5238095</td></tr>
  <tr><td>Eastern hemlock    </td><td>  7</td><td>126.0</td><td>113.0</td><td>119.50</td><td>Median trunk dbh</td><td>3.0000000</td></tr>
  <tr><td>Douglas-fir        </td><td>  2</td><td>120.5</td><td>125.5</td><td>123.00</td><td>Health index    </td><td>0.6666667</td></tr>
  <tr><td>Douglas-fir        </td><td>  2</td><td>120.5</td><td>125.5</td><td>123.00</td><td>Median trunk dbh</td><td>2.0000000</td></tr>
  <tr><td>Pond cypress       </td><td> 12</td><td>124.5</td><td>122.0</td><td>123.25</td><td>Health index    </td><td>0.5555556</td></tr>
  <tr><td>Pond cypress       </td><td> 12</td><td>124.5</td><td>122.0</td><td>123.25</td><td>Median trunk dbh</td><td>2.5000000</td></tr>
</tbody>
</table>



**Fig. 14: Dashboard Results Using 'Rank All Species, by Size & Health' System**
<img src="documentation/Dashboard1.png"/>
</br>
</br>
**Fig. 15: Dashboard Results Using 'Rank Species with Abundance ≥ 29, by Size & Health'**
<img src="documentation/Dashboard2.png"/>

## Recommendations
The following are some potential courses of action for Manhattan's urban planning department:

- Large southern neighborhoods such as Midtown-Midtown South (MN17), SoHo-TriBeCa-Civic Center-Little Italy (MN24), and Lower East Side (MN28), which are ranked third, sixth, and eighth in terms of land area, respectively, but only ranked $25$th, $15$th, and $19$th in terms of tree counts, can be ideal locations for planting trees.

- Some of the issues that need to be prioritized in the Stuyvesant Town-Cooper Village neighborhood include low tree counts, species richness, and a high number of trees that are offset from curb.

- Although two rankings were produced, the second one has a better rank estimation due to large sample size per species; thus, the top five species (out of the 64 included) in terms of size and health that are recommended to be planted on the streets of Manhattan are:

  1. Siberian elm<br/>
     - Abundance: $156$ 
     - Median trunk diameter: $11$ $(3$rd$)$
     - Heath index: $0.9316$ $(6$th$)$
  
  2. Willow oak<br/>
     - Abundance: $889$
     - Median trunk diameter: $10$ $(6$th$)$
     - Heath index: $0.9366$ $(5$th$)$
  
  3. Honeylocust<br/>
     - Abundance: $13,176$
     - Median trunk diameter: $9$ $(12$th$)$
     - Heath index: $0.9387$ $(4$th$)$
     
  4. American elm<br/>
     - Abundance: $1,698$
     - Median trunk diameter: $12$ $(2$nd$)$
     - Heath index: $0.9185$ $(17$th$)$
  
  5. Pin oak<br/>
     - Abundance: $4,584$
     - Median trunk diameter: $9$ $(12$th$)$
     - Heath index: $0.9282$ $(9$th$)$
  
  </br>
- Trees of species *Smoketree*, *Black maple*, *Amur cork tree*, *Pitch pine*, and *Red horse chestnut* from the first ranking can also be considered as they have shown superior sizes and health. However, it is also suggested looking into related literature and/or more adequate data about them. 

## Appendix
### Tables & Figures
#### ***Shape area per neighborhood***


```R
neighborhoods %>%
  filter(boroname == "Manhattan", ntacode != "MN99") %>%
  arrange(desc(shape_area)) %>%
  st_drop_geometry() %>%
  select(-boroname)
```


<table class="dataframe">
<caption>A data.frame: 28 × 3</caption>
<thead>
  <tr><th></th><th scope=col>ntacode</th><th scope=col>ntaname</th><th scope=col>shape_area</th></tr>
  <tr><th></th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;dbl&gt;</th></tr>
</thead>
<tbody>
  <tr><th scope=row>1</th><td>MN13</td><td>Hudson Yards-Chelsea-Flatiron-Union Square</td><td>37029727</td></tr>
  <tr><th scope=row>2</th><td>MN12</td><td>Upper West Side                           </td><td>34381053</td></tr>
  <tr><th scope=row>3</th><td>MN17</td><td>Midtown-Midtown South                     </td><td>30192057</td></tr>
  <tr><th scope=row>4</th><td>MN03</td><td>Central Harlem North-Polo Grounds         </td><td>25403425</td></tr>
  <tr><th scope=row>5</th><td>MN23</td><td>West Village                              </td><td>25000526</td></tr>
  <tr><th scope=row>6</th><td>MN24</td><td>SoHo-TriBeCa-Civic Center-Little Italy    </td><td>24859569</td></tr>
  <tr><th scope=row>7</th><td>MN34</td><td>East Harlem North                         </td><td>24495420</td></tr>
  <tr><th scope=row>8</th><td>MN28</td><td>Lower East Side                           </td><td>23297616</td></tr>
  <tr><th scope=row>9</th><td>MN36</td><td>Washington Heights South                  </td><td>23100223</td></tr>
  <tr><th scope=row>10</th><td>MN35</td><td>Washington Heights North                  </td><td>22662313</td></tr>
  <tr><th scope=row>11</th><td>MN31</td><td>Lenox Hill-Roosevelt Island               </td><td>21501565</td></tr>
  <tr><th scope=row>12</th><td>MN09</td><td>Morningside Heights                       </td><td>20158317</td></tr>
  <tr><th scope=row>13</th><td>MN40</td><td>Upper East Side-Carnegie Hill             </td><td>20065329</td></tr>
  <tr><th scope=row>14</th><td>MN25</td><td>Battery Park City-Lower Manhattan         </td><td>19056256</td></tr>
  <tr><th scope=row>15</th><td>MN15</td><td>Clinton                                   </td><td>18381380</td></tr>
  <tr><th scope=row>16</th><td>MN01</td><td>Marble Hill-Inwood                        </td><td>17725321</td></tr>
  <tr><th scope=row>17</th><td>MN19</td><td>Turtle Bay-East Midtown                   </td><td>17397872</td></tr>
  <tr><th scope=row>18</th><td>MN33</td><td>East Harlem South                         </td><td>16650738</td></tr>
  <tr><th scope=row>19</th><td>MN04</td><td>Hamilton Heights                          </td><td>16093788</td></tr>
  <tr><th scope=row>20</th><td>MN14</td><td>Lincoln Square                            </td><td>15805668</td></tr>
  <tr><th scope=row>21</th><td>MN27</td><td>Chinatown                                 </td><td>14501953</td></tr>
  <tr><th scope=row>22</th><td>MN20</td><td>Murray Hill-Kips Bay                      </td><td>14465848</td></tr>
  <tr><th scope=row>23</th><td>MN11</td><td>Central Harlem South                      </td><td>14436192</td></tr>
  <tr><th scope=row>24</th><td>MN32</td><td>Yorkville                                 </td><td>13594780</td></tr>
  <tr><th scope=row>25</th><td>MN22</td><td>East Village                              </td><td>10895491</td></tr>
  <tr><th scope=row>26</th><td>MN06</td><td>Manhattanville                            </td><td>10647078</td></tr>
  <tr><th scope=row>27</th><td>MN21</td><td>Gramercy                                  </td><td> 7531455</td></tr>
  <tr><th scope=row>28</th><td>MN50</td><td>Stuyvesant Town-Cooper Village            </td><td> 5575232</td></tr>
</tbody>
</table>



#### ***Tree count per neighborhood***


```R
# Tree count per neighborhood
nbh_tree_cnts %>%
  mutate(Percentage = label_percent(accuracy=0.01)(proportion)) %>%
  select(-proportion)
```


<table class="dataframe">
<caption>A tibble: 28 × 4</caption>
<thead>
  <tr><th scope=col>nta</th><th scope=col>nta_name</th><th scope=col>number_of_trees</th><th scope=col>Percentage</th></tr>
  <tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;chr&gt;</th></tr>
</thead>
<tbody>
  <tr><td>MN12</td><td>Upper West Side                           </td><td>5807</td><td>9.04%</td></tr>
  <tr><td>MN40</td><td>Upper East Side-Carnegie Hill             </td><td>4616</td><td>7.19%</td></tr>
  <tr><td>MN23</td><td>West Village                              </td><td>3801</td><td>5.92%</td></tr>
  <tr><td>MN03</td><td>Central Harlem North-Polo Grounds         </td><td>3469</td><td>5.40%</td></tr>
  <tr><td>MN13</td><td>Hudson Yards-Chelsea-Flatiron-Union Square</td><td>2931</td><td>4.56%</td></tr>
  <tr><td>MN36</td><td>Washington Heights South                  </td><td>2924</td><td>4.55%</td></tr>
  <tr><td>MN09</td><td>Morningside Heights                       </td><td>2704</td><td>4.21%</td></tr>
  <tr><td>MN11</td><td>Central Harlem South                      </td><td>2643</td><td>4.11%</td></tr>
  <tr><td>MN35</td><td>Washington Heights North                  </td><td>2612</td><td>4.07%</td></tr>
  <tr><td>MN34</td><td>East Harlem North                         </td><td>2505</td><td>3.90%</td></tr>
  <tr><td>MN04</td><td>Hamilton Heights                          </td><td>2363</td><td>3.68%</td></tr>
  <tr><td>MN31</td><td>Lenox Hill-Roosevelt Island               </td><td>2277</td><td>3.55%</td></tr>
  <tr><td>MN19</td><td>Turtle Bay-East Midtown                   </td><td>2226</td><td>3.47%</td></tr>
  <tr><td>MN32</td><td>Yorkville                                 </td><td>2180</td><td>3.39%</td></tr>
  <tr><td>MN24</td><td>SoHo-TriBeCa-Civic Center-Little Italy    </td><td>2170</td><td>3.38%</td></tr>
  <tr><td>MN14</td><td>Lincoln Square                            </td><td>2044</td><td>3.18%</td></tr>
  <tr><td>MN15</td><td>Clinton                                   </td><td>1954</td><td>3.04%</td></tr>
  <tr><td>MN33</td><td>East Harlem South                         </td><td>1945</td><td>3.03%</td></tr>
  <tr><td>MN28</td><td>Lower East Side                           </td><td>1916</td><td>2.98%</td></tr>
  <tr><td>MN20</td><td>Murray Hill-Kips Bay                      </td><td>1704</td><td>2.65%</td></tr>
  <tr><td>MN22</td><td>East Village                              </td><td>1542</td><td>2.40%</td></tr>
  <tr><td>MN01</td><td>Marble Hill-Inwood                        </td><td>1476</td><td>2.30%</td></tr>
  <tr><td>MN27</td><td>Chinatown                                 </td><td>1457</td><td>2.27%</td></tr>
  <tr><td>MN25</td><td>Battery Park City-Lower Manhattan         </td><td>1294</td><td>2.01%</td></tr>
  <tr><td>MN17</td><td>Midtown-Midtown South                     </td><td>1184</td><td>1.84%</td></tr>
  <tr><td>MN21</td><td>Gramercy                                  </td><td>1142</td><td>1.78%</td></tr>
  <tr><td>MN06</td><td>Manhattanville                            </td><td> 902</td><td>1.40%</td></tr>
  <tr><td>MN50</td><td>Stuyvesant Town-Cooper Village            </td><td> 441</td><td>0.69%</td></tr>
</tbody>
</table>



#### ***Tree count per curb location***


```R
number_of_trees_per_curb_loc
```


<table class="dataframe">
<caption>A tibble: 2 × 3</caption>
<thead>
  <tr><th scope=col>curb_loc</th><th scope=col>number_of_trees</th><th scope=col>percentage</th></tr>
  <tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;chr&gt;</th></tr>
</thead>
<tbody>
  <tr><td>OnCurb        </td><td>59932</td><td>93.07%</td></tr>
  <tr><td>OffsetFromCurb</td><td> 4297</td><td>6.67% </td></tr>
</tbody>
</table>



#### ***Curb location per neighborhood***


```R
# Curb location per neighborhood
curb_loc_per_nbh %>%
  arrange(desc(curb_loc), desc(proportion)) %>%
  select(-proportion)
```


<table class="dataframe">
<caption>A tibble: 56 × 5</caption>
<thead>
  <tr><th scope=col>nta</th><th scope=col>nta_name</th><th scope=col>curb_loc</th><th scope=col>number_of_trees</th><th scope=col>percentage</th></tr>
  <tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;ord&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;chr&gt;</th></tr>
</thead>
<tbody>
  <tr><td>MN22</td><td>East Village                              </td><td>OnCurb        </td><td>1533</td><td>99.42%</td></tr>
  <tr><td>MN06</td><td>Manhattanville                            </td><td>OnCurb        </td><td> 890</td><td>98.67%</td></tr>
  <tr><td>MN21</td><td>Gramercy                                  </td><td>OnCurb        </td><td>1119</td><td>97.99%</td></tr>
  <tr><td>MN23</td><td>West Village                              </td><td>OnCurb        </td><td>3721</td><td>97.90%</td></tr>
  <tr><td>MN13</td><td>Hudson Yards-Chelsea-Flatiron-Union Square</td><td>OnCurb        </td><td>2860</td><td>97.58%</td></tr>
  <tr><td>MN32</td><td>Yorkville                                 </td><td>OnCurb        </td><td>2127</td><td>97.57%</td></tr>
  <tr><td>MN15</td><td>Clinton                                   </td><td>OnCurb        </td><td>1906</td><td>97.54%</td></tr>
  <tr><td>MN35</td><td>Washington Heights North                  </td><td>OnCurb        </td><td>2528</td><td>96.78%</td></tr>
  <tr><td>MN31</td><td>Lenox Hill-Roosevelt Island               </td><td>OnCurb        </td><td>2198</td><td>96.53%</td></tr>
  <tr><td>MN34</td><td>East Harlem North                         </td><td>OnCurb        </td><td>2410</td><td>96.21%</td></tr>
  <tr><td>MN36</td><td>Washington Heights South                  </td><td>OnCurb        </td><td>2805</td><td>95.93%</td></tr>
  <tr><td>MN03</td><td>Central Harlem North-Polo Grounds         </td><td>OnCurb        </td><td>3324</td><td>95.82%</td></tr>
  <tr><td>MN20</td><td>Murray Hill-Kips Bay                      </td><td>OnCurb        </td><td>1630</td><td>95.66%</td></tr>
  <tr><td>MN11</td><td>Central Harlem South                      </td><td>OnCurb        </td><td>2523</td><td>95.46%</td></tr>
  <tr><td>MN01</td><td>Marble Hill-Inwood                        </td><td>OnCurb        </td><td>1408</td><td>95.39%</td></tr>
  <tr><td>MN04</td><td>Hamilton Heights                          </td><td>OnCurb        </td><td>2246</td><td>95.05%</td></tr>
  <tr><td>MN19</td><td>Turtle Bay-East Midtown                   </td><td>OnCurb        </td><td>2115</td><td>95.01%</td></tr>
  <tr><td>MN17</td><td>Midtown-Midtown South                     </td><td>OnCurb        </td><td>1104</td><td>93.24%</td></tr>
  <tr><td>MN40</td><td>Upper East Side-Carnegie Hill             </td><td>OnCurb        </td><td>4301</td><td>93.18%</td></tr>
  <tr><td>MN14</td><td>Lincoln Square                            </td><td>OnCurb        </td><td>1851</td><td>90.56%</td></tr>
  <tr><td>MN12</td><td>Upper West Side                           </td><td>OnCurb        </td><td>5225</td><td>89.98%</td></tr>
  <tr><td>MN24</td><td>SoHo-TriBeCa-Civic Center-Little Italy    </td><td>OnCurb        </td><td>1950</td><td>89.86%</td></tr>
  <tr><td>MN28</td><td>Lower East Side                           </td><td>OnCurb        </td><td>1714</td><td>89.46%</td></tr>
  <tr><td>MN33</td><td>East Harlem South                         </td><td>OnCurb        </td><td>1725</td><td>88.69%</td></tr>
  <tr><td>MN09</td><td>Morningside Heights                       </td><td>OnCurb        </td><td>2293</td><td>84.80%</td></tr>
  <tr><td>MN27</td><td>Chinatown                                 </td><td>OnCurb        </td><td>1218</td><td>83.60%</td></tr>
  <tr><td>MN25</td><td>Battery Park City-Lower Manhattan         </td><td>OnCurb        </td><td>1009</td><td>77.98%</td></tr>
  <tr><td>MN50</td><td>Stuyvesant Town-Cooper Village            </td><td>OnCurb        </td><td> 199</td><td>45.12%</td></tr>
  <tr><td>MN50</td><td>Stuyvesant Town-Cooper Village            </td><td>OffsetFromCurb</td><td> 242</td><td>54.88%</td></tr>
  <tr><td>MN25</td><td>Battery Park City-Lower Manhattan         </td><td>OffsetFromCurb</td><td> 285</td><td>22.02%</td></tr>
  <tr><td>MN27</td><td>Chinatown                                 </td><td>OffsetFromCurb</td><td> 239</td><td>16.40%</td></tr>
  <tr><td>MN09</td><td>Morningside Heights                       </td><td>OffsetFromCurb</td><td> 411</td><td>15.20%</td></tr>
  <tr><td>MN33</td><td>East Harlem South                         </td><td>OffsetFromCurb</td><td> 220</td><td>11.31%</td></tr>
  <tr><td>MN28</td><td>Lower East Side                           </td><td>OffsetFromCurb</td><td> 202</td><td>10.54%</td></tr>
  <tr><td>MN24</td><td>SoHo-TriBeCa-Civic Center-Little Italy    </td><td>OffsetFromCurb</td><td> 220</td><td>10.14%</td></tr>
  <tr><td>MN12</td><td>Upper West Side                           </td><td>OffsetFromCurb</td><td> 582</td><td>10.02%</td></tr>
  <tr><td>MN14</td><td>Lincoln Square                            </td><td>OffsetFromCurb</td><td> 193</td><td>9.44% </td></tr>
  <tr><td>MN40</td><td>Upper East Side-Carnegie Hill             </td><td>OffsetFromCurb</td><td> 315</td><td>6.82% </td></tr>
  <tr><td>MN17</td><td>Midtown-Midtown South                     </td><td>OffsetFromCurb</td><td>  80</td><td>6.76% </td></tr>
  <tr><td>MN19</td><td>Turtle Bay-East Midtown                   </td><td>OffsetFromCurb</td><td> 111</td><td>4.99% </td></tr>
  <tr><td>MN04</td><td>Hamilton Heights                          </td><td>OffsetFromCurb</td><td> 117</td><td>4.95% </td></tr>
  <tr><td>MN01</td><td>Marble Hill-Inwood                        </td><td>OffsetFromCurb</td><td>  68</td><td>4.61% </td></tr>
  <tr><td>MN11</td><td>Central Harlem South                      </td><td>OffsetFromCurb</td><td> 120</td><td>4.54% </td></tr>
  <tr><td>MN20</td><td>Murray Hill-Kips Bay                      </td><td>OffsetFromCurb</td><td>  74</td><td>4.34% </td></tr>
  <tr><td>MN03</td><td>Central Harlem North-Polo Grounds         </td><td>OffsetFromCurb</td><td> 145</td><td>4.18% </td></tr>
  <tr><td>MN36</td><td>Washington Heights South                  </td><td>OffsetFromCurb</td><td> 119</td><td>4.07% </td></tr>
  <tr><td>MN34</td><td>East Harlem North                         </td><td>OffsetFromCurb</td><td>  95</td><td>3.79% </td></tr>
  <tr><td>MN31</td><td>Lenox Hill-Roosevelt Island               </td><td>OffsetFromCurb</td><td>  79</td><td>3.47% </td></tr>
  <tr><td>MN35</td><td>Washington Heights North                  </td><td>OffsetFromCurb</td><td>  84</td><td>3.22% </td></tr>
  <tr><td>MN15</td><td>Clinton                                   </td><td>OffsetFromCurb</td><td>  48</td><td>2.46% </td></tr>
  <tr><td>MN32</td><td>Yorkville                                 </td><td>OffsetFromCurb</td><td>  53</td><td>2.43% </td></tr>
  <tr><td>MN13</td><td>Hudson Yards-Chelsea-Flatiron-Union Square</td><td>OffsetFromCurb</td><td>  71</td><td>2.42% </td></tr>
  <tr><td>MN23</td><td>West Village                              </td><td>OffsetFromCurb</td><td>  80</td><td>2.10% </td></tr>
  <tr><td>MN21</td><td>Gramercy                                  </td><td>OffsetFromCurb</td><td>  23</td><td>2.01% </td></tr>
  <tr><td>MN06</td><td>Manhattanville                            </td><td>OffsetFromCurb</td><td>  12</td><td>1.33% </td></tr>
  <tr><td>MN22</td><td>East Village                              </td><td>OffsetFromCurb</td><td>   9</td><td>0.58% </td></tr>
</tbody>
</table>



#### ***Tree population's categorical, health-related attributes***


```R
# Tree population's attributes
pop_attributes %>%
  select(-proportion)
```


<table class="dataframe">
<caption>A data.frame: 23 × 4</caption>
<thead>
  <tr><th scope=col>attribute</th><th scope=col>category</th><th scope=col>number_of_trees</th><th scope=col>percentage</th></tr>
  <tr><th scope=col>&lt;ord&gt;</th><th scope=col>&lt;ord&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;chr&gt;</th></tr>
</thead>
<tbody>
  <tr><td>status    </td><td>Alive</td><td>62427</td><td>97.19%</td></tr>
  <tr><td>status    </td><td>Dead </td><td> 1802</td><td>2.81% </td></tr>
  <tr><td>health    </td><td>Good </td><td>47358</td><td>75.86%</td></tr>
  <tr><td>health    </td><td>Fair </td><td>11460</td><td>18.36%</td></tr>
  <tr><td>health    </td><td>Poor </td><td> 3609</td><td>5.78% </td></tr>
  <tr><td>root_stone</td><td>No   </td><td>51653</td><td>80.42%</td></tr>
  <tr><td>root_stone</td><td>Yes  </td><td>12576</td><td>19.58%</td></tr>
  <tr><td>root_grate</td><td>No   </td><td>61747</td><td>96.14%</td></tr>
  <tr><td>root_grate</td><td>Yes  </td><td> 2482</td><td>3.86% </td></tr>
  <tr><td>root_other</td><td>No   </td><td>59212</td><td>92.19%</td></tr>
  <tr><td>root_other</td><td>Yes  </td><td> 5017</td><td>7.81% </td></tr>
  <tr><td>trunk_wire</td><td>No   </td><td>63312</td><td>98.57%</td></tr>
  <tr><td>trunk_wire</td><td>Yes  </td><td>  917</td><td>1.43% </td></tr>
  <tr><td>trnk_light</td><td>No   </td><td>63898</td><td>99.48%</td></tr>
  <tr><td>trnk_light</td><td>Yes  </td><td>  331</td><td>0.52% </td></tr>
  <tr><td>trnk_other</td><td>No   </td><td>58649</td><td>91.31%</td></tr>
  <tr><td>trnk_other</td><td>Yes  </td><td> 5580</td><td>8.69% </td></tr>
  <tr><td>brch_light</td><td>No   </td><td>63354</td><td>98.64%</td></tr>
  <tr><td>brch_light</td><td>Yes  </td><td>  875</td><td>1.36% </td></tr>
  <tr><td>brch_shoe </td><td>No   </td><td>64168</td><td>99.91%</td></tr>
  <tr><td>brch_shoe </td><td>Yes  </td><td>   61</td><td>0.09% </td></tr>
  <tr><td>brch_other</td><td>No   </td><td>57665</td><td>89.78%</td></tr>
  <tr><td>brch_other</td><td>Yes  </td><td> 6564</td><td>10.22%</td></tr>
</tbody>
</table>



#### ***Richness (number of tree species) per neighborhood***


```R
nbh_rchns
```


<table class="dataframe">
<caption>A tibble: 28 × 3</caption>
<thead>
  <tr><th scope=col>nta</th><th scope=col>nta_name</th><th scope=col>richness</th></tr>
  <tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;int&gt;</th></tr>
</thead>
<tbody>
  <tr><td>MN35</td><td>Washington Heights North                  </td><td>81</td></tr>
  <tr><td>MN28</td><td>Lower East Side                           </td><td>78</td></tr>
  <tr><td>MN36</td><td>Washington Heights South                  </td><td>77</td></tr>
  <tr><td>MN23</td><td>West Village                              </td><td>76</td></tr>
  <tr><td>MN03</td><td>Central Harlem North-Polo Grounds         </td><td>75</td></tr>
  <tr><td>MN04</td><td>Hamilton Heights                          </td><td>73</td></tr>
  <tr><td>MN12</td><td>Upper West Side                           </td><td>73</td></tr>
  <tr><td>MN40</td><td>Upper East Side-Carnegie Hill             </td><td>73</td></tr>
  <tr><td>MN11</td><td>Central Harlem South                      </td><td>71</td></tr>
  <tr><td>MN22</td><td>East Village                              </td><td>68</td></tr>
  <tr><td>MN09</td><td>Morningside Heights                       </td><td>66</td></tr>
  <tr><td>MN34</td><td>East Harlem North                         </td><td>64</td></tr>
  <tr><td>MN24</td><td>SoHo-TriBeCa-Civic Center-Little Italy    </td><td>62</td></tr>
  <tr><td>MN01</td><td>Marble Hill-Inwood                        </td><td>60</td></tr>
  <tr><td>MN19</td><td>Turtle Bay-East Midtown                   </td><td>60</td></tr>
  <tr><td>MN27</td><td>Chinatown                                 </td><td>58</td></tr>
  <tr><td>MN32</td><td>Yorkville                                 </td><td>57</td></tr>
  <tr><td>MN31</td><td>Lenox Hill-Roosevelt Island               </td><td>55</td></tr>
  <tr><td>MN14</td><td>Lincoln Square                            </td><td>54</td></tr>
  <tr><td>MN20</td><td>Murray Hill-Kips Bay                      </td><td>53</td></tr>
  <tr><td>MN06</td><td>Manhattanville                            </td><td>52</td></tr>
  <tr><td>MN15</td><td>Clinton                                   </td><td>52</td></tr>
  <tr><td>MN33</td><td>East Harlem South                         </td><td>46</td></tr>
  <tr><td>MN13</td><td>Hudson Yards-Chelsea-Flatiron-Union Square</td><td>44</td></tr>
  <tr><td>MN21</td><td>Gramercy                                  </td><td>39</td></tr>
  <tr><td>MN25</td><td>Battery Park City-Lower Manhattan         </td><td>39</td></tr>
  <tr><td>MN17</td><td>Midtown-Midtown South                     </td><td>37</td></tr>
  <tr><td>MN50</td><td>Stuyvesant Town-Cooper Village            </td><td>21</td></tr>
</tbody>
</table>



#### ***Species abundances***

#### ***Summary statistics of species abundances (number of trees per species)***


```R
defaultW <- getOption("warn")
options(warn=-1)

tree_attributes <- trees %>%
  select(spc_common, tree_dbh:brch_other) %>%
  filter(!is.na(spc_common))

spc_common <- levels(factor(tree_attributes$spc_common))

tree_attributes$spc_common <- factor(tree_attributes$spc_common,
                               levels = spc_common)

# Identified species abundances
identified_spc_abd <- trees %>%
  filter(!is.na(spc_common)) %>%
  group_by(spc_common) %>%
  summarize(abundance = n())

# Summary statistics of species abundances
spc_abd_stats <- data.frame(number_of_identified_spc = length(identified_spc_abd$abundance),
                mean = mean(identified_spc_abd$abundance),
                            sd = sd(identified_spc_abd$abundance),
                            min = min(identified_spc_abd$abundance),
                            first_quartile = quantile(identified_spc_abd$abundance, probs = 0.25),
                            median = median(identified_spc_abd$abundance),
                            third_quartile = quantile(identified_spc_abd$abundance, probs = 0.75),
                            max = max(identified_spc_abd$abundance))
row.names(spc_abd_stats) <- "spc_abundance" 

# HTML Table for Number of Trees per Species
#kable(tree_dbh_stats %>%
#	  	mutate_if(is.numeric, list(~format(round(., 4), nsmall = 4))),
#     "html", caption = "Table _: Summary statistics of the tree diameter")

# Histogram with density curve of the species abundances
tree_count_per_species_dist_plot <- ggplot(identified_spc_abd,
                                           aes(x = abundance)) + 
  geom_histogram(aes(y = after_stat(density)),
                   binwidth=25,
                   color=1,
                   fill="#5FBD5F") + geom_density(linewidth=0.85,
                                                  linetype=1,
                                                  colour = muted("5FBD5F"),
                                                  alpha=0.5) +

# Plot mean and median
  geom_vline(aes(xintercept = mean(abundance)), col="red", size=0.6) +
  geom_vline(aes(xintercept = median(abundance)), col="blue", size=0.6) +

  theme(axis.title = element_text(color="#65707C",
                                    face="bold",
                                    family="sans serif"),
          axis.text = element_text(color="#65707C",
                                   size=12,
                                   family="sans serif"),
          axis.line = element_line(colour="grey",
                                   linewidth=0.5),
          panel.grid.major = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.25),
          panel.background = element_blank(),
          plot.subtitle = element_text(color="#65707C",
                                    hjust=-0.33,
                                    size=10,
                                    family="sans serif"),
          plot.title = element_text(color="#65707C",
                                    hjust=0.5,
                                    size=14,
                                    family="sans serif")) +
  ggtitle("\nFig. 16: Distribution of the Species Abundance                \n") +
  labs(x="\nSpecies abundance\n", y="\nDensity\n") +
  scale_x_continuous(expand = c(0.01, 0), 
                       limits = c(0, 2550),
                       breaks = seq(0, 2550, by=250)) +
  scale_y_continuous(expand = c(0.01, 0),
                       limits = c(0, 0.0081), 
                       breaks = seq(0, 0.0081, by=0.001))

spc_abd_stats

options(warn = defaultW)
```


<table class="dataframe">
<caption>A data.frame: 1 × 8</caption>
<thead>
  <tr><th></th><th scope=col>number_of_identified_spc</th><th scope=col>mean</th><th scope=col>sd</th><th scope=col>min</th><th scope=col>first_quartile</th><th scope=col>median</th><th scope=col>third_quartile</th><th scope=col>max</th></tr>
  <tr><th></th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;int&gt;</th></tr>
</thead>
<tbody>
  <tr><th scope=row>spc_abundance</th><td>128</td><td>487.7188</td><td>1597.828</td><td>1</td><td>8.75</td><td>28.5</td><td>167.75</td><td>13176</td></tr>
</tbody>
</table>



#### ***Summary statistics of species' tree DBHs***


```R
# Summary statistics of species' tree dbhs
spc_tree_dbh_stats
```


<table class="dataframe">
<caption>A tibble: 128 × 9</caption>
<thead>
  <tr><th scope=col>spc_common</th><th scope=col>abundance</th><th scope=col>mean_tree_dbh</th><th scope=col>sd_tree_dbh</th><th scope=col>min_tree_dbh</th><th scope=col>first_quartile_tree_dbh</th><th scope=col>median_tree_dbh</th><th scope=col>third_quartile_tree_dbh</th><th scope=col>max_tree_dbh</th></tr>
  <tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th></tr>
</thead>
<tbody>
  <tr><td>Weeping willow      </td><td>   12</td><td>13.500000</td><td>7.317476</td><td> 4</td><td> 8.00</td><td>14.0</td><td>19.00</td><td> 26</td></tr>
  <tr><td>London planetree    </td><td> 4122</td><td>13.168607</td><td>7.340801</td><td> 1</td><td> 7.00</td><td>13.0</td><td>18.00</td><td> 48</td></tr>
  <tr><td>White pine          </td><td>    1</td><td>13.000000</td><td>      NA</td><td>13</td><td>13.00</td><td>13.0</td><td>13.00</td><td> 13</td></tr>
  <tr><td>American elm        </td><td> 1698</td><td>13.899293</td><td>9.703312</td><td> 1</td><td> 6.00</td><td>12.0</td><td>19.00</td><td> 62</td></tr>
  <tr><td>Amur cork tree      </td><td>    8</td><td> 9.625000</td><td>3.925648</td><td> 3</td><td> 8.50</td><td>11.0</td><td>12.25</td><td> 13</td></tr>
  <tr><td>Black maple         </td><td>   10</td><td>12.600000</td><td>8.408990</td><td> 4</td><td> 5.00</td><td>11.0</td><td>19.50</td><td> 26</td></tr>
  <tr><td>Ohio buckeye        </td><td>   24</td><td>11.958333</td><td>5.368824</td><td> 3</td><td> 9.50</td><td>11.0</td><td>15.25</td><td> 24</td></tr>
  <tr><td>Siberian elm        </td><td>  156</td><td>12.064103</td><td>7.545714</td><td> 2</td><td> 5.75</td><td>11.0</td><td>17.00</td><td> 33</td></tr>
  <tr><td>Smoketree           </td><td>    1</td><td>11.000000</td><td>      NA</td><td>11</td><td>11.00</td><td>11.0</td><td>11.00</td><td> 11</td></tr>
  <tr><td>Sycamore maple      </td><td>   23</td><td>11.521739</td><td>6.280341</td><td> 2</td><td> 7.50</td><td>11.0</td><td>16.00</td><td> 26</td></tr>
  <tr><td>Tree of heaven      </td><td>  104</td><td>11.451923</td><td>6.584595</td><td> 2</td><td> 5.00</td><td>11.0</td><td>16.00</td><td> 34</td></tr>
  <tr><td>Ash                 </td><td>   58</td><td> 9.603448</td><td>2.943561</td><td> 3</td><td> 8.00</td><td>10.0</td><td>11.75</td><td> 16</td></tr>
  <tr><td>Black locust        </td><td>  259</td><td> 9.768340</td><td>4.735689</td><td> 2</td><td> 5.00</td><td>10.0</td><td>13.00</td><td> 21</td></tr>
  <tr><td>Willow oak          </td><td>  889</td><td>10.811024</td><td>9.331016</td><td> 1</td><td> 5.00</td><td>10.0</td><td>14.00</td><td>199</td></tr>
  <tr><td>White ash           </td><td>   50</td><td> 9.800000</td><td>4.347178</td><td> 3</td><td> 6.00</td><td> 9.5</td><td>13.00</td><td> 18</td></tr>
  <tr><td>Black walnut        </td><td>   33</td><td> 9.636364</td><td>6.004260</td><td> 2</td><td> 4.00</td><td> 9.0</td><td>13.00</td><td> 26</td></tr>
  <tr><td>Eastern cottonwood  </td><td>   10</td><td>10.800000</td><td>6.178817</td><td> 3</td><td> 7.25</td><td> 9.0</td><td>11.75</td><td> 22</td></tr>
  <tr><td>Green ash           </td><td>  770</td><td> 9.255844</td><td>4.371351</td><td> 0</td><td> 6.00</td><td> 9.0</td><td>12.00</td><td> 28</td></tr>
  <tr><td>Honeylocust         </td><td>13176</td><td> 9.058060</td><td>3.997006</td><td> 0</td><td> 6.00</td><td> 9.0</td><td>11.00</td><td>109</td></tr>
  <tr><td>Mulberry            </td><td>   68</td><td>11.000000</td><td>7.732467</td><td> 1</td><td> 5.00</td><td> 9.0</td><td>15.00</td><td> 44</td></tr>
  <tr><td>Norway maple        </td><td>  290</td><td>10.237931</td><td>5.801379</td><td> 2</td><td> 6.00</td><td> 9.0</td><td>13.00</td><td> 35</td></tr>
  <tr><td>Pin oak             </td><td> 4584</td><td>10.068499</td><td>7.982340</td><td> 1</td><td> 5.00</td><td> 9.0</td><td>13.00</td><td>318</td></tr>
  <tr><td>Sophora             </td><td> 4453</td><td> 9.225915</td><td>4.892435</td><td> 1</td><td> 5.00</td><td> 9.0</td><td>13.00</td><td> 38</td></tr>
  <tr><td>Callery pear        </td><td> 7297</td><td> 8.681376</td><td>4.717342</td><td> 1</td><td> 6.00</td><td> 8.0</td><td>11.00</td><td>228</td></tr>
  <tr><td>Catalpa             </td><td>   13</td><td> 8.538462</td><td>4.370648</td><td> 4</td><td> 6.00</td><td> 8.0</td><td> 9.00</td><td> 21</td></tr>
  <tr><td>Ginkgo              </td><td> 5859</td><td> 8.445981</td><td>4.159496</td><td> 1</td><td> 5.00</td><td> 8.0</td><td>11.00</td><td> 74</td></tr>
  <tr><td>Pignut hickory      </td><td>    1</td><td> 8.000000</td><td>      NA</td><td> 8</td><td> 8.00</td><td> 8.0</td><td> 8.00</td><td>  8</td></tr>
  <tr><td>Pitch pine          </td><td>    5</td><td> 7.400000</td><td>3.286335</td><td> 4</td><td> 4.00</td><td> 8.0</td><td>10.00</td><td> 11</td></tr>
  <tr><td>Red horse chestnut  </td><td>    1</td><td> 8.000000</td><td>      NA</td><td> 8</td><td> 8.00</td><td> 8.0</td><td> 8.00</td><td>  8</td></tr>
  <tr><td>American hophornbeam</td><td>   84</td><td> 8.345238</td><td>4.956422</td><td> 2</td><td> 4.00</td><td> 7.5</td><td>12.00</td><td> 22</td></tr>
  <tr><td>⋮</td><td>⋮</td><td>⋮</td><td>⋮</td><td>⋮</td><td>⋮</td><td>⋮</td><td>⋮</td><td>⋮</td></tr>
  <tr><td>Shingle oak        </td><td>205</td><td>5.853659</td><td>4.2780847</td><td>1</td><td>3.00</td><td>4.0</td><td> 7.00</td><td>30</td></tr>
  <tr><td>Southern red oak   </td><td>  7</td><td>7.142857</td><td>4.4880794</td><td>3</td><td>4.00</td><td>4.0</td><td>10.50</td><td>14</td></tr>
  <tr><td>Sweetgum           </td><td>227</td><td>4.991189</td><td>3.3761149</td><td>2</td><td>3.00</td><td>4.0</td><td> 6.00</td><td>22</td></tr>
  <tr><td>Tulip-poplar       </td><td> 34</td><td>4.235294</td><td>0.9553303</td><td>2</td><td>4.00</td><td>4.0</td><td> 5.00</td><td> 6</td></tr>
  <tr><td>Turkish hazelnut   </td><td> 17</td><td>4.764706</td><td>2.9053703</td><td>2</td><td>3.00</td><td>4.0</td><td> 5.00</td><td>11</td></tr>
  <tr><td>White oak          </td><td>241</td><td>5.240664</td><td>2.9069181</td><td>2</td><td>3.00</td><td>4.0</td><td> 7.00</td><td>17</td></tr>
  <tr><td>American beech     </td><td> 22</td><td>5.227273</td><td>3.8412773</td><td>1</td><td>3.00</td><td>3.5</td><td> 7.50</td><td>16</td></tr>
  <tr><td>Blackgum           </td><td>  9</td><td>3.555556</td><td>2.5549516</td><td>2</td><td>2.00</td><td>3.0</td><td> 4.00</td><td>10</td></tr>
  <tr><td>Chinese fringetree </td><td>  9</td><td>3.555556</td><td>1.6666667</td><td>2</td><td>2.00</td><td>3.0</td><td> 4.00</td><td> 7</td></tr>
  <tr><td>Common hackberry   </td><td>170</td><td>4.323529</td><td>2.8484459</td><td>1</td><td>2.00</td><td>3.0</td><td> 5.00</td><td>14</td></tr>
  <tr><td>Eastern hemlock    </td><td>  7</td><td>3.571429</td><td>0.7867958</td><td>3</td><td>3.00</td><td>3.0</td><td> 4.00</td><td> 5</td></tr>
  <tr><td>Eastern redcedar   </td><td> 42</td><td>3.476190</td><td>2.1096537</td><td>2</td><td>2.00</td><td>3.0</td><td> 4.00</td><td>10</td></tr>
  <tr><td>Hardy rubber tree  </td><td> 66</td><td>3.803030</td><td>2.2750804</td><td>2</td><td>2.00</td><td>3.0</td><td> 5.00</td><td>14</td></tr>
  <tr><td>Horse chestnut     </td><td> 11</td><td>3.090909</td><td>0.7006490</td><td>2</td><td>3.00</td><td>3.0</td><td> 3.50</td><td> 4</td></tr>
  <tr><td>Kentucky yellowwood</td><td> 18</td><td>4.666667</td><td>3.2358288</td><td>2</td><td>3.00</td><td>3.0</td><td> 4.00</td><td>14</td></tr>
  <tr><td>Mimosa             </td><td> 12</td><td>3.750000</td><td>2.5980762</td><td>1</td><td>2.00</td><td>3.0</td><td> 4.25</td><td>11</td></tr>
  <tr><td>Norway spruce      </td><td>  3</td><td>4.000000</td><td>2.6457513</td><td>2</td><td>2.50</td><td>3.0</td><td> 5.00</td><td> 7</td></tr>
  <tr><td>Pagoda dogwood     </td><td> 18</td><td>4.888889</td><td>4.4442810</td><td>2</td><td>2.25</td><td>3.0</td><td> 4.00</td><td>16</td></tr>
  <tr><td>Paperbark maple    </td><td> 15</td><td>3.266667</td><td>1.7099151</td><td>1</td><td>2.00</td><td>3.0</td><td> 4.00</td><td> 8</td></tr>
  <tr><td>Sassafras          </td><td> 17</td><td>5.470588</td><td>4.2296224</td><td>2</td><td>3.00</td><td>3.0</td><td> 6.00</td><td>16</td></tr>
  <tr><td>Spruce             </td><td>  1</td><td>3.000000</td><td>       NA</td><td>3</td><td>3.00</td><td>3.0</td><td> 3.00</td><td> 3</td></tr>
  <tr><td>Swamp white oak    </td><td>681</td><td>4.027900</td><td>2.4723381</td><td>0</td><td>3.00</td><td>3.0</td><td> 4.00</td><td>32</td></tr>
  <tr><td>Blue spruce        </td><td>  4</td><td>4.250000</td><td>3.8622101</td><td>2</td><td>2.00</td><td>2.5</td><td> 4.75</td><td>10</td></tr>
  <tr><td>Pond cypress       </td><td> 12</td><td>2.666667</td><td>0.8876254</td><td>2</td><td>2.00</td><td>2.5</td><td> 3.00</td><td> 5</td></tr>
  <tr><td>Scots pine         </td><td>  2</td><td>2.500000</td><td>0.7071068</td><td>2</td><td>2.25</td><td>2.5</td><td> 2.75</td><td> 3</td></tr>
  <tr><td>Arborvitae         </td><td>  5</td><td>3.400000</td><td>3.1304952</td><td>2</td><td>2.00</td><td>2.0</td><td> 2.00</td><td> 9</td></tr>
  <tr><td>Douglas-fir        </td><td>  2</td><td>2.000000</td><td>1.4142136</td><td>1</td><td>1.50</td><td>2.0</td><td> 2.50</td><td> 3</td></tr>
  <tr><td>Himalayan cedar    </td><td>  6</td><td>2.333333</td><td>0.5163978</td><td>2</td><td>2.00</td><td>2.0</td><td> 2.75</td><td> 3</td></tr>
  <tr><td>Persian ironwood   </td><td>  1</td><td>2.000000</td><td>       NA</td><td>2</td><td>2.00</td><td>2.0</td><td> 2.00</td><td> 2</td></tr>
  <tr><td>Osage-orange       </td><td>  1</td><td>0.000000</td><td>       NA</td><td>0</td><td>0.00</td><td>0.0</td><td> 0.00</td><td> 0</td></tr>
</tbody>
</table>



#### ***Status per species***


```R
# Status per species
spc_status
```


<table class="dataframe">
<caption>A tibble: 129 × 4</caption>
<thead>
  <tr><th scope=col>spc_common</th><th scope=col>status</th><th scope=col>number_of_trees</th><th scope=col>percentage_wrt_spc</th></tr>
  <tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;chr&gt;</th></tr>
</thead>
<tbody>
  <tr><td>Honeylocust           </td><td>Dead </td><td>    1</td><td>0.01%  </td></tr>
  <tr><td>Honeylocust           </td><td>Alive</td><td>13175</td><td>99.99% </td></tr>
  <tr><td>'Schubert' chokecherry</td><td>Alive</td><td>  163</td><td>100.00%</td></tr>
  <tr><td>American beech        </td><td>Alive</td><td>   22</td><td>100.00%</td></tr>
  <tr><td>American elm          </td><td>Alive</td><td> 1698</td><td>100.00%</td></tr>
  <tr><td>American hophornbeam  </td><td>Alive</td><td>   84</td><td>100.00%</td></tr>
  <tr><td>American hornbeam     </td><td>Alive</td><td>   85</td><td>100.00%</td></tr>
  <tr><td>American larch        </td><td>Alive</td><td>    7</td><td>100.00%</td></tr>
  <tr><td>American linden       </td><td>Alive</td><td> 1583</td><td>100.00%</td></tr>
  <tr><td>Amur cork tree        </td><td>Alive</td><td>    8</td><td>100.00%</td></tr>
  <tr><td>Amur maackia          </td><td>Alive</td><td>   59</td><td>100.00%</td></tr>
  <tr><td>Amur maple            </td><td>Alive</td><td>   30</td><td>100.00%</td></tr>
  <tr><td>Arborvitae            </td><td>Alive</td><td>    5</td><td>100.00%</td></tr>
  <tr><td>Ash                   </td><td>Alive</td><td>   58</td><td>100.00%</td></tr>
  <tr><td>Atlantic white cedar  </td><td>Alive</td><td>   12</td><td>100.00%</td></tr>
  <tr><td>Bald cypress          </td><td>Alive</td><td>   89</td><td>100.00%</td></tr>
  <tr><td>Bigtooth aspen        </td><td>Alive</td><td>    5</td><td>100.00%</td></tr>
  <tr><td>Black cherry          </td><td>Alive</td><td>   32</td><td>100.00%</td></tr>
  <tr><td>Black locust          </td><td>Alive</td><td>  259</td><td>100.00%</td></tr>
  <tr><td>Black maple           </td><td>Alive</td><td>   10</td><td>100.00%</td></tr>
  <tr><td>Black oak             </td><td>Alive</td><td>  192</td><td>100.00%</td></tr>
  <tr><td>Black pine            </td><td>Alive</td><td>    3</td><td>100.00%</td></tr>
  <tr><td>Black walnut          </td><td>Alive</td><td>   33</td><td>100.00%</td></tr>
  <tr><td>Blackgum              </td><td>Alive</td><td>    9</td><td>100.00%</td></tr>
  <tr><td>Blue spruce           </td><td>Alive</td><td>    4</td><td>100.00%</td></tr>
  <tr><td>Boxelder              </td><td>Alive</td><td>    2</td><td>100.00%</td></tr>
  <tr><td>Bur oak               </td><td>Alive</td><td>   36</td><td>100.00%</td></tr>
  <tr><td>Callery pear          </td><td>Alive</td><td> 7297</td><td>100.00%</td></tr>
  <tr><td>Catalpa               </td><td>Alive</td><td>   13</td><td>100.00%</td></tr>
  <tr><td>Cherry                </td><td>Alive</td><td>  869</td><td>100.00%</td></tr>
  <tr><td>⋮</td><td>⋮</td><td>⋮</td><td>⋮</td></tr>
  <tr><td>Sawtooth oak         </td><td>Alive</td><td> 353</td><td>100.00%</td></tr>
  <tr><td>Scarlet oak          </td><td>Alive</td><td>  71</td><td>100.00%</td></tr>
  <tr><td>Schumard's oak       </td><td>Alive</td><td> 137</td><td>100.00%</td></tr>
  <tr><td>Scots pine           </td><td>Alive</td><td>   2</td><td>100.00%</td></tr>
  <tr><td>Serviceberry         </td><td>Alive</td><td>  38</td><td>100.00%</td></tr>
  <tr><td>Shingle oak          </td><td>Alive</td><td> 205</td><td>100.00%</td></tr>
  <tr><td>Siberian elm         </td><td>Alive</td><td> 156</td><td>100.00%</td></tr>
  <tr><td>Silver birch         </td><td>Alive</td><td>  10</td><td>100.00%</td></tr>
  <tr><td>Silver linden        </td><td>Alive</td><td> 541</td><td>100.00%</td></tr>
  <tr><td>Silver maple         </td><td>Alive</td><td>  71</td><td>100.00%</td></tr>
  <tr><td>Smoketree            </td><td>Alive</td><td>   1</td><td>100.00%</td></tr>
  <tr><td>Sophora              </td><td>Alive</td><td>4453</td><td>100.00%</td></tr>
  <tr><td>Southern magnolia    </td><td>Alive</td><td>  19</td><td>100.00%</td></tr>
  <tr><td>Southern red oak     </td><td>Alive</td><td>   7</td><td>100.00%</td></tr>
  <tr><td>Spruce               </td><td>Alive</td><td>   1</td><td>100.00%</td></tr>
  <tr><td>Sugar maple          </td><td>Alive</td><td>  48</td><td>100.00%</td></tr>
  <tr><td>Swamp white oak      </td><td>Alive</td><td> 681</td><td>100.00%</td></tr>
  <tr><td>Sweetgum             </td><td>Alive</td><td> 227</td><td>100.00%</td></tr>
  <tr><td>Sycamore maple       </td><td>Alive</td><td>  23</td><td>100.00%</td></tr>
  <tr><td>Tartar maple         </td><td>Alive</td><td>  12</td><td>100.00%</td></tr>
  <tr><td>Tree of heaven       </td><td>Alive</td><td> 104</td><td>100.00%</td></tr>
  <tr><td>Tulip-poplar         </td><td>Alive</td><td>  34</td><td>100.00%</td></tr>
  <tr><td>Turkish hazelnut     </td><td>Alive</td><td>  17</td><td>100.00%</td></tr>
  <tr><td>Two-winged silverbell</td><td>Alive</td><td>   8</td><td>100.00%</td></tr>
  <tr><td>Virginia pine        </td><td>Alive</td><td>   3</td><td>100.00%</td></tr>
  <tr><td>Weeping willow       </td><td>Alive</td><td>  12</td><td>100.00%</td></tr>
  <tr><td>White ash            </td><td>Alive</td><td>  50</td><td>100.00%</td></tr>
  <tr><td>White oak            </td><td>Alive</td><td> 241</td><td>100.00%</td></tr>
  <tr><td>White pine           </td><td>Alive</td><td>   1</td><td>100.00%</td></tr>
  <tr><td>Willow oak           </td><td>Alive</td><td> 889</td><td>100.00%</td></tr>
</tbody>
</table>



#### ***Health per species***


```R
# Health per species
spc_health %>%
  select(-proportion)
```


<table class="dataframe">
<caption>A tibble: 332 × 4</caption>
<thead>
  <tr><th scope=col>spc_common</th><th scope=col>health</th><th scope=col>number_of_trees</th><th scope=col>percentage</th></tr>
  <tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;fct&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;chr&gt;</th></tr>
</thead>
<tbody>
  <tr><td>'Schubert' chokecherry</td><td>Good</td><td> 111</td><td>68.10% </td></tr>
  <tr><td>'Schubert' chokecherry</td><td>Fair</td><td>  40</td><td>24.54% </td></tr>
  <tr><td>'Schubert' chokecherry</td><td>Poor</td><td>  12</td><td>7.36%  </td></tr>
  <tr><td>American beech        </td><td>Good</td><td>  15</td><td>68.18% </td></tr>
  <tr><td>American beech        </td><td>Fair</td><td>   4</td><td>18.18% </td></tr>
  <tr><td>American beech        </td><td>Poor</td><td>   3</td><td>13.64% </td></tr>
  <tr><td>American elm          </td><td>Good</td><td>1361</td><td>80.15% </td></tr>
  <tr><td>American elm          </td><td>Fair</td><td> 259</td><td>15.25% </td></tr>
  <tr><td>American elm          </td><td>Poor</td><td>  78</td><td>4.59%  </td></tr>
  <tr><td>American hophornbeam  </td><td>Good</td><td>  64</td><td>76.19% </td></tr>
  <tr><td>American hophornbeam  </td><td>Fair</td><td>  12</td><td>14.29% </td></tr>
  <tr><td>American hophornbeam  </td><td>Poor</td><td>   8</td><td>9.52%  </td></tr>
  <tr><td>American hornbeam     </td><td>Good</td><td>  67</td><td>78.82% </td></tr>
  <tr><td>American hornbeam     </td><td>Fair</td><td>  13</td><td>15.29% </td></tr>
  <tr><td>American hornbeam     </td><td>Poor</td><td>   5</td><td>5.88%  </td></tr>
  <tr><td>American larch        </td><td>Fair</td><td>   3</td><td>42.86% </td></tr>
  <tr><td>American larch        </td><td>Good</td><td>   3</td><td>42.86% </td></tr>
  <tr><td>American larch        </td><td>Poor</td><td>   1</td><td>14.29% </td></tr>
  <tr><td>American linden       </td><td>Good</td><td>1020</td><td>64.43% </td></tr>
  <tr><td>American linden       </td><td>Fair</td><td> 379</td><td>23.94% </td></tr>
  <tr><td>American linden       </td><td>Poor</td><td> 184</td><td>11.62% </td></tr>
  <tr><td>Amur cork tree        </td><td>Good</td><td>   7</td><td>87.50% </td></tr>
  <tr><td>Amur cork tree        </td><td>Fair</td><td>   1</td><td>12.50% </td></tr>
  <tr><td>Amur maackia          </td><td>Good</td><td>  46</td><td>77.97% </td></tr>
  <tr><td>Amur maackia          </td><td>Fair</td><td>  10</td><td>16.95% </td></tr>
  <tr><td>Amur maackia          </td><td>Poor</td><td>   3</td><td>5.08%  </td></tr>
  <tr><td>Amur maple            </td><td>Good</td><td>  19</td><td>63.33% </td></tr>
  <tr><td>Amur maple            </td><td>Fair</td><td>   7</td><td>23.33% </td></tr>
  <tr><td>Amur maple            </td><td>Poor</td><td>   4</td><td>13.33% </td></tr>
  <tr><td>Arborvitae            </td><td>Good</td><td>   5</td><td>100.00%</td></tr>
  <tr><td>⋮</td><td>⋮</td><td>⋮</td><td>⋮</td></tr>
  <tr><td>Sycamore maple       </td><td>Fair</td><td>  7</td><td>30.43% </td></tr>
  <tr><td>Sycamore maple       </td><td>Poor</td><td>  2</td><td>8.70%  </td></tr>
  <tr><td>Tartar maple         </td><td>Good</td><td>  5</td><td>41.67% </td></tr>
  <tr><td>Tartar maple         </td><td>Fair</td><td>  4</td><td>33.33% </td></tr>
  <tr><td>Tartar maple         </td><td>Poor</td><td>  3</td><td>25.00% </td></tr>
  <tr><td>Tree of heaven       </td><td>Good</td><td> 82</td><td>78.85% </td></tr>
  <tr><td>Tree of heaven       </td><td>Fair</td><td> 17</td><td>16.35% </td></tr>
  <tr><td>Tree of heaven       </td><td>Poor</td><td>  5</td><td>4.81%  </td></tr>
  <tr><td>Tulip-poplar         </td><td>Good</td><td> 17</td><td>50.00% </td></tr>
  <tr><td>Tulip-poplar         </td><td>Fair</td><td> 10</td><td>29.41% </td></tr>
  <tr><td>Tulip-poplar         </td><td>Poor</td><td>  7</td><td>20.59% </td></tr>
  <tr><td>Turkish hazelnut     </td><td>Fair</td><td>  9</td><td>52.94% </td></tr>
  <tr><td>Turkish hazelnut     </td><td>Good</td><td>  7</td><td>41.18% </td></tr>
  <tr><td>Turkish hazelnut     </td><td>Poor</td><td>  1</td><td>5.88%  </td></tr>
  <tr><td>Two-winged silverbell</td><td>Good</td><td>  5</td><td>62.50% </td></tr>
  <tr><td>Two-winged silverbell</td><td>Fair</td><td>  3</td><td>37.50% </td></tr>
  <tr><td>Virginia pine        </td><td>Good</td><td>  2</td><td>66.67% </td></tr>
  <tr><td>Virginia pine        </td><td>Poor</td><td>  1</td><td>33.33% </td></tr>
  <tr><td>Weeping willow       </td><td>Good</td><td>  8</td><td>66.67% </td></tr>
  <tr><td>Weeping willow       </td><td>Fair</td><td>  4</td><td>33.33% </td></tr>
  <tr><td>White ash            </td><td>Good</td><td> 40</td><td>80.00% </td></tr>
  <tr><td>White ash            </td><td>Fair</td><td>  8</td><td>16.00% </td></tr>
  <tr><td>White ash            </td><td>Poor</td><td>  2</td><td>4.00%  </td></tr>
  <tr><td>White oak            </td><td>Good</td><td>162</td><td>67.22% </td></tr>
  <tr><td>White oak            </td><td>Fair</td><td> 56</td><td>23.24% </td></tr>
  <tr><td>White oak            </td><td>Poor</td><td> 23</td><td>9.54%  </td></tr>
  <tr><td>White pine           </td><td>Fair</td><td>  1</td><td>100.00%</td></tr>
  <tr><td>Willow oak           </td><td>Good</td><td>747</td><td>84.03% </td></tr>
  <tr><td>Willow oak           </td><td>Fair</td><td>115</td><td>12.94% </td></tr>
  <tr><td>Willow oak           </td><td>Poor</td><td> 27</td><td>3.04%  </td></tr>
</tbody>
</table>



#### ***Health index per species***


```R
spc_health_index %>%
  select(-abundance)
```


<table class="dataframe">
<caption>A tibble: 128 × 2</caption>
<thead>
  <tr><th scope=col>spc_common</th><th scope=col>health_index</th></tr>
  <tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;dbl&gt;</th></tr>
</thead>
<tbody>
  <tr><td>Arborvitae         </td><td>1.0000000</td></tr>
  <tr><td>Black pine         </td><td>1.0000000</td></tr>
  <tr><td>Blue spruce        </td><td>1.0000000</td></tr>
  <tr><td>Crepe myrtle       </td><td>1.0000000</td></tr>
  <tr><td>European beech     </td><td>1.0000000</td></tr>
  <tr><td>Osage-orange       </td><td>1.0000000</td></tr>
  <tr><td>Persian ironwood   </td><td>1.0000000</td></tr>
  <tr><td>Pitch pine         </td><td>1.0000000</td></tr>
  <tr><td>Red horse chestnut </td><td>1.0000000</td></tr>
  <tr><td>Red pine           </td><td>1.0000000</td></tr>
  <tr><td>Scots pine         </td><td>1.0000000</td></tr>
  <tr><td>Smoketree          </td><td>1.0000000</td></tr>
  <tr><td>Black maple        </td><td>0.9666667</td></tr>
  <tr><td>Amur cork tree     </td><td>0.9583333</td></tr>
  <tr><td>Golden raintree    </td><td>0.9554318</td></tr>
  <tr><td>Southern red oak   </td><td>0.9523810</td></tr>
  <tr><td>Sawtooth oak       </td><td>0.9471199</td></tr>
  <tr><td>Kentucky coffeetree</td><td>0.9415709</td></tr>
  <tr><td>Japanese maple     </td><td>0.9393939</td></tr>
  <tr><td>Honeylocust        </td><td>0.9387223</td></tr>
  <tr><td>Willow oak         </td><td>0.9366329</td></tr>
  <tr><td>Holly              </td><td>0.9358974</td></tr>
  <tr><td>Siberian elm       </td><td>0.9316239</td></tr>
  <tr><td>Southern magnolia  </td><td>0.9298246</td></tr>
  <tr><td>Eastern redcedar   </td><td>0.9285714</td></tr>
  <tr><td>Hawthorn           </td><td>0.9284627</td></tr>
  <tr><td>Pin oak            </td><td>0.9282286</td></tr>
  <tr><td>Crab apple         </td><td>0.9260107</td></tr>
  <tr><td>Blackgum           </td><td>0.9259259</td></tr>
  <tr><td>Shingle oak        </td><td>0.9252033</td></tr>
  <tr><td>⋮</td><td>⋮</td></tr>
  <tr><td>Bigtooth aspen     </td><td>0.8000000</td></tr>
  <tr><td>Eastern cottonwood </td><td>0.8000000</td></tr>
  <tr><td>Japanese snowbell  </td><td>0.8000000</td></tr>
  <tr><td>Hedge maple        </td><td>0.7971014</td></tr>
  <tr><td>Sassafras          </td><td>0.7843137</td></tr>
  <tr><td>Turkish hazelnut   </td><td>0.7843137</td></tr>
  <tr><td>Silver maple       </td><td>0.7840376</td></tr>
  <tr><td>Katsura tree       </td><td>0.7807018</td></tr>
  <tr><td>Cucumber magnolia  </td><td>0.7777778</td></tr>
  <tr><td>Kentucky yellowwood</td><td>0.7777778</td></tr>
  <tr><td>Norway spruce      </td><td>0.7777778</td></tr>
  <tr><td>Pine               </td><td>0.7777778</td></tr>
  <tr><td>Virginia pine      </td><td>0.7777778</td></tr>
  <tr><td>Tulip-poplar       </td><td>0.7647059</td></tr>
  <tr><td>American larch     </td><td>0.7619048</td></tr>
  <tr><td>Horse chestnut     </td><td>0.7575758</td></tr>
  <tr><td>Pagoda dogwood     </td><td>0.7407407</td></tr>
  <tr><td>Tartar maple       </td><td>0.7222222</td></tr>
  <tr><td>Maple              </td><td>0.7027027</td></tr>
  <tr><td>Cockspur hawthorn  </td><td>0.6666667</td></tr>
  <tr><td>Douglas-fir        </td><td>0.6666667</td></tr>
  <tr><td>Paperbark maple    </td><td>0.6666667</td></tr>
  <tr><td>Pignut hickory     </td><td>0.6666667</td></tr>
  <tr><td>Spruce             </td><td>0.6666667</td></tr>
  <tr><td>White pine         </td><td>0.6666667</td></tr>
  <tr><td>Crimson king maple </td><td>0.5555556</td></tr>
  <tr><td>Pond cypress       </td><td>0.5555556</td></tr>
  <tr><td>Eastern hemlock    </td><td>0.5238095</td></tr>
  <tr><td>Boxelder           </td><td>0.5000000</td></tr>
  <tr><td>European alder     </td><td>0.5000000</td></tr>
</tbody>
</table>



#### ***Species' distribution of root problems***


```R
trees %>%
  select(spc_common, root_stone:root_other) %>%
  filter(spc_common != "null",
           if_all(-spc_common, ~ .x != "null")) %>%
  mutate(across(root_stone:root_other, ~ ifelse(.x == "Yes", 1, 0)),
           no_problem = ifelse(root_stone == 0 &
                               root_grate == 0 &
                               root_other == 0, 1, 0)) %>%
  group_by(spc_common) %>%
  summarize(no_problem = 100*sum(no_problem)/n(),
              root_stone = 100*sum(root_stone)/n(),
              root_grate = 100*sum(root_grate)/n(),
              root_other = 100*sum(root_other)/n()) %>%
  arrange(no_problem) %>%
    mutate_if(is.numeric, ~(round(., digits = 2)))
```


<table class="dataframe">
<caption>A tibble: 128 × 5</caption>
<thead>
  <tr><th scope=col>spc_common</th><th scope=col>no_problem</th><th scope=col>root_stone</th><th scope=col>root_grate</th><th scope=col>root_other</th></tr>
  <tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th></tr>
</thead>
<tbody>
  <tr><td>White pine         </td><td> 0.00</td><td>100.00</td><td> 0.00</td><td> 0.00</td></tr>
  <tr><td>European beech     </td><td>16.67</td><td> 50.00</td><td> 0.00</td><td>50.00</td></tr>
  <tr><td>Tartar maple       </td><td>16.67</td><td> 66.67</td><td> 0.00</td><td>16.67</td></tr>
  <tr><td>Southern magnolia  </td><td>26.32</td><td> 57.89</td><td> 0.00</td><td>21.05</td></tr>
  <tr><td>Norway spruce      </td><td>33.33</td><td>  0.00</td><td> 0.00</td><td>66.67</td></tr>
  <tr><td>Katsura tree       </td><td>42.11</td><td> 28.95</td><td>21.05</td><td> 7.89</td></tr>
  <tr><td>Tree of heaven     </td><td>45.19</td><td> 43.27</td><td> 1.92</td><td>12.50</td></tr>
  <tr><td>Sassafras          </td><td>47.06</td><td> 35.29</td><td> 0.00</td><td>23.53</td></tr>
  <tr><td>Boxelder           </td><td>50.00</td><td> 50.00</td><td> 0.00</td><td> 0.00</td></tr>
  <tr><td>Cucumber magnolia  </td><td>50.00</td><td> 16.67</td><td>33.33</td><td>33.33</td></tr>
  <tr><td>European alder     </td><td>50.00</td><td> 50.00</td><td> 0.00</td><td> 0.00</td></tr>
  <tr><td>Quaking aspen      </td><td>50.00</td><td> 50.00</td><td> 0.00</td><td> 0.00</td></tr>
  <tr><td>Weeping willow     </td><td>50.00</td><td> 33.33</td><td> 0.00</td><td>16.67</td></tr>
  <tr><td>Ohio buckeye       </td><td>58.33</td><td> 29.17</td><td> 0.00</td><td>12.50</td></tr>
  <tr><td>Empress tree       </td><td>58.82</td><td> 41.18</td><td> 0.00</td><td> 0.00</td></tr>
  <tr><td>Cornelian cherry   </td><td>59.26</td><td>  3.70</td><td>33.33</td><td> 3.70</td></tr>
  <tr><td>Crepe myrtle       </td><td>60.00</td><td> 40.00</td><td> 0.00</td><td> 0.00</td></tr>
  <tr><td>Eastern cottonwood </td><td>60.00</td><td> 30.00</td><td> 0.00</td><td>20.00</td></tr>
  <tr><td>Black walnut       </td><td>60.61</td><td> 39.39</td><td> 3.03</td><td> 0.00</td></tr>
  <tr><td>Japanese tree lilac</td><td>62.02</td><td> 22.48</td><td> 8.53</td><td>10.85</td></tr>
  <tr><td>Honeylocust        </td><td>62.15</td><td> 25.50</td><td> 6.28</td><td>10.66</td></tr>
  <tr><td>Japanese hornbeam  </td><td>64.52</td><td> 25.81</td><td> 3.23</td><td> 9.68</td></tr>
  <tr><td>Green ash          </td><td>65.45</td><td> 26.88</td><td> 1.04</td><td> 8.83</td></tr>
  <tr><td>Cockspur hawthorn  </td><td>66.67</td><td> 33.33</td><td> 0.00</td><td>33.33</td></tr>
  <tr><td>Crimson king maple </td><td>66.67</td><td> 33.33</td><td> 0.00</td><td>16.67</td></tr>
  <tr><td>Oklahoma redbud    </td><td>66.67</td><td> 33.33</td><td> 0.00</td><td> 0.00</td></tr>
  <tr><td>Paperbark maple    </td><td>66.67</td><td> 13.33</td><td> 6.67</td><td>20.00</td></tr>
  <tr><td>Virginia pine      </td><td>66.67</td><td> 33.33</td><td> 0.00</td><td> 0.00</td></tr>
  <tr><td>Norway maple       </td><td>67.24</td><td> 27.93</td><td> 1.03</td><td> 7.93</td></tr>
  <tr><td>Callery pear       </td><td>67.60</td><td> 20.87</td><td> 7.02</td><td> 8.17</td></tr>
  <tr><td>⋮</td><td>⋮</td><td>⋮</td><td>⋮</td><td>⋮</td></tr>
  <tr><td>Eastern redbud       </td><td> 92.00</td><td>4.00</td><td>0</td><td>4.00</td></tr>
  <tr><td>River birch          </td><td> 92.59</td><td>3.70</td><td>0</td><td>3.70</td></tr>
  <tr><td>Magnolia             </td><td> 93.10</td><td>5.17</td><td>0</td><td>1.72</td></tr>
  <tr><td>Bur oak              </td><td> 94.44</td><td>2.78</td><td>0</td><td>2.78</td></tr>
  <tr><td>American hornbeam    </td><td> 95.29</td><td>3.53</td><td>0</td><td>1.18</td></tr>
  <tr><td>Crab apple           </td><td> 96.34</td><td>2.75</td><td>0</td><td>1.14</td></tr>
  <tr><td>Eastern redcedar     </td><td> 97.62</td><td>0.00</td><td>0</td><td>2.38</td></tr>
  <tr><td>Hawthorn             </td><td> 97.72</td><td>0.91</td><td>0</td><td>1.37</td></tr>
  <tr><td>European hornbeam    </td><td> 98.20</td><td>0.00</td><td>0</td><td>1.80</td></tr>
  <tr><td>American larch       </td><td>100.00</td><td>0.00</td><td>0</td><td>0.00</td></tr>
  <tr><td>Arborvitae           </td><td>100.00</td><td>0.00</td><td>0</td><td>0.00</td></tr>
  <tr><td>Bigtooth aspen       </td><td>100.00</td><td>0.00</td><td>0</td><td>0.00</td></tr>
  <tr><td>Black pine           </td><td>100.00</td><td>0.00</td><td>0</td><td>0.00</td></tr>
  <tr><td>Blue spruce          </td><td>100.00</td><td>0.00</td><td>0</td><td>0.00</td></tr>
  <tr><td>Douglas-fir          </td><td>100.00</td><td>0.00</td><td>0</td><td>0.00</td></tr>
  <tr><td>Himalayan cedar      </td><td>100.00</td><td>0.00</td><td>0</td><td>0.00</td></tr>
  <tr><td>Kousa dogwood        </td><td>100.00</td><td>0.00</td><td>0</td><td>0.00</td></tr>
  <tr><td>Osage-orange         </td><td>100.00</td><td>0.00</td><td>0</td><td>0.00</td></tr>
  <tr><td>Persian ironwood     </td><td>100.00</td><td>0.00</td><td>0</td><td>0.00</td></tr>
  <tr><td>Pignut hickory       </td><td>100.00</td><td>0.00</td><td>0</td><td>0.00</td></tr>
  <tr><td>Pine                 </td><td>100.00</td><td>0.00</td><td>0</td><td>0.00</td></tr>
  <tr><td>Pitch pine           </td><td>100.00</td><td>0.00</td><td>0</td><td>0.00</td></tr>
  <tr><td>Pond cypress         </td><td>100.00</td><td>0.00</td><td>0</td><td>0.00</td></tr>
  <tr><td>Red horse chestnut   </td><td>100.00</td><td>0.00</td><td>0</td><td>0.00</td></tr>
  <tr><td>Red pine             </td><td>100.00</td><td>0.00</td><td>0</td><td>0.00</td></tr>
  <tr><td>Scots pine           </td><td>100.00</td><td>0.00</td><td>0</td><td>0.00</td></tr>
  <tr><td>Smoketree            </td><td>100.00</td><td>0.00</td><td>0</td><td>0.00</td></tr>
  <tr><td>Southern red oak     </td><td>100.00</td><td>0.00</td><td>0</td><td>0.00</td></tr>
  <tr><td>Spruce               </td><td>100.00</td><td>0.00</td><td>0</td><td>0.00</td></tr>
  <tr><td>Two-winged silverbell</td><td>100.00</td><td>0.00</td><td>0</td><td>0.00</td></tr>
</tbody>
</table>



#### ***Species' distribution of trunk problems***


```R
trees %>%
  select(spc_common, trunk_wire:trnk_other) %>%
  filter(spc_common != "null",
           if_all(-spc_common, ~ .x != "null")) %>%
  mutate(across(trunk_wire:trnk_other, ~ ifelse(.x == "Yes", 1, 0)),
           no_problem = ifelse(trunk_wire == 0 &
                               trnk_light == 0 &
                               trnk_other == 0, 1, 0)) %>%
  group_by(spc_common) %>%
  summarize(no_problem = 100*sum(no_problem)/n(),
              trunk_wire = 100*sum(trunk_wire)/n(),
              trnk_light = 100*sum(trnk_light)/n(),
              trnk_other = 100*sum(trnk_other)/n()) %>%
  arrange(no_problem) %>%
    mutate_if(is.numeric, ~(round(., digits = 2)))
```


<table class="dataframe">
<caption>A tibble: 128 × 5</caption>
<thead>
  <tr><th scope=col>spc_common</th><th scope=col>no_problem</th><th scope=col>trunk_wire</th><th scope=col>trnk_light</th><th scope=col>trnk_other</th></tr>
  <tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th></tr>
</thead>
<tbody>
  <tr><td>Tartar maple      </td><td>41.67</td><td> 0.00</td><td> 0.00</td><td>58.33</td></tr>
  <tr><td>Oklahoma redbud   </td><td>44.44</td><td>11.11</td><td> 0.00</td><td>44.44</td></tr>
  <tr><td>Horse chestnut    </td><td>63.64</td><td>18.18</td><td> 0.00</td><td>18.18</td></tr>
  <tr><td>Cockspur hawthorn </td><td>66.67</td><td>33.33</td><td> 0.00</td><td> 0.00</td></tr>
  <tr><td>Crimson king maple</td><td>66.67</td><td> 0.00</td><td> 0.00</td><td>33.33</td></tr>
  <tr><td>Paperbark maple   </td><td>66.67</td><td> 0.00</td><td> 0.00</td><td>33.33</td></tr>
  <tr><td>Hedge maple       </td><td>69.57</td><td> 4.35</td><td> 0.00</td><td>26.09</td></tr>
  <tr><td>Japanese snowbell </td><td>73.33</td><td> 0.00</td><td> 0.00</td><td>26.67</td></tr>
  <tr><td>Pond cypress      </td><td>75.00</td><td> 0.00</td><td> 0.00</td><td>25.00</td></tr>
  <tr><td>Silver maple      </td><td>77.46</td><td> 8.45</td><td> 0.00</td><td>14.08</td></tr>
  <tr><td>Ohio buckeye      </td><td>79.17</td><td> 0.00</td><td> 0.00</td><td>20.83</td></tr>
  <tr><td>Eastern cottonwood</td><td>80.00</td><td> 0.00</td><td> 0.00</td><td>20.00</td></tr>
  <tr><td>Pitch pine        </td><td>80.00</td><td> 0.00</td><td> 0.00</td><td>20.00</td></tr>
  <tr><td>Silver birch      </td><td>80.00</td><td>10.00</td><td>10.00</td><td>10.00</td></tr>
  <tr><td>Maple             </td><td>81.08</td><td> 0.00</td><td>10.81</td><td> 8.11</td></tr>
  <tr><td>Tulip-poplar      </td><td>82.35</td><td> 0.00</td><td> 0.00</td><td>17.65</td></tr>
  <tr><td>Paper birch       </td><td>82.98</td><td> 2.13</td><td> 0.00</td><td>14.89</td></tr>
  <tr><td>European beech    </td><td>83.33</td><td> 0.00</td><td> 0.00</td><td>16.67</td></tr>
  <tr><td>Mimosa            </td><td>83.33</td><td>16.67</td><td> 0.00</td><td> 0.00</td></tr>
  <tr><td>Green ash         </td><td>84.16</td><td> 3.77</td><td> 0.39</td><td>12.21</td></tr>
  <tr><td>Dawn redwood      </td><td>84.92</td><td> 2.01</td><td> 0.00</td><td>13.57</td></tr>
  <tr><td>Japanese hornbeam </td><td>85.48</td><td> 4.84</td><td> 1.61</td><td> 8.06</td></tr>
  <tr><td>Eastern hemlock   </td><td>85.71</td><td> 0.00</td><td> 0.00</td><td>14.29</td></tr>
  <tr><td>Southern red oak  </td><td>85.71</td><td> 0.00</td><td> 0.00</td><td>14.29</td></tr>
  <tr><td>Sweetgum          </td><td>86.78</td><td> 2.64</td><td> 0.44</td><td>10.13</td></tr>
  <tr><td>Sophora           </td><td>87.22</td><td> 1.46</td><td> 0.49</td><td>11.34</td></tr>
  <tr><td>Chinese tree lilac</td><td>87.50</td><td> 0.00</td><td> 0.00</td><td>12.50</td></tr>
  <tr><td>London planetree  </td><td>87.70</td><td> 0.68</td><td> 0.15</td><td>11.69</td></tr>
  <tr><td>Black walnut      </td><td>87.88</td><td> 0.00</td><td> 0.00</td><td>12.12</td></tr>
  <tr><td>Ginkgo            </td><td>87.92</td><td> 1.69</td><td> 0.55</td><td>10.17</td></tr>
  <tr><td>⋮</td><td>⋮</td><td>⋮</td><td>⋮</td><td>⋮</td></tr>
  <tr><td>Blue spruce          </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>Boxelder             </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>Catalpa              </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>Chinese fringetree   </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>Crepe myrtle         </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>Cucumber magnolia    </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>Douglas-fir          </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>Eastern redcedar     </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>European alder       </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>Himalayan cedar      </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>Holly                </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>Japanese maple       </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>Kousa dogwood        </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>Norway spruce        </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>Osage-orange         </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>Persian ironwood     </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>Pignut hickory       </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>Pine                 </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>Quaking aspen        </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>Red horse chestnut   </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>Red pine             </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>Scots pine           </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>Smoketree            </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>Southern magnolia    </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>Spruce               </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>Sycamore maple       </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>Turkish hazelnut     </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>Two-winged silverbell</td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>Virginia pine        </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>White pine           </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
</tbody>
</table>



#### ***Species' distribution of branch problems***


```R
trees %>%
  select(spc_common, brch_light:brch_other) %>%
  filter(spc_common != "null",
           if_all(-spc_common, ~ .x != "null")) %>%
  mutate(across(brch_light:brch_other, ~ ifelse(.x == "Yes", 1, 0)),
           no_problem = ifelse(brch_light == 0 &
                               brch_shoe == 0 &
                               brch_other == 0, 1, 0)) %>%
  group_by(spc_common) %>%
  summarize(no_problem = 100*sum(no_problem)/n(),
              brch_light = 100*sum(brch_light)/n(),
              brch_shoe = 100*sum(brch_shoe)/n(),
              brch_other = 100*sum(brch_other)/n()) %>%
  arrange(no_problem) %>%
    mutate_if(is.numeric, ~(round(., digits = 2)))
```


<table class="dataframe">
<caption>A tibble: 128 × 5</caption>
<thead>
  <tr><th scope=col>spc_common</th><th scope=col>no_problem</th><th scope=col>brch_light</th><th scope=col>brch_shoe</th><th scope=col>brch_other</th></tr>
  <tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th></tr>
</thead>
<tbody>
  <tr><td>Boxelder           </td><td>50.00</td><td> 0.00</td><td>0.00</td><td>50.00</td></tr>
  <tr><td>Crimson king maple </td><td>50.00</td><td> 0.00</td><td>0.00</td><td>50.00</td></tr>
  <tr><td>European alder     </td><td>50.00</td><td> 0.00</td><td>0.00</td><td>50.00</td></tr>
  <tr><td>Tartar maple       </td><td>50.00</td><td> 8.33</td><td>0.00</td><td>50.00</td></tr>
  <tr><td>Maple              </td><td>67.57</td><td>10.81</td><td>0.00</td><td>21.62</td></tr>
  <tr><td>Southern magnolia  </td><td>68.42</td><td> 0.00</td><td>0.00</td><td>31.58</td></tr>
  <tr><td>Sassafras          </td><td>70.59</td><td> 5.88</td><td>0.00</td><td>29.41</td></tr>
  <tr><td>Turkish hazelnut   </td><td>70.59</td><td> 0.00</td><td>0.00</td><td>29.41</td></tr>
  <tr><td>American beech     </td><td>72.73</td><td> 4.55</td><td>0.00</td><td>22.73</td></tr>
  <tr><td>Paperbark maple    </td><td>73.33</td><td> 0.00</td><td>0.00</td><td>26.67</td></tr>
  <tr><td>Silver maple       </td><td>74.65</td><td> 0.00</td><td>0.00</td><td>25.35</td></tr>
  <tr><td>Ohio buckeye       </td><td>75.00</td><td> 0.00</td><td>0.00</td><td>25.00</td></tr>
  <tr><td>Kentucky yellowwood</td><td>77.78</td><td> 0.00</td><td>0.00</td><td>22.22</td></tr>
  <tr><td>Oklahoma redbud    </td><td>77.78</td><td> 0.00</td><td>0.00</td><td>22.22</td></tr>
  <tr><td>Pagoda dogwood     </td><td>77.78</td><td> 0.00</td><td>0.00</td><td>22.22</td></tr>
  <tr><td>Arborvitae         </td><td>80.00</td><td> 0.00</td><td>0.00</td><td>20.00</td></tr>
  <tr><td>Crepe myrtle       </td><td>80.00</td><td> 0.00</td><td>0.00</td><td>20.00</td></tr>
  <tr><td>Eastern cottonwood </td><td>80.00</td><td> 0.00</td><td>0.00</td><td>20.00</td></tr>
  <tr><td>Silver birch       </td><td>80.00</td><td>20.00</td><td>0.00</td><td> 0.00</td></tr>
  <tr><td>Sugar maple        </td><td>81.25</td><td> 2.08</td><td>0.00</td><td>16.67</td></tr>
  <tr><td>Cornelian cherry   </td><td>81.48</td><td> 3.70</td><td>0.00</td><td>14.81</td></tr>
  <tr><td>Horse chestnut     </td><td>81.82</td><td> 0.00</td><td>0.00</td><td>18.18</td></tr>
  <tr><td>Amur maple         </td><td>83.33</td><td> 0.00</td><td>0.00</td><td>16.67</td></tr>
  <tr><td>European beech     </td><td>83.33</td><td> 0.00</td><td>0.00</td><td>16.67</td></tr>
  <tr><td>Callery pear       </td><td>83.92</td><td> 2.32</td><td>0.11</td><td>14.13</td></tr>
  <tr><td>Paper birch        </td><td>85.11</td><td> 2.13</td><td>0.00</td><td>12.77</td></tr>
  <tr><td>Honeylocust        </td><td>85.21</td><td> 2.18</td><td>0.14</td><td>12.83</td></tr>
  <tr><td>Tulip-poplar       </td><td>85.29</td><td> 0.00</td><td>0.00</td><td>14.71</td></tr>
  <tr><td>Japanese snowbell  </td><td>86.67</td><td> 0.00</td><td>0.00</td><td>13.33</td></tr>
  <tr><td>Katsura tree       </td><td>86.84</td><td> 0.00</td><td>0.00</td><td>13.16</td></tr>
  <tr><td>⋮</td><td>⋮</td><td>⋮</td><td>⋮</td><td>⋮</td></tr>
  <tr><td>Bigtooth aspen       </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>Black maple          </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>Black pine           </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>Blackgum             </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>Blue spruce          </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>Chinese tree lilac   </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>Cockspur hawthorn    </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>Douglas-fir          </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>Eastern hemlock      </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>Himalayan cedar      </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>Kousa dogwood        </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>Norway spruce        </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>Osage-orange         </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>Persian ironwood     </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>Pignut hickory       </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>Pine                 </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>Pitch pine           </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>Pond cypress         </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>Quaking aspen        </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>Red horse chestnut   </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>Red pine             </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>River birch          </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>Scots pine           </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>Serviceberry         </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>Smoketree            </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>Southern red oak     </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>Spruce               </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>Two-winged silverbell</td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>Virginia pine        </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>White pine           </td><td>100</td><td>0</td><td>0</td><td>0</td></tr>
</tbody>
</table>



#### ***Ranking of all 128 tree species***


```R
spc_first_ranking %>%
  select(-abd_rank)
```


<table class="dataframe">
<caption>A tibble: 128 × 7</caption>
<thead>
  <tr><th scope=col>spc_common</th><th scope=col>abundance</th><th scope=col>health_index</th><th scope=col>median_tree_dbh</th><th scope=col>hi_rank</th><th scope=col>dbh_rank</th><th scope=col>rank_sum</th></tr>
  <tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th></tr>
</thead>
<tbody>
  <tr><td>Smoketree         </td><td>    1</td><td>1.0000000</td><td>11.0</td><td> 6.5</td><td> 8.0</td><td> 7.25</td></tr>
  <tr><td>Black maple       </td><td>   10</td><td>0.9666667</td><td>11.0</td><td>13.0</td><td> 8.0</td><td>10.50</td></tr>
  <tr><td>Amur cork tree    </td><td>    8</td><td>0.9583333</td><td>11.0</td><td>14.0</td><td> 8.0</td><td>11.00</td></tr>
  <tr><td>Siberian elm      </td><td>  156</td><td>0.9316239</td><td>11.0</td><td>23.0</td><td> 8.0</td><td>15.50</td></tr>
  <tr><td>Pitch pine        </td><td>    5</td><td>1.0000000</td><td> 8.0</td><td> 6.5</td><td>26.5</td><td>16.50</td></tr>
  <tr><td>Red horse chestnut</td><td>    1</td><td>1.0000000</td><td> 8.0</td><td> 6.5</td><td>26.5</td><td>16.50</td></tr>
  <tr><td>Willow oak        </td><td>  889</td><td>0.9366329</td><td>10.0</td><td>21.0</td><td>13.0</td><td>17.00</td></tr>
  <tr><td>Honeylocust       </td><td>13175</td><td>0.9387223</td><td> 9.0</td><td>20.0</td><td>19.5</td><td>19.75</td></tr>
  <tr><td>American elm      </td><td> 1698</td><td>0.9185316</td><td>12.0</td><td>36.0</td><td> 4.0</td><td>20.00</td></tr>
  <tr><td>Pin oak           </td><td> 4584</td><td>0.9282286</td><td> 9.0</td><td>27.0</td><td>19.5</td><td>23.25</td></tr>
  <tr><td>Tree of heaven    </td><td>  104</td><td>0.9134615</td><td>11.0</td><td>39.0</td><td> 8.0</td><td>23.50</td></tr>
  <tr><td>White ash         </td><td>   50</td><td>0.9200000</td><td> 9.5</td><td>33.0</td><td>15.0</td><td>24.00</td></tr>
  <tr><td>Black locust      </td><td>  259</td><td>0.9176319</td><td>10.0</td><td>37.0</td><td>13.0</td><td>25.00</td></tr>
  <tr><td>Black walnut      </td><td>   33</td><td>0.9191919</td><td> 9.0</td><td>34.0</td><td>19.5</td><td>26.75</td></tr>
  <tr><td>Sophora           </td><td> 4453</td><td>0.9187813</td><td> 9.0</td><td>35.0</td><td>19.5</td><td>27.25</td></tr>
  <tr><td>Ohio buckeye      </td><td>   24</td><td>0.9027778</td><td>11.0</td><td>47.0</td><td> 8.0</td><td>27.50</td></tr>
  <tr><td>Japanese maple    </td><td>   11</td><td>0.9393939</td><td> 6.0</td><td>19.0</td><td>40.0</td><td>29.50</td></tr>
  <tr><td>Crepe myrtle      </td><td>    5</td><td>1.0000000</td><td> 5.0</td><td> 6.5</td><td>55.0</td><td>30.75</td></tr>
  <tr><td>Red pine          </td><td>    1</td><td>1.0000000</td><td> 5.0</td><td> 6.5</td><td>55.0</td><td>30.75</td></tr>
  <tr><td>Weeping willow    </td><td>   12</td><td>0.8888889</td><td>14.0</td><td>62.0</td><td> 1.0</td><td>31.50</td></tr>
  <tr><td>Golden raintree   </td><td>  359</td><td>0.9554318</td><td> 5.0</td><td>15.0</td><td>55.0</td><td>35.00</td></tr>
  <tr><td>Schumard's oak    </td><td>  137</td><td>0.9221411</td><td> 6.0</td><td>31.0</td><td>40.0</td><td>35.50</td></tr>
  <tr><td>Sawtooth oak      </td><td>  353</td><td>0.9471199</td><td> 5.0</td><td>17.0</td><td>55.0</td><td>36.00</td></tr>
  <tr><td>Green ash         </td><td>  770</td><td>0.8961039</td><td> 9.0</td><td>53.0</td><td>19.5</td><td>36.25</td></tr>
  <tr><td>European beech    </td><td>    6</td><td>1.0000000</td><td> 4.5</td><td> 6.5</td><td>67.0</td><td>36.75</td></tr>
  <tr><td>Southern magnolia </td><td>   19</td><td>0.9298246</td><td> 5.0</td><td>24.0</td><td>55.0</td><td>39.50</td></tr>
  <tr><td>Callery pear      </td><td> 7297</td><td>0.8923759</td><td> 8.0</td><td>56.0</td><td>26.5</td><td>41.25</td></tr>
  <tr><td>Crab apple        </td><td>  437</td><td>0.9260107</td><td> 5.0</td><td>28.0</td><td>55.0</td><td>41.50</td></tr>
  <tr><td>London planetree  </td><td> 4122</td><td>0.8458677</td><td>13.0</td><td>81.0</td><td> 2.5</td><td>41.75</td></tr>
  <tr><td>Chinese elm       </td><td>  785</td><td>0.9053079</td><td> 6.0</td><td>44.0</td><td>40.0</td><td>42.00</td></tr>
  <tr><td>⋮</td><td>⋮</td><td>⋮</td><td>⋮</td><td>⋮</td><td>⋮</td><td>⋮</td></tr>
  <tr><td>Flowering dogwood  </td><td> 65</td><td>0.8410256</td><td>4.0</td><td> 83.0</td><td> 87.0</td><td> 85.00</td></tr>
  <tr><td>European alder     </td><td>  2</td><td>0.5000000</td><td>5.5</td><td>127.5</td><td> 45.0</td><td> 86.25</td></tr>
  <tr><td>Red maple          </td><td>356</td><td>0.8389513</td><td>4.0</td><td> 86.0</td><td> 87.0</td><td> 86.50</td></tr>
  <tr><td>Chinese fringetree </td><td>  9</td><td>0.8888889</td><td>3.0</td><td> 62.0</td><td>113.0</td><td> 87.50</td></tr>
  <tr><td>Mimosa             </td><td> 12</td><td>0.8888889</td><td>3.0</td><td> 62.0</td><td>113.0</td><td> 87.50</td></tr>
  <tr><td>Cockspur hawthorn  </td><td>  3</td><td>0.6666667</td><td>5.0</td><td>120.5</td><td> 55.0</td><td> 87.75</td></tr>
  <tr><td>Cucumber magnolia  </td><td> 12</td><td>0.7777778</td><td>4.5</td><td>109.0</td><td> 67.0</td><td> 88.00</td></tr>
  <tr><td>Amur maple         </td><td> 30</td><td>0.8333333</td><td>4.0</td><td> 90.0</td><td> 87.0</td><td> 88.50</td></tr>
  <tr><td>Bald cypress       </td><td> 89</td><td>0.8277154</td><td>4.0</td><td> 94.0</td><td> 87.0</td><td> 90.50</td></tr>
  <tr><td>Boxelder           </td><td>  2</td><td>0.5000000</td><td>5.0</td><td>127.5</td><td> 55.0</td><td> 91.25</td></tr>
  <tr><td>Dawn redwood       </td><td>199</td><td>0.8157454</td><td>4.0</td><td> 96.0</td><td> 87.0</td><td> 91.50</td></tr>
  <tr><td>Empress tree       </td><td> 17</td><td>0.8039216</td><td>4.0</td><td> 97.0</td><td> 87.0</td><td> 92.00</td></tr>
  <tr><td>American beech     </td><td> 22</td><td>0.8484848</td><td>3.5</td><td> 80.0</td><td>105.0</td><td> 92.50</td></tr>
  <tr><td>Hardy rubber tree  </td><td> 66</td><td>0.8636364</td><td>3.0</td><td> 74.0</td><td>113.0</td><td> 93.50</td></tr>
  <tr><td>Japanese snowbell  </td><td> 15</td><td>0.8000000</td><td>4.0</td><td>100.0</td><td> 87.0</td><td> 93.50</td></tr>
  <tr><td>Turkish hazelnut   </td><td> 17</td><td>0.7843137</td><td>4.0</td><td>103.5</td><td> 87.0</td><td> 95.25</td></tr>
  <tr><td>Tulip-poplar       </td><td> 34</td><td>0.7647059</td><td>4.0</td><td>112.0</td><td> 87.0</td><td> 99.50</td></tr>
  <tr><td>Common hackberry   </td><td>170</td><td>0.8352941</td><td>3.0</td><td> 87.0</td><td>113.0</td><td>100.00</td></tr>
  <tr><td>Maple              </td><td> 37</td><td>0.7027027</td><td>4.0</td><td>117.0</td><td> 87.0</td><td>102.00</td></tr>
  <tr><td>Himalayan cedar    </td><td>  6</td><td>0.8333333</td><td>2.0</td><td> 90.0</td><td>125.5</td><td>107.75</td></tr>
  <tr><td>Sassafras          </td><td> 17</td><td>0.7843137</td><td>3.0</td><td>103.5</td><td>113.0</td><td>108.25</td></tr>
  <tr><td>Kentucky yellowwood</td><td> 18</td><td>0.7777778</td><td>3.0</td><td>109.0</td><td>113.0</td><td>111.00</td></tr>
  <tr><td>Norway spruce      </td><td>  3</td><td>0.7777778</td><td>3.0</td><td>109.0</td><td>113.0</td><td>111.00</td></tr>
  <tr><td>Horse chestnut     </td><td> 11</td><td>0.7575758</td><td>3.0</td><td>114.0</td><td>113.0</td><td>113.50</td></tr>
  <tr><td>Pagoda dogwood     </td><td> 18</td><td>0.7407407</td><td>3.0</td><td>115.0</td><td>113.0</td><td>114.00</td></tr>
  <tr><td>Paperbark maple    </td><td> 15</td><td>0.6666667</td><td>3.0</td><td>120.5</td><td>113.0</td><td>116.75</td></tr>
  <tr><td>Spruce             </td><td>  1</td><td>0.6666667</td><td>3.0</td><td>120.5</td><td>113.0</td><td>116.75</td></tr>
  <tr><td>Eastern hemlock    </td><td>  7</td><td>0.5238095</td><td>3.0</td><td>126.0</td><td>113.0</td><td>119.50</td></tr>
  <tr><td>Douglas-fir        </td><td>  2</td><td>0.6666667</td><td>2.0</td><td>120.5</td><td>125.5</td><td>123.00</td></tr>
  <tr><td>Pond cypress       </td><td> 12</td><td>0.5555556</td><td>2.5</td><td>124.5</td><td>122.0</td><td>123.25</td></tr>
</tbody>
</table>



#### ***Ranking of all tree species with at least 29 abundances***


```R
spc_second_ranking %>%
  select(-abd_rank)
```


<table class="dataframe">
<caption>A tibble: 64 × 7</caption>
<thead>
  <tr><th scope=col>spc_common</th><th scope=col>abundance</th><th scope=col>health_index</th><th scope=col>median_tree_dbh</th><th scope=col>hi_rank</th><th scope=col>dbh_rank</th><th scope=col>rank_sum</th></tr>
  <tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th></tr>
</thead>
<tbody>
  <tr><td>Siberian elm        </td><td>  156</td><td>0.9316239</td><td>11.0</td><td> 6</td><td> 3.5</td><td> 9.5</td></tr>
  <tr><td>Willow oak          </td><td>  889</td><td>0.9366329</td><td>10.0</td><td> 5</td><td> 6.0</td><td>11.0</td></tr>
  <tr><td>Honeylocust         </td><td>13175</td><td>0.9387223</td><td> 9.0</td><td> 4</td><td>12.0</td><td>16.0</td></tr>
  <tr><td>American elm        </td><td> 1698</td><td>0.9185316</td><td>12.0</td><td>17</td><td> 2.0</td><td>19.0</td></tr>
  <tr><td>Pin oak             </td><td> 4584</td><td>0.9282286</td><td> 9.0</td><td> 9</td><td>12.0</td><td>21.0</td></tr>
  <tr><td>White ash           </td><td>   50</td><td>0.9200000</td><td> 9.5</td><td>14</td><td> 8.0</td><td>22.0</td></tr>
  <tr><td>Tree of heaven      </td><td>  104</td><td>0.9134615</td><td>11.0</td><td>19</td><td> 3.5</td><td>22.5</td></tr>
  <tr><td>Black locust        </td><td>  259</td><td>0.9176319</td><td>10.0</td><td>18</td><td> 6.0</td><td>24.0</td></tr>
  <tr><td>Black walnut        </td><td>   33</td><td>0.9191919</td><td> 9.0</td><td>15</td><td>12.0</td><td>27.0</td></tr>
  <tr><td>Sophora             </td><td> 4453</td><td>0.9187813</td><td> 9.0</td><td>16</td><td>12.0</td><td>28.0</td></tr>
  <tr><td>Golden raintree     </td><td>  359</td><td>0.9554318</td><td> 5.0</td><td> 1</td><td>30.0</td><td>31.0</td></tr>
  <tr><td>Sawtooth oak        </td><td>  353</td><td>0.9471199</td><td> 5.0</td><td> 2</td><td>30.0</td><td>32.0</td></tr>
  <tr><td>Schumard's oak      </td><td>  137</td><td>0.9221411</td><td> 6.0</td><td>12</td><td>22.5</td><td>34.5</td></tr>
  <tr><td>Crab apple          </td><td>  437</td><td>0.9260107</td><td> 5.0</td><td>10</td><td>30.0</td><td>40.0</td></tr>
  <tr><td>Green ash           </td><td>  770</td><td>0.8961039</td><td> 9.0</td><td>31</td><td>12.0</td><td>43.0</td></tr>
  <tr><td>Chinese elm         </td><td>  785</td><td>0.9053079</td><td> 6.0</td><td>24</td><td>22.5</td><td>46.5</td></tr>
  <tr><td>Japanese zelkova    </td><td> 3596</td><td>0.9048016</td><td> 6.0</td><td>26</td><td>22.5</td><td>48.5</td></tr>
  <tr><td>Kentucky coffeetree </td><td>  348</td><td>0.9415709</td><td> 4.0</td><td> 3</td><td>47.5</td><td>50.5</td></tr>
  <tr><td>Callery pear        </td><td> 7297</td><td>0.8923759</td><td> 8.0</td><td>34</td><td>16.5</td><td>50.5</td></tr>
  <tr><td>Ash                 </td><td>   58</td><td>0.8678161</td><td>10.0</td><td>45</td><td> 6.0</td><td>51.0</td></tr>
  <tr><td>London planetree    </td><td> 4122</td><td>0.8458677</td><td>13.0</td><td>50</td><td> 1.0</td><td>51.0</td></tr>
  <tr><td>Mulberry            </td><td>   68</td><td>0.8774510</td><td> 9.0</td><td>41</td><td>12.0</td><td>53.0</td></tr>
  <tr><td>Cherry              </td><td>  869</td><td>0.9048715</td><td> 5.0</td><td>25</td><td>30.0</td><td>55.0</td></tr>
  <tr><td>Hawthorn            </td><td>  219</td><td>0.9284627</td><td> 4.0</td><td> 8</td><td>47.5</td><td>55.5</td></tr>
  <tr><td>Ginkgo              </td><td> 5859</td><td>0.8882631</td><td> 8.0</td><td>39</td><td>16.5</td><td>55.5</td></tr>
  <tr><td>American hophornbeam</td><td>   84</td><td>0.8888889</td><td> 7.5</td><td>38</td><td>18.0</td><td>56.0</td></tr>
  <tr><td>Magnolia            </td><td>  116</td><td>0.9022989</td><td> 5.0</td><td>27</td><td>30.0</td><td>57.0</td></tr>
  <tr><td>Shingle oak         </td><td>  205</td><td>0.9252033</td><td> 4.0</td><td>11</td><td>47.5</td><td>58.5</td></tr>
  <tr><td>Japanese hornbeam   </td><td>   62</td><td>0.8924731</td><td> 5.0</td><td>33</td><td>30.0</td><td>63.0</td></tr>
  <tr><td>Silver linden       </td><td>  541</td><td>0.8761553</td><td> 6.0</td><td>42</td><td>22.5</td><td>64.5</td></tr>
  <tr><td>⋮</td><td>⋮</td><td>⋮</td><td>⋮</td><td>⋮</td><td>⋮</td><td>⋮</td></tr>
  <tr><td>Amur maackia          </td><td>  59</td><td>0.9096045</td><td>4</td><td>22</td><td>47.5</td><td> 69.5</td></tr>
  <tr><td>Bur oak               </td><td>  36</td><td>0.9074074</td><td>4</td><td>23</td><td>47.5</td><td> 70.5</td></tr>
  <tr><td>Norway maple          </td><td> 290</td><td>0.8011494</td><td>9</td><td>60</td><td>12.0</td><td> 72.0</td></tr>
  <tr><td>American linden       </td><td>1583</td><td>0.8427037</td><td>6</td><td>51</td><td>22.5</td><td> 73.5</td></tr>
  <tr><td>Swamp white oak       </td><td> 681</td><td>0.9207048</td><td>3</td><td>13</td><td>62.5</td><td> 75.5</td></tr>
  <tr><td>Black oak             </td><td> 192</td><td>0.9010417</td><td>4</td><td>28</td><td>47.5</td><td> 75.5</td></tr>
  <tr><td>Littleleaf linden     </td><td>3333</td><td>0.8281828</td><td>7</td><td>57</td><td>19.0</td><td> 76.0</td></tr>
  <tr><td>Eastern redbud        </td><td>  50</td><td>0.9000000</td><td>4</td><td>29</td><td>47.5</td><td> 76.5</td></tr>
  <tr><td>Scarlet oak           </td><td>  71</td><td>0.8967136</td><td>4</td><td>30</td><td>47.5</td><td> 77.5</td></tr>
  <tr><td>Black cherry          </td><td>  32</td><td>0.8958333</td><td>4</td><td>32</td><td>47.5</td><td> 79.5</td></tr>
  <tr><td>Purple-leaf plum      </td><td> 110</td><td>0.8909091</td><td>4</td><td>35</td><td>47.5</td><td> 82.5</td></tr>
  <tr><td>Sugar maple           </td><td>  48</td><td>0.8402778</td><td>5</td><td>53</td><td>30.0</td><td> 83.0</td></tr>
  <tr><td>European hornbeam     </td><td> 167</td><td>0.8902196</td><td>4</td><td>36</td><td>47.5</td><td> 83.5</td></tr>
  <tr><td>Katsura tree          </td><td>  38</td><td>0.7807018</td><td>6</td><td>62</td><td>22.5</td><td> 84.5</td></tr>
  <tr><td>Serviceberry          </td><td>  38</td><td>0.8859649</td><td>4</td><td>40</td><td>47.5</td><td> 87.5</td></tr>
  <tr><td>Japanese tree lilac   </td><td> 129</td><td>0.8708010</td><td>4</td><td>43</td><td>47.5</td><td> 90.5</td></tr>
  <tr><td>Silver maple          </td><td>  71</td><td>0.7840376</td><td>5</td><td>61</td><td>30.0</td><td> 91.0</td></tr>
  <tr><td>'Schubert' chokecherry</td><td> 163</td><td>0.8691207</td><td>4</td><td>44</td><td>47.5</td><td> 91.5</td></tr>
  <tr><td>White oak             </td><td> 241</td><td>0.8589212</td><td>4</td><td>47</td><td>47.5</td><td> 94.5</td></tr>
  <tr><td>Paper birch           </td><td>  47</td><td>0.8581560</td><td>4</td><td>48</td><td>47.5</td><td> 95.5</td></tr>
  <tr><td>Sweetgum              </td><td> 227</td><td>0.8502203</td><td>4</td><td>49</td><td>47.5</td><td> 96.5</td></tr>
  <tr><td>Flowering dogwood     </td><td>  65</td><td>0.8410256</td><td>4</td><td>52</td><td>47.5</td><td> 99.5</td></tr>
  <tr><td>Red maple             </td><td> 356</td><td>0.8389513</td><td>4</td><td>54</td><td>47.5</td><td>101.5</td></tr>
  <tr><td>Amur maple            </td><td>  30</td><td>0.8333333</td><td>4</td><td>56</td><td>47.5</td><td>103.5</td></tr>
  <tr><td>Bald cypress          </td><td>  89</td><td>0.8277154</td><td>4</td><td>58</td><td>47.5</td><td>105.5</td></tr>
  <tr><td>Dawn redwood          </td><td> 199</td><td>0.8157454</td><td>4</td><td>59</td><td>47.5</td><td>106.5</td></tr>
  <tr><td>Hardy rubber tree     </td><td>  66</td><td>0.8636364</td><td>3</td><td>46</td><td>62.5</td><td>108.5</td></tr>
  <tr><td>Tulip-poplar          </td><td>  34</td><td>0.7647059</td><td>4</td><td>63</td><td>47.5</td><td>110.5</td></tr>
  <tr><td>Maple                 </td><td>  37</td><td>0.7027027</td><td>4</td><td>64</td><td>47.5</td><td>111.5</td></tr>
  <tr><td>Common hackberry      </td><td> 170</td><td>0.8352941</td><td>3</td><td>55</td><td>62.5</td><td>117.5</td></tr>
</tbody>
</table>



### Codes


```R
# ---------- Packages & Datasets

# Load pre-installed, required packages
suppressPackageStartupMessages(library(tidyverse)) 
suppressPackageStartupMessages(library(dplyr)) 
suppressPackageStartupMessages(library(ggplot2))
suppressPackageStartupMessages(library(sf))
suppressPackageStartupMessages(library(geojsonsf))
suppressPackageStartupMessages(library(scales))

# Install & load the 'rwantshue' package for generating random color scheme
suppressWarnings(suppressMessages(install.packages("remotes")))
suppressWarnings(suppressMessages(remotes::install_github("hoesler/rwantshue", auth_token = "")))
suppressPackageStartupMessages(library(rwantshue))

# Install & load the 'ggfun' package for round rectangle borders and backgrounds in ggplots
suppressWarnings(suppressMessages(install.packages("ggfun", verbose=TRUE, quiet=TRUE)))
suppressPackageStartupMessages(library(ggfun))

# Install & load the 'ggchicklet' package for bar charts with rounded corners
suppressWarnings(suppressMessages(remotes::install_github("hrbrmstr/ggchicklet", auth_token = "")))
suppressPackageStartupMessages(library("ggchicklet"))

# Read the 'trees' data set from the CSV file
trees <- readr::read_csv('data/trees.csv', show_col_types = FALSE) %>%
  mutate(spc_common = str_to_sentence(spc_common))

# Read the 'neighborhoods' data set from the SHP file
neighborhoods <- st_read("data/nta.shp", quiet=TRUE) %>% 
  dplyr::select(boroname, ntacode, ntaname, geometry, shape_area)

# Create a merged data frame for the 'trees' and 'neighborhoods' data sets
merged_trees_and_neighborhoods <- trees %>%
  full_join(neighborhoods, by = c("nta"="ntacode", "nta_name"="ntaname"))


# ---------- Results & Discussion

# ----- Tree Population

# -- Spatial

# Top 10 NTAs in terms of land size 
top_nta_area <- neighborhoods %>%
  filter(boroname == "Manhattan", ntacode != "MN99") %>%
  arrange(desc(shape_area)) %>%
    slice(1:10)

# Tree count per neighborhood
nbh_tree_cnts <- merged_trees_and_neighborhoods %>%
  filter(boroname == "Manhattan", nta != "MN99") %>%
  group_by(nta, nta_name) %>%
  summarize(number_of_trees = n(), .groups = "keep") %>%
  arrange(desc(number_of_trees)) %>%
  ungroup() %>%
    mutate(proportion = round(number_of_trees/sum(number_of_trees), digits = 4))

# Species richness per neighborhood
nbh_rchns <- trees %>%
  filter(!(spc_common == "null")) %>%
  group_by(nta, nta_name) %>%
  summarize(richness = n_distinct(spc_common), .groups = "keep") %>%
  arrange(desc(richness)) %>%
  ungroup()

# Data for maps
nbhs_map <- nbh_tree_cnts %>%
  full_join(neighborhoods, c("nta" = "ntacode", "nta_name" = "ntaname")) %>% 
  full_join(nbh_rchns, c("nta", "nta_name")) %>%
  mutate(borough = substr(nta, 1, 2),
           nta_code_and_name = paste(nta, nta_name, sep=": "),
           nta_and_tree_cnt = ifelse(number_of_trees < 1000, 
           paste(nta,  " - ", "   ", prettyNum(number_of_trees,big.mark=","), " : ", nta_name, sep=""),
           paste(nta,  " - ", prettyNum(number_of_trees, big.mark=","), " : ", nta_name, sep="")
                                      ),
           nta_and_rchns = paste(nta,  " - ", prettyNum(richness, big.mark=","),
                                 " : ", nta_name, sep="")
          ) %>%
  st_as_sf %>%
  st_transform("+proj=longlat +ellps=intl +no_defs +type=crs") 

# Colorize the NTAs
color_scheme <- iwanthue(seed=1234, force_init=TRUE)
nta_colors <- color_scheme$hex(nrow(nbhs_map %>%  filter(borough == "MN")))

# Data of tree locations 
tree_locs <- trees %>%
  st_as_sf(coords = c("longitude", "latitude"), crs=4326) %>%
  st_transform("+proj=longlat +ellps=intl +no_defs +type=crs") 

# Map of tree locations by neighborhood
tree_locs_map_plot <- ggplot() + 
  geom_sf(data = nbhs_map,
            fill="#E8EAED", color="grey") +
    stat_sf_coordinates(data = tree_locs, 
                        aes(color = paste(nta, nta_name, sep=": ")),
                        size=0.001
                        ) +
    stat_sf_coordinates(data = nbhs_map %>% filter(borough=="MN", nta!="MN99"),
                        color="grey25", size=0.25) +
  geom_sf(data = nbhs_map %>% filter(borough=="MN", nta!="MN99"),
            color="grey25",
            alpha=0.1) + 
    theme(legend.position = c(0.024, 0.5),
          legend.justification=0.0,
          legend.key.width = unit(2.5, 'mm'),
        legend.key.height = unit(1.8, 'mm'), 
          legend.direction="vertical",
          legend.background= element_roundrect(r = grid::unit(0.02, "snpc"),
                                               fill=alpha("#FFFFFF", 0.90)),
          legend.key = element_rect(fill=NA),
          legend.text = element_text(margin = margin(r=5, unit="pt"),
                                   color="#65707C",
                                     family="sans serif"),
          legend.title = element_text(face="bold",
                                      color="#65707C",
                                      size=8.5,
                                      family="sans serif"),
      axis.title = element_text(color="#65707C",
                                    face="bold",
                                    family="sans serif"),
          axis.text = element_text(color="#65707C",
                                   size=7,
                                   family="sans serif"),
          axis.text.x = element_text(angle=90,
                                     vjust=0.5,
                                     hjust=1),
          axis.line = element_line(colour="grey",
                                   linewidth=0.5),
          panel.grid.major = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.25),
          
          panel.border = element_rect(color="grey40",
                                      fill=NA),  
          panel.spacing = unit(2, "lines"),
          panel.background  = element_roundrect(r = grid::unit(0.001, "snpc"),
                                               fill=alpha("#9CC0F9", 1)),
          plot.title = element_text(color="#65707C",
                                    hjust=-4.5,
                                    vjust=10,
                                    size=14,
                                    family="sans serif")) +
     labs(x="", y="", color="    Code: Name") +
     ggtitle("Fig. 1: Map of the Tree Locations by Neighborhood in Manhattan") +
  scale_x_continuous(expand = c(0.01, 0),
                       limits = c(-74.25, -73.89), 
                       breaks = seq(-74.25, -73.89, by=0.02)) +
  scale_y_continuous(expand = c(0.01, 0),
                       limits = c(40.68, 40.88), 
                       breaks = seq(40.68, 40.88, by=0.02)) +
    guides(color = guide_legend(ncol=1,
                                override.aes = list(shape=15,
                                                    size=2.5
                                                    ))) +
  ggrepel::geom_label_repel(data = nbhs_map %>% filter(borough == "MN", nta != "MN99"),
                              aes(label = nta, geometry = geometry),
                              stat="sf_coordinates",
                              min.segment.length=0,
                              size=2,
                              label.size=NA,
                              alpha=0.6) +
  coord_sf(xlim = c(-74.25, -73.89), ylim = c(40.68, 40.88)) +
  scale_color_manual(values = nta_colors)

# Order legend items by number of trees
nbhs_map$nta_and_tree_cnt <- factor(
    nbhs_map$nta_and_tree_cnt,
       levels = nbhs_map$nta_and_tree_cnt,
       ordered=TRUE)

# Map of NTAs' tree counts
nbhs_tree_cnts_map_plot <- ggplot() + 
  geom_sf(data = nbhs_map %>% filter(borough != "MN" | nta == "MN99"),
            fill="#E8EAED", color="grey") +
  geom_sf(data = nbhs_map %>% filter(borough == "MN", nta != "MN99"),
            aes(fill = number_of_trees,
                color = nta_and_tree_cnt
           )) + 
    stat_sf_coordinates(data = nbhs_map %>% filter(nta %in% for_table_nbh_tree_cnts$nta),
                        color="grey25", size=0.5) +
    theme(legend.position = c(0.369, 0.5), 
          legend.justification=0.0,
          legend.key.width = unit(2.5, 'mm'),
        legend.key.height = unit(1.8, 'mm'), 
          legend.direction="vertical",
          legend.background = element_roundrect(r = grid::unit(0.02, "snpc"),
                                               fill = alpha("#FFFFFF", 0.90)),
          legend.key = element_rect(fill=NA),
          legend.text = element_text(margin = margin(r=5, unit="pt"),
                                     size=7.9,
                                   color="#65707C",
                                     family="sans serif"),
          legend.title = element_text(face="bold",
                                      color="#65707C",
                                      size=8.5,
                                      family="sans serif"),
          axis.title = element_text(color="#65707C",
                                    face="bold",
                                    family="sans serif"),
          axis.text = element_text(color="#65707C",
                                   size=7,
                                   family="sans serif"),
          axis.text.x = element_text(angle=90,
                                     vjust=0.5,
                                     hjust=1),
          axis.line = element_line(colour="grey",
                                   linewidth=0.5),
          panel.grid.major = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.25),
          
          panel.border = element_rect(color="grey40",
                                      fill=NA),  
          panel.spacing = unit(2, "lines"),
          panel.background  = element_roundrect(r = grid::unit(0.001, "snpc"),
                                               fill = alpha("#9CC0F9", 1)),
          plot.title = element_text(color="#65707C",
                                    hjust=4.2,
                                    vjust=10,
                                    size=14,
                                    family="sans serif")) +
     labs(x="", y="", color="   Code - Number of trees : Name"
             ) +
     ggtitle("Fig. 2: Map of the Number of Trees in Manhattan's Neighborhoods") +
  scale_x_continuous(expand = c(0.01, 0),
                       limits = c(-74.04, -73.64), 
                       breaks = seq(-74.04, -73.64, by=0.02)) +
  scale_y_continuous(expand = c(0.01, 0),
                       limits = c(40.68, 40.88), 
                       breaks = seq(40.68, 40.88, by=0.02)) +
  scale_color_manual(values = replicate(28, "grey25")) +
  scale_fill_gradient2(low = muted("499F78"),
                         high = muted("#216968")) +
  ggrepel::geom_label_repel(data = nbhs_map %>% filter(nta %in% for_table_nbh_tree_cnts$nta),
                              aes(label = nta, geometry = geometry),
                              stat="sf_coordinates",
                              min.segment.length=0,
                              label.size=NA,
                              alpha=0.5) +
  coord_sf(xlim = c(-74.04, -73.64), ylim = c(40.68, 40.88))

# Extract NTA fill colors
color_scheme_2 <- as.data.frame(ggplot_build(nbhs_tree_cnts_map_plot)$data[[2]])$fill

# Apply extracted fill colors to the legend
nbhs_tree_cnts_map_plot1 <- nbhs_tree_cnts_map_plot +
  guides(fill = "none",
           color = guide_legend(ncol=1,
                                override.aes = list(color = NA,
                                                    fill = color_scheme_2,
                                                    linewidth=0)))


# Tree count per curb location
number_of_trees_per_curb_loc <- merged_trees_and_neighborhoods %>%
  filter(str_detect(nta, "MN") & !(nta == "MN99")) %>%
  group_by(curb_loc) %>%
  summarize(number_of_trees = n()) %>%
  arrange(desc(number_of_trees)) %>%
    mutate(percentage = label_percent(accuracy=0.01)(number_of_trees/length(merged_trees_and_neighborhoods$tree_id)))

# OnCurb tree population
on_curb_stat <- number_of_trees_per_curb_loc %>%
    mutate(proportion = number_of_trees/sum(number_of_trees)) %>% 
  filter(proportion == max(abs(proportion)))

# Create a stacked bar plot for the curb location
curb_loc_stacked_bar_plot <- ggplot(number_of_trees_per_curb_loc) + 
  geom_chicklet(aes(x="", y = number_of_trees/sum(number_of_trees),
                      fill = curb_loc), 
                  radius = grid::unit(0.75, "mm"),
                  position="stack") +
  coord_flip() +
  theme(legend.position="right",
          legend.justification="top",
          legend.direction="vertical",
          legend.key.size = unit(0, 'pt'),
          legend.key = element_rect(fill=NA),
          legend.text = element_text(margin = margin(r = 4, unit = "pt"),
                                     color = "#65707C",
                                     family="sans serif"),
          legend.title = element_text(color = "#65707C",
                                      face="bold",
                                      size = 9,
                                      family="sans serif"),
      axis.title.x = element_text(color="#65707C",
                                    face="bold",
                                    family="sans serif"),
      axis.title.y = element_blank(),
          axis.text = element_blank(),
          axis.line = element_blank(),
          axis.ticks = element_blank(),
          panel.grid.minor = element_blank(),
          panel.grid.major = element_blank(),
          panel.background = element_blank(),
          plot.subtitle = element_text(color="#65707C",
                                    hjust=0.25,
                                    size=10,
                                    family="sans serif"),
          plot.title = element_text(color="#65707C",
                                    hjust=-0.15,
                                    size=14,
                                    family="sans serif"),
      plot.margin = unit(c(0,1,0,1), "cm")) +	
  scale_fill_manual(values = c("#875826",
                                 "#10401B")) + 
  ggtitle("\nFig. 3: Proportional Stacked Bar Graph of Tree Bed Location ",
            subtitle="  (in relation to the Curb)\n") +
  labs(y="\n%  \n(Number of trees)\n", fill="Location:  ") +
    guides(fill = guide_legend(nrow=2,
                               reverse=TRUE,
                               override.aes = list(shape = 15,
                                                   size = 4))) +
  scale_x_discrete(expand = c(0.01, 0)) +
  ggrepel::geom_text_repel(data = on_curb_stat,
                             aes(label = paste(label_percent(accuracy=0.01)(proportion),
                                       "\n (", prettyNum(number_of_trees,
                                                  big.mark=","),")",
                                       sep=""),
                                 x = "",
                                 y = 0.50 * proportion - 0.075),
                             size=5, color="white", hjust=1)


# Curb location per neighborhood
curb_loc_per_nbh <- merged_trees_and_neighborhoods %>% 
  filter(str_detect(nta, "MN") & !(nta == "MN99")) %>%
  group_by(nta, nta_name, curb_loc) %>%
  summarize(number_of_trees=n(), .groups="keep") %>%
  group_by(nta) %>%
  mutate(proportion = number_of_trees/sum(number_of_trees),
           percentage = label_percent(accuracy=0.01)(proportion)) %>%
  arrange(desc(proportion)) %>%
  ungroup()

# Higher between OnCurb and OffsetFromCurb per neighborhood
oncurb_vs_offset_per_nbh <- curb_loc_per_nbh %>% 
  group_by(nta) %>%
  filter(proportion == max(abs(proportion)))

# Order by NTA
curb_loc_per_nbh$nta_name <- factor(
    curb_loc_per_nbh$nta_name,
       levels = rev(unique(curb_loc_per_nbh$nta_name)),
       ordered=TRUE)

# Create a stacked bar plot for the curb location per neighborhood
curb_loc_per_nbh_stacked_bar_plot <- ggplot(curb_loc_per_nbh) + 
  geom_chicklet(aes(x = nta_name, y = proportion*100, fill = curb_loc), 
                  radius = grid::unit(0.75, "mm"), position="stack") +
  coord_flip() +
  theme(legend.position="right",
          legend.justification="top",
          legend.direction="vertical",
          legend.key.size = unit(0, "pt"),
          legend.key = element_rect(fill=NA),
          legend.text = element_text(margin = margin(r = 4, unit = "pt"),
                                     color="#65707C",
                                     family="sans serif"),
          legend.title = element_text(color="#65707C",
                                      face="bold",
                                      size=9,
                                      family="sans serif"),
      axis.title = element_text(color="#65707C",
                                    face="bold",
                                    family="sans serif"),
          axis.text.x = element_text(color="#65707C",
                                   size=6,
                                   family="sans serif"),
          axis.text.y = element_text(color="#65707C",
                                   size=10,
                                   family="sans serif"),
          axis.line = element_line(colour="grey",
                                   linewidth=0.5),
          panel.grid.major = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.25),
          panel.background = element_blank(),
          plot.subtitle = element_text(color="#65707C",
                                    hjust=5.38,
                                    size=10,
                                    family="sans serif"),
          plot.title = element_text(color = "#65707C",
                                    hjust = 0.709,
                                    size= 12.2,
                                    family = "sans serif")) +
  scale_fill_manual(values = c("#875826",
                                 "#10401B")) +     
  ggtitle("\nFig. 4: Proportional Stacked Bar Graph of Each Neighborhood's Tree Bed Location",
            subtitle="               (in relation to the Curb)\n") +
  labs(x="\nNTA name \n", y="\nNTA code - % of on trees\n", fill="Location: ") +
    guides(fill = guide_legend(ncol=1,
                               reverse = TRUE,
                               override.aes = list(shape = 15,
                                                   size = 4))) +
  scale_y_continuous(expand = c(0.01, 0),
                       breaks = seq(0, 100, by=10)) +
  ggrepel::geom_text_repel(data = oncurb_vs_offset_per_nbh,
                             aes(label = paste(nta, " - ", 
                                               label_percent(accuracy=0.01)(proportion),
                                       sep=""),
                                 x = nta_name,
                                 y = ifelse(nta=="MN50", 100*proportion+22,
                                            100*proportion-22)),
                             size=2.2, color="white", hjust=1)


# -- Biological

# Size

# Summary statistics of the trunk diameter
tree_dbh_stats <- data.frame(N = length(trees$tree_dbh),
                 mean = mean(trees$tree_dbh),
                             sd = sd(trees$tree_dbh),
                             min = min(trees$tree_dbh),
                             first_quartile = quantile(trees$tree_dbh, probs = 0.25),
                             median = median(trees$tree_dbh),
                             second_quartile = quantile(trees$tree_dbh, probs = 0.75),
                             max = max(trees$tree_dbh))
row.names(tree_dbh_stats) <- "tree_dbh" 

# Create a density curve of the trunk diameter
tree_dbh_dist_plot <- ggplot(trees, aes(x = tree_dbh)) + 
  geom_histogram(aes(y = after_stat(density)),
                   binwidth=1.1,
                   color=1,
                   fill="#5FBD5F") +
  geom_density(linewidth=0.85,
                 linetype=1,
                 colour = muted("5FBD5F"),
                 alpha=0.5) +

# Plot mean and median lines
  geom_vline(aes(xintercept = mean(tree_dbh)), col="red", size=0.6) +
  geom_vline(aes(xintercept = median(tree_dbh)), col="blue", size=0.6) +

  theme(axis.title = element_text(color="#65707C",
                                    face="bold",
                                    family="sans serif"),
          axis.text = element_text(color="#65707C",
                                   size=12,
                                   family="sans serif"),
          axis.line = element_line(colour="grey",
                                   linewidth=0.5),
          panel.grid.major = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.25),
          panel.background = element_blank(),
          plot.subtitle = element_text(color="#65707C",
                                    hjust=0.15,
                                    size=10,
                                    family="sans serif"),
          plot.title = element_text(color="#65707C",
                                    hjust=0.20,
                                    size=14,
                                    family="sans serif")) +
  ggtitle("\nFig. 5: Distribution of the Trunk Diameter") +
  labs(x="\nTrunk diameter in inches\n", y="\nDensity\n",
         subtitle="                (measured at 54 inches above the ground)\n") +
  scale_x_continuous(expand = c(0.01, 0), 
                       limits = c(0, 105),
                       breaks = seq(0, 105, by=10)) +
  scale_y_continuous(expand = c(0.01, 0),
                       limits = c(0, 0.12), 
                       breaks = seq(0, 0.12, by=0.02))


# Health-Related

# Status and health 
pop_status <- as.data.frame(table(trees$status)) %>%
  mutate(attribute = "status", proportion = Freq/sum(Freq)) %>%
  rename(category = Var1, number_of_trees = Freq) %>%
  select(attribute, everything())
pop_health <- as.data.frame(table(trees$health)) %>%
  mutate(attribute = "health", proportion = Freq/sum(Freq)) %>%
  rename(category = Var1, number_of_trees = Freq) %>%
  select(attribute, everything()) %>%
  arrange(desc(proportion))

# Root problems
pop_root_stone <- as.data.frame(table(trees$root_stone)) %>%
  mutate(attribute = "root_stone", proportion = Freq/sum(Freq)) %>%
  rename(category = Var1, number_of_trees = Freq) %>%
  select(attribute, everything())
pop_root_grate <- as.data.frame(table(trees$root_grate)) %>%
  mutate(attribute = "root_grate", proportion = Freq/sum(Freq)) %>%
  rename(category = Var1, number_of_trees = Freq) %>%
  select(attribute, everything())
pop_root_other <- as.data.frame(table(trees$root_other)) %>%
  mutate(attribute = "root_other", proportion = Freq/sum(Freq)) %>%
  rename(category = Var1, number_of_trees = Freq) %>%
  select(attribute, everything())

# Trunk problems
pop_trunk_wire <- as.data.frame(table(trees$trunk_wire)) %>%
  mutate(attribute = "trunk_wire", proportion = Freq/sum(Freq)) %>%
  rename(category = Var1, number_of_trees = Freq) %>%
  select(attribute, everything())
pop_trnk_light <- as.data.frame(table(trees$trnk_light)) %>%
  mutate(attribute = "trnk_light", proportion = Freq/sum(Freq)) %>%
  rename(category = Var1, number_of_trees = Freq) %>%
  select(attribute, everything())
pop_trnk_other <- as.data.frame(table(trees$trnk_other)) %>%
  mutate(attribute = "trnk_other", proportion = Freq/sum(Freq)) %>%
  rename(category = Var1, number_of_trees = Freq) %>%
  select(attribute, everything())

# Branch problems
pop_brch_light <- as.data.frame(table(trees$brch_light)) %>%
  mutate(attribute = "brch_light", proportion = Freq/sum(Freq)) %>%
  rename(category = Var1, number_of_trees = Freq) %>%
  select(attribute, everything())
pop_brch_shoe <- as.data.frame(table(trees$brch_shoe)) %>%
  mutate(attribute = "brch_shoe", proportion = Freq/sum(Freq)) %>%
  rename(category = Var1, number_of_trees = Freq) %>%
  select(attribute, everything())
pop_brch_other <- as.data.frame(table(trees$brch_other)) %>%
  mutate(attribute = "brch_other", proportion = Freq/sum(Freq)) %>%
  rename(category = Var1, number_of_trees = Freq) %>%
  select(attribute, everything())

# Tree population's categorical health-related attributes
pop_attributes <- bind_rows(pop_status,
                            pop_health,
                            pop_root_stone,
                            pop_root_grate,
                            pop_root_other,
                            pop_trunk_wire,
                            pop_trnk_light,
                            pop_trnk_other,
                            pop_brch_light,
                            pop_brch_shoe,
                            pop_brch_other) %>%
                  mutate(percentage = label_percent(accuracy = 0.01)(proportion))  		

# Highest category per attribute
pop_attributes_highest_per_category <- pop_attributes %>%
  group_by(attribute) %>%
  filter(proportion == max(abs(proportion)))

# Order by attributes 
pop_attributes$attribute <- factor(
    pop_attributes$attribute,
       levels = rev(unique(pop_attributes$attribute)),
       ordered=TRUE)

# Order by categories 
pop_attributes$category <- factor(
    pop_attributes$category,
       levels = c("Dead", "Alive", "Fair", "Poor", "Good", "Yes", "No"),
       ordered=TRUE)

# Create a stacked bar plot of the tree population's categorical, health-related attributes
pop_attributes_stacked_bar_plot <- ggplot(pop_attributes) + 
  geom_chicklet(aes(x = attribute, y = proportion*100, fill = category), 
                  radius = grid::unit(0.75, "mm"), position="stack") +
  coord_flip() +
  theme(legend.position = "right",
          legend.justification="top",
          legend.direction="vertical",
          legend.key.size = unit(0, "pt"),
          legend.key = element_rect(fill = NA),
          legend.text = element_text(margin = margin(r = 4, unit = "pt"),
                                     color = "#65707C",
                                     family="sans serif"),
          legend.title = element_text(color = "#65707C",
                                      face = "bold",
                                      size = 9,
                                      family="sans serif"),
      axis.title = element_text(color="#65707C",
                                    face="bold",
                                    family="sans serif"),
          axis.text = element_text(color="#65707C",
                                   size=12,
                                   family="sans serif"),
          axis.line = element_line(colour="grey",
                                   linewidth=0.5),
          panel.grid.major = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.25),
          panel.background = element_blank(),
          plot.title = element_text(color = "#65707C",
                                    hjust = 0.715,
                                    size= 13.75,
                                    family = "sans serif")) +
  scale_x_discrete(labels=c("Other problems (branch)",
                              "Shoes (branch)",
                              "Lights or wires (branch) ",
                              "Other problems (trunk)",
                              "Lighting installed (trunk)",
                              "Wires or rope (trunk)",
                              "Other problems (root)",
                              "Metal grates (root)",
                              "Paving stones (root)",
                              "Health",
                              "Status"))+
  scale_fill_manual(values = c("grey40",
                                 "#10401B",
                                 "#89E7B3",
                 "#40C17E",
                                 "#1F9153",
                                 "#9F2305",
                                 "#4E7A61"),
                     labels = c("Dead", "Alive", "Poor",  "Fair", "Good", "Yes", "No")) +
  ggtitle("\nFig. 6: Proportional Stacked Bar Graph of the Tree Population's Attributes\n") +
  labs(x="\nAttribute \n", y="\n%  \n(Number of trees) \n", fill="Category: ") +
    guides(fill = guide_legend(ncol=1,
                               override.aes = list(shape = 15,
                                                   size = 4))) +
  scale_y_continuous(expand = c(0.01, 0),
                       breaks = seq(0, 100, by=10)) +
  ggrepel::geom_text_repel(data = pop_attributes_highest_per_category,
                             aes(label = paste(percentage,
                                       "\n (", prettyNum(number_of_trees,
                                                  big.mark=","),")",
                                       sep=""),
                                 x = attribute,
                                 y = 100*proportion-20),
                             size=3, color="white", hjust=1)


# ----- Tree Species

# -- Biodiversity

# Richness

# Top 10 NTAs with the highest species richness
top_ten_nbh_rchns <- nbh_rchns %>%
  slice(1:10)

# Order by richness
nbhs_map$nta_and_rchns <- factor(
    nbhs_map$nta_and_rchns,
       levels = (nbhs_map %>% arrange(desc(richness)))$nta_and_rchns,
       ordered = TRUE)

# Map of NTAs' richness
nbh_rchns_map_plot <- ggplot() + 
  geom_sf(data = nbhs_map %>% filter(borough != "MN" | nta == "MN99"),
            fill="#E8EAED", color="grey") +
  geom_sf(data = nbhs_map %>% filter(borough == "MN", nta != "MN99"),
            aes(fill = richness,
                color = nta_and_rchns)) + 
    stat_sf_coordinates(data = nbhs_map %>% filter(borough == "MN", nta != "MN99") %>%
                        inner_join(nbh_rchns, by = c("nta", "nta_name")) %>%
                          filter(nta %in% top_ten_nbh_rchns$nta),
                        color="grey25", size = 0.5) +
    theme(legend.position = c(0.3518, 0.5), 
          legend.justification=0.0,
          legend.key.width = unit(2.5, 'mm'),
        legend.key.height = unit(1.8, 'mm'), 
          legend.direction="vertical",
          legend.background = element_roundrect(r = grid::unit(0.02, "snpc"),
                                               fill = alpha("#FFFFFF", 0.90)),
          legend.key = element_rect(fill=NA),
          legend.text = element_text(margin = margin(r=5, unit="pt"),
                                   color="#65707C",
                                     family="sans serif"),
          legend.title = element_text(face="bold",
                                      color="#65707C",
                                      size=8.5,
                                      family="sans serif"),
          axis.title = element_text(color="#65707C",
                                    face="bold",
                                    family="sans serif"),
          axis.text = element_text(color="#65707C",
                                   size=7,
                                   family="sans serif"),
          axis.text.x = element_text(angle=90,
                                     vjust=0.5,
                                     hjust=1),
          axis.line = element_line(colour="grey",
                                   linewidth=0.5),
          panel.grid.major = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.25),
          
          panel.border = element_rect(color="grey40",
                                      fill=NA),  
          panel.spacing = unit(2, "lines"),
          panel.background  = element_roundrect(r = grid::unit(0.001, "snpc"),
                                               fill = alpha("#9CC0F9", 1)),
          plot.title = element_text(color="#65707C",
                                    hjust=1.8,
                                    vjust=10,
                                    size=14,
                                    family="sans serif")) +
     labs(x="", y="", color="    Code - Richnesss : Name") +
     ggtitle("Fig. 7: Map of Tree Species Richness of Manhattan's Neighborhoods") +
  scale_x_continuous(expand = c(0.01, 0),
                       limits = c(-74.04, -73.64), 
                       breaks = seq(-74.04, -73.64, by=0.02)) +
  scale_y_continuous(expand = c(0.01, 0),
                       limits = c(40.68, 40.88), 
                       breaks = seq(40.68, 40.88, by=0.02)) +
  scale_color_manual(values = replicate(28, "grey25")) +
  scale_fill_gradient2(low = "#E3EDE5",
                         high = "#068409") +
  ggrepel::geom_label_repel(data = nbhs_map %>% filter(nta %in% top_ten_nbh_rchns$nta),
                              aes(label = nta, geometry = geometry),
                              stat="sf_coordinates",
                              min.segment.length=0,
                              label.size=NA,
                              alpha=0.5) +
  coord_sf(xlim = c(-74.04, -73.64), ylim = c(40.68, 40.88))     

# Extract NTA fill colors
color_scheme_3 <- as.data.frame(ggplot_build(nbh_rchns_map_plot)$data[[2]])$fill

# Apply extracted fill colors to the legend
nbh_rchns_map_plot2 <- nbh_rchns_map_plot +
  guides(fill = "none",
           color = guide_legend(ncol=1,
                                override.aes = list(color = NA,
                                                    fill = color_scheme_3,
                                                    linewidth=0)))

# Abundance

# Species abundance and relative abundance
spc_abd <- trees %>% 
  group_by(spc_common) %>%
  summarize(abundance = n()) %>%  
  ungroup() %>%
  mutate(relative_abundance = abundance/sum(abundance)) %>%
  arrange(desc(abundance)) %>%
  arrange(spc_common == "null")

# Top 10 most abundant species
for_table_spc_abd <- spc_abd %>%
  slice(1:10) %>%
  mutate(abundance = prettyNum(abundance,big.mark=","),
           perc_relative_abundance = label_percent(accuracy=0.01)(relative_abundance))

# Bar graph for Top 25 tree species
top_species_bar_plot <- ggplot(spc_abd %>% slice(1:25)) + 
  geom_chicklet(aes(x = fct_reorder(spc_common,
                                    abundance),
                      y = abundance), 
                  fill="#10401B",
                  radius = grid::unit(1, "mm"), position="stack") +
  coord_flip() +
  theme(legend.position="none",
          axis.title = element_text(color = "#65707C",
                                    face="bold",
                                    family="sans serif"),
          axis.text = element_text(color = "#65707C",
                                   size=12,
                                   family="sans serif"),
          axis.title.x = element_text(margin=margin(20,0,10,0)),
          axis.title.y = element_text(margin=margin(0,20,0,10)),
          axis.line = element_line(colour = "grey",
                                   linewidth = 0.5),
          panel.grid.major = element_line(color = "grey",
                                          linetype="dashed",
                                          linewidth=0.25),
          panel.background = element_blank(),
          plot.title = element_text(color = "#65707C",
                                    hjust = 1.03,
                                    vjust = 4,
                                    size= 14,
                                    family = "sans serif",
                                    margin=margin(0,0,20,0))) +
  ggtitle("
\nFig. 8: Bar Graph of the 25 Most Abundant Tree Species in Manhattan ") +
  labs(x="Common name of the species", y="Abundance (% relative abundance)") +
  scale_y_continuous(expand = c(0.01, 0), limits = c(0,13500),
                      breaks = seq(0, 13500, by=2000)) +
  geom_text(aes(label = paste(prettyNum(abundance, big.mark=","),
                                " (", label_percent(accuracy=0.01)(relative_abundance),")",
                                sep=""),
                                 x = spc_common,
                                 y = ifelse(between(rank(desc(abundance)),3,10), abundance-807.5,
                                           ifelse(between(rank(desc(abundance)),2,2), abundance-880,
                                           ifelse(between(rank(desc(abundance)),1,1), abundance-980,
                                           ifelse(between(rank(desc(abundance)),11,11), abundance+770,
                                           abundance+670)))),
                  color = ifelse(between(rank(desc(abundance)),1,10), "white",
                                           "#65707C")),
              size = 2) +
  scale_color_manual(values=c("#65707C","white"))

# Identified species abundances
identified_spc_abd <- trees %>%
  filter(!is.na(spc_common)) %>%
  group_by(spc_common) %>%
  summarize(abundance = n())

# Summary statistics of species abundances
spc_abd_stats <- data.frame(number_of_identified_spc = length(identified_spc_abd$abundance),
                mean = mean(identified_spc_abd$abundance),
                            sd = sd(identified_spc_abd$abundance),
                            min = min(identified_spc_abd$abundance),
                            first_quartile = quantile(identified_spc_abd$abundance, probs = 0.25),
                            median = median(identified_spc_abd$abundance),
                            third_quartile = quantile(identified_spc_abd$abundance, probs = 0.75),
                            max = max(identified_spc_abd$abundance))
row.names(spc_abd_stats) <- "spc_abundance" 

# Histogram with density curve of the species abundances
tree_count_per_species_dist_plot <- ggplot(identified_spc_abd,
                                           aes(x = abundance)) + 
  geom_histogram(aes(y = after_stat(density)),
                   binwidth=25,
                   color=1,
                   fill="#5FBD5F") + geom_density(linewidth=0.85,
                                                  linetype=1,
                                                  colour = muted("5FBD5F"),
                                                  alpha=0.5) +

# Plot mean and median
  geom_vline(aes(xintercept = mean(abundance)), col="red", size=0.6) +
  geom_vline(aes(xintercept = median(abundance)), col="blue", size=0.6) +

  theme(axis.title = element_text(color="#65707C",
                                    face="bold",
                                    family="sans serif"),
          axis.text = element_text(color="#65707C",
                                   size=12,
                                   family="sans serif"),
          axis.line = element_line(colour="grey",
                                   linewidth=0.5),
          panel.grid.major = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.25),
          panel.background = element_blank(),
          plot.subtitle = element_text(color="#65707C",
                                    hjust=-0.33,
                                    size=10,
                                    family="sans serif"),
          plot.title = element_text(color="#65707C",
                                    hjust=0.5,
                                    size=14,
                                    family="sans serif")) +
  ggtitle("\nFig. 16: Distribution of the Species Abundance                \n") +
  labs(x="\nSpecies abundance\n", y="\nDensity\n") +
  scale_x_continuous(expand = c(0.01, 0), 
                       limits = c(0, 2550),
                       breaks = seq(0, 2550, by=250)) +
  scale_y_continuous(expand = c(0.01, 0),
                       limits = c(0, 0.0081), 
                       breaks = seq(0, 0.0081, by=0.001))

# Species abundances per neighborhood
spc_abd_nbh <- nbh_spc_long %>%
  group_by(nta, nta_name) %>%
  filter(!(number_of_trees == 0)) %>%
  rename(abundance_wrt_nta = number_of_trees) %>%
  select(starts_with("nta"), spc_common, everything()) %>%
  mutate(relative_abundance_wrt_nta = label_percent(accuracy=0.01)(abundance_wrt_nta/sum(abundance_wrt_nta))) %>% 
  arrange(nta, desc(abundance_wrt_nta)) %>%
  ungroup()


# Diversity

# Simpson's Diversity Index (SDI)
mnh_sdi <- spc_abd %>%
  filter(!is.na(spc_common)) %>%
  select(-relative_abundance) %>%
  mutate(numerator = abundance*(abundance-1)) %>%
  summarize(SDI = 1-(sum(numerator)/(sum(abundance)*(sum(abundance)-1))),
              number_of_trees = sum(abundance),
              richness = n())


# -- Biology

# Size

# Summary statistics of species' tree DBHs
spc_tree_dbh_stats <- trees %>% 
  group_by(spc_common) %>%
  filter(!is.na(spc_common), !is.na(tree_dbh)) %>%
  summarize(abundance = n(),
              mean_tree_dbh = mean(tree_dbh),
              sd_tree_dbh = sd(tree_dbh),
              min_tree_dbh = min(tree_dbh),
              first_quartile_tree_dbh = quantile(tree_dbh, probs=0.25),
              median_tree_dbh = median(tree_dbh),
              third_quartile_tree_dbh = quantile(tree_dbh, probs=0.75),
              max_tree_dbh = max(tree_dbh))  %>%
  arrange(desc(median_tree_dbh))

# Create a bar plot for Top 25 tree species in terms of median dbh
top_spc_dbh_plot <- ggplot(top_spc_tree_dbh_stats %>% slice(1:25)) + 
  geom_chicklet(aes(x = fct_reorder(spc_common,
                                    median_tree_dbh),
                      y = median_tree_dbh), 
                  fill="#10401B",
                  radius = grid::unit(1, "mm"), position="stack") +
  coord_flip() +
  theme(axis.title = element_text(color = "#65707C",
                                    face="bold",
                                    family="sans serif"),
          axis.text = element_text(color = "#65707C",
                                   size=12,
                                   family="sans serif"),
          axis.title.x = element_text(margin=margin(20,0,10,0)),
          axis.title.y = element_text(margin=margin(0,20,0,10)),
          axis.line = element_line(colour = "grey",
                                   linewidth = 0.5),
          panel.grid.major = element_line(color = "grey",
                                          linetype="dashed",
                                          linewidth=0.25),
          panel.background = element_blank(),
          plot.title = element_text(color="#65707C",
                                    hjust=1.13,
                                    size=14,
                                    family="sans serif"),
          plot.subtitle = element_text(color="#65707C",
                                    hjust=2.95,
                                    size=10,
                                    family="sans serif")) +   
  ggtitle("\nFig. 9: Bar Graph of the Top 25 Largest Tree Species in Manhattan",
            subtitle="(in terms of median diameter at breast height (DBH) of 54 inches)    \n") +
  labs(x="\nCommon name of the species\n", y="Trunk diameter in inches\n") +
  scale_y_continuous(expand = c(0.01, 0),
                       limits = c(0, 15.5),
                       breaks = seq(0, 15.5, by=3)) +
  geom_text(aes(label = median_tree_dbh,
                                 x = spc_common,
                                 y = median_tree_dbh-0.4),
              size = 3, color = "white")

# Health-related

# Status per species
spc_status <- trees %>% 
  filter(!(is.na(spc_common) | is.na(spc_common))) %>%
  group_by(spc_common, status) %>%
  summarize(number_of_trees = n(), .groups="keep") %>%
  group_by(spc_common) %>%
  mutate(proportion_wrt_spc = number_of_trees/sum(number_of_trees),
           percentage_wrt_spc = label_percent(accuracy=0.01)(proportion_wrt_spc)) %>%
  arrange(proportion_wrt_spc) %>%
  select(-proportion_wrt_spc) %>%
  ungroup()

# Health per species
spc_health <- trees %>% 
  filter(!is.na(spc_common), !is.na(health)) %>%
  group_by(spc_common, health) %>%
  summarize(number_of_trees = n(), .groups="keep") %>%
  group_by(spc_common) %>%
  mutate(proportion = number_of_trees/sum(number_of_trees),
           percentage = label_percent(accuracy=0.01)(proportion),
           health = as.factor(health)) %>%
  arrange(spc_common, desc(proportion)) %>%
  ungroup()

# Health index per species
spc_health_index <- spc_health %>%
  group_by(spc_common) %>%
  mutate(health_score = ifelse(health=="Good", 3*number_of_trees,
                                 ifelse(health=="Fair", 2*number_of_trees,
                                        1*number_of_trees)),
          health_index = sum(health_score)/(3*sum(number_of_trees))) %>%
  ungroup() %>%
  select(spc_common, number_of_trees, health_index) %>%
  group_by(spc_common) %>%
  mutate(number_of_trees = sum(number_of_trees)) %>%
  distinct(spc_common, number_of_trees, health_index) %>%
  arrange(desc(health_index)) %>%
  rename(abundance = number_of_trees) %>%
  ungroup()

# Top 25 species in terms of health index
for_graph_top_spc_health <- spc_health %>%
  filter(spc_common %in% (
        spc_health_index %>%
        top_n(25, health_index))$spc_common) %>%
  arrange(desc(proportion))

# Order health per species
for_graph_top_spc_health$health <- factor(
    for_graph_top_spc_health$health,
    levels = c("Poor", "Fair", "Good"),
    ordered = TRUE)

# Order species by proportion of 'Good' health
for_graph_top_spc_health$spc_common <- factor(
    for_graph_top_spc_health$spc_common,
    levels = rev((for_graph_top_spc_health %>% filter(health == "Good"))$spc_common),
    ordered = TRUE)

# Highest percentage among species' health
top_spc_health_highest <- for_graph_top_spc_health %>% 
  group_by(spc_common) %>%
  filter(proportion == max(abs(proportion))) %>%
  ungroup()

# Create a stacked bar plot of the tree species' categorical, health-related attributes
top_spc_health_stacked_bar_plot <- ggplot(for_graph_top_spc_health) + 
  geom_chicklet(aes(x = spc_common, y = proportion*100, fill = health), 
                  radius = grid::unit(0.75, "mm"), position="stack") +
  coord_flip() +
  theme(legend.position = "right",
          legend.justification="top",
          legend.direction="vertical",
          legend.key.size = unit(0, 'pt'),
          legend.key = element_rect(fill = NA),
          legend.text = element_text(margin = margin(r = 4, unit = "pt"),
                                     color = "#65707C",
                                     family="sans serif"),
          legend.title = element_text(color = "#65707C",
                                      face="bold",
                                      size = 9,
                                      family="sans serif"),
      axis.title = element_text(color="#65707C",
                                    face="bold",
                                    family="sans serif"),
          axis.text.x = element_text(color="#65707C",
                                   size=6,
                                   family="sans serif"),
          axis.text.y = element_text(color="#65707C",
                                   size=10,
                                   family="sans serif"),
          axis.line = element_line(colour="grey",
                                   linewidth=0.5),
          panel.grid.major = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.25),
          panel.background = element_blank(),
          plot.subtitle = element_text(color="#65707C",
                                    hjust=-2.15,
                                    size=10,
                                    family="sans serif"),
          plot.title = element_text(color = "#65707C",
                                    hjust = 0.74,
                                    size= 12,
                                    family = "sans serif")) +
  scale_fill_manual(values = c("#89E7B3",
                 "#40C17E",
                                 "#1F9153")) +     
  ggtitle("\nFig. 10: Proportional Stacked Bar Graph of the Top 25 Healthiest Tree Species",
            subtitle="               (in terms of Health Index (HI) value)\n") +
  labs(x="\nCommon name of the species\n", y="\n% relative abundance\n", fill="Health: ") +
    guides(fill = guide_legend(ncol=1,
                               override.aes = list(shape = 15,
                                                   size = 4))) +
  scale_y_continuous(expand = c(0.01, 0),
                       breaks = seq(0, 100, by=10)) +
  ggrepel::geom_text_repel(data = top_spc_health_highest %>% 
                              inner_join(spc_health_index, by="spc_common"),
                             aes(label = paste("HI: ", round(health_index, digits=2),
                                               ", Good: ", label_percent(
                                                   accuracy=0.01)(proportion), sep=""),
                                 x = spc_common,
                                 y = ifelse(proportion==1, 100*proportion-21.5,
                                            100*proportion-22)),
                             size=2.2, color="white", hjust=1)

# Create a data for the graph of top 25 species in terms of root problems
spc_root_problems <- trees %>%
  select(spc_common, root_stone:root_other) %>%
  filter(spc_common != "null",
           if_all(-spc_common, ~ .x != "null")) %>%
  mutate(across(root_stone:root_other, ~ ifelse(.x == "Yes", 1, 0)),
           None = ifelse(root_stone == 0 &
                         root_grate == 0 &
                         root_other == 0, 1, 0)) %>%
  group_by(spc_common) %>%
  summarize(none = 100*sum(None)/n(),
              root_stone = 100*sum(root_stone)/n(),
              root_grate = 100*sum(root_grate)/n(),
              root_other = 100*sum(root_other)/n()) %>%
  rename(`Common name of the species` = spc_common,
           `''Paving stones` = root_stone,
           `'Metal grates` = root_grate,
           `Others` = root_other) %>% 
  ungroup() %>%
  filter(rank((none)) <= 25) %>%
  arrange((none)) %>%
    mutate_if(is.numeric, ~(round(., digits = 2))) %>%
  pivot_longer(cols = c(3:5), 
                 names_to = "Root problem",
                 values_to = "% of trees")

# Create a data for the graph of top 25 species in terms of trunk problems
spc_trunk_problems <- trees %>%
  select(spc_common, trunk_wire:trnk_other) %>%
  filter(spc_common != "null",
           if_all(-spc_common, ~ .x != "null")) %>%
  mutate(across(trunk_wire:trnk_other, ~ ifelse(.x == "Yes", 1, 0)),
           None = ifelse(trunk_wire == 0 &
                         trnk_light == 0 &
                         trnk_other == 0, 1, 0)) %>%
  group_by(spc_common) %>%
  summarize(none = 100*sum(None)/n(),
              trunk_wire = 100*sum(trunk_wire)/n(),
              trnk_light = 100*sum(trnk_light)/n(),
              trnk_other = 100*sum(trnk_other)/n()) %>%
  rename(`Common name of the species` = spc_common,
           `''Wires or rope` = trunk_wire,
           `'Lighting installed` = trnk_light,
           `Others` = trnk_other) %>% 
  ungroup() %>%
  filter(rank((none)) <= 25) %>%
  arrange((none)) %>%
    mutate_if(is.numeric, ~(round(., digits = 2))) %>%
  pivot_longer(cols = c(3:5), 
                 names_to = "Trunk problem",
                 values_to = "% of trees")

# Create a data for the graph of top 25 species in terms of branch problems
brch_trunk_problems <- trees %>%
  select(spc_common, brch_light:brch_other) %>%
  filter(spc_common != "null",
           if_all(-spc_common, ~ .x != "null")) %>%
  mutate(across(brch_light:brch_other, ~ ifelse(.x == "Yes", 1, 0)),
           None = ifelse(brch_light == 0 &
                         brch_shoe == 0 &
                         brch_other == 0, 1, 0)) %>%
  group_by(spc_common) %>%
  summarize(none = 100*sum(None)/n(),
              brch_light = 100*sum(brch_light)/n(),
              brch_shoe = 100*sum(brch_shoe)/n(),
              brch_other = 100*sum(brch_other)/n()) %>%
  rename(`Common name of the species` = spc_common,
           `''Lights or wires ` = brch_light,
           `'Shoes` = brch_shoe,
           `Others` = brch_other) %>% 
  ungroup() %>%
  filter(rank((none)) <= 25) %>%
  arrange((none)) %>%
    mutate_if(is.numeric, ~(round(., digits = 2))) %>%
  pivot_longer(cols = c(3:5), 
                 names_to = "Branch problem",
                 values_to = "% of trees")

# Ranking

# Correlation coefficient of health vs. size

# Spearman
spearman_corr <- data.frame(
    test_stat=cor.test(spc_health_index$health_index, spc_tree_dbh_stats$median_tree_dbh,
         method = "spearman", exact = FALSE)$statistic,
    corr_coeff=cor.test(spc_health_index$health_index, spc_tree_dbh_stats$median_tree_dbh,
         method = "spearman", exact = FALSE)$estimate,
    p_value=cor.test(spc_health_index$health_index, spc_tree_dbh_stats$median_tree_dbh,
         method = "spearman", exact = FALSE)$p.value)

# Kendall
kendall_corr <- data.frame(
    test_stat=cor.test(spc_health_index$health_index, spc_tree_dbh_stats$median_tree_dbh,
         method = "kendall", exact = FALSE)$statistic,
    corr_coeff=cor.test(spc_health_index$health_index, spc_tree_dbh_stats$median_tree_dbh,
         method = "kendall", exact = FALSE)$estimate,
    p_value=cor.test(spc_health_index$health_index, spc_tree_dbh_stats$median_tree_dbh,
         method = "kendall", exact = FALSE)$p.value)

# Pearson
pearson_corr <- data.frame(
    test_stat=cor.test(spc_health_index$health_index, spc_tree_dbh_stats$median_tree_dbh)$statistic,
    corr_coeff=cor.test(spc_health_index$health_index, spc_tree_dbh_stats$median_tree_dbh)$estimate,
    p_value=cor.test(spc_health_index$health_index, spc_tree_dbh_stats$median_tree_dbh)$p.value)

# Merge results
corr_coeffs <- spearman_corr %>%
    mutate(method = "Spearman") %>%
  bind_rows(kendall_corr %>%
                mutate(method = "Kendall"), 
              pearson_corr %>%
                mutate(method = "Pearson")) %>%
  select(method, everything()) %>%
  mutate(p_value = formatC(p_value, format = "e", digits = 4))
rownames(corr_coeffs) <- 1:nrow(corr_coeffs)

# Rank all 128 species in terms of size & health 
spc_first_ranking <- spc_health_index %>%
  select(spc_common, abundance, health_index) %>%
  inner_join(trees %>% 
               group_by(spc_common) %>%
               filter(spc_common != "null", health != "null") %>%
               summarize(abundance = n(),
                         median_tree_dbh = median(tree_dbh)),
      by = c("spc_common", "abundance")) %>%
  mutate(abd_rank = rank(desc(abundance)),
           hi_rank = rank(desc(health_index)),
           dbh_rank = rank(desc(median_tree_dbh)),
           rank_sum = (hi_rank + dbh_rank)) %>%
  arrange(rank_sum)

# Rank all species with abundances of 29 in terms of size & health 
spc_second_ranking <- spc_health_index %>%
  select(spc_common, abundance, health_index) %>%
  inner_join(trees %>% 
               group_by(spc_common) %>%
               filter(spc_common != "null", health != "null") %>%
               summarize(abundance = n(),
                         median_tree_dbh = median(tree_dbh)),
      by = c("spc_common", "abundance")) %>%

# Filter out species with abundances less than the median abundances
  filter(abundance >= median(spc_tree_dbh_stats$abundance)) %>% 

  mutate(abd_rank = rank(desc(abundance)),
           hi_rank = rank(desc(health_index)),
           dbh_rank = rank(desc(median_tree_dbh)),
           rank_sum = (hi_rank + dbh_rank)) %>%
  arrange(rank_sum)

# Pivot 'spc_first_ranking' to a long format
spc_first_ranking_long <- spc_first_ranking %>%
  rename(`Common name of the species` = spc_common,
           `Health index` = health_index,
           `Median trunk dbh` = median_tree_dbh) %>%
  pivot_longer(cols = c(3:4), 
                 names_to = "Measurement",
                 values_to = "Value")

# Pivot 'spc_second_ranking' to a long format
spc_second_ranking_long <- spc_second_ranking %>%
  rename(`Common name of the species` = spc_common,
           `Health index` = health_index,
           `Median trunk dbh` = median_tree_dbh) %>%
  pivot_longer(cols = c(3:4), 
                 names_to = "Measurement",
                 values_to = "Value")

# Top 10 species in the first ranking 
top_spc_first_ranking <- spc_first_ranking_long %>%
  arrange(rank_sum) %>%
  filter(`Common name of the species` %in% (spc_first_ranking %>% slice(1:10))$spc_common)

# Top 10 species in the second ranking 
top_spc_second_ranking <- spc_second_ranking_long %>%
  arrange(rank_sum) %>%
  filter(`Common name of the species` %in% (spc_second_ranking %>% slice(1:10))$spc_common)
```

    The following package(s) will be installed:
    - remotes [2.5.0]
    These packages will be installed into "~/renv/library/linux-ubuntu-jammy/R-4.4/x86_64-pc-linux-gnu".
    
    # Installing packages --------------------------------------------------------
    - Installing remotes ...                        OK [linked from cache]
    Successfully installed 1 package in 9.3 milliseconds.



    Error: Failed to install 'rwantshue' from GitHub:
      HTTP error 401.
      Bad credentials
    
      Rate limit remaining: 59/60
      Rate limit reset at: 2025-08-19 03:06:24 UTC
    
      
    Traceback:


    1. withCallingHandlers(expr, warning = function(w) if (inherits(w, 
     .     classes)) tryInvokeRestart("muffleWarning"))

    2. suppressMessages(remotes::install_github("hoesler/rwantshue", 
     .     auth_token = ""))

    3. withCallingHandlers(expr, message = function(c) if (inherits(c, 
     .     classes)) tryInvokeRestart("muffleMessage"))

    4. remotes::install_github("hoesler/rwantshue", auth_token = "")

    5. install_remotes(remotes, auth_token = auth_token, host = host, 
     .     dependencies = dependencies, upgrade = upgrade, force = force, 
     .     quiet = quiet, build = build, build_opts = build_opts, build_manual = build_manual, 
     .     build_vignettes = build_vignettes, repos = repos, type = type, 
     .     ...)

    6. tryCatch(res[[i]] <- install_remote(remotes[[i]], ...), error = function(e) {
     .     stop(remote_install_error(remotes[[i]], e))
     . })

    7. tryCatchList(expr, classes, parentenv, handlers)

    8. tryCatchOne(expr, names, parentenv, handlers[[1L]])

    9. value[[3L]](cond)

    10. stop(remote_install_error(remotes[[i]], e))
 -->
