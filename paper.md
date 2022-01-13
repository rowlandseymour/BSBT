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
    orcid: 0000-0002-7329-3161
    affiliation: "2"
affiliations:
 - name: Rights Lab, University of Nottingham, UK
   index: 1
 - name: Department of Statistical Science, University College London, UK
   index: 2
date: 12th January 2021
bibliography: paper.bib

---

# Summary
Comparative judgement models estimate the features of a set of objects based on pairwise comparisons of the objects. It is often easier for participants to compare objects based on a set of criteria that to quantify the value of each object directly. Pairwise comparisons may also elicit more informative responses. This can be useful in scenarios where traditional data sources are unavailable or unreliable, such as estimating the level of deprivation in different parts of a city in a developing country. In practice however, comparative judgment studies require time-consuming and expensive fieldwork. The `BSBT` package offers a solution for contexts with a strong spatial element by implementing a comparative judgment model with a spatial component. This package makes efficient use of the use of the collected comparative judgement data collected and reduces the amount of data required compared to previous methods. This package also allows this data to be analysed without technical knowledge, making this approach attractive to non-mathematical practitioners. 

# Statement of need
In a comparative judgement study, we wish to infer  the features of a set of objects based on pairwise comparisons of the objects. Participants, known as judges, are shown pairs of objects and asked to choose a winner based on a set of features. Current comparative judgement models are data inefficient, requiring days or weeks of time-consuming and expensive fieldwork. This makes carrying out comparative judgement studies expensive and logistically difficult [@Etten19; @Seymour22]. Existing packages, such as the widely used `BradleyTerry2` [@Turner2012; @Firth12], produce poor quality results when insufficient data is provided. Recently,a Bayesian implementation of a comparative judgement model have been made available in R, but it does not allow for spatial correlations [@IssaMattos2021]. We address these issues by providing a data analysis package that implements and extends the Bayesian spatial Bradley--Terry model (BSBTm) [@Seymour22], which reduces the number of comparisons required to provide accurate estimates compared to other methods. 

In the BSBT package each object in the study is assigned a quality $\lambda \in \mathbb{R}$, and the probability that, in a comparison between objects $i$ and $j$, object $i$ is judged to have a higher quality than $j$ depends on the difference in quality parameters. When inferring the values of the parameters given the comparisons, we include a spatial structure, where the quality of each object depends on its location in the spatial. Including this spatial structure reduces the number of comparisons needed to accurately estimate the parameter values. We infer the parameters values using a Markov chain Monte Carlo (MCMC) algorithm. 

The package not only compliments the methodological development in @Seymour22, but extends the work in a number of ways. The package includes code to simulate and comparative judgement datasets, allowing for both spatial and non-spatial simulation studies to be carried out. The inference algorithms in the package include a number of covariance functions and inference for their parameters. The package includes two vignettes which walk the user through the functions and data in the package and are a recommended starting point for the user. This will allow others to use the software and act as a springboard for new comparative judgement projects. 

# The Bayesian spatial Bradley--Terry model
Below, we briefly describe the BSBTm, while full details can be found in [@Seymour22]. If objects $i$ and $j$ are compared $n_{ij}$ times, the number of times object $i$ is preferred to object $j$ is modelled as 
$$
Y_{ij} \sim \hbox{Bin}(n_{ij}, \pi_{ij}),
$$
where we assume the $Y_{ij}$ are independent. Here the probability $\pi_{ij}$ that object $i$ is judged to be more affluent than object $j$ depends on the difference in relative quality of $i$ and $j$ and is expressed as
$$
\pi_{ij} = \frac{\exp(\lambda_i)}{\exp(\lambda_i) + \exp(\lambda_j)} \iff   \hbox{logit}(\pi_{ij}) = \lambda_i - \lambda_j  \qquad (i \neq j, 1\leq i, j \leq N). \label{eq: logit difference}
$$
We assume the quality parameters are correlated, with parameters in nearby objects being highly correlated and parameters in distant objects having low correlation. This is achieved by a prior distribution on $\boldsymbol{\lambda}$ which is a multivariate normal distribution given by
$$
(\boldsymbol{\lambda} \mid \boldsymbol{1}^T\boldsymbol{\lambda} = 0) \sim \textrm{MVN}\Big(\textbf{0}, \, \Sigma - \Sigma\boldsymbol{1}(\boldsymbol{1}^T\Sigma \boldsymbol{1})^{-1}\boldsymbol{1}^T\Sigma\Big),
$$
where $\boldsymbol{1}$ is a vector of ones. This constraint ensures the quality parameters sum to 0 and avoids identifiability issues. The covariance matrix depends on the spatial structure and any assumptions we make about the correlation  of the object qualities. In the package, we represent the spatial structure through a network, considering the objects and nodes and placing edges between adjacent nodes. The main assumption is that nodes that are highly connected have highly correlated parameters and the package allows this to be included in a number of ways. We recommend using the matrix exponential of the adjacency matrix, which asigns high correlation to objects with many short paths between them, and low correlation to objects which can only be reached through long paths. The other methods we allow for are using the squared exponential, rational quadratic or Mat\`{e}rn covariance function with a shortest path based distance metric. All covariance functions supplied contain a total variance parameter. This can either be fixed or inferred, in which case an inverse gamma prior distribution is used in the package.  

## Symmetric model
The package includes a further extension, where the participants can be split into two types e.g. male and female.  This is known as the symmetric model and allows us to analyse the difference in hwo the types percieve the objects. We denote the perceived quality in object $i$ for type one individuals by $\lambda_i^{(1)}$ and type two individuals by $\lambda_i^{(2)}$. The mean and difference for object $i$ are respectively given by
$$
\lambda_i = \frac{1}{2}(\lambda_i^{(1)} + \lambda_i^{(2)}), \, \mu_i = \frac{1}{2}(\lambda_i^{(1)} - \lambda_i^{(2)}).
$$
The package outputs the posterior distribution for these values. The posterior distribution for $\mu_i$ contains information about the difference in percpetion of object $i$ between the two types of participant. For example, we intepret the case where the credible for $\mu_i$ does not contain 0 to mean a significant difference between how object $i$ is perceived. 


# Data 
In the package, there is a comparative judgement data set collected in Dar es Salaam, Tanzania. It includes over 75,000 comparisons, where citizens were asked to compare subwards in the city based on deprivation. Also included are shapefiles for the 452 subwards. These can be accessed by calling `data(dar.comparisons, package = "BSBT")` and `data(dar.shapefiles, package = "BSBT")`. The vignette "BSBT for Dar es Salaam" demonstrates the BSBT model on this data and gives examples of how the results can be plotted. 


# Acknowledgements
This work is supported by the Engineering and Physical Sciences Research Council [grant numbers EP/T003928/1 and EP/R513283/1] and the University of Nottingham. We thank Georgios Aristotelous for his helpful comments on the manuscript. 

The comparative judgement dataset was collected by Madeleine Ellis, James Goulding, Bertrand Perrat, Gavin Smith and Gregor Engelmann. We gratefully acknowledge the Rights Lab at the University of Nottingham for supporting funding for the comprehensive ground truth survey. We also acknowledge Humanitarian Street Mapping Team (HOT) for providing a team of experts in data collection to facilitate the surveys. This fieldwork was also supported by the EPSRC Horizon Centre for Doctoral Training - My Life in Data [EP/L015463/1] and by EPSRC grant Neodemographics [EP/L021080/1].

# References
