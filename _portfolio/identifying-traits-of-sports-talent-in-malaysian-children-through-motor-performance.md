---
title: 'Identifying Traits of Sports Talent in Malaysian Children Through Motor Performance'
collection: portfolio
permalink: /portfolio/identifying-traits-of-sports-talent-in-malaysian-children-through-motor-performance
date: 2022-12-18
last_updated: 2025-10-01
excerpt: 'This project—which earned first place in a [24-hour DataCamp challenge](https://www.datacamp.com/competitions/childrens-motor-performance?entry=7b91f332-e08a-41a0-9db4-a1c5c1ac5e28)—investigates how the Motor Performance Index (MPI), based on four essential motor skills (power, speed, flexibility, and coordination), relates to children’s attributes such as age, gender, weight, and height. Through multiple linear regression, it identifies the most significant predictors of motor performance, offering valuable insights for early sports talent identification.'
venue: 'DataCamp'
categories:
  - R
  - Regression
slidesurl: []
images:
  - '/files/identifying-traits-of-sports-talent-in-malaysian-children-through-motor-performance/images/page-1.png'
  - image: '/files/identifying-traits-of-sports-talent-in-malaysian-children-through-motor-performance/images/page-2.png'
    link:  'https://www.datacamp.com/competitions/why-hair-loss?entry=05f354fb-dd89-4631-a682-00499eab8fb2'
# link: 'https://www.datacamp.com/datalab/w/7b91f332-e08a-41a0-9db4-a1c5c1ac5e28'
# url: 'https://www.datacamp.com/datalab/w/7b91f332-e08a-41a0-9db4-a1c5c1ac5e28'
thumbnail: '/images/projects/project3-cover.png'
featured: false
doc_type: 'Full Report'
---

# Identifying Traits of Sports Talent in Malaysian Children Through Motor Performance

## Background

Evaluating children's physical abilities is crucial for gaining insight into their growth and development, as well as for recognizing potential talent in sports. One common metric for this assessment is the Motor Performance Index (MPI), which measures different aspects of a child's motor skills.

### Objectives
The primary objective of this report is to analyze datasets related to children's motor performance using summary statistics, visualizations, statistical models, and narratives. Specifically, it aims to:

1. Explore the demographic profile and characteristics of the sample.
2. Understand the relationship between the four motor skills.
3. Explain how the children's  attributes affect their motor skills.

