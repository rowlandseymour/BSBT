---
title: 'BSBT: A package for collecting and analysing spatial comparative judgement data'
tags:
  - R
  - Python
  - Data Collection
  - Bayesian Computation
  - Comparative Judgement
authors:
  - name: Bertrand Perrat
    affiliation: "1"
    orcid: 
  - name: Rowland G. Seymour
    orcid: 0000-0002-8739-3921
    affiliation: "2" # (Multiple affiliations must be quoted)
  - name: James Briant
    affiliation: "2"
    orcid: 
affiliations:
 - name:  N/LAB, Nottingham University Business School, UK
   index: 1
 - name: School of Mathematical Sciences, University of Nottingham, UK
   index: 2
date: xxxxx
bibliography: paper.bib

---

# Summary
Comparative judgement models estimate the features of a set of objects based on pair-wise comparisons of the objects. Comparing objects based on certain criteria is often easier for participants than quantifying the value of each object in the set, and ellicits informative responses. This can be useful in scenarios where traditional data collection methods struggle, such as: inferring the level of deprivation in parts of a city in a developing country, qauntifying the risk of forced marriage young women face in different regions of a country, and estimating the number of cases of female genital mutilation in rural parts of a country. In practice however, comparative judgment models require time-consuming and expensive fieldwork. `BSBT` offers a solution for contexts with a strong spatial element by providing both a GUI for data collection and an R package to analyse the data. It deploys a web interface to collect comparative judgements and stores the results in a SQLite database. The R package allows this data to be analysed without technical knowledge, making this approach attractive to non-mathematical practitioners. The package implements a comparative judgment model with a spatial element, which makes efficient use of the use of the data collected and reduces the amount of data required compared to previous methods. 

# Statement of need
Current comparative judgement models are data inefficient, requiring days or weeks of time-consuming and expensive fieldwork. This makes carrying out comparative judgement studies in developing countries prohibitively expensive and logistically difficult [@Eng18; @Etten19; @Seymour20]. Exisiting packages, such as the widely used `BradleyTerry2` [@Turner2012; @Firth12], produce poor quality results when insuffient data is provided. We address this in two ways: firstly, we provide an easy-to-use GUI to carry out the fieldwork, simplifying the task for both judges and researchers; secondly, we include a data analysis package that implements and extends the Bayesian Spatial Bradley--Terry (BSBT) model [@Seymour20], which reduces the number of comparisons required to provide accurate estimates compared to current methods. 


