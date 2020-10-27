#' Comparative Judgment on Deprivation in Dar es Salaam, Tanzania
#'
#' A comparative judgment data set on deprivation in subwards in Dar es Salaam, Tanzania.
#' Citizens were shown pairs of subwards at random and asked which was more deprived.
#' If they said they were equal, one of the pair was chosen at random to be more deprived.
#' The data was collected in August 2018. The gender of each judge is also included.
#' @docType data
#'
#'
#' @format A csv file containing 75078 rows and 3 columns. Each row corresponds to a judgement made by a single judge. Columns 2 and 3 shows which of the pair of subwards was judged to be poorest and richest, and column 3 shows the gender of the judge.
#'
#' @keywords datasets
#'
#' @source This data set was collected by Madeleine Ellis, James Goulding, Bertrand Perrat, Gavin Smith and Gregor Engelmann.We gratefully acknowledge the Rights Lab at the University of Nottingham for supporting funding for the comprehensive ground truth survey. We also acknowledge HumanitarianStreet Mapping Team (HOT) for providing a team of experts in data collection to facilitate the surveys. This work was also supported by the EPSRC Horizon Centre for Doctoral Training - My Life in Data (EP/L015463/1) and EPSRC grant Neodemographics (EP/L021080/1).
#'
"dar.comparisons"





#' Shape files for the subwards in Dar es Salaam, Tanzania
#'
#' Polygons for the 452 subwards in Dar es Salaam, Tanzania
#'
#' @docType data
#'
#'
#' @format A .shp object
#'
#'
#' @keywords datasets
#'
#'
"dar.shapefiles"



#' Adjacency matrix for the subwards in Dar es Salaam, Tanzania
#'
#'
#'
#' @docType data
#'
#'
#' @format A 452x452 matrix, where a_{ij} = 1 if subwards i and j are neighbours and 0 otherwise. The adjacency matrix is based on areas which share administrative borders. Two additional edges over the Kurasini creek to represent a road and ferry crossing have been added.
#'
#'
#' @keywords datasets
#'
#'
"dar.adj.matrix"


#' The Mean Level of Deprivation for Subwards in Dar es Salaam
#'
#'This data is used in the vignette
#'
#' @docType data
#'
#'
#' @format An vector
#'
#'
#' @keywords datasets
#'
#'
"mean.deprivation"




#' The mean level of deprivation for subwards in Dar es Salaam as perceived by men
#'
#' This data is used in the vignette
#'
#' @docType data
#'
#'
#' @format An vector of 452 elements, one for each subward
#'
#'
#' @keywords datasets
#'
#'
"male.mean.deprivation"



#' The mean level of deprivation for subwards in Dar es Salaam as perceived by women
#'
#' This data is used in the vignette
#'
#' @docType data
#'
#'
#' @format An vector of 452 elements, one for each subward
#'
#'
#' @keywords datasets
#'
#'
"female.mean.deprivation"





