---
title: 'BSBT: A package for analysing spatial comparative judgement data'
tags:
  - R
  - Data collection
  - Bayesian computation
  - Comparative judgement
authors:
  - name: Rowland G. Seymour
    orcid: 0000-0002-8739-3921
    affiliation: "1" # (Multiple affiliations must be quoted)
  - name: James Briant
    affiliation: "2"
    orcid: 
affiliations:
 - name: School of Mathematical Sciences, University of Nottingham, UK
   index: 1
 - name: xxxx
    index: 2
date: xxxxx
bibliography: paper.bib

---

# Summary
Comparative judgement models estimate the features of a set of objects based on pair-wise comparisons of the objects. Comparing objects based on certain criteria is often easier for participants than quantifying the value of each object in the set and elicits informative responses. This can be useful in scenarios where traditional data collection methods struggle, such as: inferring the level of deprivation in parts of a city in a developing country, quantifying the risk of forced marriage young women face in different regions of a country, and estimating the number of cases of female genital mutilation in rural parts of a country. In practice however, comparative judgment models require time-consuming and expensive fieldwork. `BSBT` offers a solution for contexts with a strong spatial element by implementing a comparative judgment model with a spatial element, which makes efficient use of the use of the data collected and reduces the amount of data required compared to previous methods. The R package allows this data to be analysed without technical knowledge, making this approach attractive to non-mathematical practitioners. The package 

# Statement of need
Current comparative judgement models are data inefficient, requiring days or weeks of time-consuming and expensive fieldwork. This makes carrying out comparative judgement studies in developing countries prohibitively expensive and logistically difficult [@Eng18; @Etten19; @Seymour20]. Existing packages, such as the widely used `BradleyTerry2` [@Turner2012; @Firth12], produce poor quality results when insufficient data is provided. We address this by providing a data analysis package that implements and extends the Bayesian Spatial Bradley--Terry (BSBT) model [@Seymour20], which reduces the number of comparisons required to provide accurate estimates compared to other methods. 

In the BSBT model each area in the study is assigned a quality $\lambda \in \mathbb{R}$, and the probability that, in a comparison between areas $i$ and $j$, area $i$ is judged to have a higher quality than $j$ depends on the difference in quality parameters. When inferring the values of the parameters given the comparisons, we include a spatial structure, where the level of deprivation in one area depends on the level in nearby areas. Including this spatial structure reduces the number of comparisons needed to accurately estimate the parameter values. We infer the parameters values using a Markov chain Monte Carlo (MCMC) algorithm. 


# The Bayesian Spatial Bradley--Terry model
We briefly describe the BSBT model and full details are provided in [@Seymour20]. If areas $i$ and $j$ are compared $n_{ij}$ times, the number of times area $i$ is judged to be more affluent than area $j$ is modelled as 
$$
Y_{ij} \sim \hbox{Bin}(n_{ij}, \pi_{ij}),
$$
and we assume $Y_{ij}$ are independent. Here the probability $\pi_{ij}$ that area $i$ is judged to be more affluent than area $j$ depends on the difference in relative deprivation of $i$ and $j$ and is
$$
    \hbox{logit}(\pi_{ij}) = \lambda_i - \lambda_j \iff \pi_{ij} = \frac{\exp(\lambda_i)}{\exp(\lambda_i) + \exp(\lambda_j)} \qquad (i \neq j, 1\leq i, j \leq N). \label{eq: logit difference}
$$
We assume the deprivation parameters are correlated, with deprivation levels in nearby areas being highly correlated and levels in far away areas having low correlation. To achieve this,  we place a multivariate normal prior distribution such that
$$
(\boldsymbol{\lambda} \mid \boldsymbol{1}^T\boldsymbol{\lambda} = 0) \sim \textrm{MVN}\Big(\textbf{0}, \, \Sigma - \Sigma\boldsymbol{1}(\boldsymbol{1}^T\Sigma \boldsymbol{1})^{-1}\boldsymbol{1}^T\Sigma\Big),
$$
with the constraint that the deprivation parameters sum to 0 to remove identifiability issues. The covariance matrix contains the spatial information and the package provides a number of ways to construct this. We recommend using a network structure, where each area is a node and edges are placed between adjacent areas. The covariance matrix is constructed using the matrix exponential of the adjecency matrix, which assigns high correlation to areas with many short paths between them, and low correlation to areas which can only be reached through long paths. The package allows other network measures to be used, including one based on the length of the shortest path between areas. It is also possible to use a Euclidean distance metric. All covariance functions supplied contain a total variance parameter. This can either be fixed or inferred using an inverse-gamma prior distribution. 

## Symmetric model
Two extensions of the model are provided in the BSBT package. The first is when there are two types of participants in the model, e.g. male and female. The symmetric model allows us to infer whether the two types agree on the level of deprivation for each area. Denote the perceived deprivation in area $i$ for type one individuals by $\lambda_i^{(1)}$ and type two individuals by $\lambda_i^{(2)}$. We construct the mean and difference for area $i$ by
$$
\lambda_i = \frac{1}{2}(\lambda_i^{(1)} + \lambda_i^{(2)}), \, \mu_i = \frac{1}{2}(\lambda_i^{(1)} - \lambda_i^{(2)}).
$$
We place multivariate normal distributions on the vectors $\boldsymbol{\lambda}$ and $\boldsymbol{\mu}$. If the posterior credible interval for $\mu_i$ does not contain 0, then there is evidence that the two types have differing opinions about area $i$.

## Asymmetric model
The second extension allows for any number of types of individuals. We treat one type as a baseline and then measure then discrepancy between each type and the baseline. Choosing type one as the baseline type, the perceived deprivation by type $k$ is
$$
\boldsymbol{\lambda}^{(k)} = \boldsymbol{\lambda}^{(1)} + \boldsymbol{u}^{(k)},
$$
where $\boldsymbol{u}^{(k)}$ follows a multivariate normal distribution. 
# Example Workflow

## Data analysis
To use with the `BSBT` package, we need to transform the table into a matrix, where element $w_{ij}$ contains the number of times area $i$ was chosen over area $j$. This can be done by calling
```r
win.matrix <- comparisons_to_matrix(N, your_comparisons),
```
where N is the number of areas in the study. We can now analyse the comparisons. We first construct the prior distribution covariance matrix, which contains the spatial structure of the areas. Then we feed this matrix and the processed data into the MCMC function, which infers the quality of each area. The covariance matrix function requires the adjacency matrix from the shape files. The can be done using the `spdep` package, the `surveillance` package using, or GIS software, such as QGIS. 
```r
k            <- constrained_adjacency_covariance_function(your_adjacency_matrix, type = "matrix", hyperparameters = c(1), linear.combination = rep(1, N), linear.constraint = 0)
mcmc.output  <- run_mcmc(n.iter = 1000000, delta = 0.01, k, win.matrix, f.initial =  rep(0, N), alpha = TRUE)
```
The MCMC algorithm may take several hours to run. To include the posterior median estimates for the quality of each area in the database, call
```r
burn.in                    <- 500000 #burn-in period 
mean.quality               <- apply(mcmc.output$f[-c(1:burn.in), ], 2, mean)
quality                    <- data.frame("area_id" = 1:N, "quality" = mean.quality)
```


# Acknowledgements

This work is supported by the Engineering and Physical Sciences Research Council. 

# References
