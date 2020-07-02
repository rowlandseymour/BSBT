# BTUN <img src='man/figures/logo.png' align="right" height="140px" />
----
## Bradley--Terry for Urban Networks
<!-- badges: start -->
[![Travis build status](https://travis-ci.com/rowlandseymour/BTUN.svg?branch=master)](https://travis-ci.com/rowlandseymour/BTUN)
[![R build status](https://github.com/rowlandseymour/BTUN/workflows/R-CMD-check/badge.svg)](https://github.com/rowlandseymour/BTUN/actions)
<!-- badges: end -->
----
The `BTUN` R package allows you to fit a spatial Bradley--Terry model to  comparative judgement data sets. The aim is to estimate the deprivation levels in urban areas and find the most deprived citizens. The `BTUN` model creates a network from the urban area and uses a Gaussian Process to nonparametrically model the deprivation levels.

## Installation
----
You can install `BTUN` by calling the following commands:
```{r}
install.packages('devtools')
devtools::install_github("rowlandseymour/BTUN", dependencies = TRUE)
# devtools::install_github("rowlandseymour/BTUN") #for a quicker install
```

## Creating a Network from an Urban Area
----
The first step is to create a network from the urban area.Here's an example of a network made from Local Authority Areas in the England:
![England Map and Network (BTUN)](man/figures/england_network.png?raw=true)
 There are two ways to do this in `BTUN`. The first is to construct an adjacency matrix, which describes which areas are neighbours. This can then be fed into `registered_adjacent_covariance_function`. The second way is to use coordinates which can be used with`registered_covariance_matrix`. This uses the Euclidean distance metric.


## Fitting the Model
----
The `BTUN` package uses MCMC the estimate the model parameters. The MCMC can be run by calling the `run_mcmc` function. This make take some time, up to a few hours, depending on how many subdivisions there are in the urban area. Here are the results of the method applied to a comparative judgement data set in Tanzania:

![Deprivation in Dar es Salaam, Tanzania (BTUN)](man/figures/dar_results.png?raw=true)


## Data
----
In the package, there is a comparative judgement data set collected in Dar es Salaam, Tanzania. It includes over 75,000 comparisons, where citizens where are to compare subwards in the city based on deprivation. Also included are shapefiles for the 452 subwards. These can be accessed by calling `data(dar.comparisons, package = "BTUN")` and `data(dar.shapefiles, package = "BTUN")`.

There is also code for simulating comparative judgement data given the underlying levels of deprivation. More information can be found by calling `?BTUN::simulate_contests`

## Acknowledgements
----
This work is supported the UK Engineering and Physical Sciences Research Council (EP/T003928/1) and the Bid East African Data Science research group at the University of Nottingham.

The comparative judgement dataset was collected by Madeleine Ellis, James Goulding, Bertrand Perrat, Gavin Smith and Gregor Engelmann. We gratefully acknowledge the Rights Lab at the University of Nottingham for supporting funding for the comprehensive ground truth survey. We also acknowledge Humanitarian Street Mapping Team (HOT) for providing a team of experts in data collection to facilitate the surveys. This fieldwork was also supported by the EPSRC Horizon Centre for Doctoral Training - My Life in Data (EP/L015463/1) and by EPSRC grant Neodemographics (EP/L021080/1).

<img src='man/figures/EPSRC.png' align="left" height="50px" /> <img src='man/figures/uon.png' align="left" height="50px" /><img src='man/figures/Beads.png' align="left" height="50px" />