### Data Used
The dataset used in the analysis is a slightly cleaned version of a dataset described in the article entitled ["Kids motor performances datasets"](https://www.sciencedirect.com/science/article/pii/S2352340920314633) from the Data in Brief journal. It consists of a single CSV file, where each row represents a seven year old Malaysian child. The following lists describe its variables: 

Four properties of motor skills were recorded.

- POWER ($$cm$$): Distance of a two-footed standing jump.
- SPEED ($$sec$$): Time taken to sprint 20m.
- FLEXIBILITY ($$cm$$): Distance reached forward in a sitting position.
- COORDINATION (no.): Number of catches of a ball, out of ten.

Attributes of the children are included.

- STATE: The Malaysian state where the child resides.
- RESIDENTIAL: Whether the child lives in a rural or urban area.
- GENDER: The child's gender, `Female` or `Male`.
- AGE: The child's age in years.
- WEIGHT ($$kg$$): The child's bodyweight in kg.
- HEIGHT ($$cm$$): The child's height in cm.
- BMI ($$kg/m^{2}$$): The child's body mass index (weight in kg divided by height in meters squared).
- CLASS (BMI): Categorization of the BMI: `SEVERE THINNESS`, `THINNESS`, `NORMAL`, `OVERWEIGHT`, `OBESITY`.

Full details of these metrics are described in sections 2.2 to 2.5 of the linked article.

```R
# Load required packages
library(tidyverse)
library(dplyr)
library(ggplot2)
library(scales)
library(readr)

# Read the data set from the CSV file
motor_performance <- read_csv("data/motor-performance.csv", show_col_types = FALSE)

# Make a character vector for all 8 attributes
attributes <- c("STATE",
                "RESIDENTIAL",
                "GENDER",
                "AGE",
                "WEIGHT (kg)",
                "HEIGHT (CM)",
                "BMI (kg/m2)",
                "CLASS (BMI)")

# Make a character vector for all 4 motor skills
motor_skills <- c("POWER (cm)",
                  "SPEED (sec)",
                  "FLEXIBILITY (cm)",
                  "COORDINATION (no.)")

# Make a character vector for all numerical variables
num_vars <- c("AGE",
              "WEIGHT (kg)",
              "HEIGHT (cm)",
              "BMI (kg/m2)",
              "POWER (cm)",
              "SPEED (sec)",
              "FLEXIBILITY (cm)", 
              "COORDINATION (no.)")
```

## Results & Discussion
### Descriptive Analysis

The following information describe the demographic profile and characteristics of the sample composing of 1998 seven-year-old children who are in national primary regional school and participating in Malaysia's physical fitness test (SEGAK).

#### Numerical Variables

![Box Plots of the Numerical Attributes and Motor Skills](/files/identifying-traits-of-sports-talent-in-malaysian-children-through-motor-performance/images/final_boxplots.png)

- As expected, the mean age of the children is around 7, with a standard deviation of 0.05.
- The mean weight is 22.21 kg, with a standard deviation of 5.41.
- The mean height is 118.26 cm, with a standard deviation of 5.97.
- The mean body mass index (BMI) is 15.77 (kg/m<sup>2</sup>), with a standard deviation of 3.06.
- The mean distance of a two-footed standing jump is 96.20 cm, with a standard deviation of 17.59.
- The mean time taken to sprint 20 m is 5.16 sec, with a standard deviation of 0.71.
- The mean distance reached forward in a sitting position is 26.2615 cm, with a standard deviation of 4.93.
- Out of ten, the mean number of ball catches is about 4, with a standard deviation of about 3.
- We can see from the boxplots below that all numerical variables seem to be symmetrically distributed at their median.

```R
# Subset numerical variable columms
stacked_num_vars <- stack(
    motor_performance %>% 
    dplyr::select(all_of(num_vars))
) %>%
    rename(Variable = ind) %>%
  mutate(Type = ifelse(Variable %in% c("AGE","WEIGHT (kg)","HEIGHT (cm)","BMI (kg/m2)"),
                         "Attribute", "Motor skill"))

# Summary statistics for numerical variables
sum_stats <- data.frame(Variable = num_vars) %>%
  bind_cols(as.data.frame(t(motor_performance %>%
                              summarise_at(num_vars, list(mean)) %>%
                              bind_rows(motor_performance %>%
                                        summarise_at(num_vars, list(sd)), motor_performance %>%
                                        summarise_at(num_vars, list(min)),
                                        motor_performance %>%
                                        summarise_at(num_vars, list(median)),
                                        motor_performance %>%
                                        summarise_at(num_vars, list(max)))
                             )) %>%
              rename(Mean = V1,
                     `Std. Dev.` = V2,
                     `Min.` = V3,
                     `Median` = V4,
                     `Max.` = V5))

rownames(sum_stats) <- 1: nrow(sum_stats)

# Boxplots for numerical variables
boxplots <- ggplot(stacked_num_vars, aes(x = Variable, y = values, fill=Type)) +       
  geom_boxplot(width = 0.75) +
  theme(legend.position = "top",  
          legend.justification=0.48,
          legend.key.size = unit(7, 'mm'),
          legend.text = element_text(margin = margin(r = 10, unit = "pt"),
                                     size = 8.5,
                                     color = "#65707C",
                                     family="sans serif"),
          legend.title = element_text(color = "#65707C",
                                   face = "bold",
                                   size = 9,
                                   family="sans serif"),  
          legend.key = element_rect(fill = NA),
          axis.title = element_text(color = "#65707C",
                                    face = "bold",
                                    size = 8.5,
                                    family="sans serif"),
          axis.text = element_text(color = "#65707C",
                                   size = 8,
                                   family="sans serif"),
          axis.line = element_line(colour = "grey",
                                   linewidth = 0.5),
          panel.grid.major = element_line(color = "grey",
                                          linetype="dashed",
                                          linewidth=0.25),
          panel.background = element_blank(),
          panel.border = element_rect(color="grey40",
                                      fill=NA),  
          panel.spacing = unit(2, "lines"),
          plot.title = element_text(color = "#65707C",
                                    hjust = 0.5,
                                    face = "bold",
                                    size= 11,
                                    family = "sans serif")) +
  labs(x = "\nVariable \n(unit)\n", y = "", fill = "Type:  ") +
  ggtitle("\n Fig. 1: Box Plots of the Numerical Attributes and Motor Skills          ") +
  scale_x_discrete(labels=c("AGE",
              "WEIGHT \n(kg)",
              "HEIGHT \n(cm)",
              "BMI \n(kg/m2)",
              "POWER \n(cm)",
              "SPEED \n(sec)",
              "FLEXIBILITY \n(cm)", 
              "COORDINATION \n(no.)")) + 
  scale_y_continuous(expand = c(0.01, 0),
                       limits = c(0, 175), 
                       breaks = seq(0, 175, by = 25)) +
  scale_fill_manual(values = c('#025C70',
                                 '#007E6C'))

# Save ggplot data
dat <- ggplot_build(boxplots)$data[[1]]

# Reformat boxplots' median line
final_boxplots <- boxplots + geom_segment(data=dat, aes(x=xmin, 
                                      xend=xmax,
                                      y=middle-.15,
                                      yend=middle-.15), 
                        color="grey75", 
                        linewidth=0.5,
                        inherit.aes = FALSE)
```

#### Categorical Variables

- The five states where most of the sampled children reside are Selangor, Johor, Sabah, Sarawak, and Perak.

| STATE           | Number of Children | Percentage |
|-----------------|--------------------|------------|
| SELANGOR        | 349                | 17.47%     |
| JOHOR           | 241                | 12.06%     |
| SABAH           | 202                | 10.11%     |
| SARAWAK         | 199                | 9.96%      |
| PERAK           | 166                | 8.31%      |
| KEDAH           | 133                | 6.66%      |
| PAHANG          | 129                | 6.46%      |
| KELANTAN        | 128                | 6.41%      |
| PULAU PINANG    | 122                | 6.11%      |
| KUALA LUMPUR    | 90                 | 4.50%      |
| TERENGGANU      | 90                 | 4.50%      |
| NEGERI SEMBILAN | 72                 | 3.60%      |
| MELAKA          | 45                 | 2.25%      |
| PERLIS          | 16                 | 0.80%      |
| PUTRAJAYA       | 11                 | 0.55%      |
| LABUAN          | 5                  | 0.25%      |

- The distribution of sampled children is almost balanced, with 1,052 urban residents (53%) and 946 rural residents (47%). 
- There is an equal distribution between male (999) and female (999) groups.
- Majority or about 71% (1,419) of the sampled children have normal BMIs.

| CLASS (BMI)     | Number of Children | Percentage |
|-----------------|--------------------|------------|
| NORMAL          | 1419               | 71.02%     |
| OBESITY         | 218                | 10.91%     |
| OVERWEIGHT      | 205                | 10.26%     |
| THINNESS        | 108                | 5.41%      |
| SEVERE THINNESS | 48                 | 2.40%      |

```R
# Count children per state
state_counts <- motor_performance %>%
  count(STATE, sort = TRUE)  %>%
  mutate(Percentage = label_percent(accuracy=0.01)(n/1998)) %>%
  rename(`Number of Children` = n)      

# Count children per residential
residential_counts <- motor_performance %>%
	count(RESIDENTIAL, sort = TRUE) %>%
  mutate(Percentage = label_percent(accuracy=0.01)(n/1998)) %>%
  rename(`Number of Children` = n)      

# Count children per gender
gender_counts <- motor_performance %>%
  count(GENDER, sort = TRUE) %>%
  mutate(Percentage = label_percent(accuracy=0.01)(n/1998)) %>%
  rename(`Number of Children` = n)      

# Count children per BMI class
bmi_class_counts <- motor_performance %>%
  count(`CLASS (BMI)`, sort = TRUE) %>%
  mutate(Percentage = label_percent(accuracy=0.01)(n/1998)) %>%
  rename(`Number of Children` = n)              
```

### Correlation Analysis
Using the sample, the following observations can be said about the pairwise correlations of the four motor skills:
- There is a low negative correlation of 0.36 between power and speed.
- Other pairs of variables seem to have negligible levels of correlation. 

(This [table](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3576830/table/T1/?report=objectonly) was used for interpreting correlation coefficients.)


```R
# Install & load the "corrplot" package for correlation plots
#install.packages("corrplot")
library(corrplot)

# Subset motor skill columns
motor_skills_df <- motor_performance %>%
  dplyr::select(all_of(motor_skills)) %>%
    rename(POWER = `POWER (cm)`,
           SPEED = `SPEED (sec)`,
           FLEXIBILITY = `FLEXIBILITY (cm)`,
           COORDINATION = `COORDINATION (no.)`)

# Color scheme for the correlation plot
col <- colorRampPalette(c("#025C70", "white", "#007E6C"))

# Correlation plot for motor skills
#par(family="sans serif")
#corrplot(cor(motor_skills_df), 
#         method="color", 
#         col=col(20),
#         order="FPC",
#         type="lower",
#         diag=FALSE, 
#         cl.cex=0.5,
#         tl.cex=0.9,
#         tl.srt=0,
#         tl.col="#65707C",
#         col.main="#65707C",
#         addCoef.col="#65707C",
#         addgrid.col="black",
#         main="\nFig. 6: Correlation Plot of the Four Motor Skills          ",
#         cex.main=1.1,
#         mar = c(5,3.5,6,0)
#        )

# Pairwise correlation coefficients for motor skills
motor_performance.cor <- cor(motor_performance %>%
  dplyr::select(all_of(motor_skills)))
                             
pairwise_corr <- data.frame(Variable = num_vars[5:8]) %>% 
  bind_cols(as.data.frame(round(motor_performance.cor, 2)) %>%
    dplyr::select(all_of(motor_skills)))

rownames(pairwise_corr) <- 1:nrow(pairwise_corr)
```

<img src="documentation/corrplot.png" alt="" title=""/>

### Regression Analysis

The Motor Performance Index (MPI) was computed based on the sum of the four motors skills, which served as the dependent variable in a general linear model (GLM). The independent variables included all eight child attributes, with dummy variables automatically generated for each categorical attribute.

#### Full Model

The following infomation describe the full model:

- It has a residual standard error of 18.5998 and an R-square of 0.1143 (i.e. 11.43% of the variation in MPI can be explained by the 25 independent variables).
- Seven (7) independent variables were significant at 0.05 level, which are:</br>
    ㅤ1. STATE KEDAH</br>
    ㅤ2. STATE KUALA LUMPUR</br>
    ㅤ3. STATE PULAU PINANG</br>
    ㅤ4. STATE SABAH</br>
    ㅤ5. STATE SELANGOR</br>
    ㅤ6. GENDER M</br>
    ㅤ7. CLASS (BMI) THINNESS</br>


```R
## ---------- Regression Analysis

# Create an index variable called MPI
data_for_regression <- motor_performance %>% 
    mutate(MPI = (`POWER (cm)` + `SPEED (sec)` + `FLEXIBILITY (cm)` + `COORDINATION (no.)`))

## ----- Full Model
full_model <- lm(MPI ~ STATE + RESIDENTIAL + GENDER + AGE + `WEIGHT (kg)` + `HEIGHT (cm)` + `BMI (kg/m2)` + `CLASS (BMI)`, data = data_for_regression)

# Summary statistics of the full model
paste("Residual standard error:", round(summary.lm(full_model)$sigma, 4), 
      " ,  R-square: ", round(summary.lm(full_model)$r.squared, 4), 
      " ,  Adj. R-square: ", round(summary.lm(full_model)$adj.r.squared, 4))

# Full model's table of estimated coefficients, their SEs, t-stats, and (two-sided) p-values
summary_full <- data.frame(
    Variable = rownames(as.data.frame(summary.lm(full_model)$coefficients))
) %>%
  bind_cols(as.data.frame(summary.lm(full_model)$coefficients))

rownames(summary_full) <- 1:nrow(summary_full)
summary_full
```


<span style=white-space:pre-wrap>'Residual standard error: 18.5998  ,  R-square:  0.1143  ,  Adj. R-square:  0.103'</span>



<table class="dataframe">
<!-- <caption>A data.frame: 26 × 5</caption> -->
<thead>
  <tr><th></th><th scope=col>Variable</th><th scope=col>Estimate</th><th scope=col>Std. Error</th><th scope=col>t value</th><th scope=col>Pr(&gt;|t|)</th></tr>
  <!-- <tr><th></th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th></tr> -->
</thead>
<tbody>
  <tr><th scope=row>1</th><td>(Intercept)                 </td><td>65.0217354</td><td>69.1123732</td><td> 0.94081179</td><td>3.469165e-01</td></tr>
  <tr><th scope=row>2</th><td>STATEKEDAH                  </td><td> 4.9864502</td><td> 2.0291488</td><td> 2.45740983</td><td>1.407982e-02</td></tr>
  <tr><th scope=row>3</th><td>STATEKELANTAN               </td><td>-0.2035077</td><td> 2.0697095</td><td>-0.09832669</td><td>9.216829e-01</td></tr>
  <tr><th scope=row>4</th><td>STATEKUALA LUMPUR           </td><td> 4.9068455</td><td> 2.3175311</td><td> 2.11727272</td><td>3.436159e-02</td></tr>
  <tr><th scope=row>5</th><td>STATELABUAN                 </td><td>-4.8443791</td><td> 8.4380719</td><td>-0.57410973</td><td>5.659590e-01</td></tr>
  <tr><th scope=row>6</th><td>STATEMELAKA                 </td><td>-5.2062606</td><td> 3.0569554</td><td>-1.70308686</td><td>8.870939e-02</td></tr>
  <tr><th scope=row>7</th><td>STATENEGERI SEMBILAN        </td><td>-3.4623878</td><td> 2.5126976</td><td>-1.37795642</td><td>1.683731e-01</td></tr>
  <tr><th scope=row>8</th><td>STATEPAHANG                 </td><td>-1.5492991</td><td> 2.0377064</td><td>-0.76031522</td><td>4.471571e-01</td></tr>
  <tr><th scope=row>9</th><td>STATEPERAK                  </td><td>-2.4083089</td><td> 1.8931314</td><td>-1.27212978</td><td>2.034770e-01</td></tr>
  <tr><th scope=row>10</th><td>STATEPERLIS                 </td><td>-2.0499381</td><td> 4.8442085</td><td>-0.42317297</td><td>6.722152e-01</td></tr>
  <tr><th scope=row>11</th><td>STATEPULAU PINANG           </td><td>-4.4417736</td><td> 2.0795204</td><td>-2.13596055</td><td>3.280546e-02</td></tr>
  <tr><th scope=row>12</th><td>STATEPUTRAJAYA              </td><td>-5.0581068</td><td> 5.7489537</td><td>-0.87983085</td><td>3.790582e-01</td></tr>
  <tr><th scope=row>13</th><td>STATESABAH                  </td><td> 6.4421313</td><td> 1.7943039</td><td> 3.59032345</td><td>3.383426e-04</td></tr>
  <tr><th scope=row>14</th><td>STATESARAWAK                </td><td> 0.8817717</td><td> 1.8214728</td><td> 0.48409822</td><td>6.283699e-01</td></tr>
  <tr><th scope=row>15</th><td>STATESELANGOR               </td><td> 4.1372652</td><td> 1.5689123</td><td> 2.63702772</td><td>8.429271e-03</td></tr>
  <tr><th scope=row>16</th><td>STATETERENGGANU             </td><td> 0.8072483</td><td> 2.3244795</td><td> 0.34728131</td><td>7.284170e-01</td></tr>
  <tr><th scope=row>17</th><td>RESIDENTIALURBAN            </td><td>-1.5802387</td><td> 0.8839906</td><td>-1.78761927</td><td>7.399097e-02</td></tr>
  <tr><th scope=row>18</th><td>GENDERM                     </td><td>10.0430571</td><td> 0.8429613</td><td>11.91401982</td><td>1.185731e-31</td></tr>
  <tr><th scope=row>19</th><td>AGE                         </td><td> 0.8084578</td><td> 8.4729958</td><td> 0.09541582</td><td>9.239942e-01</td></tr>
  <tr><th scope=row>20</th><td>`WEIGHT (kg)`               </td><td>-1.3840064</td><td> 0.7113665</td><td>-1.94556022</td><td>5.184951e-02</td></tr>
  <tr><th scope=row>21</th><td>`HEIGHT (cm)`               </td><td> 0.5578033</td><td> 0.2966919</td><td> 1.88007578</td><td>6.024505e-02</td></tr>
  <tr><th scope=row>22</th><td>`BMI (kg/m2)`               </td><td> 1.3365364</td><td> 1.0106452</td><td> 1.32245852</td><td>1.861689e-01</td></tr>
  <tr><th scope=row>23</th><td>`CLASS (BMI)`OBESITY        </td><td>-3.5346197</td><td> 2.8041009</td><td>-1.26051805</td><td>2.076317e-01</td></tr>
  <tr><th scope=row>24</th><td>`CLASS (BMI)`OVERWEIGHT     </td><td> 0.9695707</td><td> 1.7353525</td><td> 0.55871684</td><td>5.764184e-01</td></tr>
  <tr><th scope=row>25</th><td>`CLASS (BMI)`SEVERE THINNESS</td><td>-3.3867506</td><td> 2.9608854</td><td>-1.14383036</td><td>2.528328e-01</td></tr>
  <tr><th scope=row>26</th><td>`CLASS (BMI)`THINNESS       </td><td>-6.0155153</td><td> 1.9871211</td><td>-3.02725145</td><td>2.499846e-03</td></tr>
</tbody>
</table>




```R
plot(full_model)
```


    
![png](notebook_files/notebook_24_0.png)
    



    
![png](notebook_files/notebook_24_1.png)
    



    
![png](notebook_files/notebook_24_2.png)
    



    
![png](notebook_files/notebook_24_3.png)
    


#### Reduced Model
Using a backward elimination procedure, a reduced model consisting of 23 predictor variables was developed. This model excludes the variables for age and body mass index (BMI in $kg/m^{2}$), likely due to the homogeneity of children's ages within the sample and the correlation of BMI with other variables, specifically height and weight.

The following information describe the reduced model:

- It has a slightly better residual standard error of 18.5986 compared to the full model.
- The model's R-square slightly increased to 0.1135, that is, 11.35% of the variation in MPI can be accounted by the 23 independent variables in the model”.
- The same seven (7) independent variables with the addition of WEIGHT ($kg$) were significant at 0.05 level.


```R
# Install & load the "MASS" package for backward stepwise regression
# install.packages("MASS")
library(MASS)

# 1 here means the intercept 
null <- lm(`POWER (cm)` ~ 1, data = data_for_regression)

# Backward elimination
bw_elim <- stepAIC(full_model, scope=list(lower=null, upper=full_model),
                   data = data_for_regression, direction='backward')

## ----- First Reduced Model
reduced_model1 <- lm(MPI ~ STATE + RESIDENTIAL + GENDER + `WEIGHT (kg)` + `HEIGHT (cm)` + `CLASS (BMI)`, data = data_for_regression)

# Summary statistics of the first reduced model
paste("Residual standard error:", round(summary.lm(reduced_model1)$sigma, 4), 
      " ,  R-square: ", round(summary.lm(reduced_model1)$r.squared, 4), 
      " ,  Adj. R-square: ", round(summary.lm(reduced_model1)$adj.r.squared, 4))

# First reduced model's table of estimated coefficients, their SEs, t-stats, and (two-sided) p-values
summary_reduced1 <- data.frame(
    Variable = rownames(as.data.frame(summary.lm(reduced_model1)$coefficients))
) %>%
  bind_cols(as.data.frame(summary.lm(reduced_model1)$coefficients))

rownames(summary_reduced1) <- 1:nrow(summary_reduced1)
summary_reduced1

#plot(reduced_model1)
```

    Start:  AIC=11706.73
    MPI ~ STATE + RESIDENTIAL + GENDER + AGE + `WEIGHT (kg)` + `HEIGHT (cm)` + 
        `BMI (kg/m2)` + `CLASS (BMI)`
    
                    Df Sum of Sq    RSS   AIC
    - AGE            1         3 682219 11705
    - `BMI (kg/m2)`  1       605 682821 11706
    <none>                       682216 11707
    - RESIDENTIAL    1      1106 683322 11708
    - `HEIGHT (cm)`  1      1223 683439 11708
    - `WEIGHT (kg)`  1      1309 683526 11709
    - `CLASS (BMI)`  4      6009 688225 11716
    - STATE         15     23466 705682 11744
    - GENDER         1     49106 731322 11844
    
    Step:  AIC=11704.74
    MPI ~ STATE + RESIDENTIAL + GENDER + `WEIGHT (kg)` + `HEIGHT (cm)` + 
        `BMI (kg/m2)` + `CLASS (BMI)`
    
                    Df Sum of Sq    RSS   AIC
    - `BMI (kg/m2)`  1       605 682824 11704
    <none>                       682219 11705
    - RESIDENTIAL    1      1114 683333 11706
    - `HEIGHT (cm)`  1      1224 683443 11706
    - `WEIGHT (kg)`  1      1310 683529 11707
    - `CLASS (BMI)`  4      6006 688225 11714
    - STATE         15     23464 705683 11742
    - GENDER         1     49121 731340 11842
    
    Step:  AIC=11704.51
    MPI ~ STATE + RESIDENTIAL + GENDER + `WEIGHT (kg)` + `HEIGHT (cm)` + 
        `CLASS (BMI)`
    
                    Df Sum of Sq    RSS   AIC
    <none>                       682824 11704
    - `HEIGHT (cm)`  1      1016 683840 11706
    - RESIDENTIAL    1      1099 683924 11706
    - `WEIGHT (kg)`  1      1798 684622 11708
    - `CLASS (BMI)`  4      6336 689160 11715
    - STATE         15     23467 706291 11742
    - GENDER         1     49004 731828 11841



<span style=white-space:pre-wrap>'Residual standard error: 18.5986  ,  R-square:  0.1135  ,  Adj. R-square:  0.1032'</span>



<table class="dataframe">
<!-- <caption>A data.frame: 24 × 5</caption> -->
<thead>
  <tr><th></th><th scope=col>Variable</th><th scope=col>Estimate</th><th scope=col>Std. Error</th><th scope=col>t value</th><th scope=col>Pr(&gt;|t|)</th></tr>
  <!-- <tr><th></th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th></tr> -->
</thead>
<tbody>
  <tr><th scope=row>1</th><td>(Intercept)                 </td><td>114.6837462</td><td>10.5498589</td><td>10.8706427</td><td>8.972322e-27</td></tr>
  <tr><th scope=row>2</th><td>STATEKEDAH                  </td><td>  4.9995849</td><td> 2.0288212</td><td> 2.4642807</td><td>1.381351e-02</td></tr>
  <tr><th scope=row>3</th><td>STATEKELANTAN               </td><td> -0.2746474</td><td> 2.0685727</td><td>-0.1327714</td><td>8.943877e-01</td></tr>
  <tr><th scope=row>4</th><td>STATEKUALA LUMPUR           </td><td>  4.8511979</td><td> 2.3144001</td><td> 2.0960930</td><td>3.620098e-02</td></tr>
  <tr><th scope=row>5</th><td>STATELABUAN                 </td><td> -4.7655878</td><td> 8.4361872</td><td>-0.5648983</td><td>5.722071e-01</td></tr>
  <tr><th scope=row>6</th><td>STATEMELAKA                 </td><td> -4.8875654</td><td> 3.0464262</td><td>-1.6043603</td><td>1.087946e-01</td></tr>
  <tr><th scope=row>7</th><td>STATENEGERI SEMBILAN        </td><td> -3.4943188</td><td> 2.5121631</td><td>-1.3909602</td><td>1.643943e-01</td></tr>
  <tr><th scope=row>8</th><td>STATEPAHANG                 </td><td> -1.5896358</td><td> 2.0353551</td><td>-0.7810115</td><td>4.348894e-01</td></tr>
  <tr><th scope=row>9</th><td>STATEPERAK                  </td><td> -2.5389245</td><td> 1.8901321</td><td>-1.3432524</td><td>1.793447e-01</td></tr>
  <tr><th scope=row>10</th><td>STATEPERLIS                 </td><td> -2.3512322</td><td> 4.8361233</td><td>-0.4861812</td><td>6.268927e-01</td></tr>
  <tr><th scope=row>11</th><td>STATEPULAU PINANG           </td><td> -4.5448868</td><td> 2.0772698</td><td>-2.1879136</td><td>2.879278e-02</td></tr>
  <tr><th scope=row>12</th><td>STATEPUTRAJAYA              </td><td> -5.2458440</td><td> 5.7459381</td><td>-0.9129656</td><td>3.613721e-01</td></tr>
  <tr><th scope=row>13</th><td>STATESABAH                  </td><td>  6.3322964</td><td> 1.7922115</td><td> 3.5332306</td><td>4.199524e-04</td></tr>
  <tr><th scope=row>14</th><td>STATESARAWAK                </td><td>  0.9161919</td><td> 1.8211668</td><td> 0.5030796</td><td>6.149644e-01</td></tr>
  <tr><th scope=row>15</th><td>STATESELANGOR               </td><td>  4.1373446</td><td> 1.5688082</td><td> 2.6372534</td><td>8.423618e-03</td></tr>
  <tr><th scope=row>16</th><td>STATETERENGGANU             </td><td>  0.6892802</td><td> 2.3226322</td><td> 0.2967668</td><td>7.666758e-01</td></tr>
  <tr><th scope=row>17</th><td>RESIDENTIALURBAN            </td><td> -1.5740942</td><td> 0.8829311</td><td>-1.7828053</td><td>7.477163e-02</td></tr>
  <tr><th scope=row>18</th><td>GENDERM                     </td><td> 10.0313573</td><td> 0.8428016</td><td>11.9023949</td><td>1.347188e-31</td></tr>
  <tr><th scope=row>19</th><td>`WEIGHT (kg)`               </td><td> -0.4870348</td><td> 0.2136321</td><td>-2.2797833</td><td>2.272680e-02</td></tr>
  <tr><th scope=row>20</th><td>`HEIGHT (cm)`               </td><td>  0.1959724</td><td> 0.1143583</td><td> 1.7136709</td><td>8.674619e-02</td></tr>
  <tr><th scope=row>21</th><td>`CLASS (BMI)`OBESITY        </td><td> -3.2599963</td><td> 2.7962650</td><td>-1.1658396</td><td>2.438202e-01</td></tr>
  <tr><th scope=row>22</th><td>`CLASS (BMI)`OVERWEIGHT     </td><td>  1.1859822</td><td> 1.7275272</td><td> 0.6865201</td><td>4.924658e-01</td></tr>
  <tr><th scope=row>23</th><td>`CLASS (BMI)`SEVERE THINNESS</td><td> -3.5142913</td><td> 2.9589427</td><td>-1.1876848</td><td>2.351005e-01</td></tr>
  <tr><th scope=row>24</th><td>`CLASS (BMI)`THINNESS       </td><td> -6.2734191</td><td> 1.9763175</td><td>-3.1742973</td><td>1.525143e-03</td></tr>
</tbody>
</table>



#### Diagnostics Checking
The reduced model was evaluated for assumptions to demonstrate its validity.

##### Multicollinearity
Four of the six attributes exhibit Variance Inflation Factor (VIF) values near 1, whereas two attributes have values exceeding five. This indicates a potential presence of multicollinearity within the model, particularly between WEIGHT ($kg$) and CLASS (BMI).


```R
# Install & load the "car" package for Variance inflation factor (VIF)
#install.packages("car")
library(car)

# VIF for detecting multicollinearity
vif_1 <- data.frame(Attribute = c("STATE",
                        "RESIDENTIAL",
                        "GENDER",
                        "WEIGHT (kg)",
                        "HEIGHT (cm)", "CLASS (BMI)")) %>%
  bind_cols(as.data.frame(vif(reduced_model1))) 

rownames(vif_1) <- 1:nrow(vif_1)
vif_1
```


<table class="dataframe">
<!-- <caption>A data.frame: 6 × 4</caption> -->
<thead>
  <tr><th></th><th scope=col>Attribute</th><th scope=col>GVIF</th><th scope=col>Df</th><th scope=col>GVIF^(1/(2*Df))</th></tr>
  <!-- <tr><th></th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th></tr> -->
</thead>
<tbody>
  <tr><th scope=row>1</th><td>STATE      </td><td>1.222732</td><td>15</td><td>1.006725</td></tr>
  <tr><th scope=row>2</th><td>RESIDENTIAL</td><td>1.122544</td><td> 1</td><td>1.059502</td></tr>
  <tr><th scope=row>3</th><td>GENDER     </td><td>1.025710</td><td> 1</td><td>1.012773</td></tr>
  <tr><th scope=row>4</th><td>WEIGHT (kg)</td><td>7.717934</td><td> 1</td><td>2.778117</td></tr>
  <tr><th scope=row>5</th><td>HEIGHT (cm)</td><td>2.694061</td><td> 1</td><td>1.641360</td></tr>
  <tr><th scope=row>6</th><td>CLASS (BMI)</td><td>5.389246</td><td> 4</td><td>1.234358</td></tr>
</tbody>
</table>



Excluding WEIGHT ($kg$) from the model resulted in VIF values nearing 1 for all attributes, indicating that none of the five attributes are significantly correlated.


```R
## ----- Second Reduced Model
reduced_model2 <- lm(MPI ~ STATE + RESIDENTIAL + GENDER + `HEIGHT (cm)` + `CLASS (BMI)`,
                     data = data_for_regression)

# Variance inflation factor (VIF) for detecting multicollinearity
vif_2 <- data.frame(Attribute = c("STATE",
                                 "RESIDENTIAL",
                                 "GENDER",
                                 "HEIGHT (cm)",
                                 "CLASS (BMI)")) %>%
  bind_cols(as.data.frame(vif(reduced_model2))) 

rownames(vif_2) <- 1:nrow(vif_2)
vif_2
```


<table class="dataframe">
<!-- <caption>A data.frame: 5 × 4</caption> -->
<thead>
  <tr><th></th><th scope=col>Attribute</th><th scope=col>GVIF</th><th scope=col>Df</th><th scope=col>GVIF^(1/(2*Df))</th></tr>
  <!-- <tr><th></th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th></tr> -->
</thead>
<tbody>
  <tr><th scope=row>1</th><td>STATE      </td><td>1.209391</td><td>15</td><td>1.006357</td></tr>
  <tr><th scope=row>2</th><td>RESIDENTIAL</td><td>1.121651</td><td> 1</td><td>1.059080</td></tr>
  <tr><th scope=row>3</th><td>GENDER     </td><td>1.025265</td><td> 1</td><td>1.012554</td></tr>
  <tr><th scope=row>4</th><td>HEIGHT (cm)</td><td>1.106692</td><td> 1</td><td>1.051994</td></tr>
  <tr><th scope=row>5</th><td>CLASS (BMI)</td><td>1.131043</td><td> 4</td><td>1.015512</td></tr>
</tbody>
</table>



##### Homoscedasticity
Based on the results of the Breusch-Pagan test, with a p-value of 0.0001568 (significant at the 0.05 level), we reject the null hypothesis of constant variances, suggesting a violation of the homoscedasticity assumption in this model. Remedial measures, such as Weighted Least Squares (WLS) or data transformation, may be required.

   <br/>          **Fig. 7: Studentized Breusch-Pagan Test**


```R
# Install & load the "lmtest" package for Breusch-Pagan (BP) Test
install.packages("lmtest")
library(lmtest)

# BP Test for determining presence of heteroscedasticity
bp_test_stat <- bptest(reduced_model2)$statistic
names(bp_test_stat)[1] <- "Test statistic"

# Test statistic
bp_test_stat

# Degrees of freedom
bptest(reduced_model2)$parameter

# P-value
bp_pv <- bptest(reduced_model2)$p.value
names(bp_pv)[1] <- "p-value"
bp_pv 
```


<strong>Test statistic:</strong> 54.1480970638192



<strong>df:</strong> 22



<strong>p-value:</strong> 0.000156773259412571


##### Autocorrelation
The model was also tested for first-order autocorrelation in the random error terms using the Breusch-Godfrey test. With a p-value below 0.05, we reject the null hypothesis and conclude that autocorrelation exists among the residuals at an order of 1 or less.

   <br/>          **Fig. 8: Breusch-Godfrey Test for Serial Correlation of Order up to 1**


```R
# BP Test for determining presence of autocorrelation
bg_test_stat <- bgtest(reduced_model2)$statistic
names(bg_test_stat)[1] <- "Test statistic"

# Test-statistic
bg_test_stat

# Degrees of freedom
bgtest(reduced_model2)$parameter

# P-value
bg_pv <- bgtest(reduced_model2)$p.value
names(bg_pv)[1] <- "p-value"
bg_pv 
```


<strong>Test statistic:</strong> 371.95016031299



<strong>df:</strong> 1



<strong>p-value:</strong> 7.04022815928729e-83


##### Normality
Shapiro-Wilk normality test shows a p-value of 0.6914, which is insignificant at 0.05 level. Therefore, we do not reject the null hypothesis of normally distributed error terms and conclude that the residuals are drawn from a normal distribution.

   <br/>          **Fig. 9: Shapiro-Wilk Normality Test**


```R
# Shapiro-Wilk Normality Test
sw_test_stat <- shapiro.test(resid(reduced_model2))$statistic
names(sw_test_stat)[1] <- "Test statistic"
sw_test_stat

# P-value
sw_pv <- shapiro.test(resid(reduced_model2))$p.value
names(sw_pv)[1] <- "p-value"
sw_pv
```


<strong>Test statistic:</strong> 0.999306609968656



<strong>p-value:</strong> 0.691396526904326



```R
q <- (rank(rstandard(reduced_model2)) - .5) / length(rstandard(reduced_model2))


residuals_df <- data.frame(residuals = reduced_model2$residuals,
               fitted_values = reduced_model2$fitted.values,
                           standardized_residuals = rstandard(reduced_model2),
               theoretical_quantiles = qnorm(
                 q,
                 mean(rstandard(reduced_model2)),
                 sd(rstandard(reduced_model2))
               ),
               leverage = hatvalues(reduced_model2)
              )
write.csv(residuals_df, "residuals_df.csv")
```

<img src="documentation/resid_plots.png" alt="" title=""/>

#### Final Model
The following infomation describe the final model:

- The final model has a standard error of 18.6184 in predicting MPI.
- The model's R-square is 0.1111, which means that 11.11% of the variation in MPI can be explained by the 22 independent variables.
- Eight (8) independent variables were significant at 0.05 level, which are:</br>
    ㅤ1. STATE KEDAH</br>
    ㅤ2. STATE KUALA LUMPUR</br>
    ㅤ3. STATE PULAU PINANG</br>
    ㅤ4. STATE SABAH</br>
    ㅤ5. STATE SELANGOR</br>
    ㅤ6. GENDER M</br>
    ㅤ7. CLASS (BMI) OBESITY</br>
    ㅤ8. CLASS (BMI) THINNESS


```R
## ----- Second Reduced / Final Model

# Summary statistics of the second reduced / final model
paste("Residual standard error:", round(summary.lm(reduced_model2)$sigma, 4), 
      " ,  R-square: ", round(summary.lm(reduced_model2)$r.squared, 4), 
      " ,  Adj. R-square: ", round(summary.lm(reduced_model2)$adj.r.squared, 4))

# Second reduced / final model's table of estimated coefficients, their SEs, t-stats, and (two-sided) p-values
summary_reduced2 <- data.frame(Variable = rownames(
                  as.data.frame(summary.lm(reduced_model2)$coefficients))
                          ) %>%
  bind_cols(as.data.frame(summary.lm(reduced_model2)$coefficients))
rownames(summary_reduced2) <- 1:nrow(summary_reduced2)

summary_reduced2
```


<span style=white-space:pre-wrap>'Residual standard error: 18.6184  ,  R-square:  0.1111  ,  Adj. R-square:  0.1012'</span>



<table class="dataframe">
<!-- <caption>A data.frame: 23 × 5</caption> -->
<thead>
  <tr><th></th><th scope=col>Variable</th><th scope=col>Estimate</th><th scope=col>Std. Error</th><th scope=col>t value</th><th scope=col>Pr(&gt;|t|)</th></tr>
  <!-- <tr><th></th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th></tr> -->
</thead>
<tbody>
  <tr><th scope=row>1</th><td>(Intercept)                 </td><td>128.186424988</td><td>8.73968327</td><td>14.66717053</td><td>2.601903e-46</td></tr>
  <tr><th scope=row>2</th><td>STATEKEDAH                  </td><td>  5.067786255</td><td>2.03075510</td><td> 2.49551817</td><td>1.265837e-02</td></tr>
  <tr><th scope=row>3</th><td>STATEKELANTAN               </td><td> -0.027453992</td><td>2.06792296</td><td>-0.01327612</td><td>9.894088e-01</td></tr>
  <tr><th scope=row>4</th><td>STATEKUALA LUMPUR           </td><td>  4.737962881</td><td>2.31632457</td><td> 2.04546588</td><td>4.094119e-02</td></tr>
  <tr><th scope=row>5</th><td>STATELABUAN                 </td><td> -4.315881290</td><td>8.44283806</td><td>-0.51118845</td><td>6.092762e-01</td></tr>
  <tr><th scope=row>6</th><td>STATEMELAKA                 </td><td> -5.042016560</td><td>3.04890750</td><td>-1.65371254</td><td>9.834485e-02</td></tr>
  <tr><th scope=row>7</th><td>STATENEGERI SEMBILAN        </td><td> -3.565114571</td><td>2.51463902</td><td>-1.41774407</td><td>1.564232e-01</td></tr>
  <tr><th scope=row>8</th><td>STATEPAHANG                 </td><td> -1.527963461</td><td>2.03733681</td><td>-0.74998079</td><td>4.533556e-01</td></tr>
  <tr><th scope=row>9</th><td>STATEPERAK                  </td><td> -2.543450663</td><td>1.89213853</td><td>-1.34422011</td><td>1.790316e-01</td></tr>
  <tr><th scope=row>10</th><td>STATEPERLIS                 </td><td> -2.280852724</td><td>4.84116094</td><td>-0.47113755</td><td>6.375945e-01</td></tr>
  <tr><th scope=row>11</th><td>STATEPULAU PINANG           </td><td> -4.320885947</td><td>2.07714846</td><td>-2.08020083</td><td>3.763577e-02</td></tr>
  <tr><th scope=row>12</th><td>STATEPUTRAJAYA              </td><td> -5.173760462</td><td>5.75195359</td><td>-0.89947883</td><td>3.685073e-01</td></tr>
  <tr><th scope=row>13</th><td>STATESABAH                  </td><td>  6.424110227</td><td>1.79366189</td><td> 3.58156142</td><td>3.498079e-04</td></tr>
  <tr><th scope=row>14</th><td>STATESARAWAK                </td><td>  0.867500918</td><td>1.82297565</td><td> 0.47587082</td><td>6.342190e-01</td></tr>
  <tr><th scope=row>15</th><td>STATESELANGOR               </td><td>  4.111387490</td><td>1.57043298</td><td> 2.61799615</td><td>8.912351e-03</td></tr>
  <tr><th scope=row>16</th><td>STATETERENGGANU             </td><td>  0.806372786</td><td>2.32453043</td><td> 0.34689707</td><td>7.287056e-01</td></tr>
  <tr><th scope=row>17</th><td>RESIDENTIALURBAN            </td><td> -1.517334206</td><td>0.88351733</td><td>-1.71737911</td><td>8.606669e-02</td></tr>
  <tr><th scope=row>18</th><td>GENDERM                     </td><td>  9.991360034</td><td>0.84351388</td><td>11.84492663</td><td>2.555312e-31</td></tr>
  <tr><th scope=row>19</th><td>`HEIGHT (cm)`               </td><td> -0.004150265</td><td>0.07337333</td><td>-0.05656367</td><td>9.548985e-01</td></tr>
  <tr><th scope=row>20</th><td>`CLASS (BMI)`OBESITY        </td><td> -8.781853177</td><td>1.39881818</td><td>-6.27805193</td><td>4.203575e-10</td></tr>
  <tr><th scope=row>21</th><td>`CLASS (BMI)`OVERWEIGHT     </td><td> -1.069646723</td><td>1.41763537</td><td>-0.75452881</td><td>4.506217e-01</td></tr>
  <tr><th scope=row>22</th><td>`CLASS (BMI)`SEVERE THINNESS</td><td> -1.034018181</td><td>2.75459885</td><td>-0.37537886</td><td>7.074190e-01</td></tr>
  <tr><th scope=row>23</th><td>`CLASS (BMI)`THINNESS       </td><td> -4.826267726</td><td>1.87358878</td><td>-2.57594824</td><td>1.006865e-02</td></tr>
</tbody>
</table>



## Conclusion

Using the available data and results of the analyses, the following conclusions can be drawn about the attributes, motor skills, and motor performances of the seven-year-old Malaysians in the sample:

- Children from Kedah, Kuala Lumpur, Sabah, and Selangor appear to have higher MPIs among others.
- Male children are more likely to have higher MPIs than their female counterparts. 
- Children with BMI classes of "Obesity" and "Thinness" have potentially less MPIs compared to the other classes.

## Recommendation
Based on these conclusions, among the eight attributes that were considered in identifying gifted young Malaysian sports talents, their STATE, GENDER, and CLASS (BMI) are the most significant. Specifically, the characteristics that can increase the chances of having a high Motor Performance Index (MPI) are:
- residing in the states of Kedah, Kuala Lumpur, Sabah, or Selangor;
- being male; and
- having a "Normal" BMI class.

Despite these recommended characteristics, however, one major limitation of the final model is it accounts for only a relatively small percentage of the variation in MPI. Therefore, it is suggested to look for additional attributes or variables that can potentially contribute to motor performance.

## Appendix
#### Tables
##### ***Summary statistics of the numerical variables***

<table class="dataframe">
<!-- <caption>A data.frame: 8 × 6</caption> -->
<thead>
  <tr><th></th><th scope=col>Variable</th><th scope=col>Mean</th><th scope=col>Std. Dev.</th><th scope=col>Min.</th><th scope=col>Median</th><th scope=col>Max.</th></tr>
  <!-- <tr><th></th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th><th scope=col>&lt;dbl&gt;</th></tr> -->
</thead>
<tbody>
  <tr><th scope=row>1</th><td>AGE               </td><td>  7.057508</td><td> 0.04944554</td><td> 7.00</td><td>  7.10</td><td>  7.1</td></tr>
  <tr><th scope=row>2</th><td>WEIGHT (kg)       </td><td> 22.208253</td><td> 5.41222597</td><td>11.00</td><td> 21.00</td><td> 49.0</td></tr>
  <tr><th scope=row>3</th><td>HEIGHT (cm)       </td><td>118.259660</td><td> 5.97348877</td><td>76.50</td><td>118.05</td><td>140.0</td></tr>
  <tr><th scope=row>4</th><td>BMI (kg/m2)       </td><td> 15.774274</td><td> 3.06391583</td><td> 8.20</td><td> 15.00</td><td> 35.1</td></tr>
  <tr><th scope=row>5</th><td>POWER (cm)        </td><td> 96.200701</td><td>17.59424894</td><td>50.00</td><td> 96.00</td><td>160.0</td></tr>
  <tr><th scope=row>6</th><td>SPEED (sec)       </td><td>  5.163423</td><td> 0.70676451</td><td> 1.59</td><td>  5.10</td><td> 10.0</td></tr>
  <tr><th scope=row>7</th><td>FLEXIBILITY (cm)  </td><td> 26.261512</td><td> 4.93084932</td><td> 9.00</td><td> 26.50</td><td> 41.0</td></tr>
  <tr><th scope=row>8</th><td>COORDINATION (no.)</td><td>  4.079079</td><td> 2.78017028</td><td> 1.00</td><td>  4.00</td><td> 10.0</td></tr>
</tbody>
</table>



##### ***Counts and percentages of the categorical variables***

<table class="dataframe">
<!-- <caption>A tibble: 25 × 4</caption> -->
<thead>
  <tr><th scope=col>Attribute</th><th scope=col>Category</th><th scope=col>Number of children</th><th scope=col>Percentage</th></tr>
  <!-- <tr><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;chr&gt;</th><th scope=col>&lt;int&gt;</th><th scope=col>&lt;chr&gt;</th></tr> -->
</thead>
<tbody>
  <tr><td>STATE      </td><td>SELANGOR       </td><td> 349</td><td>17.47%</td></tr>
  <tr><td>STATE      </td><td>JOHOR          </td><td> 241</td><td>12.06%</td></tr>
  <tr><td>STATE      </td><td>SABAH          </td><td> 202</td><td>10.11%</td></tr>
  <tr><td>STATE      </td><td>SARAWAK        </td><td> 199</td><td>9.96% </td></tr>
  <tr><td>STATE      </td><td>PERAK          </td><td> 166</td><td>8.31% </td></tr>
  <tr><td>STATE      </td><td>KEDAH          </td><td> 133</td><td>6.66% </td></tr>
  <tr><td>STATE      </td><td>PAHANG         </td><td> 129</td><td>6.46% </td></tr>
  <tr><td>STATE      </td><td>KELANTAN       </td><td> 128</td><td>6.41% </td></tr>
  <tr><td>STATE      </td><td>PULAU PINANG   </td><td> 122</td><td>6.11% </td></tr>
  <tr><td>STATE      </td><td>KUALA LUMPUR   </td><td>  90</td><td>4.50% </td></tr>
  <tr><td>STATE      </td><td>TERENGGANU     </td><td>  90</td><td>4.50% </td></tr>
  <tr><td>STATE      </td><td>NEGERI SEMBILAN</td><td>  72</td><td>3.60% </td></tr>
  <tr><td>STATE      </td><td>MELAKA         </td><td>  45</td><td>2.25% </td></tr>
  <tr><td>STATE      </td><td>PERLIS         </td><td>  16</td><td>0.80% </td></tr>
  <tr><td>STATE      </td><td>PUTRAJAYA      </td><td>  11</td><td>0.55% </td></tr>
  <tr><td>STATE      </td><td>LABUAN         </td><td>   5</td><td>0.25% </td></tr>
  <tr><td>RESIDENTIAL</td><td>URBAN          </td><td>1052</td><td>52.65%</td></tr>
  <tr><td>RESIDENTIAL</td><td>RURAL          </td><td> 946</td><td>47.35%</td></tr>
  <tr><td>GENDER     </td><td>F              </td><td> 999</td><td>50.00%</td></tr>
  <tr><td>GENDER     </td><td>M              </td><td> 999</td><td>50.00%</td></tr>
  <tr><td>CLASS (BMI)</td><td>NORMAL         </td><td>1419</td><td>71.02%</td></tr>
  <tr><td>CLASS (BMI)</td><td>OBESITY        </td><td> 218</td><td>10.91%</td></tr>
  <tr><td>CLASS (BMI)</td><td>OVERWEIGHT     </td><td> 205</td><td>10.26%</td></tr>
  <tr><td>CLASS (BMI)</td><td>THINNESS       </td><td> 108</td><td>5.41% </td></tr>
  <tr><td>CLASS (BMI)</td><td>SEVERE THINNESS</td><td>  48</td><td>2.40% </td></tr>
</tbody>
</table>
