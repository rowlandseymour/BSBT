---
title: 'BSBT: A package for analysing network comparative judgement data'
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
    orcid: xxxx
affiliations:
 - name: School of Mathematical Sciences, University of Nottingham, UK
   index: 1
 - name: xxxx
   index: 2
date: xxxxx
bibliography: paper.bib

---

# Summary
Comparative judgement models estimate the features of a set of objects based on pair-wise comparisons of the objects. Comparing objects based on certain criteria is often easier for participants than quantifying the value of each object in the set and elicits informative responses. This can be useful in scenarios where traditional data collection methods struggle, such as: inferring the level of quality in parts of a city in a developing country, quantifying the risk of forced marriage young women face in different regions of a country, and estimating the number of cases of female genital mutilation in rural parts of a country. In practice however, comparative judgment models require time-consuming and expensive fieldwork. `BSBT` offers a solution for contexts with a strong network element by implementing a comparative judgment model with a network element, which makes efficient use of the use of the data collected and reduces the amount of data required compared to previous methods. The R package allows this data to be analysed without technical knowledge, making this approach attractive to non-mathematical practitioners. The package 

# Statement of need
In a comparative judgement study, we wish to infer  the features of a set of objects based on pairwaise comparisons of the objects. Particiapnts, known as judges, are shown pairs of objects and asked to choose one based on the features. Current comparative judgement models are data inefficient, requiring days or weeks of time-consuming and expensive fieldwork. This makes carrying out comparative judgement studies expensive and logistically difficult [ @Etten19; @Seymour20]. Existing packages, such as the widely used `BradleyTerry2` [@Turner2012; @Firth12], produce poor quality results when insufficient data is provided. We address this by providing a data analysis package that implements and extends the Bayesian spatial Bradley--Terry (BSBT) model [@Seymour20], which reduces the number of comparisons required to provide accurate estimates compared to other methods. 

In the BSBT model each object in the study is assigned a quality $\lambda \in \mathbb{R}$, and the probability that, in a comparison between objects $i$ and $j$, object $i$ is judged to have a higher quality than $j$ depends on the difference in quality parameters. When inferring the values of the parameters given the comparisons, we include a network structure, where the quality of each object depends on its location in the network. Including this network structure reduces the number of comparisons needed to accurately estimate the parameter values. We infer the parameters values using a Markov chain Monte Carlo (MCMC) algorithm. 


# The Bayesian spatial Bradley--Terry model
We briefly describe the BSBT model and full details are provided in [@Seymour20]. If objects $i$ and $j$ are compared $n_{ij}$ times, the number of times object $i$ is preferred to object $j$ is modelled as 
$$
Y_{ij} \sim \hbox{Bin}(n_{ij}, \pi_{ij}),
$$
and we assume the $Y_{ij}$ are independent. Here the probability $\pi_{ij}$ that object $i$ is judged to be more affluent than object $j$ depends on the difference in relative quality of $i$ and $j$ and is
$$
    \hbox{logit}(\pi_{ij}) = \lambda_i - \lambda_j \iff \pi_{ij} = \frac{\exp(\lambda_i)}{\exp(\lambda_i) + \exp(\lambda_j)} \qquad (i \neq j, 1\leq i, j \leq N). \label{eq: logit difference}
$$
We assume the quality parameters are correlated, with quality levels in nearby objects being highly correlated and levels in far away objects having low correlation. To achieve this, we place a multivariate normal prior distribution on the object qualities $\boldsymbol{\lambda}$ such that
$$
(\boldsymbol{\lambda} \mid \boldsymbol{1}^T\boldsymbol{\lambda} = 0) \sim \textrm{MVN}\Big(\textbf{0}, \, \Sigma - \Sigma\boldsymbol{1}(\boldsymbol{1}^T\Sigma \boldsymbol{1})^{-1}\boldsymbol{1}^T\Sigma\Big),
$$
where $\boldsymbol{1}$ is a vector of ones. This constraint ensures the quality parameters sum to 0 and resolves identifiability issues. The covariance matrix depends on the network strucuture and assumptions we make about the correlation  of the obbject qualities. For studies using a spatial structure, we reccommend setting the spatial areas to be nodes and placing edges between adjacent areas. The main assumption is that nodes that are highly connected have highly correlated qualities and the package allows this to be included in a number of ways. We recommend using the matrix exponential of the adjacency matrix, which assigns high correlation to objects with many short paths between them, and low correlation to objects which can only be reached through long paths. The other methods we allow for are using the squared exponential, rational quadratic or Matern covariance function with a shortest path based distance metric. All covariance functions supplied contain a total variance parameter. This can either be fixed or inferred using an inverse-gamma prior distribution. 

## Symmetric model
Two extensions of the model are provided in the BSBT package. The first is when there are two types of participants in the model, e.g. male and female. The symmetric model allows us to infer whether the two types agree on the level of quality for each object. Denote the perceived quality in object $i$ for type one individuals by $\lambda_i^{(1)}$ and type two individuals by $\lambda_i^{(2)}$. We construct the mean and difference for object $i$ by
$$
\lambda_i = \frac{1}{2}(\lambda_i^{(1)} + \lambda_i^{(2)}), \, \mu_i = \frac{1}{2}(\lambda_i^{(1)} - \lambda_i^{(2)}).
$$
We place multivariate normal distributions on the vectors $\boldsymbol{\lambda}$ and $\boldsymbol{\mu}$. If the posterior credible interval for $\mu_i$ does not contain 0, then there is evidence that the two types have differing opinions about object $i$.

## Asymmetric model
The second extension allows for any number of types of individuals. We treat one type as a baseline and then measure then discrepancy between each type and the baseline. Choosing type one as the baseline type, the perceived quality by type $k$ is
$$
\boldsymbol{\lambda}^{(k)} = \boldsymbol{\lambda}^{(1)} + \boldsymbol{u}^{(k)},
$$
where $\boldsymbol{u}^{(k)}$ follows a multivariate normal distribution and is the discrepancies between the qualities percived by the baseline type and type $j$. 


# Data 
In the package, there is a comparative judgement data set collected in Dar es Salaam, Tanzania. It includes over 75,000 comparisons, where citizens where are to compare subwards in the city based on deprivation. Also included are shapefiles for the 452 subwards. These can be accessed by calling `data(dar.comparisons, package = "BSBT")` and `data(dar.shapefiles, package = "BSBT")`. The vignette "BSBT for Dar es Salaam" demonstrates the BSBT model on this data and gives examples of how the results can be plotted. 


# Acknowledgements
This work is supported by the Engineering and Physical Sciences Research Council [grant numbers EP/T003928/1 and EP/R513283/1] and the Univesity of Nottingham. 

The comparative judgement dataset was collected by Madeleine Ellis, James Goulding, Bertrand Perrat, Gavin Smith and Gregor Engelmann. We gratefully acknowledge the Rights Lab at the University of Nottingham for supporting funding for the comprehensive ground truth survey. We also acknowledge Humanitarian Street Mapping Team (HOT) for providing a team of experts in data collection to facilitate the surveys. This fieldwork was also supported by the EPSRC Horizon Centre for Doctoral Training - My Life in Data [EP/L015463/1] and by EPSRC grant Neodemographics [EP/L021080/1].

# References
