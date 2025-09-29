---
title: 'Patient Characteristics and Readmission Modeling'
collection: portfolio
permalink: /portfolio/patient-characteristics-and-readmission-modeling
date: 2023-03-06
last_updated: 2025-09-29
excerpt: 'This report analyzes ten years of hospital data (n ≈ 25,000) from 130 US hospitals to identify high-risk groups for readmission. Using multivariate logistic regression, it measures the effects of variables such as age, diabetes diagnosis or medication, and length of stay on patient readmission, supporting targeted follow-up care after discharge.'
venue: 'DataCamp'
categories:
  - R
slidesurl: []
images:
  - '/files/patient-characteristics-and-readmission-modeling/images/page-1.png'
# link: 'https://www.datacamp.com/datalab/w/25b9af80-8fb3-4b12-a863-2188ee07d059'
# url: 'https://www.datacamp.com/datalab/w/25b9af80-8fb3-4b12-a863-2188ee07d059'
thumbnail: '/images/projects/project5-cover.png'
featured: false
doc_type: 'Full Report'

---

# Patient Characteristics and Readmission Modeling

## 1.0 Background
### 1.1. Introduction
A healthcare organization has engaged our team to conduct a comprehensive analysis of ten years of patient readmission data following discharge. The objective is to evaluate whether factors such as initial diagnoses, number of procedures, and other clinical variables can improve the prediction of readmission likelihood. The insights from this analysis will support more proactive patient care strategies, enabling targeted follow-up and resource allocation for individuals at higher risk of readmission.

### 1.2. Objectives
The main objective of this report is to explore patient characteristics and readmissions. It specifically aims to:

- Describe the overall and by age characteristics of the patients.
- Investigate and model the patient readmissions by their representing features.
- Identify patient groups with the best readmission rates.

### 1.3. Libraries

```R
# Load required packages
library(tidyverse) 
library(dplyr)
library(ggplot2)
library(scales)
library(ggfun) # for round rectangle borders and backgrounds in ggplots
library(ggchicklet) # for bar charts with rounded corners
library(ggthemes) # for using the look of a plot theme
library(patchwork) # for combining ggplots into the same graphic		
library(ggpubr) # for boxplots

# Install and load the "mlbench" package							   
#suppressWarnings(suppressMessages(install.packages("mlbench")))
#suppressPackageStartupMessages(library(mlbench))
```

