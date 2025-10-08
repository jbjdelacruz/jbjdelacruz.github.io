---
title: 'Patient Characteristics and Readmission Modeling'
collection: portfolio
permalink: /portfolio/patient-characteristics-and-readmission-modeling
date: 2023-03-06
last_updated: 2025-10-09
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

## 1. Background
### 1.1. Introduction
A healthcare organization has engaged our team to conduct a comprehensive analysis of ten years of patient readmission data following discharge. The objective is to evaluate whether factors such as initial diagnoses, number of procedures, and other clinical variables can improve the prediction of readmission likelihood. The insights from this analysis will support more proactive patient care strategies, enabling targeted follow-up and resource allocation for individuals at higher risk of readmission.

### 1.2. Objectives
The main objective of this report is to explore patient characteristics and readmissions. It specifically aims to:

- Describe the overall and by age characteristics of the patients.
- Investigate and model the patient readmissions by their representing features.
- Identify patient groups with the best readmission rates.

### 1.3. Libraries & Functions

```R
# Load required packages
library(tidyverse) 
library(dplyr)
library(ggplot2)
library(Amelia)
library(summarytools)
library(scales)
library(ggchicklet)
library(ggthemes)
library(ggpubr)
library(rwantshue)
library(questionr)

# ========================================================
# Function: GroupedMedian()
# Purpose: Compute the median of grouped data
# Reference: Mahto (2013)
# ========================================================

GroupedMedian <- function(frequencies, intervals, sep = NULL, trim = NULL) {
  
  # ----------------------------------------------------------
  # Step 1. Preprocessing intervals
  # ----------------------------------------------------------
  # If "sep" is specified, attempt to parse textual intervals
  # into numeric lower and upper boundaries.
  # Example: "20-29" → c(20, 29)
  if (!is.null(sep)) {
    if (is.null(trim)) pattern <- ""
    else if (trim == "cut") pattern <- "\\[|\\]|\\(|\\)"
    else pattern <- trim
    
    # Clean intervals and split into numeric matrix
    intervals <- sapply(
      strsplit(gsub(pattern, "", intervals), sep),
      as.numeric
    )
  }

  # ----------------------------------------------------------
  # Step 2. Calculate midpoints and cumulative frequencies
  # ----------------------------------------------------------
  Midpoints <- rowMeans(intervals)
  cf <- cumsum(frequencies)

  # ----------------------------------------------------------
  # Step 3. Identify the median class
  # ----------------------------------------------------------
  Midrow <- findInterval(max(cf) / 2, cf) + 1

  # ----------------------------------------------------------
  # Step 4. Extract parameters for grouped median formula
  # ----------------------------------------------------------
  L   <- intervals[1, Midrow]       # Lower class boundary of median class
  h   <- diff(intervals[, Midrow])  # Width of the median class
  f   <- frequencies[Midrow]        # Frequency of median class
  cf2 <- cf[Midrow - 1]             # Cumulative frequency before median class
  n_2 <- max(cf) / 2                # Half of total frequency (n/2)

  # ----------------------------------------------------------
  # Step 5. Apply the grouped median formula
  # ----------------------------------------------------------
  # Median = L + ((n/2 – cf_before) / f_median) * class_width
  median_value <- L + (n_2 - cf2) / f * h

  # Return median
  unname(median_value)
}

# ======================================================
# Function: plot_distribution()
# Purpose: Create standardized histogram + density plots
# ======================================================

plot_distribution <- function(data, var, 
                              fig_title, x_label,
                              binwidth = 1,
                              x_breaks = NULL, y_breaks = NULL,
                              x_limits = NULL, y_limits = NULL,
                              mean_x_offset = 0, mean_y = NULL,
                              fill_color = "#5AA7A7", density_color = "#FF6666",
                              mean_color = "red") {
  
  # Evaluate the variable input
  var <- rlang::enquo(var)
  
  # Compute variable mean
  var_mean <- mean(dplyr::pull(data, !!var), na.rm = TRUE)
  
  # Build the plot
  p <- ggplot(data, aes(x = !!var)) +
    geom_histogram(aes(y = after_stat(density)),
                   colour = "white",
                   fill = fill_color,
                   binwidth = binwidth) +
    geom_density(alpha = 0.2, fill = density_color) +
    geom_vline(aes(xintercept = var_mean),
               col = mean_color,
               linewidth = 0.6) +
    ggtitle(fig_title) +
    labs(x = x_label, y = "Density\n") +
    scale_x_continuous(expand = c(0.01, 0),
                       breaks = x_breaks,
                       limits = x_limits) +
    scale_y_continuous(expand = c(0.01, 0),
                       breaks = y_breaks,
                       limits = y_limits) +
    theme_economist() +
    scale_color_economist() +
    theme(
      plot.title = element_text(size = 12),
      panel.grid.minor = element_line(color = "grey",
                                      linetype = "dashed",
                                      linewidth = 0.3),
      panel.grid.major = element_line(color = "grey",
                                      linetype = "dashed",
                                      linewidth = 0.3)
    ) +
    annotate("text",
             x = var_mean + mean_x_offset,
             y = mean_y,
             label = paste("Mean =", round(var_mean, 4)),
             color = mean_color,
             size = 3.5)
  
  return(p)
}
```

