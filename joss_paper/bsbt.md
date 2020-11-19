---
title: 'BSBT: A package for collecting and analysing comparative judgement data'
tags:
  - R
  - Python
  - Data Collection
  - Bayesian Computation
  - Comparative Judgement
authors:
  - name: Bertrand Perratt
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
Statistics UN sustainabale developement goals such as availability of clearn water, the prevelance of Female Genital Mutilation, and the accessibility of healthcare in areas in developing countries are often unreliable or unavaialble.  Comparative judgement methods allow us to estimate these statistics by asking citizens of developing countries to compare different areas in their region based on the quality in question. In practice however, comparative judgement models require time-consuming and expensive fieldwork. BSBT offers a soultion by providing both a GUI for data collection and an R package to analyse the data. [One sentence about the data collection software]. The R package allows the data to be analysed without tehcnincal knowlegde, making this approach attractive to non-mathematical practitioners, and implements a comparative judgement model with a spatial element, which makes efficient use of the use of the data collected and reduces the amount of data required compared to previous methods. 

# Statement of Need
Comparative judgement models, such the the Bradley--Terry (BT) model `[@Brad52]`, are used to estimate the quality of objects in a set, for example chess players in a tournament `[@Car12]` or sports teams in a league `[@Cat12]`. In this software, the objects are areas of cities or countries and the qualities are statistics about each area, such as the deprivation level. In the BT model each area in the study is assigned a quality $\lambda \in \mathbb{R}$, and the probability that, in a comparison between areas $i$ and $j$, area $i$ is judged to have a higher quality than $j$ depends on the difference in quality parameters. The `BradleyTerry2` R package `[@Turner2012; @Firth20]` provides a widely-used implementation of the BT model, however, in order to get good estimates for the qualities, a large amount of data needs to be collected. This makes carrying out comparative judgement fieldwork in developing countries prohbitively expensive and logistically difficult `[@Eng18; @Etten19]`. We address this in two ways: firstly, we provide an easy-to-use GUI to carry out the fieldwork simplifying the task for both participants and researchers; secondly, we include a data analysis package that implements and extends the Bayesian Spatial Bradley--Terry (BSBT) model, which reduces the number of comparisons required to provide good estimates comapred to the `BradleyTerry2` package. 

[Probably needs more and may be incorrect] In order to carry out a comparative judgement study, sepcialised software is required to show user pairs of areas to compare and to manage the details of the users. This may be challenging to develop for researchers who wish to carry out this kind of fieldwork. We have developed a GUI, written in python, which shows participants pairs of areas based on shapefiles the researcher has provided. We also provide database interfacing with postegresql, to allow for different participants to make comparisons simultaneously and to store participants details, for example name, age, or occupation. 

The `BSBT` R package provides an implementation of the BSBT model. In this model, we assume the quality of the areas are correlated, with qualities of nearby areas having corrleation than qualities of areas which are far apart. Inlcuding spatial correlation reduces the number of comparisons that need to be collected in order to provide good estimates of the qualities, as we can learn about the quality from one area from nearby areas. In order to make this applicable to as many contexts as possible, we provide two methods of defining nearby areas: the first is using a Euclidean distance metric, which is suitable for regions which contain areas of similar sizes, the second is a network distance metric, where each area is represented as a node and edges a placed between adjacent areas and this method is sutiable for regions which contain areas of different sizes, such as cities where the centre is packed with small areas and the suburbs contain larger areas. The qualities of the areas and model hyperparameters are then estimated using a Markov chain Monte Carlo (MCMC) algorithm. 

# Features 

[Bertrand's part about the data collection software]


The R package includes the following features: 
  * an implementation of the BSBT model,
  * an implementation of the BSBT model with two types of participants, e.g. male and female,
  * an asymmetric implementation of the BSBT model with $n$ types of participants,
  * a method for including prior assumptions or elicited information about the qualities of the areas, 
  * methods for simulating comparative judgements,
  * a smooth transition between the data collection and analysis, and
  * a bayesian implementation of the BT model, analogous to the classical implementation provided in the `BradleyTerry2` package.
The package includes vignettes on how to use each of the features, and examples of the analysis, alongside the documentation for the functions. Aslo included in the R package is a comparative judgement data set we collected in Tanzania, which contains over 75,000 comparisons of areas of the countries largest city Dar es Salaam. Over 200 citizens were involved in the study and compared areas based on affluence. This data set has been used in 




# Acknowledgements

This work is supported by the Engineering and Physical Sciences Research Council [grant number EP/T003928/1] and the Big East African Data Science research group at the University of Nottingham. The comparative judgement dataset was collected by Madeleine Ellis, James Goulding, Bertrand Perrat, Gavin Smith and Gregor Engelmann. We gratefully acknowledge the Rights Lab at the University of Nottingham for supporting funding for the comprehensive ground truth survey. We also acknowledge Humanitarian Street Mapping Team (HOT) for providing a team of experts in data collection to facilitate the surveys. This fieldwork was also supported by the EPSRC Horizon Centre for Doctoral Training - My Life in Data [EP/L015463/1] and by EPSRC grant Neodemographics [EP/L021080/1].

# References