### 1.4. Dataset
The [dataset](https://archive.ics.uci.edu/ml/datasets/Diabetes+130-US+hospitals+for+years+1999-2008) referenced was part of the clinical care system at 130 hospitals and integrated delivery networks in the United States ([Strack et al., 2014](#reference)).

<img src="https://i.ibb.co/pbk1JXM/vars-desc.png" alt="vars-desc" border="0">

```R                     
# Read 'readmissions' dataset
readmissions <- readr::read_csv('data/hospital_readmissions.csv', show_col_types = FALSE) %>%
  mutate_if(is.character,as.factor) %>%
  mutate_all(~ if_else(.x == "Missing", NA,.x))

#is.na(readmissions)
#colSums(is.na(readmissions))
#which(colSums(is.na(readmissions))>0)
#names(which(colSums(is.na(readmissions))>0))
#missmap(readmissions, col=c("blue", "red"), legend=FALSE)

#summary(readmissions)
#par(mfrow=c(1,6))
#for(i in 1:17) {
#    boxplot(readmissions[,i], main=names(readmissions)[i])
#}
```

    The following package(s) will be installed:
    - ggthemes [5.1.0]
    These packages will be installed into "~/renv/library/linux-ubuntu-jammy/R-4.4/x86_64-pc-linux-gnu".
    
    # Installing packages --------------------------------------------------------
    - Installing ggthemes ...                       OK [linked from cache]
    Successfully installed 1 package in 6.4 milliseconds.
    The following package(s) will be installed:
    - ggpubr [0.6.0]
    These packages will be installed into "~/renv/library/linux-ubuntu-jammy/R-4.4/x86_64-pc-linux-gnu".
    
    # Installing packages --------------------------------------------------------
    - Installing ggpubr ...                         OK [linked from cache]
    Successfully installed 1 package in 6.3 milliseconds.



```R
# ----- For link's image thumbnail

# Install and load the 'png' package
# For superimposing PNG images in a ggplot								   
suppressWarnings(suppressMessages(install.packages("png", verbose=TRUE, quiet=TRUE)))       
suppressPackageStartupMessages(library(png))  

# Create a data
data <- data.frame(x = 1:3,
                   y = 1:3)

# Read the PNG file
my_image <- readPNG("documentation/cover_Fig10_diag_stacked_bar_plot.png", native = TRUE)

# Create a plot and combine with the image
ggplot(data, aes(x, y)) +
  geom_point() +
  theme_minimal() +
  theme(axis.title = element_blank(),
          axis.text = element_blank(),
          axis.line = element_blank(),
          axis.ticks = element_blank()) +
  inset_element(p = my_image,
                  left = -0.52,
                  bottom = -0.03,
                  right = 1.52,
                  top = 1.02)
```


    
![png](notebook_files/notebook_2_0.png)
    


## Results and Discussion
### Patient Characteristics
The following information describe the characteristics of the sample composing of 25,000 patients admitted to the hospital after being discharged.

#### Overall
##### Numerical
**Age**: The grouped mean and median ages are approximately 68 and 69, respectively, with a standard deviation of ~13, indicating that the hospital primarily admitted elderly patients. As shown in Figure 1, the distribution of patients across age groups is approximately symmetric at the mean.


```R
# Frequency Distribution Table (FDT) for Age
age_fdt <- readmissions %>%
  select(age) %>%
  group_by(age) %>%
  count() %>%
  mutate(class_interval = paste(as.numeric(unlist(regmatches(age, gregexpr("[[:digit:]]+", age)))), collapse = "-"),
           class_mark = mean(as.numeric(unlist(regmatches(age, gregexpr("[[:digit:]]+", age)))))) %>%
  ungroup() %>%
  mutate(cum_freq = cumsum(n),
           n_times_cm = n*class_mark) %>%
  select(age, class_interval, everything())

# Create GroupedMedian() function to calculate the median of grouped data	
# Reference: http://stackoverflow.com/a/18931054/1270695
GroupedMedian <- function(frequencies, intervals, sep = NULL, trim = NULL) {
  # If "sep" is specified, the function will try to create the 
  #   required "intervals" matrix. "trim" removes any unwanted 
  #   characters before attempting to convert the ranges to numeric.
  if (!is.null(sep)) {
    if (is.null(trim)) pattern <- ""
    else if (trim == "cut") pattern <- "\\[|\\]|\\(|\\)"
    else pattern <- trim
    intervals <- sapply(strsplit(gsub(pattern, "", intervals), sep), as.numeric)
  }

  Midpoints <- rowMeans(intervals)
  cf <- cumsum(frequencies)
  Midrow <- findInterval(max(cf)/2, cf) + 1
  L <- intervals[1, Midrow]      # lower class boundary of median class
  h <- diff(intervals[, Midrow]) # size of median class
  f <- frequencies[Midrow]       # frequency of median class
  cf2 <- cf[Midrow - 1]          # cumulative frequency class before median class
  n_2 <- max(cf)/2               # total observations divided by 2

  unname(L + (n_2 - cf2)/f * h)
}

# Grouped Mean, Median, and Sample SD
grouped_age_stats <- age_fdt %>% 
  summarize(Variable = "Age group",
        "Mean" = sum(n_times_cm)/sum(n),
              "Std. Dev." = sqrt(sum(n*(Mean-class_mark)^2)/(sum(n))),
        "Med." = GroupedMedian(frequencies = age_fdt$n, intervals = age_fdt$class_interval, sep = "-")
       )

grouped_age_stats

# Bar plot
age_bar_plot <- ggplot(age_fdt, aes(group=1)) + 
  geom_chicklet(aes(x = age,
                      y = n,
            group=1), 
                  color="white",
                  fill="#6C8CBF",
                  radius = grid::unit(1, "mm"), position="stack") +
    
  # Plot mean and median lines
  geom_vline(xintercept=3.344, color="red", linewidth=0.6) +
 
  ggtitle("Fig. 1: Bar Graph of the Patients' Age Groups\n") +
  labs(x="\nAge group", y="Number of patients\n") +
  scale_y_continuous(expand = c(0.01, 0), limits = c(0,7000),
                      breaks = seq(0, 7000, by=1000)) +
  theme_economist() + 
  scale_color_economist() +
  theme(plot.title = element_text(size= 12),
          panel.grid.minor = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.3),
      panel.grid.major = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.3),
          axis.ticks = element_blank()
         ) +
  annotate("text", x=2.7, y=6500, 
       label=paste("Mean = ",sum(age_fdt$n_times_cm)/sum(age_fdt$n)),
       color="red",
       size=3.5)
```


<table class="dataframe">
<caption>A tibble: 1 × 4</caption>
<thead>
  <tr><th scope=col>Variable</th><th scope=col>Mean</th><th scope=col>Std. Dev.</th><th scope=col>Med.</th></tr>
  <tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th></tr>
</thead>
<tbody>
  <tr><td>Age group</td><td>68.4412</td><td>13.15607</td><td>69.3286</td></tr>
</tbody>
</table>



<img src="documentation/Fig1_age_bar_plot.png"/>

**Time in hospital**: The mean and median lengths of stay in the hospital are 4.4533 and 4, respectively, with a standard deviation of ~3. Figure 2 shows a positively skewed distribution for this patient feature.


```R
# Summary statistics for numerical variables
sum_stats <- data.frame(
    Variable = readmissions %>%
    select_if(is.numeric) %>%
    colnames) %>%
  bind_cols(as.data.frame(t(readmissions %>%
                              summarise_if(is.numeric, list(mean)) %>%
                              bind_rows(readmissions %>%
                                          summarise_if(is.numeric, list(sd)), 
                                        readmissions %>%
                                          summarise_if(is.numeric, list(min)),
                                        readmissions %>%
                                          summarise_if(is.numeric, list(median)),
                                        readmissions %>%
                                          summarise_if(is.numeric, list(max)))
                             )) %>%
              rename(Mean = V1,
                     `Std. Dev.` = V2,
                     `Min.` = V3,
                     `Median` = V4,
                     `Max.` = V5))

rownames(sum_stats) <- 1: nrow(sum_stats)
sum_stats

# time in hospital
time_in_hospital_dst_plot <- ggplot(readmissions, aes(x = time_in_hospital)) + 
  geom_histogram(aes(y=after_stat(density)),
                   colour="white",
                   fill="#5AA7A7",
                   binwidth=1) +
  geom_density(alpha=0.2,
                 fill="#FF6666") +

  # Plot mean and median lines
  geom_vline(aes(xintercept = mean(time_in_hospital)), col="red", linewidth=0.6) +
  #geom_vline(aes(xintercept = median(time_in_hospital)), col="blue", linewidth=0.6) +
  
  ggtitle("Fig. 2: Distribution of the Time Length in Hospital\n") +
  labs(x="\nNumber of days (from 1 to 14)", y="Density\n") +
  scale_x_continuous(expand = c(0.01, 0), 
                       breaks = seq(0, 14, by=2)) +
  scale_y_continuous(expand = c(0.01, 0),
                       limits = c(0,0.20),
                       breaks = seq(0,0.20, by=0.025)) +
  theme_economist() + 
  scale_color_economist() +
  theme(plot.title = element_text(size= 12),
          panel.grid.minor = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.3),
      panel.grid.major = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.3)
         ) +
  annotate("text", x=mean(readmissions$time_in_hospital)+1.45, y=(0.200+0.175)/2, 
       label=paste("Mean = ",round(mean(readmissions$time_in_hospital),4)),
       color="red",
       size=3.5)
```


<table class="dataframe">
<caption>A data.frame: 7 × 6</caption>
<thead>
  <tr><th></th><th scope=col>Variable</th><th scope=col>Mean</th><th scope=col>Std. Dev.</th><th scope=col>Min.</th><th scope=col>Median</th><th scope=col>Max.</th></tr>
  <tr><th></th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th></tr>
</thead>
<tbody>
  <tr><th scope=row>1</th><td>time_in_hospital</td><td> 4.45332</td><td> 3.0014699</td><td>1</td><td> 4</td><td> 14</td></tr>
  <tr><th scope=row>2</th><td>n_lab_procedures</td><td>43.24076</td><td>19.8186202</td><td>1</td><td>44</td><td>113</td></tr>
  <tr><th scope=row>3</th><td>n_procedures    </td><td> 1.35236</td><td> 1.7151793</td><td>0</td><td> 1</td><td>  6</td></tr>
  <tr><th scope=row>4</th><td>n_medications   </td><td>16.25240</td><td> 8.0605318</td><td>1</td><td>15</td><td> 79</td></tr>
  <tr><th scope=row>5</th><td>n_outpatient    </td><td> 0.36640</td><td> 1.1954782</td><td>0</td><td> 0</td><td> 33</td></tr>
  <tr><th scope=row>6</th><td>n_inpatient     </td><td> 0.61596</td><td> 1.1779511</td><td>0</td><td> 0</td><td> 15</td></tr>
  <tr><th scope=row>7</th><td>n_emergency     </td><td> 0.18660</td><td> 0.8858735</td><td>0</td><td> 0</td><td> 64</td></tr>
</tbody>
</table>



<img src="documentation/Fig2_time_in_hospital_dst_plot.png"/>

**Number of procedures**: The mean and median number of medical procedures performed during the hospital stay are 1.3524 and 1, with a standard deviation of 1.7152, respectively, whereas the mean and median numbers of laboratory procedures performed are 43.2408 and 44, respectively, with a standard deviation of 19.8186. This implies that throughout their hospitalization, patients underwent laboratory procedures more frequently than medical procedures.

Based on Figures 3 and 4, the two types of procedures exhibit dissimilar distributional characteristics, with medical procedures demonstrating positive skewness, and laboratory procedures showing slight symmetry.


```R
# Number of Procedures
n_procedures_hs_dst_plot <- ggplot(readmissions, aes(x = n_procedures)) + 
  geom_histogram(aes(y=after_stat(density)),
                   colour="white",
                   fill="#5AA7A7",
                   binwidth=0.5
                  ) +
  geom_density(alpha=0.2,
                 fill="#FF6666") +

  # Plot mean and median lines
  geom_vline(aes(xintercept = mean(n_procedures)), col="red", linewidth=0.6) +
  #geom_vline(aes(xintercept = median(n_procedures)), col="blue", linewidth=0.6) +
  
  ggtitle("Fig. 3: Distribution of the Number of Medical Procedures\n") +
  labs(x="\nNumber of procedures performed during the hospital stay", y="Density\n") +
  theme_economist() + 
  scale_color_economist() +
  theme(plot.title = element_text(size= 12),
          panel.grid.minor = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.3),
      panel.grid.major = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.3)
         ) +
  annotate("text", x=mean(readmissions$n_procedures)+0.72, y=0.7, 
       label=paste("Mean = ",round(mean(readmissions$n_procedures),4)),
       color="red",
       size=3.5)

# Number of Lab Procedures
n_lab_procedures_hs_dst_plot <- ggplot(readmissions, aes(x = n_lab_procedures)) + 
  geom_histogram(aes(y=after_stat(density)),
                   colour="white",
                   fill="#5AA7A7",
                   binwidth=3
                  ) +
  geom_density(alpha=0.2,
                 fill="#FF6666") +

  # Plot mean and median lines
  geom_vline(aes(xintercept = mean(n_lab_procedures)), col="red", linewidth=0.6) +
  #geom_vline(aes(xintercept = median(n_lab_procedures)), col="blue", linewidth=0.6) +
  
  ggtitle("Fig. 4: Distribution of the Number of Laboratory Procedures\n") +
  labs(x="\nNumber of lab procedures performed during the hospital stay", y="Density\n") +
  theme_economist() + 
  scale_color_economist() +
  theme(plot.title = element_text(size= 12),
          panel.grid.minor = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.3),
      panel.grid.major = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.3)
         ) +
  annotate("text", x=mean(readmissions$n_lab_procedures)+14, y=0.025, 
       label=paste("Mean = ",round(mean(readmissions$n_lab_procedures),4)),
       color="red",
       size=3.5)

#ggarrange(n_procedures_hs_dst_plot, n_lab_procedures_hs_dst_plot, 
#          ncol = 1, nrow = 2)
```

<img src="documentation/Fig3-4_n_procedures_dst_plot.png"/>

**Number of medications**: The mean and median numbers of medications administered during the hospital stay are 16.2524 and 15, with a standard deviation of 8.0605, as well as a slightly skewed distribution to the right.


```R
# Number of Procedures
n_medications_hs_dst_plot <- ggplot(readmissions, aes(x = n_medications)) + 
  geom_histogram(aes(y=after_stat(density)),
                   colour="white",
                   fill="#5AA7A7",
                   binwidth=1
                  ) +
  geom_density(alpha=0.2,
                 fill="#FF6666") +

  # Plot mean and median lines
  geom_vline(aes(xintercept = mean(n_medications)), col="red", linewidth=0.6) +
  #geom_vline(aes(xintercept = median(n_medications)), col="blue", linewidth=0.6) +
  
  ggtitle("Fig. 5: Distribution of the Number of Medications\n") +
  labs(x="\nNumber of medications administered during the hospital stay", y="Density\n") +
  scale_y_continuous(expand = c(0.01, 0),
                       limits = c(0,0.065),
                       breaks = seq(0,0.065, by=0.01)) +
  theme_economist() + 
  scale_color_economist() +
  theme(plot.title = element_text(size= 12),
          panel.grid.minor = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.3),
      panel.grid.major = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.3)
         ) +
  annotate("text", x=mean(readmissions$n_medications)+9, y=0.065, 
       label=paste("Mean = ",round(mean(readmissions$n_medications),4)),
       color="red",
       size=3.5)
```

<img src="documentation/Fig5_n_medications_hs_dst_plot.png"/>

**Number of visits**: The mean numbers of outpatient, inpatient, and emergency room visits in the year preceding a hospital stay are 0.3664, 0.616, and 0.1866, with medians of 0 for all types, and standard deviations of 1.1955, 1.178, and 0.8859, respectively. The numbers of visits for all types are positively skewed, indicating that visitation is not much frequent among patients a year prior to their hospitalization.


```R
# Outpatient
n_outpatient_hs_dst_plot <- ggplot(readmissions, aes(x = n_outpatient)) + 
  geom_histogram(aes(y=after_stat(density)),
                   colour="white",
                   fill="#5AA7A7",
                   binwidth=1
                  ) +
  geom_density(alpha=0.2,
                 fill="#FF6666") +

  # Plot mean and median lines
  geom_vline(aes(xintercept = mean(n_outpatient)), col="red", linewidth=0.6) +
  #geom_vline(aes(xintercept = median(n_outpatient)), col="blue", linewidth=0.6) +
  
  ggtitle("Fig. 6: Distribution of the Number of Outpatient Visits\n") +
  labs(x="\nNumber of outpatient visits in the year before a hospital stay", y="Density\n") +
  scale_y_continuous(expand = c(0.01, 0),
                       limits = c(0,1),
                       breaks = seq(0,1, by=0.2)) +
  scale_x_continuous(expand = c(0.01, 0),
                       #limits = c(0,75),
                       breaks = seq(0,35, by=5)) +
  theme_economist() + 
  scale_color_economist() +
  theme(plot.title = element_text(size= 12),
          panel.grid.minor = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.3),
      panel.grid.major = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.3)
         ) +
  annotate("text", x=3.6, y=0.97, 
       label=paste("Mean = ",round(mean(readmissions$n_outpatient),4)),
       color="red",
       size=3.5)

# Inpatient
n_inpatient_procedures_hs_dst_plot <- ggplot(readmissions, aes(x = n_inpatient)) + 
  geom_histogram(aes(y=after_stat(density)),
                   colour="white",
                   fill="#5AA7A7",
                   binwidth=1
                  ) +
  geom_density(alpha=0.2,
                 fill="#FF6666") +

  # Plot mean and median lines
  geom_vline(aes(xintercept = mean(n_inpatient)), col="red", linewidth=0.6) +
  #geom_vline(aes(xintercept = median(n_inpatient)), col="blue", linewidth=0.6) +
  
  ggtitle("Fig. 7: Distribution of the Number of Inpatient Visits\n") +
  labs(x="\nNumber of inpatient visits in the year before the hospital stay", y="Density\n") +
  scale_y_continuous(expand = c(0.01, 0),
                       limits = c(0,1),
                       breaks = seq(0,1, by=0.2)) +
  scale_x_continuous(expand = c(0.01, 0),
                       #limits = c(0,75),
                       breaks = seq(0,18, by=3)) +
  theme_economist() + 
  scale_color_economist() +
  theme(plot.title = element_text(size= 12),
          panel.grid.minor = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.3),
      panel.grid.major = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.3)
         ) +
  annotate("text", x=2, y=0.97, 
       label=paste("Mean = ",round(mean(readmissions$n_inpatient),4)),
       color="red",
       size=3.5)

# Emergency
n_emergency_procedures_hs_dst_plot <- ggplot(readmissions, aes(x = n_emergency)) + 
  geom_histogram(aes(y=after_stat(density)),
                   colour="white",
                   fill="#5AA7A7",
                   binwidth=1
                   ) +
  geom_density(alpha=0.2,
                 fill="#FF6666") +

  # Plot mean and median lines
  geom_vline(aes(xintercept = mean(n_emergency)), col="red", linewidth=0.6) +
  #geom_vline(aes(xintercept = median(n_emergency)), col="blue", linewidth=0.6) +
  
  ggtitle("Fig. 8: Distribution of the Number of Emergency Room Visits\n") +
  labs(x="\nNumber of visits to the emergency room in the year before the hospital stay", y="Density\n") +
  scale_y_continuous(expand = c(0.01, 0),
                       limits = c(0,1),
                       breaks = seq(0,1, by=0.2)) +
  scale_x_continuous(expand = c(0.01, 0),
                       #limits = c(0,75),
                       breaks = seq(0,75, by=10)) +
  theme_economist() + 
  scale_color_economist() +
  theme(plot.title = element_text(size= 12),
          panel.grid.minor = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.3),
      panel.grid.major = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.3)
         ) +
  annotate("text", x=6.7, y=0.97, 
       label=paste("Mean = ",round(mean(readmissions$n_emergency),4)),
       color="red",
       size=3.5)

#ggarrange(n_outpatient_hs_dst_plot, 
#          n_inpatient_procedures_hs_dst_plot,
#          n_emergency_procedures_hs_dst_plot, 
#          ncol = 1, nrow = 3)
```

<img src="documentation/Fig6-8_n_visits_dst_plot.png"/>

##### Categorical

**Medical Specialty**: Of the 12,618 (50.47%) patients with a recorded admitting physician, 3,565 had an admitting physician whose specialty was Internal Medicine.


```R
# Frequency Distribution Table (FDT) for the Specialty of the Admitting Physician
medical_specialty_fdt <- readmissions %>%
  select(medical_specialty) %>%
  group_by(medical_specialty) %>%
  count() %>%
  ungroup() %>%
  mutate(perc = label_percent(accuracy=0.01)(n/sum(n))) %>%
  arrange(desc(n))

# Age
medical_specialty_bar_plot <- ggplot(medical_specialty_fdt %>% 
                    filter(!is.na(medical_specialty))) + 
  geom_chicklet(aes(x = fct_reorder(medical_specialty,n),
                      y = n), 
                  fill=c("#6C8CBF"),
                  color="white",
                  radius = grid::unit(1, "mm"), position="stack",
          na.rm = TRUE) +
  coord_flip() +
  ggtitle("Fig. 9: Bar Graph of the Specialty of Patients' Admitting Physician \n") +
  labs(y="\nNumber of patients", x="Specialty of the admitting physician\n") +
  theme_economist() + 
  scale_color_economist() + 
  theme(legend.position="bottom",
          legend.text = element_text(margin = margin(r = 2, unit = "pt"),
                                     size = 10),
          axis.ticks = element_blank(),
      axis.text.y = element_text(size=10),
          legend.title = element_text(face="bold",
                                      size = 12),
          panel.grid.minor = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.3),
      panel.grid.major = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.3),
          plot.title = element_text(hjust = 0,
                                    size= 12),
          legend.box.margin = margin(t=0, b=0, l=-95, unit='pt'))  +
  #scale_y_continuous(expand = c(0.01, 0),
    #                   limits = c(0, 13000),
    #                   breaks = seq(0, 13000, by=2000)) +
  scale_x_discrete(expand = c(0.11, 0),
           labels = rev(c("Internal\nMedicine",
                "Other",
                "Emergency/\nTrauma",
                "Family/\nGeneral\nPractice",
                  "Cardiology",
                  "Surgery"))
           )
```

<img src="documentation/Fig9_medical_specialty_bar_plot.png"/>

**Diagnoses**: Most of the circulatory diagnoses or 7,824 (31.30%) were identified as primary, whereas most of the patients who had a diagnosis other than circulatory, diabetes, digestive, injury, musculoskeletal, or respiratory received it as a secondary (9,056 or 36.22%) and additional secondary (9,107 or 36.43%).


```R
# Table for the diagnoses
diag_tbl <- readmissions %>% 
  select(diag_1, diag_2, diag_3) %>%
  pivot_longer(cols = c(1:3), 
                 names_to = "diag_type",
                 values_to = "diag") %>%
  group_by(diag_type, diag) %>%
  summarize(n=n(), .groups="keep") %>%
  group_by(diag_type) %>%
  mutate(perc=label_percent(accuracy = 0.01)(n/sum(n))) %>%
  arrange(diag_type, desc(n)) %>%
  ungroup()


# Install and load the 'rwantshue' package
# For generating random color scheme
suppressWarnings(suppressMessages(install.packages("remotes")))
suppressWarnings(suppressMessages(remotes::install_github("hoesler/rwantshue", auth_token = "")))
suppressPackageStartupMessages(library(rwantshue))

# Colorize the Physician's Specialty
color_scheme1 <- iwanthue(seed=1234, force_init=TRUE)
diag_colors <- color_scheme1$hex(length(levels(factor(diag_tbl$diag))))

#convert diagnostic type to factor and specify level order
diag_tbl$diag_type <- factor(diag_tbl$diag_type, levels=c('diag_3', 'diag_2', 'diag_1'))

diag_stacked_bar_plot <- ggplot(diag_tbl %>% filter(!is.na(diag))) + 
  geom_chicklet(aes(x = diag_type, y = n,
                      fill = fct_reorder(diag, n)),
                  color="white",
                  alpha=0.95,
                  radius = grid::unit(0.75, "mm"),
                  position="dodge") +
  coord_flip() +	
    #scale_x_discrete(labels = c("Additional Secondary", "Secondary", "Primary")) + 
  ggtitle("Fig. 10: Stacked Bar Graph of the Patients' Diagnoses\n") +
  labs(x="Diagnosis Type\n", y="\nNumber of patients", fill="Diagnosis: ") +
  theme_economist() + 
  scale_color_economist() + 
    guides(fill = guide_legend(ncol=3,
                               reverse = TRUE,
                               override.aes = list(shape = 15,
                                                   size = 4),
                               title.position="top")) +
  theme(legend.position="bottom",
          legend.text = element_text(margin = margin(r = 2, unit = "pt"),
                                     size = 10),
          axis.ticks = element_blank(),
      axis.text.y = element_text(size=10),
          legend.title = element_text(face="bold",
                                      size = 12),
          panel.grid.minor = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.3),
      panel.grid.major = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.3),
          plot.title = element_text(hjust = 0,
                                    size= 12),
          legend.box.margin = margin(t=0, b=0, l=-135, unit='pt')) +
  scale_fill_manual(values = diag_colors#,
            #labels = rev(c("Missing",
          #			"Circulatory",
          #				 "Other",
          #			"Diabetes",
          #		    "Respiratory",
          #		    "Digestive",
          #			"Injury",
          #			"Musculoskeletal"))
           ) +
  scale_y_continuous(expand = c(0.01, 0),
                   limits = c(0, 10200),
                       breaks = seq(0, 10200, by=2000)) +
  scale_x_discrete(expand = c(0.275, 0),
                    labels = c("Additional\nSecondary", "Secondary", "Primary")) 
```

    The following package(s) will be installed:
    - remotes [2.5.0]
    These packages will be installed into "~/renv/library/linux-ubuntu-jammy/R-4.4/x86_64-pc-linux-gnu".
    
    # Installing packages --------------------------------------------------------
    - Installing remotes ...                        OK [linked from cache]
    Successfully installed 1 package in 6.1 milliseconds.
    curl     (5.2.1  -> 5.2.3   ) [CRAN]
    jsonlite (1.8.8  -> 1.8.9   ) [CRAN]
    Rcpp     (1.0.12 -> 1.0.13-1) [CRAN]
    V8       (4.4.2  -> 6.0.0   ) [CRAN]
    [36m──[39m [36mR CMD build[39m [36m─────────────────────────────────────────────────────────────────[39m
    * checking for file ‘/tmp/Rtmpvo1Xrr/remotes193d3d1cdf74/hoesler-rwantshue-07a58c7/DESCRIPTION’ ... OK
    * preparing ‘rwantshue’:
    * checking DESCRIPTION meta-information ... OK
    * checking for LF line-endings in source and make files and shell scripts
    * checking for empty or unneeded directories
    Omitted ‘LazyData’ from DESCRIPTION
    * building ‘rwantshue_0.0.3.tar.gz’
    


<img src="documentation/Fig10_diag_stacked_bar_plot.png"/>

**Prediabetes test results**: A total of 20,938 (83.75%) had not performed an A1C test, while 23,625 (94.50%) had not performed a glucose test. For those who had performed, however, a high result was seen more than a normal one for A1C tests and almost equal number in high and normal results for glucose test.


```R
# Table for Prediabetes tests
diab_test_tbl <- readmissions %>% 
  select(glucose_test, A1Ctest) %>%
  rename(A1C = A1Ctest, 
           Glucose = glucose_test) %>%
  pivot_longer(cols = c(1:2), 
                 names_to = "prediab_test",
                 values_to = "result") %>%
  group_by(prediab_test, result) %>%
  summarize(n=n(), .groups="keep") %>%
  group_by(prediab_test) %>%
  mutate(perc=label_percent(accuracy = 0.01)(n/sum(n))) %>%
  arrange(prediab_test, desc(n)) %>%
  ungroup()

#convert test result type to factor and specify level order
diab_test_tbl$result <- factor(diab_test_tbl$result, levels=c("no",'normal','high'))

diab_test_stacked_bar_plot <- ggplot(diab_test_tbl) + 
  geom_chicklet(aes(x = fct_reorder(prediab_test, n), y = n,
                      fill = result),
                  color="white",
                  alpha=0.95,
                  radius = grid::unit(0.75, "mm"),
                  position="dodge") +
  coord_flip() +	
  scale_fill_manual(values = c("#838484", "#8BD69D", "#BD3E38"),
                      labels = c("Not Performed", "Normal", "High")
                     ) + 
  ggtitle("Fig. 11: Stacked Bar Graph of the Patients' Prediabetes Test Results\n") +
  labs(x="Prediabetes test\n", y="\nNumber of patients", fill="Test Result:  ") +
  theme_economist() + 
  scale_color_economist() + 
    guides(fill = guide_legend(ncol=3,
                               reverse = TRUE,
                               override.aes = list(shape = 15,
                                                   size = 4),
                               title.position="top")) +
  theme(legend.position="bottom",
          legend.text = element_text(margin = margin(r = 2, unit = "pt"),
                                     size = 10),
          legend.title = element_text(face="bold",
                                      size = 12),
          axis.ticks = element_blank(),
      axis.text.y = element_text(size=10),
          panel.grid.minor = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.3),
      panel.grid.major = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.3),
          plot.title = element_text(hjust = 0,
                                    size= 12),
          legend.box.margin = margin(t=0, b=0, l=-200, unit='pt')) +
  scale_y_continuous(expand = c(0.01, 0),
                   limits = c(0, 25000),
                       breaks = seq(0, 24000, by=4000)) +
  scale_x_discrete(expand = c(0.5, 0))
```

<img src="documentation/Fig11_diab_test_stacked_bar_plot.png"/>

**Diabetes medication**: Among all the patients, 19,228 (76.91%) had been prescribed a diabetes medication, while 13,497 (53.99%) had not changed diabetes medication.


```R
# Table for change
diab_ques_tbl <- readmissions %>% 
  select(change, diabetes_med) %>%
  rename("Was there a  \nchange in the \ndiabetes \nmedication?" = change, 
           "Was there a  \nprescribed \ndiabetes \nmedication?"= diabetes_med) %>%
  pivot_longer(cols = c(1:2), 
                 names_to = "diab_ques",
                 values_to = "response") %>%
  group_by(diab_ques, response) %>%
  summarize(n=n(), .groups="keep") %>%
  group_by(diab_ques) %>%
  mutate(perc=label_percent(accuracy = 0.01)(n/sum(n))) %>%
  arrange(diab_ques, desc(n)) %>%
  ungroup()

diab_ques_stacked_bar_plot <- ggplot(diab_ques_tbl) + 
  geom_chicklet(aes(x = fct_reorder(diab_ques, n), y = n,
                      fill = fct_reorder(response, n)),
                  color="white",
                  alpha=0.95,
                  radius = grid::unit(0.75, "mm"),
                  position="stack") +
  coord_flip() +	
    scale_fill_manual(values = c("#EE6C4D", "#98C1D9"),
                      labels = c("No", "Yes")
                     ) +
  ggtitle("Fig. 12: Stacked Bar Graph of the Patient's Response to Questions Related to\n             Diabetes Medication\n") +
  labs(x="Question\n", y="\nNumber of patients", fill="Response:  ") +
  theme_economist() + 
  scale_color_economist() + 
    guides(fill = guide_legend(ncol=2,
                               reverse = TRUE,
                               override.aes = list(shape = 15,
                                                   size = 4),
                               title.position="top")) +
  theme(legend.position="bottom",
          legend.text = element_text(margin = margin(r = 2, unit = "pt"),
                                     size = 10),
          legend.title = element_text(face="bold",
                                      size = 12),
          axis.ticks = element_blank(),
      axis.text.y = element_text(size=9.5),
          panel.grid.minor = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.3),
      panel.grid.major = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.3),
          plot.title = element_text(hjust = 0,
                                    size= 10),
          legend.box.margin = margin(t=0, b=0, l=-290, unit='pt')) +
  scale_y_continuous(expand = c(0.01, 0),
                   limits = c(),
                       breaks = seq(0, 25000, by=3000)) +
  scale_x_discrete(expand = c(0.5, 0))

diab_ques_tbl
```


<table class="dataframe">
<caption>A tibble: 4 × 4</caption>
<thead>
  <tr><th scope=col>diab_ques</th><th scope=col>response</th><th scope=col>n</th><th scope=col>perc</th></tr>
  <tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;fct&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;chr&gt;</th></tr>
</thead>
<tbody>
  <tr><td>Was there a  
change in the 
diabetes 
medication?</td><td>no </td><td>13497</td><td>53.99%</td></tr>
  <tr><td>Was there a  
change in the 
diabetes 
medication?</td><td>yes</td><td>11503</td><td>46.01%</td></tr>
  <tr><td>Was there a  
prescribed 
diabetes 
medication?   </td><td>yes</td><td>19228</td><td>76.91%</td></tr>
  <tr><td>Was there a  
prescribed 
diabetes 
medication?   </td><td>no </td><td> 5772</td><td>23.09%</td></tr>
</tbody>
</table>



<img src="documentation/Fig12_diab_ques_stacked_bar_plot.png"/>


```R
# Table for change in diabetes medication
change_tbl <- readmissions %>%
  count(change, sort = TRUE) %>%
  mutate(proportion = n/sum(n),
           #Attribute = "change in the diabetes medication",
           Percentage = label_percent(accuracy=0.01)(proportion),
           lab.ypos = cumsum(proportion) - 0.6*proportion)

# Create a pie chart
change_pie_chart <- ggplot(change_tbl, aes(x = "", y = proportion, fill = change)) +
    geom_bar(width=1,
             stat = "identity",
             color = "white",
             linewidth=0.4) +
    coord_polar("y", start = 0, direction = -1) +
    geom_text(aes(y = lab.ypos, 
                  label = paste(label_percent(accuracy=0.01)(proportion),
                                "\n (", prettyNum(n,
                                                  big.mark=","),")",
                                sep="")), color = "grey5",  size = 5) +
    scale_fill_manual(values = c("#EE6C4D", "#98C1D9"),
                      labels = c("No", "Yes")
                     ) +
  ggtitle("Fig. 13: Pie Chart of Patient Distribution in Terms of the Change \nin Diabetes Medication") +
  labs(x="", y="",
         fill="Was there a change in the patient's diabetes medication?") +
  scale_x_discrete(expand = c(0.01, 0)) + 
  theme_economist() + 
  scale_color_economist() +
  theme(legend.position="bottom",
          legend.text = element_text(margin = margin(r = 2, unit = "pt"),
                                     size=10),
          legend.title = element_text(face="bold",
                                      size = 11),
          axis.title = element_blank(),
          axis.text = element_blank(),
          axis.line = element_blank(),
          axis.ticks = element_blank(),
          panel.grid.minor = element_blank(),
      panel.grid.major = element_blank(),
          plot.background = element_rect(fill = "#D5E4EB"),
          plot.title = element_text(vjust=7,
                                    hjust=0.5,
                                    size=14,
                                    margin = margin(0,0,-30,0)),
          plot.margin = unit(c(1.5,2,0.5,2), "cm"),
          legend.box.margin = margin(t=-30, b=32, l=0, unit='pt')
         ) +
    guides(fill = guide_legend(reverse=TRUE,
                               override.aes = list(shape = 15,
                                                   size = 6),
                               title.position="top"))
```

<img src="documentation/Fig13_change_pie_chart.png"/>

**Readmission**: A slightly higher number of patients were not readmitted to the hospital compared to those who were readmitted. The blue bar represents the number of patients who were readmitted, which is 11,754 (47.02%), while the orange bar represents the number of patients who were not readmitted, which is 13,246 (52.98%)


```R
# Frequency Distribution Table (FDT) for the Readmission
readmitted_fdt <- readmissions %>%
  select(readmitted) %>%
  group_by(readmitted) %>%
  count() %>%
  ungroup() %>%
  mutate(perc = label_percent(accuracy=0.01)(n/sum(n))) %>%
  arrange(desc(n))

# Age
readmitted_bar_plot <- ggplot(readmitted_fdt) + 
  geom_chicklet(aes(x = fct_reorder(readmitted,n),
                      y = n), 
                   fill=c("#EE6C4D", "#98C1D9"),
                  color="white",
                  radius = grid::unit(1, "mm"), position="stack") +
  coord_flip() +
  ggtitle("Fig. 13: Bar Graph of the Patients' Readmission \n") +
  labs(y="\nNumber of patients", x="Readmitted\n") +
  theme_economist() + 
  scale_color_economist() + 
  theme(legend.position="bottom",
          legend.text = element_text(margin = margin(r = 2, unit = "pt"),
                                     size = 10),
          axis.ticks = element_blank(),
          legend.title = element_text(face="bold",
                                      size = 12),
          panel.grid.minor = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.3),
      panel.grid.major = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.3),
          plot.title = element_text(hjust = 0,
                                    size= 12),
          legend.box.margin = margin(t=0, b=0, l=-95, unit='pt'))  +
  scale_y_continuous(expand = c(0.01, 0),
                       limits = c(0, 14500),
                       breaks = seq(0, 14500, by=2000)) +
  scale_x_discrete(expand = c(0.52, 0),
           labels = c("Yes", "No"))
```


```R
readmitted_fdt
```


<table class="dataframe">
<caption>A tibble: 2 × 3</caption>
<thead>
  <tr><th scope=col>readmitted</th><th scope=col>n</th><th scope=col>perc</th></tr>
  <tr><th scope=col>&lt;fct&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;chr&gt;</th></tr>
</thead>
<tbody>
  <tr><td>no </td><td>13246</td><td>52.98%</td></tr>
  <tr><td>yes</td><td>11754</td><td>47.02%</td></tr>
</tbody>
</table>



<img src="documentation/Fig13_readmitted_bar_plot.png"/>

#### By Age
##### Numbers

The following statements can be said about the age groups' hospital stay through the comparisons of their seven (7) discrete numerical features. In general,

**Time in hospital**: Groups within the age of [60-100) had the most number of hospital days of about four.</br>
**Number of procedures**: Groups aged [40-80] had at least one medical procedure performed, whereas groups aged [80-100] had none; all age groups had a high number of laboratory procedures performed ranging from 43-46.</br>
**Number of medications**: The [60-70) group had the most number of medications of 17; as the patient moves one age group away from it, the number decreases by 1 or 2. </br>
**Number of visits**: Outpatient, inpatient, and emergency room visits were not very common (close to zero) before hospitalization for all age groups.
##### Categories
**Medical specialty**: We can see from Figure 14 graph the distribution of patients varies across different age groups and specialties. Among the patients with information about their physician's specialty, most, if not all, age groups seem to be admitted by a physician of Internal Medicine, while specialties categorized as 'Others' were second.


```R
# Summary statistics of age groups' time in hospital 
age_time_in_hospital_stats <- readmissions %>% 
  group_by(age) %>%
  filter(!is.na(age), !is.na(time_in_hospital)) %>%
  summarize(mean_time_in_hospital = mean(time_in_hospital),
              sd_time_in_hospital = sd(time_in_hospital),
              min_time_in_hospital = min(time_in_hospital),
              first_time_in_hospital = quantile(time_in_hospital, probs=0.25),
              median_time_in_hospital = median(time_in_hospital),
              third_quartile_time_in_hospital = quantile(time_in_hospital, probs=0.75),
              max_time_in_hospital = max(time_in_hospital)) %>%
  arrange(desc(median_time_in_hospital), desc(mean_time_in_hospital))

# Summary statistics of age groups' number of procedures
age_n_procedures_stats <- readmissions %>% 
  group_by(age) %>%
  filter(!is.na(age), !is.na(n_procedures)) %>%
  summarize(mean_n_procedures = mean(n_procedures),
              sd_n_procedures = sd(n_procedures),
              min_n_procedures = min(n_procedures),
              first_n_procedures = quantile(n_procedures, probs=0.25),
              median_n_procedures = median(n_procedures),
              third_n_procedures = quantile(n_procedures, probs=0.75),
              max_n_procedures = max(n_procedures)) %>%
  arrange(desc(median_n_procedures), desc(mean_n_procedures))

# Summary statistics of age groups' number of lab procedures
age_n_lab_procedures_stats <- readmissions %>% 
  group_by(age) %>%
  filter(!is.na(age), !is.na(n_lab_procedures)) %>%
  summarize(mean_n_lab_procedures = mean(n_lab_procedures),
              sd_n_lab_procedures = sd(n_lab_procedures),
              min_n_lab_procedures = min(n_lab_procedures),
              first_n_lab_procedures = quantile(n_lab_procedures, probs=0.25),
              median_n_lab_procedures = median(n_lab_procedures),
              third_n_lab_procedures = quantile(n_lab_procedures, probs=0.75),
              max_n_lab_procedures = max(n_lab_procedures))  %>%
  arrange(desc(median_n_lab_procedures), desc(mean_n_lab_procedures))

# Summary statistics of age groups' number of medications
age_n_medications_stats <- readmissions %>% 
  group_by(age) %>%
  filter(!is.na(age), !is.na(n_medications)) %>%
  summarize(mean_n_medications = mean(n_medications),
              sd_n_medications = sd(n_medications),
              min_n_medications = min(n_medications),
              first_n_medications = quantile(n_medications, probs=0.25),
              median_n_medications = median(n_medications),
              third_n_medications = quantile(n_medications, probs=0.75),
              max_n_medications = max(n_medications))  %>%
  arrange(desc(median_n_medications), desc(mean_n_medications))

# Summary statistics of age groups' number of outpatient visits
age_n_outpatient_stats <- readmissions %>% 
  group_by(age) %>%
  filter(!is.na(age), !is.na(n_outpatient)) %>%
  summarize(mean_n_outpatient = mean(n_outpatient),
              sd_n_outpatient = sd(n_outpatient),
              min_n_outpatient = min(n_outpatient),
              first_n_outpatient = quantile(n_outpatient, probs=0.25),
              median_n_outpatient = median(n_outpatient),
              third_n_outpatient = quantile(n_outpatient, probs=0.75),
              max_n_outpatient = max(n_outpatient))  %>%
  arrange(desc(median_n_outpatient), desc(mean_n_outpatient))

# Summary statistics of age groups' number of inpatient visits
age_n_inpatient_stats <- readmissions %>% 
  group_by(age) %>%
  filter(!is.na(age), !is.na(n_inpatient)) %>%
  summarize(mean_n_inpatient = mean(n_inpatient),
              sd_n_inpatient = sd(n_inpatient),
              min_n_inpatient = min(n_inpatient),
              first_n_inpatient = quantile(n_inpatient, probs=0.25),
              median_n_inpatient = median(n_inpatient),
              third_n_inpatient = quantile(n_inpatient, probs=0.75),
              max_n_inpatient = max(n_inpatient))  %>%
  arrange(desc(median_n_inpatient), desc(mean_n_inpatient))

# Summary statistics of age groups' number of ER visits
age_n_emergency_stats <- readmissions %>% 
  group_by(age) %>%
  filter(!is.na(age), !is.na(n_emergency)) %>%
  summarize(mean_n_emergency = mean(n_emergency),
              sd_n_emergency = sd(n_emergency),
              min_n_emergency = min(n_emergency),
              first_n_emergency = quantile(n_emergency, probs=0.25),
              median_n_emergency = median(n_emergency),
              third_n_emergency = quantile(n_emergency, probs=0.75),
              max_n_emergency = max(n_emergency))  %>%
  arrange(desc(median_n_emergency), desc(mean_n_emergency))


plyr::join_all(list(age_time_in_hospital_stats %>%
          select(age, median_time_in_hospital#, mean_time_in_hospital
            ),
         age_n_procedures_stats %>%
            select(age, median_n_procedures#, mean_n_procedures
            ),
         age_n_lab_procedures_stats %>%
          select(age, median_n_lab_procedures#, mean_n_lab_procedures
            ),
         age_n_medications_stats %>%
          select(age, median_n_medications#, mean_n_medications
            ),
         age_n_outpatient_stats %>%
          select(age, median_n_outpatient#, mean_n_outpatient
            ),
         age_n_inpatient_stats %>%
          select(age, median_n_inpatient#, mean_n_inpatient
            ),
         age_n_emergency_stats %>%
          select(age, median_n_emergency#, mean_n_emergency
            )),
  by='age') %>%
    arrange(desc(age))

plyr::join_all(list(age_time_in_hospital_stats %>%
          select(age, mean_time_in_hospital
            ),
         age_n_procedures_stats %>%
            select(age, mean_n_procedures
            ),
         age_n_lab_procedures_stats %>%
          select(age, mean_n_lab_procedures
            ),
         age_n_medications_stats %>%
          select(age, mean_n_medications
            ),
         age_n_outpatient_stats %>%
          select(age, mean_n_outpatient
            ),
         age_n_inpatient_stats %>%
          select(age, mean_n_inpatient
            ),
         age_n_emergency_stats %>%
          select(age, mean_n_emergency
            )),
  by='age') %>%
    arrange(desc(age))
```


<table class="dataframe">
<caption>A data.frame: 6 × 8</caption>
<thead>
  <tr><th scope=col>age</th><th scope=col>median_time_in_hospital</th><th scope=col>median_n_procedures</th><th scope=col>median_n_lab_procedures</th><th scope=col>median_n_medications</th><th scope=col>median_n_outpatient</th><th scope=col>median_n_inpatient</th><th scope=col>median_n_emergency</th></tr>
  <tr><th scope=col>&lt;fct&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th></tr>
</thead>
<tbody>
  <tr><td>[90-100)</td><td>4</td><td>0</td><td>45</td><td>13</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>[80-90) </td><td>4</td><td>0</td><td>46</td><td>14</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>[70-80) </td><td>4</td><td>1</td><td>45</td><td>15</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>[60-70) </td><td>4</td><td>1</td><td>44</td><td>16</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>[50-60) </td><td>3</td><td>1</td><td>43</td><td>15</td><td>0</td><td>0</td><td>0</td></tr>
  <tr><td>[40-50) </td><td>3</td><td>1</td><td>44</td><td>14</td><td>0</td><td>0</td><td>0</td></tr>
</tbody>
</table>




<table class="dataframe">
<caption>A data.frame: 6 × 8</caption>
<thead>
  <tr><th scope=col>age</th><th scope=col>mean_time_in_hospital</th><th scope=col>mean_n_procedures</th><th scope=col>mean_n_lab_procedures</th><th scope=col>mean_n_medications</th><th scope=col>mean_n_outpatient</th><th scope=col>mean_n_inpatient</th><th scope=col>mean_n_emergency</th></tr>
  <tr><th scope=col>&lt;fct&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th></tr>
</thead>
<tbody>
  <tr><td>[90-100)</td><td>4.762667</td><td>0.6853333</td><td>43.97467</td><td>13.87333</td><td>0.2613333</td><td>0.5573333</td><td>0.1386667</td></tr>
  <tr><td>[80-90) </td><td>4.813773</td><td>0.9694420</td><td>44.34965</td><td>15.29562</td><td>0.4007972</td><td>0.6045173</td><td>0.1472542</td></tr>
  <tr><td>[70-80) </td><td>4.599093</td><td>1.3760421</td><td>43.57920</td><td>16.36142</td><td>0.3965189</td><td>0.6011409</td><td>0.1351470</td></tr>
  <tr><td>[60-70) </td><td>4.384407</td><td>1.5996956</td><td>42.59716</td><td>17.22307</td><td>0.3757822</td><td>0.6074751</td><td>0.1603247</td></tr>
  <tr><td>[50-60) </td><td>4.154537</td><td>1.5188679</td><td>42.48967</td><td>16.69946</td><td>0.3270440</td><td>0.6118598</td><td>0.2295597</td></tr>
  <tr><td>[40-50) </td><td>4.011453</td><td>1.2985782</td><td>42.95537</td><td>15.31635</td><td>0.3021327</td><td>0.7207741</td><td>0.3957346</td></tr>
</tbody>
</table>




```R
# Specialty of admitting physician by age group
age_and_medical_specialty_counts <- readmissions %>%
  group_by(age, medical_specialty) %>%
  summarize(n = n(), .groups = "drop_last") %>%
  mutate(perc = label_percent(accuracy=0.01)(n/sum(n))) %>% 
  arrange(age, desc(n)) %>%
  ungroup()

# Colorize the Physician's Specialty
color_scheme <- iwanthue(seed=1234, force_init=TRUE)
medical_specialty_colors <- color_scheme$hex(length(levels(factor(age_and_medical_specialty_counts$medical_specialty))))

# Bar plot
age_medical_specialty_bar_plot <- ggplot(age_and_medical_specialty_counts %>%
                      filter(!is.na(medical_specialty))) + 
  geom_chicklet(aes(x = age, y = n,
                      fill = fct_reorder(medical_specialty, n)), 
                  color="white",
                  radius = grid::unit(1, "mm"), position="stack") +
  ggtitle("Fig. 14: Stacked Bar Graph of the Patients' Age Groups by the\n                                  Specialty of the Admitting Physician\n") +
  labs(x="\nDiagnosis", y="Number of patients\n", fill="Specialty of the Admitting Physician: ") +
  scale_x_discrete(expand = c(0.01, 0)) + 
  theme_economist() + 
  scale_color_economist() + 
    guides(fill = guide_legend(ncol=4,nrow=2,
                               reverse = FALSE,
                               override.aes = list(shape = 15,
                                                   size = 4),
                               title.position="top")) +
  theme(legend.position="bottom",
          legend.text = element_text(margin = margin(r = 2, unit = "pt"),
                                     size = 10),
          legend.title = element_text(face="bold",
                                      size = 12),
          axis.ticks = element_blank(),          
          panel.grid.minor = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.3),
      panel.grid.major = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.3),
          plot.title = element_text(hjust = -0.9,
                                    size= 14),
          legend.box.margin = margin(t=0, b=0, l=-78, unit='pt')) +
  scale_y_continuous(expand = c(0.01, 0),
                       breaks = seq(0, 3500, by=500)) + 
  scale_fill_manual(values = medical_specialty_colors)
```


```R
age_and_medical_specialty_counts
```


<table class="dataframe">
<caption>A tibble: 42 × 4</caption>
<thead>
  <tr><th scope=col>age</th><th scope=col>medical_specialty</th><th scope=col>n</th><th scope=col>perc</th></tr>
  <tr><th scope=col>&lt;fct&gt;</th><th scope=col>&lt;fct&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;chr&gt;</th></tr>
</thead>
<tbody>
  <tr><td>[40-50) </td><td>NA                    </td><td>1186</td><td>46.84%</td></tr>
  <tr><td>[40-50) </td><td>InternalMedicine      </td><td> 352</td><td>13.90%</td></tr>
  <tr><td>[40-50) </td><td>Other                 </td><td> 322</td><td>12.72%</td></tr>
  <tr><td>[40-50) </td><td>Family/GeneralPractice</td><td> 234</td><td>9.24% </td></tr>
  <tr><td>[40-50) </td><td>Emergency/Trauma      </td><td> 208</td><td>8.21% </td></tr>
  <tr><td>[40-50) </td><td>Surgery               </td><td> 116</td><td>4.58% </td></tr>
  <tr><td>[40-50) </td><td>Cardiology            </td><td> 114</td><td>4.50% </td></tr>
  <tr><td>[50-60) </td><td>NA                    </td><td>2123</td><td>47.69%</td></tr>
  <tr><td>[50-60) </td><td>InternalMedicine      </td><td> 608</td><td>13.66%</td></tr>
  <tr><td>[50-60) </td><td>Other                 </td><td> 546</td><td>12.26%</td></tr>
  <tr><td>[50-60) </td><td>Family/GeneralPractice</td><td> 336</td><td>7.55% </td></tr>
  <tr><td>[50-60) </td><td>Emergency/Trauma      </td><td> 304</td><td>6.83% </td></tr>
  <tr><td>[50-60) </td><td>Cardiology            </td><td> 290</td><td>6.51% </td></tr>
  <tr><td>[50-60) </td><td>Surgery               </td><td> 245</td><td>5.50% </td></tr>
  <tr><td>[60-70) </td><td>NA                    </td><td>2978</td><td>50.36%</td></tr>
  <tr><td>[60-70) </td><td>Other                 </td><td> 714</td><td>12.08%</td></tr>
  <tr><td>[60-70) </td><td>InternalMedicine      </td><td> 706</td><td>11.94%</td></tr>
  <tr><td>[60-70) </td><td>Family/GeneralPractice</td><td> 396</td><td>6.70% </td></tr>
  <tr><td>[60-70) </td><td>Emergency/Trauma      </td><td> 390</td><td>6.60% </td></tr>
  <tr><td>[60-70) </td><td>Cardiology            </td><td> 383</td><td>6.48% </td></tr>
  <tr><td>[60-70) </td><td>Surgery               </td><td> 346</td><td>5.85% </td></tr>
  <tr><td>[70-80) </td><td>NA                    </td><td>3363</td><td>49.19%</td></tr>
  <tr><td>[70-80) </td><td>InternalMedicine      </td><td>1055</td><td>15.43%</td></tr>
  <tr><td>[70-80) </td><td>Other                 </td><td> 725</td><td>10.60%</td></tr>
  <tr><td>[70-80) </td><td>Family/GeneralPractice</td><td> 495</td><td>7.24% </td></tr>
  <tr><td>[70-80) </td><td>Emergency/Trauma      </td><td> 462</td><td>6.76% </td></tr>
  <tr><td>[70-80) </td><td>Cardiology            </td><td> 412</td><td>6.03% </td></tr>
  <tr><td>[70-80) </td><td>Surgery               </td><td> 325</td><td>4.75% </td></tr>
  <tr><td>[80-90) </td><td>NA                    </td><td>2360</td><td>52.26%</td></tr>
  <tr><td>[80-90) </td><td>InternalMedicine      </td><td> 705</td><td>15.61%</td></tr>
  <tr><td>[80-90) </td><td>Emergency/Trauma      </td><td> 430</td><td>9.52% </td></tr>
  <tr><td>[80-90) </td><td>Family/GeneralPractice</td><td> 349</td><td>7.73% </td></tr>
  <tr><td>[80-90) </td><td>Other                 </td><td> 319</td><td>7.06% </td></tr>
  <tr><td>[80-90) </td><td>Cardiology            </td><td> 198</td><td>4.38% </td></tr>
  <tr><td>[80-90) </td><td>Surgery               </td><td> 155</td><td>3.43% </td></tr>
  <tr><td>[90-100)</td><td>NA                    </td><td> 372</td><td>49.60%</td></tr>
  <tr><td>[90-100)</td><td>InternalMedicine      </td><td> 139</td><td>18.53%</td></tr>
  <tr><td>[90-100)</td><td>Emergency/Trauma      </td><td>  91</td><td>12.13%</td></tr>
  <tr><td>[90-100)</td><td>Family/GeneralPractice</td><td>  72</td><td>9.60% </td></tr>
  <tr><td>[90-100)</td><td>Other                 </td><td>  38</td><td>5.07% </td></tr>
  <tr><td>[90-100)</td><td>Surgery               </td><td>  26</td><td>3.47% </td></tr>
  <tr><td>[90-100)</td><td>Cardiology            </td><td>  12</td><td>1.60% </td></tr>
</tbody>
</table>



<img src="documentation/Fig14_age_medical_specialty_bar_plot.png"/>

**Diagnoses**: Figures 15-16 demonstrates the patient distribution across age groups and primary, secondary, and additional secondary diagnoses. Diagnoses other than the six listed were given to patients in most, if not all, age groups among these three types of diagnosis.


```R
# Primary diagnosis by age group
age_and_diag_1_counts <- readmissions %>%
  group_by(age, diag_1) %>%
  summarize(n = n(), .groups = "drop_last") %>%
  mutate(perc = label_percent(accuracy=0.01)(n/sum(n))) %>% 
  arrange(age, desc(n)) %>%
  ungroup()

# Colorize
color_scheme <- iwanthue(seed=1234, force_init=TRUE)
diag_1_colors <- color_scheme$hex(length(levels(factor(age_and_diag_1_counts$diag_1,
                                                      levels = c('Circulatory', 
                                                                 'Diabetes',
                                                                 'Digestive',
                                                                 'Injury',
                                                                 'Musculoskeletal',
                                                                 'Respiratory',
                                                                 'Other'),
                                                       order = TRUE))))

# Bar plot
age_diag_bar_plot <- ggplot(age_and_diag_1_counts %>%
                filter(!is.na(diag_1))) + 
  geom_chicklet(aes(x = age, y = n,
                      fill = fct_reorder(diag_1,n)), 
                  radius = grid::unit(1, "mm"), position="stack") +
  ggtitle("Fig. 15: Stacked Bar Graph of the Patients' Age Groups by Primary Diagnoses\n") +
  labs(x="", y="Number of patients\n", fill="Diagnosis: ") +
  scale_x_discrete(expand = c(0.01, 0)) + 
  theme_economist() + 
  scale_color_economist() + 
    guides(fill = guide_legend(ncol=4,nrow=2,
                               reverse = FALSE,
                               override.aes = list(shape = 15,
                                                   size = 4),
                               title.position="top")) +
  theme(legend.position="none",
          legend.text = element_text(margin = margin(r = 2, unit = "pt"),
                                     size = 10),
          legend.title = element_text(face="bold",
                                      size = 12),
          axis.ticks = element_blank(),        
          axis.title.x=element_blank(),
          axis.text.x=element_blank(),
          panel.grid.minor = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.3),
      panel.grid.major = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.3),
          plot.title = element_text(hjust = 0,
                                    size= 11),
          legend.box.margin = margin(t=0, b=0, l=-95, unit='pt')
         ) +
  scale_y_continuous(expand = c(0.01, 0),
                       breaks = seq(0, 7500, by=2000)) +
  scale_fill_manual(values = diag_1_colors)

# Secondary diagnosis by age group
age_and_diag_2_counts <- readmissions %>%
  group_by(age, diag_2) %>%
  summarize(n = n(), .groups = "drop_last") %>%
  mutate(perc = label_percent(accuracy=0.01)(n/sum(n))) %>% 
  arrange(age, desc(n)) %>%
  ungroup()

# Colorize
color_scheme2 <- iwanthue(seed=1234, force_init=TRUE)
diag_2_colors <- color_scheme2$hex(length(levels(factor(age_and_diag_2_counts$diag_2,
                                                      levels = c('Circulatory', 
                                                                 'Diabetes',
                                                                 'Digestive',
                                                                 'Injury',
                                                                 'Musculoskeletal',
                                                                 'Respiratory',
                                                                 'Other'),
                                                       order = TRUE))))

# Bar plot
age_diag_2_bar_plot <- ggplot(age_and_diag_2_counts %>%
                filter(!is.na(diag_2))) + 
  geom_chicklet(aes(x = age, y = n,
                      fill = fct_reorder(diag_2,n)), 
                  radius = grid::unit(1, "mm"), position="stack") +
  ggtitle("Fig. 16: Stacked Bar Graph of the Patients' Age Groups by Secondary Diagnoses\n") +
  labs(x="", y="Number of patients\n", fill="Secondary Diagnosis: ") +
  scale_x_discrete(expand = c(0.01, 0)) + 
  theme_economist() + 
  scale_color_economist() + 
    guides(fill = guide_legend(ncol=4,nrow=2,
                               reverse = FALSE,
                               override.aes = list(shape = 15,
                                                   size = 4),
                               title.position="top")) +
  theme(legend.position="none",
          legend.text = element_text(margin = margin(r = 2, unit = "pt"),
                                     size = 10),
          legend.title = element_text(face="bold",
                                      size = 12),
          axis.ticks = element_blank(),     
          axis.title.x=element_blank(),
          axis.text.x=element_blank(),
          panel.grid.minor = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.3),
      panel.grid.major = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.3),
          plot.title = element_text(hjust = 0,
                                    size= 11),
          legend.box.margin = margin(t=0, b=-100, l=-100, unit='pt')
         ) +
  scale_y_continuous(expand = c(0.01, 0),
                       breaks = seq(0, 7500, by=2000)) +
  scale_fill_manual(values = diag_1_colors)


# Additional Secondary diagnosis by age group
age_and_diag_3_counts <- readmissions %>%
  group_by(age, diag_3) %>%
  summarize(n = n(), .groups = "drop_last") %>%
  mutate(perc = label_percent(accuracy=0.01)(n/sum(n))) %>% 
  arrange(age, desc(n)) %>%
  ungroup()

# Colorize
color_scheme <- iwanthue(seed=1234, force_init=TRUE)
diag_3_colors <- color_scheme$hex(length(levels(factor(age_and_diag_3_counts$diag_3,
                                                      levels = c('Circulatory', 
                                                                 'Diabetes',
                                                                 'Digestive',
                                                                 'Injury',
                                                                 'Musculoskeletal',
                                                                 'Respiratory',
                                                                 'Other'),
                                                       order = TRUE))))

# Bar plot
age_diag_3_bar_plot <- ggplot(age_and_diag_3_counts %>%
                filter(!is.na(diag_3))) + 
  geom_chicklet(aes(x = age, y = n,
                      fill = fct_reorder(diag_3,n)),  
                  radius = grid::unit(1, "mm"), position="stack") +
  ggtitle("Fig. 17: Stacked Bar Graph of the Patients' Age Groups by Additional Secondary Diagnoses\n") +
  labs(x="\nAge group", y="Number of patients\n", fill="Diagnosis: ") +
  scale_x_discrete(expand = c(0.01, 0)) + 
  theme_economist() + 
  scale_color_economist() + 
    guides(fill = guide_legend(ncol=4,nrow=2,
                               reverse = FALSE,
                               override.aes = list(shape = 15,
                                                   size = 4),
                               title.position="top")) +
  theme(legend.position="bottom",
          legend.text = element_text(margin = margin(r = 2, unit = "pt"),
                                     size = 10),
          legend.title = element_text(face="bold",
                                      size = 12),
          axis.ticks = element_blank(), 
          panel.grid.minor = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.3),
      panel.grid.major = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.3),
          plot.title = element_text(hjust = 0,
                                    size= 10),
          legend.box.margin = margin(t=0, b=0, l=-110, unit='pt')
         ) +
  scale_y_continuous(expand = c(0.01, 0),
                       breaks = seq(0, 7500, by=2000)) +
  scale_fill_manual(values = diag_3_colors)

#ggarrange(age_diag_bar_plot, 
#          age_diag_2_bar_plot,
#          age_diag_3_bar_plot,
#          ncol = 1, nrow = 3,
#          heights = c(0.9,0.9,1.65),
#          align = "v")
```


```R
age_and_diag_1_counts
age_and_diag_2_counts
age_and_diag_3_counts
```


<table class="dataframe">
<caption>A tibble: 45 × 4</caption>
<thead>
  <tr><th scope=col>age</th><th scope=col>diag_1</th><th scope=col>n</th><th scope=col>perc</th></tr>
  <tr><th scope=col>&lt;fct&gt;</th><th scope=col>&lt;fct&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;chr&gt;</th></tr>
</thead>
<tbody>
  <tr><td>[40-50) </td><td>Other          </td><td> 750</td><td>29.62%</td></tr>
  <tr><td>[40-50) </td><td>Circulatory    </td><td> 504</td><td>19.91%</td></tr>
  <tr><td>[40-50) </td><td>Respiratory    </td><td> 376</td><td>14.85%</td></tr>
  <tr><td>[40-50) </td><td>Diabetes       </td><td> 369</td><td>14.57%</td></tr>
  <tr><td>[40-50) </td><td>Digestive      </td><td> 271</td><td>10.70%</td></tr>
  <tr><td>[40-50) </td><td>Injury         </td><td> 162</td><td>6.40% </td></tr>
  <tr><td>[40-50) </td><td>Musculoskeletal</td><td> 100</td><td>3.95% </td></tr>
  <tr><td>[50-60) </td><td>Circulatory    </td><td>1256</td><td>28.21%</td></tr>
  <tr><td>[50-60) </td><td>Other          </td><td>1164</td><td>26.15%</td></tr>
  <tr><td>[50-60) </td><td>Respiratory    </td><td> 694</td><td>15.59%</td></tr>
  <tr><td>[50-60) </td><td>Digestive      </td><td> 442</td><td>9.93% </td></tr>
  <tr><td>[50-60) </td><td>Diabetes       </td><td> 393</td><td>8.83% </td></tr>
  <tr><td>[50-60) </td><td>Injury         </td><td> 273</td><td>6.13% </td></tr>
  <tr><td>[50-60) </td><td>Musculoskeletal</td><td> 230</td><td>5.17% </td></tr>
  <tr><td>[60-70) </td><td>Circulatory    </td><td>1962</td><td>33.18%</td></tr>
  <tr><td>[60-70) </td><td>Other          </td><td>1402</td><td>23.71%</td></tr>
  <tr><td>[60-70) </td><td>Respiratory    </td><td> 836</td><td>14.14%</td></tr>
  <tr><td>[60-70) </td><td>Digestive      </td><td> 554</td><td>9.37% </td></tr>
  <tr><td>[60-70) </td><td>Injury         </td><td> 400</td><td>6.76% </td></tr>
  <tr><td>[60-70) </td><td>Diabetes       </td><td> 385</td><td>6.51% </td></tr>
  <tr><td>[60-70) </td><td>Musculoskeletal</td><td> 373</td><td>6.31% </td></tr>
  <tr><td>[60-70) </td><td>NA             </td><td>   1</td><td>0.02% </td></tr>
  <tr><td>[70-80) </td><td>Circulatory    </td><td>2392</td><td>34.99%</td></tr>
  <tr><td>[70-80) </td><td>Other          </td><td>1693</td><td>24.76%</td></tr>
  <tr><td>[70-80) </td><td>Respiratory    </td><td> 964</td><td>14.10%</td></tr>
  <tr><td>[70-80) </td><td>Digestive      </td><td> 585</td><td>8.56% </td></tr>
  <tr><td>[70-80) </td><td>Injury         </td><td> 444</td><td>6.49% </td></tr>
  <tr><td>[70-80) </td><td>Diabetes       </td><td> 385</td><td>5.63% </td></tr>
  <tr><td>[70-80) </td><td>Musculoskeletal</td><td> 373</td><td>5.46% </td></tr>
  <tr><td>[70-80) </td><td>NA             </td><td>   1</td><td>0.01% </td></tr>
  <tr><td>[80-90) </td><td>Circulatory    </td><td>1482</td><td>32.82%</td></tr>
  <tr><td>[80-90) </td><td>Other          </td><td>1269</td><td>28.10%</td></tr>
  <tr><td>[80-90) </td><td>Respiratory    </td><td> 691</td><td>15.30%</td></tr>
  <tr><td>[80-90) </td><td>Digestive      </td><td> 402</td><td>8.90% </td></tr>
  <tr><td>[80-90) </td><td>Injury         </td><td> 321</td><td>7.11% </td></tr>
  <tr><td>[80-90) </td><td>Diabetes       </td><td> 181</td><td>4.01% </td></tr>
  <tr><td>[80-90) </td><td>Musculoskeletal</td><td> 168</td><td>3.72% </td></tr>
  <tr><td>[80-90) </td><td>NA             </td><td>   2</td><td>0.04% </td></tr>
  <tr><td>[90-100)</td><td>Circulatory    </td><td> 228</td><td>30.40%</td></tr>
  <tr><td>[90-100)</td><td>Other          </td><td> 220</td><td>29.33%</td></tr>
  <tr><td>[90-100)</td><td>Respiratory    </td><td> 119</td><td>15.87%</td></tr>
  <tr><td>[90-100)</td><td>Digestive      </td><td>  75</td><td>10.00%</td></tr>
  <tr><td>[90-100)</td><td>Injury         </td><td>  66</td><td>8.80% </td></tr>
  <tr><td>[90-100)</td><td>Diabetes       </td><td>  34</td><td>4.53% </td></tr>
  <tr><td>[90-100)</td><td>Musculoskeletal</td><td>   8</td><td>1.07% </td></tr>
</tbody>
</table>




<table class="dataframe">
<caption>A tibble: 47 × 4</caption>
<thead>
  <tr><th scope=col>age</th><th scope=col>diag_2</th><th scope=col>n</th><th scope=col>perc</th></tr>
  <tr><th scope=col>&lt;fct&gt;</th><th scope=col>&lt;fct&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;chr&gt;</th></tr>
</thead>
<tbody>
  <tr><td>[40-50) </td><td>Other          </td><td>1097</td><td>43.33%</td></tr>
  <tr><td>[40-50) </td><td>Circulatory    </td><td> 526</td><td>20.77%</td></tr>
  <tr><td>[40-50) </td><td>Diabetes       </td><td> 462</td><td>18.25%</td></tr>
  <tr><td>[40-50) </td><td>Respiratory    </td><td> 181</td><td>7.15% </td></tr>
  <tr><td>[40-50) </td><td>Digestive      </td><td> 129</td><td>5.09% </td></tr>
  <tr><td>[40-50) </td><td>Injury         </td><td>  77</td><td>3.04% </td></tr>
  <tr><td>[40-50) </td><td>Musculoskeletal</td><td>  53</td><td>2.09% </td></tr>
  <tr><td>[40-50) </td><td>NA             </td><td>   7</td><td>0.28% </td></tr>
  <tr><td>[50-60) </td><td>Other          </td><td>1587</td><td>35.65%</td></tr>
  <tr><td>[50-60) </td><td>Circulatory    </td><td>1266</td><td>28.44%</td></tr>
  <tr><td>[50-60) </td><td>Diabetes       </td><td> 705</td><td>15.84%</td></tr>
  <tr><td>[50-60) </td><td>Respiratory    </td><td> 477</td><td>10.71%</td></tr>
  <tr><td>[50-60) </td><td>Digestive      </td><td> 210</td><td>4.72% </td></tr>
  <tr><td>[50-60) </td><td>Musculoskeletal</td><td> 102</td><td>2.29% </td></tr>
  <tr><td>[50-60) </td><td>Injury         </td><td> 100</td><td>2.25% </td></tr>
  <tr><td>[50-60) </td><td>NA             </td><td>   5</td><td>0.11% </td></tr>
  <tr><td>[60-70) </td><td>Other          </td><td>2036</td><td>34.43%</td></tr>
  <tr><td>[60-70) </td><td>Circulatory    </td><td>1965</td><td>33.23%</td></tr>
  <tr><td>[60-70) </td><td>Respiratory    </td><td> 717</td><td>12.13%</td></tr>
  <tr><td>[60-70) </td><td>Diabetes       </td><td> 687</td><td>11.62%</td></tr>
  <tr><td>[60-70) </td><td>Digestive      </td><td> 252</td><td>4.26% </td></tr>
  <tr><td>[60-70) </td><td>Injury         </td><td> 140</td><td>2.37% </td></tr>
  <tr><td>[60-70) </td><td>Musculoskeletal</td><td> 107</td><td>1.81% </td></tr>
  <tr><td>[60-70) </td><td>NA             </td><td>   9</td><td>0.15% </td></tr>
  <tr><td>[70-80) </td><td>Circulatory    </td><td>2483</td><td>36.32%</td></tr>
  <tr><td>[70-80) </td><td>Other          </td><td>2339</td><td>34.21%</td></tr>
  <tr><td>[70-80) </td><td>Respiratory    </td><td> 840</td><td>12.29%</td></tr>
  <tr><td>[70-80) </td><td>Diabetes       </td><td> 675</td><td>9.87% </td></tr>
  <tr><td>[70-80) </td><td>Digestive      </td><td> 227</td><td>3.32% </td></tr>
  <tr><td>[70-80) </td><td>Injury         </td><td> 162</td><td>2.37% </td></tr>
  <tr><td>[70-80) </td><td>Musculoskeletal</td><td> 103</td><td>1.51% </td></tr>
  <tr><td>[70-80) </td><td>NA             </td><td>   8</td><td>0.12% </td></tr>
  <tr><td>[80-90) </td><td>Other          </td><td>1691</td><td>37.44%</td></tr>
  <tr><td>[80-90) </td><td>Circulatory    </td><td>1613</td><td>35.72%</td></tr>
  <tr><td>[80-90) </td><td>Respiratory    </td><td> 575</td><td>12.73%</td></tr>
  <tr><td>[80-90) </td><td>Diabetes       </td><td> 330</td><td>7.31% </td></tr>
  <tr><td>[80-90) </td><td>Digestive      </td><td> 136</td><td>3.01% </td></tr>
  <tr><td>[80-90) </td><td>Injury         </td><td> 102</td><td>2.26% </td></tr>
  <tr><td>[80-90) </td><td>Musculoskeletal</td><td>  56</td><td>1.24% </td></tr>
  <tr><td>[80-90) </td><td>NA             </td><td>  13</td><td>0.29% </td></tr>
  <tr><td>[90-100)</td><td>Other          </td><td> 306</td><td>40.80%</td></tr>
  <tr><td>[90-100)</td><td>Circulatory    </td><td> 281</td><td>37.47%</td></tr>
  <tr><td>[90-100)</td><td>Respiratory    </td><td>  82</td><td>10.93%</td></tr>
  <tr><td>[90-100)</td><td>Diabetes       </td><td>  47</td><td>6.27% </td></tr>
  <tr><td>[90-100)</td><td>Digestive      </td><td>  19</td><td>2.53% </td></tr>
  <tr><td>[90-100)</td><td>Injury         </td><td>  10</td><td>1.33% </td></tr>
  <tr><td>[90-100)</td><td>Musculoskeletal</td><td>   5</td><td>0.67% </td></tr>
</tbody>
</table>




<table class="dataframe">
<caption>A tibble: 48 × 4</caption>
<thead>
  <tr><th scope=col>age</th><th scope=col>diag_3</th><th scope=col>n</th><th scope=col>perc</th></tr>
  <tr><th scope=col>&lt;fct&gt;</th><th scope=col>&lt;fct&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;chr&gt;</th></tr>
</thead>
<tbody>
  <tr><td>[40-50) </td><td>Other          </td><td>1084</td><td>42.81%</td></tr>
  <tr><td>[40-50) </td><td>Diabetes       </td><td> 528</td><td>20.85%</td></tr>
  <tr><td>[40-50) </td><td>Circulatory    </td><td> 520</td><td>20.54%</td></tr>
  <tr><td>[40-50) </td><td>Respiratory    </td><td> 135</td><td>5.33% </td></tr>
  <tr><td>[40-50) </td><td>Digestive      </td><td> 129</td><td>5.09% </td></tr>
  <tr><td>[40-50) </td><td>Injury         </td><td>  53</td><td>2.09% </td></tr>
  <tr><td>[40-50) </td><td>NA             </td><td>  49</td><td>1.94% </td></tr>
  <tr><td>[40-50) </td><td>Musculoskeletal</td><td>  34</td><td>1.34% </td></tr>
  <tr><td>[50-60) </td><td>Other          </td><td>1635</td><td>36.73%</td></tr>
  <tr><td>[50-60) </td><td>Circulatory    </td><td>1229</td><td>27.61%</td></tr>
  <tr><td>[50-60) </td><td>Diabetes       </td><td> 875</td><td>19.65%</td></tr>
  <tr><td>[50-60) </td><td>Respiratory    </td><td> 290</td><td>6.51% </td></tr>
  <tr><td>[50-60) </td><td>Digestive      </td><td> 200</td><td>4.49% </td></tr>
  <tr><td>[50-60) </td><td>Musculoskeletal</td><td> 101</td><td>2.27% </td></tr>
  <tr><td>[50-60) </td><td>Injury         </td><td>  74</td><td>1.66% </td></tr>
  <tr><td>[50-60) </td><td>NA             </td><td>  48</td><td>1.08% </td></tr>
  <tr><td>[60-70) </td><td>Other          </td><td>2068</td><td>34.97%</td></tr>
  <tr><td>[60-70) </td><td>Circulatory    </td><td>1839</td><td>31.10%</td></tr>
  <tr><td>[60-70) </td><td>Diabetes       </td><td>1042</td><td>17.62%</td></tr>
  <tr><td>[60-70) </td><td>Respiratory    </td><td> 470</td><td>7.95% </td></tr>
  <tr><td>[60-70) </td><td>Digestive      </td><td> 214</td><td>3.62% </td></tr>
  <tr><td>[60-70) </td><td>Injury         </td><td> 125</td><td>2.11% </td></tr>
  <tr><td>[60-70) </td><td>Musculoskeletal</td><td> 114</td><td>1.93% </td></tr>
  <tr><td>[60-70) </td><td>NA             </td><td>  41</td><td>0.69% </td></tr>
  <tr><td>[70-80) </td><td>Other          </td><td>2383</td><td>34.85%</td></tr>
  <tr><td>[70-80) </td><td>Circulatory    </td><td>2292</td><td>33.52%</td></tr>
  <tr><td>[70-80) </td><td>Diabetes       </td><td>1082</td><td>15.83%</td></tr>
  <tr><td>[70-80) </td><td>Respiratory    </td><td> 558</td><td>8.16% </td></tr>
  <tr><td>[70-80) </td><td>Digestive      </td><td> 235</td><td>3.44% </td></tr>
  <tr><td>[70-80) </td><td>Musculoskeletal</td><td> 130</td><td>1.90% </td></tr>
  <tr><td>[70-80) </td><td>Injury         </td><td> 124</td><td>1.81% </td></tr>
  <tr><td>[70-80) </td><td>NA             </td><td>  33</td><td>0.48% </td></tr>
  <tr><td>[80-90) </td><td>Other          </td><td>1645</td><td>36.43%</td></tr>
  <tr><td>[80-90) </td><td>Circulatory    </td><td>1542</td><td>34.15%</td></tr>
  <tr><td>[80-90) </td><td>Diabetes       </td><td> 633</td><td>14.02%</td></tr>
  <tr><td>[80-90) </td><td>Respiratory    </td><td> 404</td><td>8.95% </td></tr>
  <tr><td>[80-90) </td><td>Digestive      </td><td> 122</td><td>2.70% </td></tr>
  <tr><td>[80-90) </td><td>Injury         </td><td>  80</td><td>1.77% </td></tr>
  <tr><td>[80-90) </td><td>Musculoskeletal</td><td>  67</td><td>1.48% </td></tr>
  <tr><td>[80-90) </td><td>NA             </td><td>  23</td><td>0.51% </td></tr>
  <tr><td>[90-100)</td><td>Other          </td><td> 292</td><td>38.93%</td></tr>
  <tr><td>[90-100)</td><td>Circulatory    </td><td> 264</td><td>35.20%</td></tr>
  <tr><td>[90-100)</td><td>Diabetes       </td><td> 101</td><td>13.47%</td></tr>
  <tr><td>[90-100)</td><td>Respiratory    </td><td>  58</td><td>7.73% </td></tr>
  <tr><td>[90-100)</td><td>Digestive      </td><td>  16</td><td>2.13% </td></tr>
  <tr><td>[90-100)</td><td>Musculoskeletal</td><td>   9</td><td>1.20% </td></tr>
  <tr><td>[90-100)</td><td>Injury         </td><td>   8</td><td>1.07% </td></tr>
  <tr><td>[90-100)</td><td>NA             </td><td>   2</td><td>0.27% </td></tr>
</tbody>
</table>



<img src="documentation/Fig15-17_age_diag_bar_plot.png"/>

**Prediabetes test results**: For patients who took a glucose test, the distributions of 'Normal' and 'High' results appear to be similar across age groups, while the majority of patients across age groups who took an A1C test had a 'High' result.


```R
# Glucose test result by age group
age_and_glucose_test_counts <- readmissions %>%
  group_by(age, glucose_test) %>%
  summarize(n = n(), .groups = "drop_last") %>%
  mutate(perc = label_percent(accuracy=0.01)(n/sum(n))) %>% 
  arrange(age, desc(n)) %>%
  ungroup()

# Bar plot
age_glucose_test_bar_plot <- ggplot(age_and_glucose_test_counts %>%
                    filter(glucose_test != "no")) + 
  geom_chicklet(aes(x = age, y = n,
                      fill = fct_reorder(glucose_test,n)), 
                  radius = grid::unit(1, "mm"), position="stack") +
  ggtitle("Fig. 18: Stacked Bar Graph of the Patients' Age Groups by Glucose Prediabetes Test Result\n") +
  labs(x="", y="Number of patients\n", fill="Test Result: ") +
  scale_x_discrete(expand = c(0.01, 0)) + 
  theme_economist() + 
  scale_color_economist() + 
    guides(fill = guide_legend(reverse = FALSE,
                               override.aes = list(shape = 15,
                                                   size = 4),
                               title.position="top")) +
  theme(legend.position="none",
          legend.text = element_text(margin = margin(r = 2, unit = "pt"),
                                     size = 10),
          legend.title = element_text(face="bold",
                                      size = 12),
          axis.ticks = element_blank(),        
          axis.title.x=element_blank(),
          axis.text.x=element_blank(),
          panel.grid.minor = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.3),
      panel.grid.major = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.3),
          plot.title = element_text(hjust = 0,
                                    size= 10),
          legend.box.margin = margin(t=0, b=0, l=-95, unit='pt')
         ) +
  scale_y_continuous(expand = c(0.01, 0),
                       breaks = seq(0, 400, by=100)) +
  scale_fill_manual(values = c("#8BD69D", "#BD3E38"),
                      labels = c("Normal", "High")
                     )

# A1C by age group
age_and_A1Ctest_counts <- readmissions %>%
  group_by(age, A1Ctest) %>%
  filter(age != "Missing", A1Ctest != "Missing") %>%
  summarize(n = n(), .groups = "drop_last") %>%
  mutate(perc = label_percent(accuracy=0.01)(n/sum(n))) %>% 
  arrange(age, desc(n)) %>%
  ungroup()

# Bar plot
age_A1Ctest_bar_plot <- ggplot(age_and_A1Ctest_counts %>%
                    filter(A1Ctest != "no")) + 
  geom_chicklet(aes(x = age, y = n,
                      fill = fct_reorder(A1Ctest,n)),  
                  radius = grid::unit(1, "mm"), position="stack") +
  ggtitle("Fig. 19: Stacked Bar Graph of the Patients' Age Groups by A1C Prediabetes Test Result       \n") +
  labs(x="\nAge group", y="Number of patients\n", fill="Test Result: ") +
  scale_x_discrete(expand = c(0.01, 0)) + 
  theme_economist() + 
  scale_color_economist() + 
    guides(fill = guide_legend(reverse = FALSE,
                               override.aes = list(shape = 15,
                                                   size = 4),
                               title.position="top")) +
  theme(legend.position="bottom",
          legend.text = element_text(margin = margin(r = 2, unit = "pt"),
                                     size = 10),
          legend.title = element_text(face="bold",
                                      size = 12),
          axis.ticks = element_blank(), 
          panel.grid.minor = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.3),
      panel.grid.major = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.3),
          plot.title = element_text(hjust = 0,
                                    size= 10),
          legend.box.margin = margin(t=0, b=0, l=-320, unit='pt')
         ) +
  scale_y_continuous(expand = c(0.01, 0),
                      breaks = seq(0, 850, by=200)) +
  scale_fill_manual(values = c("#8BD69D", "#BD3E38"),
                      labels = c("Normal", "High")
                     )

#ggarrange(age_glucose_test_bar_plot, 
#          age_A1Ctest_bar_plot,
#          ncol = 1, nrow = 2,
#          heights = c(0.85,1.4),
#          align = "v")
```


```R
age_and_glucose_test_counts %>%
  filter(glucose_test!="no")
age_and_A1Ctest_counts
```


<table class="dataframe">
<caption>A tibble: 12 × 4</caption>
<thead>
  <tr><th scope=col>age</th><th scope=col>glucose_test</th><th scope=col>n</th><th scope=col>perc</th></tr>
  <tr><th scope=col>&lt;fct&gt;</th><th scope=col>&lt;fct&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;chr&gt;</th></tr>
</thead>
<tbody>
  <tr><td>[40-50) </td><td>high  </td><td> 82</td><td>3.24%</td></tr>
  <tr><td>[40-50) </td><td>normal</td><td> 59</td><td>2.33%</td></tr>
  <tr><td>[50-60) </td><td>normal</td><td>100</td><td>2.25%</td></tr>
  <tr><td>[50-60) </td><td>high  </td><td> 88</td><td>1.98%</td></tr>
  <tr><td>[60-70) </td><td>normal</td><td>143</td><td>2.42%</td></tr>
  <tr><td>[60-70) </td><td>high  </td><td>127</td><td>2.15%</td></tr>
  <tr><td>[70-80) </td><td>high  </td><td>198</td><td>2.90%</td></tr>
  <tr><td>[70-80) </td><td>normal</td><td>197</td><td>2.88%</td></tr>
  <tr><td>[80-90) </td><td>normal</td><td>159</td><td>3.52%</td></tr>
  <tr><td>[80-90) </td><td>high  </td><td>156</td><td>3.45%</td></tr>
  <tr><td>[90-100)</td><td>high  </td><td> 35</td><td>4.67%</td></tr>
  <tr><td>[90-100)</td><td>normal</td><td> 31</td><td>4.13%</td></tr>
</tbody>
</table>




<table class="dataframe">
<caption>A tibble: 18 × 4</caption>
<thead>
  <tr><th scope=col>age</th><th scope=col>A1Ctest</th><th scope=col>n</th><th scope=col>perc</th></tr>
  <tr><th scope=col>&lt;fct&gt;</th><th scope=col>&lt;fct&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;chr&gt;</th></tr>
</thead>
<tbody>
  <tr><td>[40-50) </td><td>no    </td><td>1938</td><td>76.54%</td></tr>
  <tr><td>[40-50) </td><td>high  </td><td> 447</td><td>17.65%</td></tr>
  <tr><td>[40-50) </td><td>normal</td><td> 147</td><td>5.81% </td></tr>
  <tr><td>[50-60) </td><td>no    </td><td>3560</td><td>79.96%</td></tr>
  <tr><td>[50-60) </td><td>high  </td><td> 631</td><td>14.17%</td></tr>
  <tr><td>[50-60) </td><td>normal</td><td> 261</td><td>5.86% </td></tr>
  <tr><td>[60-70) </td><td>no    </td><td>4990</td><td>84.39%</td></tr>
  <tr><td>[60-70) </td><td>high  </td><td> 683</td><td>11.55%</td></tr>
  <tr><td>[60-70) </td><td>normal</td><td> 240</td><td>4.06% </td></tr>
  <tr><td>[70-80) </td><td>no    </td><td>5885</td><td>86.08%</td></tr>
  <tr><td>[70-80) </td><td>high  </td><td> 626</td><td>9.16% </td></tr>
  <tr><td>[70-80) </td><td>normal</td><td> 326</td><td>4.77% </td></tr>
  <tr><td>[80-90) </td><td>no    </td><td>3886</td><td>86.05%</td></tr>
  <tr><td>[80-90) </td><td>high  </td><td> 396</td><td>8.77% </td></tr>
  <tr><td>[80-90) </td><td>normal</td><td> 234</td><td>5.18% </td></tr>
  <tr><td>[90-100)</td><td>no    </td><td> 679</td><td>90.53%</td></tr>
  <tr><td>[90-100)</td><td>high  </td><td>  44</td><td>5.87% </td></tr>
  <tr><td>[90-100)</td><td>normal</td><td>  27</td><td>3.60% </td></tr>
</tbody>
</table>



<img src="documentation/Fig18-19_age_test_bar_plot.png"/>

**Diabetes medication**: In all age groups, people with a prescription and a change in diabetes medication outnumbered those without a prescription and no change.


```R
# Change in diabestes medication by age group
age_and_change_counts <- readmissions %>%
  group_by(age, change) %>%
  summarize(n = n(), .groups = "drop_last") %>%
  mutate(perc = label_percent(accuracy=0.01)(n/sum(n))) %>% 
  arrange(age, desc(n)) %>%
  ungroup()

# Bar plot
age_change_bar_plot <- ggplot(age_and_change_counts) + 
  geom_chicklet(aes(x = age, y = n,
                      fill = fct_reorder(change,n)), 
                  #color="white",
                  radius = grid::unit(1, "mm"), position="stack") +
  ggtitle("Fig. 20: Stacked Bar Graph of the Patient's Response to the Question\n              Related to the Change in Diabetes Medication\n") +
  labs(x="", y="Number of patients\n", fill="Response: ") +
  scale_x_discrete(expand = c(0.01, 0)) + 
  theme_economist() + 
  scale_color_economist() + 
    guides(fill = guide_legend(reverse = TRUE,
                               override.aes = list(shape = 15,
                                                   size = 4),
                               title.position="top")) +
  theme(legend.position="none",
          legend.text = element_text(margin = margin(r = 2, unit = "pt"),
                                     size = 10),
          legend.title = element_text(face="bold",
                                      size = 12),
          axis.ticks = element_blank(),        
          axis.title.x=element_blank(),
          axis.text.x=element_blank(),
          panel.grid.minor = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.3),
      panel.grid.major = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.3),
          plot.title = element_text(hjust = 0,
                                    size= 11.5),
          legend.box.margin = margin(t=0, b=0, l=-92, unit='pt')
         ) +
  scale_y_continuous(expand = c(0.01, 0),
                       breaks = seq(0, 7500, by=2000)) +
    scale_fill_manual(values = c("#EE6C4D", "#98C1D9"),
                      labels = c("No", "Yes")
                     ) 

# A1C by age group
age_and_diabetes_med_counts <- readmissions %>%
  group_by(age, diabetes_med) %>%
  summarize(n = n(), .groups = "drop_last") %>%
  mutate(perc = label_percent(accuracy=0.01)(n/sum(n))) %>% 
  arrange(age, desc(n)) %>%
  ungroup()

# Bar plot
age_diabetes_med_bar_plot <- ggplot(age_and_diabetes_med_counts) + 
  geom_chicklet(aes(x = age, y = n,
                      fill = fct_reorder(diabetes_med,n)),  
                  #color="white",
                  radius = grid::unit(1, "mm"), position="stack") +
  ggtitle("Fig. 21: Stacked Bar Graph of the Patient's Response to the Question\n               Related to the Prescription of a Diabetes Medication\n") +
  labs(x="\nAge group", y="Number of patients\n", fill="Response: ") +
  scale_x_discrete(expand = c(0.01, 0)) + 
  theme_economist() + 
  scale_color_economist() + 
    guides(fill = guide_legend(ncol=3,nrow=1,
                               reverse = TRUE,
                               override.aes = list(shape = 15,
                                                   size = 4),
                               title.position="top")) +
  theme(legend.position="bottom",
          legend.text = element_text(margin = margin(r = 2, unit = "pt"),
                                     size = 11.5),
          legend.title = element_text(face="bold",
                                      size = 12),
          axis.ticks = element_blank(), 
          panel.grid.minor = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.3),
      panel.grid.major = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.3),
          plot.title = element_text(hjust = 0,
                                    size= 11.5),
          legend.box.margin = margin(t=0, b=0, l=-305, unit='pt')
         ) +
  scale_y_continuous(expand = c(0.01, 0),
                       breaks = seq(0, 7500, by=2000)) +
    scale_fill_manual(values = c("#EE6C4D", "#98C1D9"),
                      labels = c("No", "Yes")
                     )


#ggarrange(age_change_bar_plot, 
#          age_diabetes_med_bar_plot,#+
#          	#rremove("x.text"), 
#          ncol = 1, nrow = 2,
#          heights = c(0.85,1.4),
#          align = "v")
```

<img src="documentation/Fig20-21_diabetes_med_question_bar_plot.png"/>

**Readmission**: Although all of the age groups have patients who mostly had not readmitted, the difference between their readmissions and non-readmissions seem to be little.


```R
# Readmission by age group
age_and_readmitted_counts <- readmissions %>%
  group_by(age, readmitted) %>%
  summarize(n = n(), .groups = "drop_last") %>%
  mutate(perc = label_percent(accuracy=0.01)(n/sum(n))) %>% 
  arrange(age, desc(n)) %>%
  ungroup()

# Bar plot
age_readmitted_bar_plot <- ggplot(age_and_readmitted_counts) + 
  geom_chicklet(aes(x = age, y = n,
                      fill = fct_reorder(readmitted, n)), 
                  color="white",
                  radius = grid::unit(1, "mm"), position="stack") +
  ggtitle("Fig. 22: Stacked Bar Graph of the Patients' Age Groups by Readmission\n") +
  labs(x="\nDiagnosis", y="Number of patients\n", fill="Readmitted ") +
  scale_x_discrete(expand = c(0.01, 0)) + 
  theme_economist() + 
  scale_color_economist() + 
    guides(fill = guide_legend(reverse = FALSE,
                               override.aes = list(shape = 15,
                                                   size = 4),
                               title.position="top")) +
  theme(legend.position="bottom",
          legend.text = element_text(margin = margin(r = 2, unit = "pt"),
                                     size = 10),
          legend.title = element_text(face="bold",
                                      size = 12),
          axis.ticks = element_blank(),          
          panel.grid.minor = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.3),
      panel.grid.major = element_line(color="grey",
                                          linetype="dashed",
                                          linewidth=0.3),
          plot.title = element_text(hjust = 0,
                                    size= 12),
          legend.box.margin = margin(t=0, b=0, l=-338, unit='pt')) +
  scale_y_continuous(expand = c(0.01, 0),
                       breaks = seq(0, 6000, by=1000)) +
    scale_fill_manual(values = c("#EE6C4D", "#98C1D9"),
                      labels = c("Yes", "No")
                     )
```


```R
age_and_readmitted_counts
```


<table class="dataframe">
<caption>A tibble: 12 × 4</caption>
<thead>
  <tr><th scope=col>age</th><th scope=col>readmitted</th><th scope=col>n</th><th scope=col>perc</th></tr>
  <tr><th scope=col>&lt;fct&gt;</th><th scope=col>&lt;fct&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;chr&gt;</th></tr>
</thead>
<tbody>
  <tr><td>[40-50) </td><td>no </td><td>1405</td><td>55.49%</td></tr>
  <tr><td>[40-50) </td><td>yes</td><td>1127</td><td>44.51%</td></tr>
  <tr><td>[50-60) </td><td>no </td><td>2486</td><td>55.84%</td></tr>
  <tr><td>[50-60) </td><td>yes</td><td>1966</td><td>44.16%</td></tr>
  <tr><td>[60-70) </td><td>no </td><td>3143</td><td>53.15%</td></tr>
  <tr><td>[60-70) </td><td>yes</td><td>2770</td><td>46.85%</td></tr>
  <tr><td>[70-80) </td><td>no </td><td>3501</td><td>51.21%</td></tr>
  <tr><td>[70-80) </td><td>yes</td><td>3336</td><td>48.79%</td></tr>
  <tr><td>[80-90) </td><td>no </td><td>2277</td><td>50.42%</td></tr>
  <tr><td>[80-90) </td><td>yes</td><td>2239</td><td>49.58%</td></tr>
  <tr><td>[90-100)</td><td>no </td><td> 434</td><td>57.87%</td></tr>
  <tr><td>[90-100)</td><td>yes</td><td> 316</td><td>42.13%</td></tr>
</tbody>
</table>



<img src="documentation/Fig22_age_readmitted_bar_plot.png"/>

### Patient Readmissions
In this section, the patients' readmission will be analyzed by different representing features through contingency tables, graphs, and regression analysis.

As previously mentioned, the number of readmitted patients is 11,754 which translates to an overall readmission rate of 47.02%.

#### By Variable

The table below shows the comparisons of means and medians of the readmitted, not readmitted, and overall patients in terms of the seven (7) numeric features. We can see that the three sets seem to be the same in characteristics.


```R
as.data.frame(xtabs(~ readmitted, data = readmissions)) %>%
  rename(n_patients = Freq) %>%
  mutate(rate=n_patients/sum(n_patients))
```


<table class="dataframe">
<caption>A data.frame: 2 × 3</caption>
<thead>
  <tr><th scope=col>readmitted</th><th scope=col>n_patients</th><th scope=col>rate</th></tr>
  <tr><th scope=col>&lt;fct&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;dbl&gt;</th></tr>
</thead>
<tbody>
  <tr><td>no </td><td>13246</td><td>0.52984</td></tr>
  <tr><td>yes</td><td>11754</td><td>0.47016</td></tr>
</tbody>
</table>




```R
# Summary statistics for numerical variables of readmitted patients
readmitted_sum_stats <- data.frame(
    Variable = readmissions %>%
    select_if(is.numeric) %>%
    colnames) %>%
  bind_cols(as.data.frame(t(readmissions %>% filter(readmitted == "yes") %>%
                              summarise_if(is.numeric, list(mean)) %>%
                              bind_rows(readmissions %>% filter(readmitted == "yes") %>%
                                          summarise_if(is.numeric, list(sd)), 
                                        readmissions %>% filter(readmitted == "yes") %>%
                                          summarise_if(is.numeric, list(min)),
                                        readmissions %>% filter(readmitted == "yes") %>%
                                          summarise_if(is.numeric, list(median)),
                                        readmissions %>% filter(readmitted == "yes") %>%
                                          summarise_if(is.numeric, list(max)))
                             )) %>%
              rename(Mean = V1,
                     `Std. Dev.` = V2,
                     `Min.` = V3,
                     `Median` = V4,
                     `Max.` = V5))

rownames(readmitted_sum_stats) <- 1: nrow(readmitted_sum_stats)

# Summary statistics for numerical variables of not readmitted patients
not_readmitted_sum_stats <- data.frame(
    Variable = readmissions %>%
    select_if(is.numeric) %>%
    colnames) %>%
  bind_cols(as.data.frame(t(readmissions %>% filter(readmitted == "no") %>%
                              summarise_if(is.numeric, list(mean)) %>%
                              bind_rows(readmissions %>% filter(readmitted == "no") %>%
                                          summarise_if(is.numeric, list(sd)), 
                                        readmissions %>% filter(readmitted == "no") %>%
                                          summarise_if(is.numeric, list(min)),
                                        readmissions %>% filter(readmitted == "no") %>%
                                          summarise_if(is.numeric, list(median)),
                                        readmissions %>% filter(readmitted == "no") %>%
                                          summarise_if(is.numeric, list(max)))
                             )) %>%
              rename(Mean = V1,
                     `Std. Dev.` = V2,
                     `Min.` = V3,
                     `Median` = V4,
                     `Max.` = V5))

rownames(not_readmitted_sum_stats) <- 1: nrow(not_readmitted_sum_stats)

# Med
readmitted_sum_stats %>%
  select(Variable, Mean, Median) %>%
  rename(readm_Mean = Mean, readm_Median = Median) %>%
    bind_cols(not_readmitted_sum_stats %>%
            select(Mean, Median) %>%
            rename(not_readm_Mean = Mean, not_readm_Median = Median),
          sum_stats %>%
            select(Mean, Median) %>%
            rename(overall_Mean = Mean, overall_Median = Median)
         )
```


<table class="dataframe">
<caption>A data.frame: 7 × 7</caption>
<thead>
  <tr><th scope=col>Variable</th><th scope=col>readm_Mean</th><th scope=col>readm_Median</th><th scope=col>not_readm_Mean</th><th scope=col>not_readm_Median</th><th scope=col>overall_Mean</th><th scope=col>overall_Median</th></tr>
  <tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th></tr>
</thead>
<tbody>
  <tr><td>time_in_hospital</td><td> 4.5907776</td><td> 4</td><td> 4.3313453</td><td> 4</td><td> 4.45332</td><td> 4</td></tr>
  <tr><td>n_lab_procedures</td><td>43.9344053</td><td>45</td><td>42.6252454</td><td>44</td><td>43.24076</td><td>44</td></tr>
  <tr><td>n_procedures    </td><td> 1.2713970</td><td> 1</td><td> 1.4242035</td><td> 1</td><td> 1.35236</td><td> 1</td></tr>
  <tr><td>n_medications   </td><td>16.5678918</td><td>16</td><td>15.9724445</td><td>15</td><td>16.25240</td><td>15</td></tr>
  <tr><td>n_outpatient    </td><td> 0.4875787</td><td> 0</td><td> 0.2588706</td><td> 0</td><td> 0.36640</td><td> 0</td></tr>
  <tr><td>n_inpatient     </td><td> 0.8816573</td><td> 0</td><td> 0.3801902</td><td> 0</td><td> 0.61596</td><td> 0</td></tr>
  <tr><td>n_emergency     </td><td> 0.2745448</td><td> 0</td><td> 0.1085611</td><td> 0</td><td> 0.18660</td><td> 0</td></tr>
</tbody>
</table>




```R
#readmissions %>%
#	group_by(readmitted) %>%
#	summarize(count = n(),
#			  median = median(time_in_hospital, na.rm = TRUE),
#			  IQR = IQR(time_in_hospital, na.rm = TRUE))
 
#ggboxplot(readmissions, x = "readmitted", y = "time_in_hospital",
#          color = "readmitted", palette = c("#FFA500", "#FF0000"),
#          ylab = "times_in_hospital", xlab = "readmitted?")
 
wilcox.test(time_in_hospital ~ readmitted,
                   data = readmissions,
                   exact = FALSE)

wilcox.test(n_procedures ~ readmitted,
                   data = readmissions,
                   exact = FALSE)

wilcox.test(n_lab_procedures ~ readmitted,
                   data = readmissions,
                   exact = FALSE)

wilcox.test(n_medications ~ readmitted,
                   data = readmissions,
                   exact = FALSE)

wilcox.test(n_outpatient ~ readmitted,
                   data = readmissions,
                   exact = FALSE)

wilcox.test(n_inpatient ~ readmitted,
                   data = readmissions,
                   exact = FALSE)

wilcox.test(n_emergency ~ readmitted,
                   data = readmissions,
                   exact = FALSE)
```


    
      Wilcoxon rank sum test with continuity correction
    
    data:  time_in_hospital by readmitted
    W = 73042702, p-value < 2.2e-16
    alternative hypothesis: true location shift is not equal to 0




    
      Wilcoxon rank sum test with continuity correction
    
    data:  n_procedures by readmitted
    W = 81897160, p-value = 5.333e-14
    alternative hypothesis: true location shift is not equal to 0




    
      Wilcoxon rank sum test with continuity correction
    
    data:  n_lab_procedures by readmitted
    W = 74776296, p-value = 6.973e-08
    alternative hypothesis: true location shift is not equal to 0




    
      Wilcoxon rank sum test with continuity correction
    
    data:  n_medications by readmitted
    W = 71996398, p-value < 2.2e-16
    alternative hypothesis: true location shift is not equal to 0




    
      Wilcoxon rank sum test with continuity correction
    
    data:  n_outpatient by readmitted
    W = 70962944, p-value < 2.2e-16
    alternative hypothesis: true location shift is not equal to 0




    
      Wilcoxon rank sum test with continuity correction
    
    data:  n_inpatient by readmitted
    W = 61536228, p-value < 2.2e-16
    alternative hypothesis: true location shift is not equal to 0




    
      Wilcoxon rank sum test with continuity correction
    
    data:  n_emergency by readmitted
    W = 72302580, p-value < 2.2e-16
    alternative hypothesis: true location shift is not equal to 0



The table below shows the readmissions and rates by category of each factor arranged descendingly.


```R
#
readmitted_age <- as.data.frame(xtabs(~ readmitted + age, data = readmissions)) %>%
  filter(readmitted == "yes") %>%
  group_by(age) %>%
  summarize(readmissions=sum(Freq), rate=sum(Freq)/25000, .groups = "keep") %>%
  arrange(desc(readmissions)) %>%
  ungroup()

#
readmitted_medical_specialty <- as.data.frame(xtabs(~ readmitted + medical_specialty, data = readmissions)) %>%
  filter(readmitted == "yes") %>%
  group_by(medical_specialty) %>%
  summarize(readmissions=sum(Freq), rate=sum(Freq)/25000, .groups = "keep") %>%
  arrange(desc(readmissions)) %>%
  ungroup()

#
readmitted_diag_1 <- as.data.frame(xtabs(~ readmitted + diag_1, data = readmissions)) %>%
  filter(readmitted == "yes") %>%
  group_by(diag_1) %>%
  summarize(readmissions=sum(Freq), rate=sum(Freq)/25000, .groups = "keep") %>%
  arrange(desc(readmissions)) %>%
  ungroup() 

#
readmitted_diag_2 <- as.data.frame(xtabs(~ readmitted + diag_2, data = readmissions)) %>%
  filter(readmitted == "yes") %>%
  group_by(diag_2) %>%
  summarize(readmissions=sum(Freq), rate=sum(Freq)/25000, .groups = "keep") %>%
  arrange(desc(readmissions)) %>%
  ungroup() 

#
readmitted_diag_3 <- as.data.frame(xtabs(~ readmitted + diag_3, data = readmissions)) %>%
  filter(readmitted == "yes") %>%
  group_by(diag_3) %>%
  summarize(readmissions=sum(Freq), rate=sum(Freq)/25000, .groups = "keep") %>%
  arrange(desc(readmissions)) %>%
  ungroup() 

#
readmitted_glucose_test <- as.data.frame(xtabs(~ readmitted + glucose_test, data = readmissions)) %>%
  filter(readmitted == "yes") %>%
  group_by(glucose_test) %>%
  summarize(readmissions=sum(Freq), rate=sum(Freq)/25000, .groups = "keep") %>%
  arrange(desc(readmissions)) %>%
  ungroup() 

#
readmitted_A1Ctest <- as.data.frame(xtabs(~ readmitted + A1Ctest, data = readmissions)) %>%
  filter(readmitted == "yes") %>%
  group_by(A1Ctest) %>%
  summarize(readmissions=sum(Freq), rate=sum(Freq)/25000, .groups = "keep") %>%
  arrange(desc(readmissions)) %>%
  ungroup() 

#
readmitted_change <- as.data.frame(xtabs(~ readmitted + change, data = readmissions)) %>%
  filter(readmitted == "yes") %>%
  group_by(change) %>%
  summarize(readmissions=sum(Freq), rate=sum(Freq)/25000, .groups = "keep") %>%
  arrange(desc(readmissions)) %>%
  ungroup() 

#
readmitted_diabetes_med <- as.data.frame(xtabs(~ readmitted + diabetes_med, data = readmissions)) %>%
  filter(readmitted == "yes") %>%
  group_by(diabetes_med) %>%
  summarize(readmissions=sum(Freq), rate=sum(Freq)/25000, .groups = "keep") %>%
  arrange(desc(readmissions)) %>%
  ungroup() 

#
readmitted_factor <- rbind(readmitted_age %>% rename(category = age) %>% mutate(factor = "age"),
  readmitted_medical_specialty %>% rename(category = medical_specialty) %>% mutate(factor = "medical_specialty"),
  readmitted_diag_1 %>% rename(category = diag_1) %>% mutate(factor = "diag_1"),
  readmitted_diag_2 %>% rename(category = diag_2) %>% mutate(factor = "diag_2"),
  readmitted_diag_3 %>% rename(category = diag_3) %>% mutate(factor = "diag_3"),
  readmitted_glucose_test %>% rename(category = glucose_test) %>% mutate(factor = "glucose_test"),
  readmitted_A1Ctest %>% rename(category = A1Ctest) %>% mutate(factor = "A1Ctest"),
  readmitted_change %>% rename(category = change) %>% mutate(factor = "change"),
  readmitted_diabetes_med %>% rename(category = diabetes_med) %>% mutate(factor = "diabetes_med")
)

readmitted_factor %>%
  select(factor, everything())
```


<table class="dataframe">
<caption>A tibble: 47 × 4</caption>
<thead>
  <tr><th scope=col>factor</th><th scope=col>category</th><th scope=col>readmissions</th><th scope=col>rate</th></tr>
  <tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;fct&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;dbl&gt;</th></tr>
</thead>
<tbody>
  <tr><td>age              </td><td>[70-80)               </td><td> 3336</td><td>0.13344</td></tr>
  <tr><td>age              </td><td>[60-70)               </td><td> 2770</td><td>0.11080</td></tr>
  <tr><td>age              </td><td>[80-90)               </td><td> 2239</td><td>0.08956</td></tr>
  <tr><td>age              </td><td>[50-60)               </td><td> 1966</td><td>0.07864</td></tr>
  <tr><td>age              </td><td>[40-50)               </td><td> 1127</td><td>0.04508</td></tr>
  <tr><td>age              </td><td>[90-100)              </td><td>  316</td><td>0.01264</td></tr>
  <tr><td>medical_specialty</td><td>InternalMedicine      </td><td> 1596</td><td>0.06384</td></tr>
  <tr><td>medical_specialty</td><td>Other                 </td><td> 1105</td><td>0.04420</td></tr>
  <tr><td>medical_specialty</td><td>Family/GeneralPractice</td><td>  932</td><td>0.03728</td></tr>
  <tr><td>medical_specialty</td><td>Emergency/Trauma      </td><td>  931</td><td>0.03724</td></tr>
  <tr><td>medical_specialty</td><td>Cardiology            </td><td>  634</td><td>0.02536</td></tr>
  <tr><td>medical_specialty</td><td>Surgery               </td><td>  500</td><td>0.02000</td></tr>
  <tr><td>medical_specialty</td><td>Missing               </td><td>    0</td><td>0.00000</td></tr>
  <tr><td>diag_1           </td><td>Circulatory           </td><td> 3750</td><td>0.15000</td></tr>
  <tr><td>diag_1           </td><td>Other                 </td><td> 2932</td><td>0.11728</td></tr>
  <tr><td>diag_1           </td><td>Respiratory           </td><td> 1806</td><td>0.07224</td></tr>
  <tr><td>diag_1           </td><td>Digestive             </td><td> 1105</td><td>0.04420</td></tr>
  <tr><td>diag_1           </td><td>Diabetes              </td><td>  937</td><td>0.03748</td></tr>
  <tr><td>diag_1           </td><td>Injury                </td><td>  727</td><td>0.02908</td></tr>
  <tr><td>diag_1           </td><td>Musculoskeletal       </td><td>  495</td><td>0.01980</td></tr>
  <tr><td>diag_1           </td><td>Missing               </td><td>    0</td><td>0.00000</td></tr>
  <tr><td>diag_2           </td><td>Other                 </td><td> 4248</td><td>0.16992</td></tr>
  <tr><td>diag_2           </td><td>Circulatory           </td><td> 3932</td><td>0.15728</td></tr>
  <tr><td>diag_2           </td><td>Respiratory           </td><td> 1406</td><td>0.05624</td></tr>
  <tr><td>diag_2           </td><td>Diabetes              </td><td> 1283</td><td>0.05132</td></tr>
  <tr><td>diag_2           </td><td>Digestive             </td><td>  431</td><td>0.01724</td></tr>
  <tr><td>diag_2           </td><td>Injury                </td><td>  240</td><td>0.00960</td></tr>
  <tr><td>diag_2           </td><td>Musculoskeletal       </td><td>  197</td><td>0.00788</td></tr>
  <tr><td>diag_2           </td><td>Missing               </td><td>    0</td><td>0.00000</td></tr>
  <tr><td>diag_3           </td><td>Other                 </td><td> 4253</td><td>0.17012</td></tr>
  <tr><td>diag_3           </td><td>Circulatory           </td><td> 3712</td><td>0.14848</td></tr>
  <tr><td>diag_3           </td><td>Diabetes              </td><td> 1947</td><td>0.07788</td></tr>
  <tr><td>diag_3           </td><td>Respiratory           </td><td>  954</td><td>0.03816</td></tr>
  <tr><td>diag_3           </td><td>Digestive             </td><td>  430</td><td>0.01720</td></tr>
  <tr><td>diag_3           </td><td>Musculoskeletal       </td><td>  205</td><td>0.00820</td></tr>
  <tr><td>diag_3           </td><td>Injury                </td><td>  197</td><td>0.00788</td></tr>
  <tr><td>diag_3           </td><td>Missing               </td><td>    0</td><td>0.00000</td></tr>
  <tr><td>glucose_test     </td><td>no                    </td><td>11064</td><td>0.44256</td></tr>
  <tr><td>glucose_test     </td><td>high                  </td><td>  357</td><td>0.01428</td></tr>
  <tr><td>glucose_test     </td><td>normal                </td><td>  333</td><td>0.01332</td></tr>
  <tr><td>A1Ctest          </td><td>no                    </td><td> 9935</td><td>0.39740</td></tr>
  <tr><td>A1Ctest          </td><td>high                  </td><td> 1299</td><td>0.05196</td></tr>
  <tr><td>A1Ctest          </td><td>normal                </td><td>  520</td><td>0.02080</td></tr>
  <tr><td>change           </td><td>no                    </td><td> 6077</td><td>0.24308</td></tr>
  <tr><td>change           </td><td>yes                   </td><td> 5677</td><td>0.22708</td></tr>
  <tr><td>diabetes_med     </td><td>yes                   </td><td> 9367</td><td>0.37468</td></tr>
  <tr><td>diabetes_med     </td><td>no                    </td><td> 2387</td><td>0.09548</td></tr>
</tbody>
</table>



#### Model
Since the feature representing a patient's readmission takes on two values, 'yes' or 'no', it is used as the dependent variable of a multivariate logistic regression model in order to predict the odds of readmission. Also, not all of the patient's features are used as independent variables, that is, variables *medical_specialty*, *glucose_test*, and *A1Ctest* were excluded due to large number of missing values. Variables with few missing values *(diag_1*, *diag_2*, and *diag_3)* were imputed by their respective modes. 

The reference category for each factor variable is:
- age: [40-50)
- diag_1, diag_2, and diag_3: Circulatory
- change: no
- diabetes_med: no

Below are the estimates of the coefficients along with their standard errors, t-statistics, p-values, odds ratios (ORs), and 95% CIs of the ORs. 


```R
## Univariate Regression Analysis
logstc_model_age <- glm(readmitted ~ age, data=readmissions, family="binomial"(link=logit))

logstc_model_time_in_hospital <- glm(readmitted ~ time_in_hospital, data=readmissions, family="binomial"(link=logit))

logstc_model_n_procedures <- glm(readmitted ~ n_procedures, data=readmissions, family="binomial"(link=logit))

logstc_model_n_lab_procedures <- glm(readmitted ~ n_lab_procedures, data=readmissions, family="binomial"(link=logit))

logstc_model_n_medications <- glm(readmitted ~ n_medications, data=readmissions, family="binomial"(link=logit))

logstc_model_n_outpatient <- glm(readmitted ~ n_outpatient, data=readmissions, family="binomial"(link=logit))

logstc_model_n_inpatient <- glm(readmitted ~ n_inpatient, data=readmissions, family="binomial"(link=logit))

logstc_model_n_emergency <- glm(readmitted ~ n_emergency, data=readmissions, family="binomial"(link=logit))

logstc_model_medical_specialty <- glm(readmitted ~ medical_specialty, data=readmissions, family="binomial"(link=logit))

logstc_model_diag_1 <- glm(readmitted ~ diag_1, data=readmissions, family="binomial"(link=logit))

logstc_model_diag_2 <- glm(readmitted ~ diag_2, data=readmissions, family="binomial"(link=logit))

logstc_model_diag_3 <- glm(readmitted ~ diag_3, data=readmissions, family="binomial"(link=logit))

logstc_model_change <- glm(readmitted ~ change, data=readmissions, family="binomial"(link=logit))

logstc_model_diabetes_med <- glm(readmitted ~ diabetes_med, data=readmissions, family="binomial"(link=logit))

# Install and load the "questionr" package
# For calculating the odds ratio									   
suppressWarnings(suppressMessages(install.packages("questionr")))
suppressPackageStartupMessages(library(questionr))

#
#as.data.frame(summary.lm(logstc_model_age)$coefficients) %>%
#	rownames_to_column("Variable") %>%
#	mutate(`Signif. Code` = case_when(`Pr(>|t|)` < 0.001 ~  "***",
#                                      `Pr(>|t|)` >= 0.001 & `Pr(>|t|)` < 0.01 ~ "**",
#                                      `Pr(>|t|)` >= 0.01 & `Pr(>|t|)` < 0.05 ~ "*",
#                                      `Pr(>|t|)` >= 0.05 & `Pr(>|t|)` < 0.1 ~ ".",
#                                       TRUE ~ "")) %>%
#	merge(odds.ratio(logstc_model_age, 0.95) %>% 
#		  	rownames_to_column("Variable") %>%
#		  	select(-p))

# Create mode() function to calculate mode
mode <- function(x, na.rm = FALSE) {
  if(na.rm){ #if na.rm is TRUE, remove NA values from input x
    x = x[!is.na(x)]
  }
  val <- unique(x)
  return(val[which.max(tabulate(match(x, val)))])
}


## Multivariate Regression Analysis

data_for_regression <- readmissions %>% 
  select(-c(medical_specialty, glucose_test, A1Ctest)) %>%
  mutate_all(~case_when(is.character(.) & is.na(.) ~ mode(.),
              TRUE ~ .))

# Logistics Regression Model
logstc_model <- glm(readmitted ~ ., data=data_for_regression, family="binomial"(link=logit))

# Summary statistics of the full model
#paste("Residual standard error:", round(summary.lm(full_model)$sigma, 4), 
#      " ,  R-square: ", round(summary.lm(full_model)$r.squared, 4), 
#      " ,  Adj. R-square: ", round(summary.lm(full_model)$adj.r.squared, 4))

# Full model's table of estimated coefficients, their SEs, t-stats, and (two-sided) p-values
summary_logstc <- as.data.frame(summary.lm(logstc_model)$coefficients) %>%
  rownames_to_column("Variable") %>%
  mutate(`Signif. Code` = case_when(`Pr(>|t|)` < 0.001 ~  "***",
                                      `Pr(>|t|)` >= 0.001 & `Pr(>|t|)` < 0.01 ~ "**",
                                      `Pr(>|t|)` >= 0.01 & `Pr(>|t|)` < 0.05 ~ "*",
                                      `Pr(>|t|)` >= 0.05 & `Pr(>|t|)` < 0.1 ~ ".",
                                       TRUE ~ "")) %>%
  merge(odds.ratio(logstc_model, 0.95) %>% 
        rownames_to_column("Variable") %>%
        select(-p))
```

    Waiting for profiling to be done...
    



```R
summary_logstc
```


<table class="dataframe">
<caption>A data.frame: 33 × 9</caption>
<thead>
  <tr><th scope=col>Variable</th><th scope=col>Estimate</th><th scope=col>Std. Error</th><th scope=col>t value</th><th scope=col>Pr(&gt;|t|)</th><th scope=col>Signif. Code</th><th scope=col>OR</th><th scope=col>2.5 %</th><th scope=col>97.5 %</th></tr>
  <tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th></tr>
</thead>
<tbody>
  <tr><td>(Intercept)          </td><td>-0.676308664</td><td>0.0727457345</td><td>-9.29688413</td><td> 1.562023e-20</td><td>***</td><td>0.5084905</td><td>0.4433359</td><td>0.5830338</td></tr>
  <tr><td>age[50-60)           </td><td> 0.027580089</td><td>0.0552481797</td><td> 0.49920358</td><td> 6.176404e-01</td><td>   </td><td>1.0279639</td><td>0.9264833</td><td>1.1407389</td></tr>
  <tr><td>age[60-70)           </td><td> 0.140138815</td><td>0.0531046658</td><td> 2.63891718</td><td> 8.322339e-03</td><td>** </td><td>1.1504335</td><td>1.0410870</td><td>1.2715419</td></tr>
  <tr><td>age[70-80)           </td><td> 0.208365868</td><td>0.0523118146</td><td> 3.98315122</td><td> 6.820194e-05</td><td>***</td><td>1.2316637</td><td>1.1162713</td><td>1.3593055</td></tr>
  <tr><td>age[80-90)           </td><td> 0.220960379</td><td>0.0559845407</td><td> 3.94681061</td><td> 7.941792e-05</td><td>***</td><td>1.2472740</td><td>1.1226112</td><td>1.3860596</td></tr>
  <tr><td>age[90-100)          </td><td>-0.053054919</td><td>0.0918668717</td><td>-0.57751960</td><td> 5.635938e-01</td><td>   </td><td>0.9483279</td><td>0.7973616</td><td>1.1269743</td></tr>
  <tr><td>changeyes            </td><td> 0.039509849</td><td>0.0325303449</td><td> 1.21455365</td><td> 2.245480e-01</td><td>   </td><td>1.0403007</td><td>0.9785075</td><td>1.1060109</td></tr>
  <tr><td>diabetes_medyes      </td><td> 0.227533505</td><td>0.0381635967</td><td> 5.96205611</td><td> 2.524595e-09</td><td>***</td><td>1.2554995</td><td>1.1685024</td><td>1.3490779</td></tr>
  <tr><td>diag_1Diabetes       </td><td> 0.148048457</td><td>0.0612105412</td><td> 2.41867584</td><td> 1.558428e-02</td><td>*  </td><td>1.1595691</td><td>1.0334018</td><td>1.3012846</td></tr>
  <tr><td>diag_1Digestive      </td><td>-0.013140042</td><td>0.0542553278</td><td>-0.24218898</td><td> 8.086357e-01</td><td>   </td><td>0.9869459</td><td>0.8910678</td><td>1.0930423</td></tr>
  <tr><td>diag_1Injury         </td><td>-0.188171950</td><td>0.0606963642</td><td>-3.10021782</td><td> 1.935954e-03</td><td>** </td><td>0.8284722</td><td>0.7388791</td><td>0.9286184</td></tr>
  <tr><td>diag_1Musculoskeletal</td><td>-0.227602478</td><td>0.0693867245</td><td>-3.28020207</td><td> 1.038761e-03</td><td>** </td><td>0.7964408</td><td>0.6986402</td><td>0.9072697</td></tr>
  <tr><td>diag_1Other          </td><td>-0.166568633</td><td>0.0393675922</td><td>-4.23111052</td><td> 2.333769e-05</td><td>***</td><td>0.8465647</td><td>0.7860692</td><td>0.9116689</td></tr>
  <tr><td>diag_1Respiratory    </td><td>-0.037630283</td><td>0.0451369154</td><td>-0.83369195</td><td> 4.044626e-01</td><td>   </td><td>0.9630689</td><td>0.8845903</td><td>1.0484649</td></tr>
  <tr><td>diag_2Diabetes       </td><td>-0.051929157</td><td>0.0495084120</td><td>-1.04889564</td><td> 2.942364e-01</td><td>   </td><td>0.9493961</td><td>0.8648507</td><td>1.0420843</td></tr>
  <tr><td>diag_2Digestive      </td><td>-0.155934654</td><td>0.0775036909</td><td>-2.01196423</td><td> 4.423453e-02</td><td>*  </td><td>0.8556151</td><td>0.7391957</td><td>0.9897442</td></tr>
  <tr><td>diag_2Injury         </td><td>-0.178988923</td><td>0.0948599735</td><td>-1.88687511</td><td> 5.918882e-02</td><td>.  </td><td>0.8361152</td><td>0.6987815</td><td>0.9989114</td></tr>
  <tr><td>diag_2Musculoskeletal</td><td>-0.033857049</td><td>0.1107840497</td><td>-0.30561303</td><td> 7.599019e-01</td><td>   </td><td>0.9667097</td><td>0.7842180</td><td>1.1904138</td></tr>
  <tr><td>diag_2Other          </td><td>-0.077084024</td><td>0.0351261254</td><td>-2.19449266</td><td> 2.820927e-02</td><td>*  </td><td>0.9258121</td><td>0.8665632</td><td>0.9891005</td></tr>
  <tr><td>diag_2Respiratory    </td><td>-0.065264765</td><td>0.0477940091</td><td>-1.36554279</td><td> 1.720949e-01</td><td>   </td><td>0.9368194</td><td>0.8561699</td><td>1.0249865</td></tr>
  <tr><td>diag_3Diabetes       </td><td>-0.046963422</td><td>0.0423694828</td><td>-1.10842565</td><td> 2.676888e-01</td><td>   </td><td>0.9541223</td><td>0.8809486</td><td>1.0333233</td></tr>
  <tr><td>diag_3Digestive      </td><td>-0.001843499</td><td>0.0777562600</td><td>-0.02370869</td><td> 9.810852e-01</td><td>   </td><td>0.9981582</td><td>0.8620371</td><td>1.1553276</td></tr>
  <tr><td>diag_3Injury         </td><td>-0.120078026</td><td>0.1048401374</td><td>-1.14534403</td><td> 2.520777e-01</td><td>   </td><td>0.8868512</td><td>0.7273160</td><td>1.0795854</td></tr>
  <tr><td>diag_3Musculoskeletal</td><td>-0.078950919</td><td>0.1062193390</td><td>-0.74328197</td><td> 4.573180e-01</td><td>   </td><td>0.9240853</td><td>0.7560518</td><td>1.1280833</td></tr>
  <tr><td>diag_3Other          </td><td>-0.079470675</td><td>0.0342788439</td><td>-2.31835925</td><td> 2.043791e-02</td><td>*  </td><td>0.9236051</td><td>0.8658785</td><td>0.9851707</td></tr>
  <tr><td>diag_3Respiratory    </td><td>-0.005092567</td><td>0.0554708711</td><td>-0.09180615</td><td> 9.268528e-01</td><td>   </td><td>0.9949204</td><td>0.8962213</td><td>1.1044124</td></tr>
  <tr><td>n_emergency          </td><td> 0.216328283</td><td>0.0264002294</td><td> 8.19418195</td><td> 2.643943e-16</td><td>***</td><td>1.2415099</td><td>1.1822193</td><td>1.3057433</td></tr>
  <tr><td>n_inpatient          </td><td> 0.383827889</td><td>0.0150281702</td><td>25.54056032</td><td>4.841353e-142</td><td>***</td><td>1.4678928</td><td>1.4272055</td><td>1.5102947</td></tr>
  <tr><td>n_lab_procedures     </td><td> 0.001063578</td><td>0.0007531879</td><td> 1.41210218</td><td> 1.579325e-01</td><td>   </td><td>1.0010641</td><td>0.9996458</td><td>1.0024849</td></tr>
  <tr><td>n_medications        </td><td> 0.001389491</td><td>0.0021909349</td><td> 0.63420012</td><td> 5.259561e-01</td><td>   </td><td>1.0013905</td><td>0.9972669</td><td>1.0055284</td></tr>
  <tr><td>n_outpatient         </td><td> 0.120890635</td><td>0.0137120597</td><td> 8.81637317</td><td> 1.258480e-18</td><td>***</td><td>1.1285015</td><td>1.1000870</td><td>1.1583729</td></tr>
  <tr><td>n_procedures         </td><td>-0.043869470</td><td>0.0091983519</td><td>-4.76927502</td><td> 1.859425e-06</td><td>***</td><td>0.9570789</td><td>0.9406329</td><td>0.9737829</td></tr>
  <tr><td>time_in_hospital     </td><td> 0.017843737</td><td>0.0054244633</td><td> 3.28949358</td><td> 1.005080e-03</td><td>** </td><td>1.0180039</td><td>1.0076614</td><td>1.0284549</td></tr>
</tbody>
</table>



##### Odds Ratios
To interpret the odds ratios in the model, we will separate them into categorical and numerical variables once more.

The odds ratio for categorical data is the percentage increase (or decrease) in the odds of readmission among patients within a particular case-category compared to those in the control or reference group. Therefore:

1. Patients in the [80-90], [70-80], and [60-70] age groups have 24.73%, 23.17%, and 15.04% higher odds of readmission, respectively, than those in the [40-50] group.
2. Patients with diabetes as their primary diagnosis had a 15.96% greater odds of readmission than those with a circulatory diagnosis. On the other hand, those with a secondary and additional secondary diagnosis of diabetes had a 5.06% and 4.59% decrease, respectively, as compared to those with circulatory.
3. Patients who were prescribed a diabetes medication had a 25.55% increase in the odds of readmission as compared to those without.


The odds ratio for numerical variables is the percentage increase (or decrease) in the odds of readmission for every unit increase (or decrease) in that variable. Therefore,

1. Every additional hospital day increases the odds of a patient's readmission by 1.8%.
2. An increase in the number of procedures performed during a patient's hospital stay reduces the odds of readmission by 4.29%.
3. With every increase in the number of outpatient, inpatient, and emergency department visits prior to hospitalization, the odds of readmission rise by 46.79%, 12.85%, and 24.15%, respectively.

## Recommendations
Using the odds ratios of the multivariate logistic model, the following groups should be the hospital's focus for their follow up efforts to better monitor patients with high probability of readmission:

1. Individuals that are at least 60 but below 90 years of age at the time of admission.
2. Primarily diagnosed with diabetes or was prescribed a diabetes medication.<br>
3. With either of the following characteristics: long hospitalization time or frequently visited before hospital stay for all either types (outpatient, inpatient, and emergency room).

Nevertheless, it is also advised to explore for additional characteristics that can help better predict the probability of readmission among patients, as the data used may be insufficient to reliably identify patient groups with the best readmission rates.

## Reference

Strack, B., DeShazo, J. P., Gennings, C., Olmo, J. L., Ventura, S., Cios, K. J., & Clore, J. N. (2014). *Impact of HbA1c measurement on hospital readmission rates: Analysis of 70,000 clinical database patient records.* *BioMed Research International, 2014,* 781670, 11 pages. [https://doi.org/10.1155/2014/781670](https://doi.org/10.1155/2014/781670)