### 1.4. Dataset
The [dataset](https://archive.ics.uci.edu/ml/datasets/Diabetes+130-US+hospitals+for+years+1999-2008) referenced was part of the clinical care system at 130 hospitals and integrated delivery networks in the United States ([Strack et al., 2014](#reference)).

![Variable Descriptions](/files/patient-characteristics-and-readmission-modeling/images/vars-desc.png)

```R                     
# Read 'readmissions' dataset
readmissions <- read_csv('data/hospital_readmissions.csv', show_col_types = FALSE)
#glimpse(readmissions)

# Mutate 'Missing' values to NA & convert character variables to factors
readmissions <- readmissions %>%
    mutate_all(~ if_else(.x == "Missing", NA, .x)) %>%
    mutate_if(is.character, as.factor)
head(readmissions)
```

| age &lt;fct&gt; | time_in_hospital &lt;dbl&gt; | n_lab_procedures &lt;dbl&gt; | n_procedures &lt;dbl&gt; | n_medications &lt;dbl&gt; | n_outpatient &lt;dbl&gt; | n_inpatient &lt;dbl&gt; | n_emergency &lt;dbl&gt; | medical_specialty &lt;fct&gt; | diag_1 &lt;fct&gt; | diag_2 &lt;fct&gt; | diag_3 &lt;fct&gt; | glucose_test &lt;fct&gt; | A1Ctest &lt;fct&gt; | change &lt;fct&gt; | diabetes_med &lt;fct&gt; | readmitted &lt;fct&gt; |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| [70-80) | 8 | 72 | 1 | 18 | 2 | 0 | 0 | NA               | Circulatory | Respiratory | Other       | no | no | no  | yes | no  |
| [70-80) | 3 | 34 | 2 | 13 | 0 | 0 | 0 | Other            | Other       | Other       | Other       | no | no | no  | yes | no  |
| [50-60) | 5 | 45 | 0 | 18 | 0 | 0 | 0 | NA               | Circulatory | Circulatory | Circulatory | no | no | yes | yes | yes |
| [70-80) | 2 | 36 | 0 | 12 | 1 | 0 | 0 | NA               | Circulatory | Other       | Diabetes    | no | no | yes | yes | yes |
| [60-70) | 1 | 42 | 0 |  7 | 0 | 0 | 0 | InternalMedicine | Other       | Circulatory | Respiratory | no | no | no  | yes | no  |
| [40-50) | 2 | 51 | 0 | 10 | 0 | 0 | 0 | NA               | Other       | Other       | Other       | no | no | no  | no  | yes |

```R
# Check NA's
colSums(is.na(readmissions)) # NA's per column
which(colSums(is.na(readmissions))>0) # column indices containing NA's
missmap(readmissions, col=c("red", "green"), legend=FALSE) # missingness map
```
              age  time_in_hospital  n_lab_procedures      n_procedures 
                0                 0                 0                 0 
    n_medications      n_outpatient       n_inpatient       n_emergency 
                0                 0                 0                 0 
    medical_specialty            diag_1            diag_2            diag_3 
                12382                 4                42               196 
     glucose_test           A1Ctest            change      diabetes_med 
                0                 0                 0                 0 
       readmitted 
                0 


    medical_specialty            diag_1            diag_2            diag_3 
                    9                10                11                12  


                    

![Missingness Map](/files/patient-characteristics-and-readmission-modeling/images/missingness_map.png)
         
## 2. Results & Discussion

### 2.1. Descriptive Statistics
The following information describe the characteristics of the sample composing of 25,000 patients admitted to the hospital after being discharged.

#### 2.1.1. Numerical

##### 2.1.1.2. Time in Hospital

![Fig. 1: Distribution of the Time Length in Hospital](/files/patient-characteristics-and-readmission-modeling/images/Fig1_time_in_hospital_dst_plot.png)

The mean and median lengths of hospital stay are 4.45 and 4 days, respectively, with a standard deviation of approximately 3 days. As shown in Figure 2, the distribution of hospital stay duration is positively skewed, indicating that most patients were hospitalized for shorter periods.

| Variable           |      N |    Mean | Std.Dev | Min | Q1 | Median | Q3 | Max |
| ------------------ | -----: | ------: | ------: | --: | -: | -----: | -: | --: |
| time_in_hospital   | 25,000 |  4.4533 |  3.0015 |   1 |  2 |      4 |  6 |  14 |

```R
# Summary statistics for numerical variables
sum_stats <- descr(readmissions) %>%
  t() %>%
  as.data.frame() %>%
  tibble::rownames_to_column("Variable") %>%
  select(Variable, N, Mean, Std.Dev, Min, Q1, Median, Q3, Max) %>%
  mutate(across(where(is.numeric), round, 4))

## Time in Hospital

# Fig. 1
plot_distribution(readmissions, time_in_hospital,
  fig_title = "Fig. 1: Distribution of the Time Length in Hospital\n",
  x_label = "\nNumber of days (from 1 to 14)",
  binwidth = 1,
  x_breaks = seq(0, 14, 2),
  y_breaks = seq(0, 0.20, 0.025),
  mean_x_offset = 1.45,
  mean_y = 0.1875
)

# Summary statistics
sum_stats %>% filter(Variable == "time_in_hospital")
```

##### 2.1.1.3. Number of Procedures

![Fig. 2: Distribution of the Number of Medical Procedures, Fig. 4: Distribution of the Number of Laboratory Procedures](/files/patient-characteristics-and-readmission-modeling/images/Fig2-3_n_procedures_dst_plot.png)

During hospitalization, patients underwent an average of approximately one medical procedure and 43 to 44 laboratory procedures, with standard deviations of 1.72 and 19.82, respectively. Figures 3 and 4 further illustrate distinct distributional patterns between the two procedure types: medical procedures exhibit positive skewness, indicating that most patients underwent few procedures, whereas laboratory procedures display a nearly symmetric distribution, suggesting a more consistent level of administration across patients.

| Variable           |      N |    Mean | Std.Dev | Min | Q1 | Median | Q3 | Max |
| ------------------ | -----: | ------: | ------: | --: | -: | -----: | -: | --: |
| n_procedures       | 25,000 |  1.3524 |  1.7152 |   0 |  0 |      1 |  2 |   6 |
| n_lab_procedures   | 25,000 | 43.2408 | 19.8186 |   1 | 31 |     44 | 57 | 113 |

```R
# Fig. 2: Number of Procedures
n_procedures_hs_dst_plot <- plot_distribution(readmissions, n_procedures,
  fig_title = "Fig. 2: Distribution of the Number of Medical Procedures\n",
  x_label = "\nNumber of procedures performed during the hospital stay",
  binwidth = 0.5,
  x_breaks = seq(0, 7, 2),
  y_breaks = seq(0, 1, 0.25),
  mean_x_offset = 0.72,
  mean_y = 0.7
)

# Fig. 3: Number of Lab Procedures
n_lab_procedures_hs_dst_plot <- plot_distribution(readmissions, n_lab_procedures,
  fig_title = "Fig. 3: Distribution of the Number of Laboratory Procedures\n",
  x_label = "\nNumber of lab procedures performed during the hospital stay",
  binwidth = 3,
  x_breaks = seq(0, 120, 30),
  y_breaks = seq(0, 0.025, 0.005),
  y_limits = c(0, 0.025),
  mean_x_offset = 14,
  mean_y = 0.024
)

ggarrange(n_procedures_hs_dst_plot, n_lab_procedures_hs_dst_plot, ncol = 1, nrow = 2)

# Summary statistics
sum_stats %>% filter(str_detect(Variable, "procedures"))
```

##### 2.1.1.4. Number of Medications

![Fig. 4: Distribution of the Number of Medications](/files/patient-characteristics-and-readmission-modeling/images/Fig4_n_medications_hs_dst_plot.png)

The average number of medications administered during hospitalization is 16.25, with a median of 15 and a standard deviation of 8.06. This indicates that medication usage varied notably among patients, with some receiving substantially more medications than others. The distribution is slightly right-skewed, suggesting that while most patients received a moderate number of medications, a smaller proportion were prescribed a relatively higher number.

| Variable           |      N |    Mean | Std.Dev | Min | Q1 | Median | Q3 | Max |
| ------------------ | -----: | ------: | ------: | --: | -: | -----: | -: | --: |
| n_medications      | 25,000 | 16.2524 |  8.0605 |   1 | 11 |     15 | 20 |  79 |

```R
# Fig. 4: Number of Medications
plot_distribution(readmissions, n_medications,
  fig_title = "Fig. 4: Distribution of the Number of Medications\n",
  x_label = "\nNumber of medications administered during the hospital stay",
  binwidth = 1,
  x_breaks = seq(0, 80, 20),
  y_breaks = seq(0, 0.065, 0.01),
  y_limits = c(0, 0.065),
  mean_x_offset = 9,
  mean_y = 0.065
)

# Summary statistics
sum_stats %>% filter(Variable == "n_medications")
```

##### 2.1.1.5. Number of Visits

![Fig. 5: Distribution of the Number of Outpatient Visits, Fig. 6: Distribution of the Number of Inpatient Visits, Fig. 7: Distribution of the Number of Emergency Room Visits](/files/patient-characteristics-and-readmission-modeling/images/Fig5-7_n_visits_dst_plot.png)

The average numbers of outpatient, inpatient, and emergency room visits in the year preceding hospitalization are all below one, with median values of zero across visit types. This indicates that most patients had no recorded visits prior to admission. The moderate standard deviations suggest some variation in visit frequency, as a small subset of patients had multiple visits. Overall, the positively skewed distributions imply that frequent pre-hospital visits were uncommon within the patient population.

| Variable           |      N |    Mean | Std.Dev | Min | Q1 | Median | Q3 | Max |
| ------------------ | -----: | ------: | ------: | --: | -: | -----: | -: | --: |
| n_outpatient       | 25,000 |  0.3664 |  1.1955 |   0 |  0 |      0 |  0 |  33 |
| n_inpatient        | 25,000 |  0.6160 |  1.1780 |   0 |  0 |      0 |  1 |  15 |
| n_emergency        | 25,000 |  0.1866 |  0.8859 |   0 |  0 |      0 |  0 |  64 |

```R
# Fig. 5: Outpatient Visits
n_outpatient_hs_dst_plot <- plot_distribution(readmissions, n_outpatient,
  fig_title = "Fig. 5: Distribution of the Number of Outpatient Visits\n",
  x_label = "\nNumber of outpatient visits in the year before a hospital stay",
  binwidth = 1,
  x_breaks = seq(0, 35, 5),
  y_breaks = seq(0, 1, 0.2),
  y_limits = c(0, 1),
  mean_x_offset = 3.6,
  mean_y = 0.97
)

# Fig. 6: Inpatient Visits
n_inpatient_hs_dst_plot <- plot_distribution(readmissions, n_inpatient,
  fig_title = "Fig. 6: Distribution of the Number of Inpatient Visits\n",
  x_label = "\nNumber of inpatient visits in the year before the hospital stay",
  binwidth = 1,
  x_breaks = seq(0, 18, 3),
  y_breaks = seq(0, 1, 0.2),
  y_limits = c(0, 1),
  mean_x_offset = 2,
  mean_y = 0.97
)

# Fig. 7: Emergency Room Visits
n_emergency_hs_dst_plot <- plot_distribution(readmissions, n_emergency,
  fig_title = "Fig. 7: Distribution of the Number of Emergency Room Visits\n",
  x_label = "\nNumber of visits to the emergency room in the year before the hospital stay",
  binwidth = 1,
  x_breaks = seq(0, 65, 10),
  y_breaks = seq(0, 1, 0.2),
  y_limits = c(0, 1),
  mean_x_offset = 6.7,
  mean_y = 0.97
)

ggarrange(n_outpatient_hs_dst_plot, n_inpatient_hs_dst_plot, n_emergency_hs_dst_plot, ncol = 1, nrow = 3)

# Summary statistics
sum_stats %>% filter(Variable %in% c("n_outpatient", "n_inpatient", "n_emergency"))
```

#### 2.1.2. Categorical

##### 2.1.2.1. Age

![Fig. 8: Bar Graph of the Patients' Age Groups](/files/patient-characteristics-and-readmission-modeling/images/Fig8_age_bar_plot.png)

The grouped mean and median ages are approximately 68 and 69 years, respectively, with a standard deviation of about 13 years, indicating that the hospitals primarily admitted elderly patients. Moreover, Figure 8 shows that the age distribution is approximately symmetric around the mean.

|  age_group  | class_interval |      n | lower | upper | class_mark  |  cumulative  | n_times_cm |
|-------------|----------------|-------:|------:|------:|------------:|-------------:|-----------:|
| [40–50)     | 40–50          |  2,532 |    40 |    50 |         45  |       2,532  |    113,940 |
| [50–60)     | 50–60          |  4,452 |    50 |    60 |         55  |       6,984  |    244,860 |
| [60–70)     | 60–70          |  5,913 |    60 |    70 |         65  |      12,897  |    384,345 |
| [70–80)     | 70–80          |  6,837 |    70 |    80 |         75  |      19,734  |    512,775 |
| [80–90)     | 80–90          |  4,516 |    80 |    90 |         85  |      24,250  |    383,860 |
| [90–100)    | 90–100         |    750 |    90 |   100 |         95  |      25,000  |     71,250 |

| Variable   |   Mean   |  Std.Dev |  Median  |
|------------|---------:|---------:|---------:|
| Age group  | 68.4412  | 13.1561  | 69.3286  |

```R

## Age

# Frequency distribution table
age_fdt <- readmissions %>%
  count(age, name = "n") %>% 
  mutate(
    lower = as.numeric(str_extract(age, "(?<=\\[|\\()(\\d+)")),
    upper = as.numeric(str_extract(age, "(\\d+)(?=\\)|\\])")),
    class_interval = paste(lower, upper, sep = "-"),
    class_mark = (lower + upper) / 2,
    cumulative = cumsum(n),
    n_times_cm = n * class_mark
  ) %>%
  select(age, class_interval, everything()) %>%
  rename(age_group = age)

# Figure 8: Age
age_bar_plot <- ggplot(age_fdt, aes(group=1)) + 
	geom_chicklet(aes(x = age,
                      y = n,
					  group=1), 
                  color="white",
                  fill="#6C8CBF",
                  radius = grid::unit(1, "mm"), position="stack") +
    
	# Plot mean line
	geom_vline(xintercept=3.344, color="red", linewidth=0.6) +
 
	ggtitle("Fig. 8: Bar Graph of the Patients' Age Groups\n") +
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

# Summary statistics
age_stats <- age_fdt %>%
  summarise(
    Variable = "Age group",
    Mean = sum(n * class_mark) / sum(n),
    Std.Dev = sqrt(sum(n * (class_mark - (sum(n * class_mark) / sum(n)))^2) / sum(n)),
    Median = GroupedMedian(frequencies = n, intervals = class_interval, sep = "-")
  ) %>%
  mutate(across(where(is.numeric), ~ round(.x, 4)))
```

##### 2.1.2.1. Medical Specialty

<img src="documentation/Fig9_medical_specialty_bar_plot.png"/>

Of the 12,618 (50.47%) patients with a recorded admitting physician, 3,565 had an admitting physician whose specialty was Internal Medicine.

```R
# Frequency Distribution Table (FDT) for the Specialty of the Admitting Physician
medical_specialty_fdt <- readmissions %>%
  select(medical_specialty) %>%
  group_by(medical_specialty) %>%
  count() %>%
  ungroup() %>%
  mutate(perc = label_percent(accuracy=0.01)(n/sum(n))) %>%
  arrange(desc(n))

# Figure 9:
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

##### 2.1.2.2. Diagnoses

<img src="documentation/Fig10_diag_stacked_bar_plot.png"/>

Most of the circulatory diagnoses or 7,824 (31.30%) were identified as primary, whereas most of the patients who had a diagnosis other than circulatory, diabetes, digestive, injury, musculoskeletal, or respiratory received it as a secondary (9,056 or 36.22%) and additional secondary (9,107 or 36.43%).


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

##### 2.1.2.3. Prediabetes Test

<img src="documentation/Fig11_diab_test_stacked_bar_plot.png"/>

A total of 20,938 (83.75%) had not performed an A1C test, while 23,625 (94.50%) had not performed a glucose test. For those who had performed, however, a high result was seen more than a normal one for A1C tests and almost equal number in high and normal results for glucose test.

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

##### 2.1.2.4. Diabetes Medication

<img src="documentation/Fig12_diab_ques_stacked_bar_plot.png"/>

Among all the patients, 19,228 (76.91%) had been prescribed a diabetes medication, while 13,497 (53.99%) had not changed diabetes medication.

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

##### 2.1.2.5. Readmission

<img src="documentation/Fig13_readmitted_bar_plot.png"/>

A slightly higher number of patients were not readmitted to the hospital compared to those who were readmitted. The blue bar represents the number of patients who were readmitted, which is 11,754 (47.02%), while the orange bar represents the number of patients who were not readmitted, which is 13,246 (52.98%)


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

### 2.2. Correlation Analysis
In this section, the patients' readmission will be analyzed by different representing features through contingency tables, graphs, and regression analysis.

As previously mentioned, the number of readmitted patients is 11,754 which translates to an overall readmission rate of 47.02%.

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



### 2.3. Logistic Regression

#### 2.3.1. Model
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



#### 2.3.2. Odds Ratio
To interpret the odds ratios in the model, we will separate them into categorical and numerical variables once more.

The odds ratio for categorical data is the percentage increase (or decrease) in the odds of readmission among patients within a particular case-category compared to those in the control or reference group. Therefore:

1. Patients in the [80-90], [70-80], and [60-70] age groups have 24.73%, 23.17%, and 15.04% higher odds of readmission, respectively, than those in the [40-50] group.
2. Patients with diabetes as their primary diagnosis had a 15.96% greater odds of readmission than those with a circulatory diagnosis. On the other hand, those with a secondary and additional secondary diagnosis of diabetes had a 5.06% and 4.59% decrease, respectively, as compared to those with circulatory.
3. Patients who were prescribed a diabetes medication had a 25.55% increase in the odds of readmission as compared to those without.


The odds ratio for numerical variables is the percentage increase (or decrease) in the odds of readmission for every unit increase (or decrease) in that variable. Therefore,

1. Every additional hospital day increases the odds of a patient's readmission by 1.8%.
2. An increase in the number of procedures performed during a patient's hospital stay reduces the odds of readmission by 4.29%.
3. With every increase in the number of outpatient, inpatient, and emergency department visits prior to hospitalization, the odds of readmission rise by 46.79%, 12.85%, and 24.15%, respectively.

## 3. Recommendations
Using the odds ratios of the multivariate logistic model, the following groups should be the hospital's focus for their follow up efforts to better monitor patients with high probability of readmission:

1. Individuals that are at least 60 but below 90 years of age at the time of admission.
2. Primarily diagnosed with diabetes or was prescribed a diabetes medication.<br>
3. With either of the following characteristics: long hospitalization time or frequently visited before hospital stay for all either types (outpatient, inpatient, and emergency room).

Nevertheless, it is also advised to explore for additional characteristics that can help better predict the probability of readmission among patients, as the data used may be insufficient to reliably identify patient groups with the best readmission rates.

## 4. Reference

Mahto, A. (2013, September 21). Answer to “How to calculate the median on grouped dataset?” Stack Overflow. http://stackoverflow.com/a/18931054/1270695

Strack, B., DeShazo, J. P., Gennings, C., Olmo, J. L., Ventura, S., Cios, K. J., & Clore, J. N. (2014). *Impact of HbA1c measurement on hospital readmission rates: Analysis of 70,000 clinical database patient records.* *BioMed Research International, 2014,* 781670, 11 pages. [https://doi.org/10.1155/2014/781670](https://doi.org/10.1155/2014/781670)
