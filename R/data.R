#' Comparative Judgement on Deprivation in Dar es Salaam, Tanzania
#'
#' A comparative judgement dataset on deprivation in subwards in Dar es Salaam, Tanzania.
#' Citizens were shown pairs of subwards at random and asked which was more deprived.
#' If they said they were equal, one of the pair was chosen at random to be more deprived.
#' The data was collected in August 2018.
#' @docType data
#'
#'
#' @format A csv file containing 76408 rows and 2 columns. Each row corresponds to a judgement made by a single judge. The column shows which of the pair of subwards was judged to be poorest and richest.
#'
#' @keywords datasets
#'
#'@source This dataset was collected by Madeleine Ellis, James Goulding, Bertrand Perrat, Gavin Smith and Gregor Engelmann.We gratefully acknowledge the Rights Lab at the University of Nottingham for supporting funding for the comprehensive ground truth survey. We also acknowledge HumanitarianStreet Mapping Team (HOT) for providing a team of experts in data collectionto facilitate the surveys. This work was also supported by the EPSRC HorizonCentre for Doctoral Training - My Life in Data (EP/L015463/1) and EPSRC grant Neodemographics (EP/L021080/1).
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
#' @format A 452x452 matrix, where a_{ij} = 1 if subwards i and j are neighbours and 0 otherwise.
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

