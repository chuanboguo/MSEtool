% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/define_S4_class_SRA.R
\docType{class}
\name{SRA-class}
\alias{SRA-class}
\alias{SRA}
\title{Class-\code{SRA}}
\description{
An S4 class for the output from \link{SRA_scope}.
}
\section{Slots}{

\describe{
\item{\code{OM}}{An updated operating model, class \linkS4class{OM}.}

\item{\code{SSB}}{A matrix of estimated spawning biomass with \code{OM@nsim} rows and \code{OM@nyears+1} columns.}

\item{\code{NAA}}{An array for the predicted numbers at age with dimension \code{OM@nsim}, \code{OM@nyears+1}, and \code{OM@maxage}.}

\item{\code{CAA}}{An array for the predicted catch at age with dimension \code{OM@nsim}, \code{OM@nyears}, \code{OM@maxage}, and nfleet.}

\item{\code{CAL}}{An array for the predicted catch at length with dimension \code{OM@nsim}, \code{OM@nyears}, length bins, and nfleet.}

\item{\code{conv}}{A logical vector of length \code{OM@nsim} indicating convergence of the SRA scoping model in the i-th simulation.}

\item{\code{Misc}}{A list of length \code{OM@nsim} with more output from the fitted SRA scoping model. Within each simulation, items of interest include:

\itemize{
\item B - total biomass - vector of length nyears+1
\item E0 - annual unfished spawning biomass - vector of length nyears
\item E0_SR - unfished spawning biomass for the stock-recruit relationship - numeric
\item Arec - alpha parameter of the stock-recruit relationship - numeric
\item Brec - beta parameter of the stock-recruit relationship - numeric
\item R - recruitment - vector of length nyears+1
\item R_early - recruitment for the cohorts in first year of the model - vector maxage-1
\item VB - vulnerable biomass - matrix of nyears x nfleet
\item N - abundance at age - matrix of nyears+1 x maxage
\item F - apical fishing mortality - matrix of nyears x nfleet
\item F_at_age - fishing mortality at age - array of nyears x maxage x nfleet
\item F_equilibrium - equilibrium fishing mortality prior to first year - vector of length nfleet
\item M - natural mortality - matrix of nyears x maxage
\item Z - total mortality - matrix of nyears x maxage
\item q - survey catchability - vector of length nsurvey
\item s_vul - survey selectivity at age - array of dim nyears+1, maxage, nsurvey
\item s_vul_len - corresponding survey selectivity at length - matrix of nbins x nsurvey
\item Ipred - predicted index values - matrix of nyears x nsurvey
\item s_CAApred - predicted survey catch at age - array of dim nyears, maxage, nsurvey
\item vul - fleet selectivity at age - array of dim nyears+1, maxage, nfleet (or nsel_block)
\item vul_len - corresponding fleet selectivity at length - matrix of nbins x nfleet (or nsel_block)
\item s_CALpred - predicted survey catch at length - array of dim nyears, nbins, nsurvey
\item mlen_pred - predicted mean lengths - matrix of nyears x nfleet
\item CAApred - predicted catch at age - array of nyears, maxage, nfleet
\item CALpred - predicted catch at length - array of nyears, nbins, nfleet
\item Cpred - predicted catch in weight - matrix of nyears x nfleet
\item CN - predicted catch in numbers - matrix of nyears x nfleet
\item nll - Total objective function of the model - numeric
}}

\item{\code{mean_fit}}{A list of output from fit to mean values of life history parameters in the operating model. The named list consists of:

\itemize{
\item obj - a list with components returned from \code{\link[TMB]{MakeADFun}}.
\item opt - a list with components from calling \code{\link[stats]{nlminb}} to \code{obj}.
\item SD - a list (class sdreport) with parameter estimates and their standard errors, obtained from
\code{\link[TMB]{sdreport}}.
\item report - a list of model output reported from the TMB executable, i.e. \code{obj$report()}. See Misc.
}}

\item{\code{data}}{A list of the data inputs for the SRA scoping model.}

\item{\code{config}}{A data frame describing configuration of the SRA scoping model (not currently used).}
}}

\seealso{
\link{plot.SRA} \link{SRA_scope}
}
\author{
Q. Huynh
}