In order to carry out a comparative judgement study, specialised software is required to show judges pairs of areas to compare and to manage the details of the users. [Bertrand's part about the data collection software]


In the BSBT model each area in the study is assigned a quality $\lambda \in \mathbb{R}$, and the probability that, in a comparison between areas $i$ and $j$, area $i$ is judged to have a higher quality than $j$ depends on the difference in quality parameters. When inferring the values of the parameters given the comparisons, we include a spatial structure, where the level of deprivation in one area depends on the level in nearby areas. Inclduding this spatial structure reduces the number of comparions needed to accurately estimate the parameter values. We infer the parameters values using a Markov chain Monte Carlo (MCMC) alogrithm. 


# The Bayesian Spatial Bradley--Terry model
We breifly describe the BSBT model and full details are provided in [@Seymour20]. If areas $i$ and $j$ are compared $n_{ij}$ times, the number of times area $i$ is judged to be more affluent than area $j$ is modelled as 
$$
Y_{ij} \sim \hbox{Bin}(n_{ij}, \pi_{ij}),
$$
and we assume $Y_{ij}$ are independent. Here the probability $\pi_{ij}$ that area $i$ is judged to be more affluent than area $j$ depends on the difference in relative deprivation of $i$ and $j$ and is
$$
    \hbox{logit}(\pi_{ij}) = \lambda_i - \lambda_j \iff \pi_{ij} = \frac{\exp(\lambda_i)}{\exp(\lambda_i) + \exp(\lambda_j)} \qquad (i \neq j, 1\leq i, j \leq N). \label{eq: logit difference}
$$
We assume the deprivation parameters are correlated, with deprivation levels in nearby areas being highly correlated and levels in far away areas having low correlation. To achieve this,  we place a multivaraition normal prior distribution such that
$$
(\boldlambda \mid \boldsymbol{1}^T\boldlambda = 0) \sim \textrm{MVN}\Big(\textbf{0}, \, \Sigma - \Sigma\boldsymbol{1}(\boldsymbol{1}^T\Sigma \boldsymbol{1})^{-1}\boldsymbol{1}^T\Sigma\Big),
$$
with the constraint that the deprivation parameters sum to 0 to remove identifaibility issues. The covariance matrix contains the spatial information and the package provides a number of ways to construct this. We recommend using a network structure, where each area is a node and edges are placed between adjacent areas. The covariance matrix is constructed using the matrix exponential of the adjecency matrix, which assigns high correlation to areas with many short paths between them, and low correlation to areas which can only be reached through long paths. The pakcage allows other network measures to be used, including one based on the length of the shortest path between areas. It is also possibel to use a Euclidean distance metric. All covariance functions supplied contain a total variance parameter. This can either be fixed or inferred using an inverse-gamma prior distribution. 

## Symmetric model
Two extensions of the model are provided in the BSBT package. The first is when there are two types of participants in the model, e.g. male and female. The symmetric model allows us to infer whether the two types agree on the level of deprivation for each area. Denote the percieved deprivation in area $i$ for type one individuals by $\lambda_i^{(1)}$ and type two individuals by $\lambda_i^{(2)}$. We construct the mean and difference for area $i$ by
$$
\lambda_i = \frac{1}{2}(\lambda_i^{(1)} + \lambda_i^{(2)}), \, \mu_i = \frac{1}{2}(\lambda_i^{(1)} - \lambda_i^{(2)}).
$$
We place multivariate normal distributions on the vectors $\boldsymbol{\lambda}$ and $\boldsymbol{\mu}$. If the posterior credible interval for $\mu_i$ does not contain 0, then there is evidence that the two types have differing opinions about area $i$.

## Asymmetric model
The second extension allows for any number of types of individuals. We treat one type as a baseline and then measure then discrepancy between each type and the baseline. Choosing type one as the baseline type, the percieved deprivation by type $k$ is
$$
\boldsymbol{\lambda}^{(k)} = \boldsymbol{\lambda}^{(1)} + \boldsymbol{u}^{(k)},
$$
where $\boldsymbol{u}^{(k)}$ follows a multivariate normal distribution. 
# Example Workflow

## Data collection interface
To install the BSBT interface, we call
```bash
git clone https://github.com/BPerrat/BSBT-Interface.git
cd BSBT-Interface
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

The following command prepares the website
```bash
python3 prepare_website.py <your_shapefile.shp>
```
We will be asked to first select which column in the Shapefile should be used as a unique identifier for the regions and secondly to select which column we wish to use to name the regions. In both cases, only suitable candidates are displayed (i.e. if a column doesn't uniquely identify each entry of the shapefile, it will not be candidate).

The script will then:
1. Regionalize (cluster) the regions for a pre-filtering stage if the dataset is large
2. Create images for each region displaying their extent on top of a map
3. Setup the database that will then be used to store the comparative judgements and eventually be passed to the BSBT model.

Once the script has run, it will have populated the folder `website/static/maps` with images and the database `comparative_judgements.db` in the root project folder. The user can run the interface using the following commands:
```bash
export FLASK_APP=website
flask run
```

If the website is likely to experience significant traffic, it is recommended to move away from Flask's built-in webserver (called with `flask run`) towards a production WSGI server such as Gunicorn.

## Data analysis
To connect to the database, call
```r
library(RSQLite)
library(BSBT)
bsbt.connection   <- dbConnect(RSQLite::SQLite(), "~/Desktop/test.db")
comparisons       <- dbReadTable(bsbt.connection, "rankings")
dbListTables(bsbt.connection) #available tables

```
There are a number of quality control measures that need to be carried out before the data is analysed. For example,  all comparisons which have been rejudged must be removed from the data set, this means a user has decided they made a mistake and would like to carry out that comparisons again. To do this, we remove any comparisons which have a flag in the rejudged column. 
```r
comparisons <- comparisons[comparisons$rejudged == 0, ]
```

To use with the `BSBT` package, we need to transform the table into a matrix, where element $w_{ij}$ contains the number of times area $i$ was chosen over area $j$. This can be done by calling
```r
win.matrix <- comparisons_to_matrix(452, comparisons[, 4:5])
```

We can now analyse the comparisons. We first construct the prior distribution covariance matrix, which contains the spatial structure of the areas. Then we feed this matrix and the processed data into the MCMC function, which infers the quality of each area. The covariance matrix function requires the adjacency matrix from the shape files. The can be done using the `spdep` package, the `surveillance` package using, or GIS software, such as QGIS. 
```r
N            <- 100 #number of areas in study
k            <- constrained_adjacency_covariance_function(your_adjacency_matrix, type = "matrix", hyperparameters = c(1), linear.combination = rep(1, N), linear.constraint = 0)
mcmc.output  <- run_mcmc(n.iter = 1500000, delta = 0.01, k, win.matrix, f.initial =  rep(0, N), alpha = TRUE)
```
The MCMC algorithm may take several hours to run. To include the posterior median estimates for the quality of each area in the data base, call
```r
burn.in            <- 500000 #burn-in period 
mean.deprivation   <- apply(mcmc.output$f[-c(1:burn.in), ], 2, mean)
quality            <- data.frame("area_id" = 1:N, "quality" = mean.deprivation)
dbCreateTable(bsbt.connection, "quality", quality)
dbDisconnect(bsbt.connection) #clean up
```


# Acknowledgements

This work is supported by the Engineering and Physical Sciences Research Council. 

# References
