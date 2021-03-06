% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/SRA_scope.R
\name{SRA_scope}
\alias{SRA_scope}
\alias{Sub_cpars}
\title{Stock-reduction analysis (SRA) for conditioning operating models}
\usage{
SRA_scope(
  OM,
  data = list(),
  condition = c("catch", "catch2", "effort"),
  selectivity = "logistic",
  s_selectivity = NULL,
  LWT = list(),
  comp_like = c("multinomial", "lognormal"),
  ESS = c(30, 30),
  max_F = 3,
  cores = 1L,
  integrate = FALSE,
  mean_fit = FALSE,
  drop_nonconv = FALSE,
  drop_highF = FALSE,
  control = list(iter.max = 2e+05, eval.max = 4e+05),
  ...
)

Sub_cpars(OM, sims = 1:OM@nsim)
}
\arguments{
\item{OM}{An object of class \linkS4class{OM} that specifies natural mortality (M), growth (Linf, K, t0, a, b), stock-recruitment relationship,
steepness, maturity parameters (L50 and L50_95), standard deviation of recruitment variability (Perr), as well as index uncertainty (Iobs).}

\item{data}{A list of data inputs. See Data section below.}

\item{condition}{String to indicate whether the SRA model is conditioned on "catch" (where F are estimated parameters), "catch2" (where F is solved internally using Newton's method),
or "effort".}

\item{selectivity}{A character vector of length nfleet to indicate \code{"logistic"}, \code{"dome"}, or \code{"free"} selectivity for each fleet in \code{Chist}.
If there is time-varying selectivity, this is a character vector of length nsel_block (see Data section below). "free" indicates independent selectivity parameters for each age,
and additional modifications for fixing selectivity parameters will likely be needed (see details).}

\item{s_selectivity}{Only used if any of the corresponding entries of \code{data$I_type = "est"}. A vector of length nsurvey to indicate \code{"logistic"}, \code{"dome"}, or \code{"free"} selectivity for each survey
corresponding to the columns in \code{data$Index}.}

\item{LWT}{A named list of likelihood weights for the SRA model. See details.}

\item{comp_like}{A string indicating either \code{"multinomial"} (default) or \code{"lognormal"} distributions for the composition data.}

\item{ESS}{If \code{comp_like = "multinomial"}, a numeric vector of length two to cap the maximum effective samples size of the age and length compositions,
respectively, for the multinomial likelihood function. The effective sample size of an age or length composition sample is the minimum of ESS or the number of observations
(sum across columns). For more flexibility, set ESS to be very large and alter the age and length arrays as needed.}

\item{max_F}{The maximum F for any fleet in the scoping model (higher F's in the model are penalized in the objective function). See also `drop_highF`.}

\item{cores}{Integer for the number of CPU cores for the stock reduction analysis.}

\item{integrate}{Logical, whether to treat recruitment deviations as penalized parameters in the likelihood (FALSE) or random effects to be marginalized out of the likelihood (TRUE).}

\item{mean_fit}{Logical, whether to run an additional with mean values of life history parameters from the OM.}

\item{drop_nonconv}{Logical, whether to drop non-converged fits of the SRA model.}

\item{drop_highF}{Logical, whether to drop fits of the SRA model where F hits \code{max_F}. Only applies if \code{drop_nonconv = TRUE}.}

\item{control}{A named list of arguments (e.g, max. iterations, etc.) for optimization, to be passed to the control argument of \code{\link[stats]{nlminb}}.}

\item{...}{Other arguments to pass in for starting values of parameters and fixing parameters. See details.}

\item{sims}{A logical vector of length \code{OM@nsim} or a numeric vector indicating which simulations to keep.}
}
\value{
An object of class \linkS4class{SRA} (see link for description of output).
}
\description{
Intended for conditioning operating models for data-limited stocks. From a historical time series of total catch or effort, and potentially
age/length compositions and multiple indices of abundance, the SRA returns a range of values for depletion, selectivity,
unfished recruitment (R0), historical fishing effort, and recruitment deviations for the operating model. This is done by sampling life history parameters
provided by the user and fitting to the data in a statistical catch-at-age model (with the predicted catch equal to the observed catch).
Alternatively one can do a single model fit and sample the covariance matrix to generate an operating model with uncertainty based on the model fit.
This function is intended to generate a range of potential depletion scenarios that could be supported from sparse data.
Either a full catch (conditioned on catch) or effort (conditioned on effort) time series is needed but missing data (as NAs) are allowed for all other data types.
}
\details{
Fleet selectivity is fixed to values sampled from \code{OM} if no age or length compositions are provided.

Survey selectivity is estimable only if \code{s_CAA} or \code{s_CAL} is provided. Otherwise, the selectivity should
be mirrored to a fleet (vulnerable biomass selectivity) or indexed to total or spawning biomass (see \code{I_type}).

Parameters that were used in the fitting model are placed in objects in \code{OM@cpars}.

\code{Sub_cpars} is a convenient function to subset simulations
for the operating model, for example, to remove simulations from unconverged model fits or outlier simulations.

If the operating model \code{OM} uses time-varying growth or M, then those trends will be used in the SRA as well.
Time-varying life history parameters create ambiguity in the calculation and interpretation of depletion and reference points in \link[DLMtool]{runMSE}.
See section D.5 of \code{DLMtool::userguide()}.

The easiest way to turn off time-varying growth/M is by setting: \code{OM@Msd <- OM@Linfsd <- OM@Ksd <- c(0, 0)}.
}
\section{Vignette}{

Three vignettes are available for the SRA model:

\itemize{
\item \href{../doc/SRA_scope.html}{General overview of approach}
\item \href{../doc/SRA_scope_eq.html}{Mathematical description}
\item \href{../doc/SRA_scope_sel.html}{Setup of selectivity settings} (useful for more data-rich cases)
}
}

\section{Data}{

One of indices, age compositions, or length compositions should be provided in addition to the historical catch or effort. Not all arguments
are needed to run the model (some have defaults, while others are ignored if not applicable depending on the data provided).

The \code{data} list can include:

\itemize{
\item Chist - A vector of historical catch, should be of length OM@nyears. If there are multiple fleets: a matrix of OM@nyears rows and nfleet columns.
Ideally, the first year of the catch series represents unfished conditions (see also \code{C_eq}).
\item Ehist - A vector of historical effort, should be of length OM@nyears (see also \code{E_eq}).
\item Index - A vector of values of an index (of length OM@nyears). If there are multiple surveys: a matrix of historical indices of abundances, with rows
indexing years and columns indexing surveys. Age-specific indices should be numbers-specific while all others are weight-based.
\item I_sd - A vector or matrix of standard deviations (lognormal distribution) for the indices corresponding to the entries in \code{Index}.
If not provided, this function will use values from \code{OM@Iobs}.
\item I_type - A character vector of length nsurvey to indicate the type of biomass for which each index follows. Either \code{"B"} for
total biomass, or \code{"SSB"} for spawning biomass. If not provided, "B" is used. Use numbers if the index corresponds to a fleet in \code{Chist}.
Use \code{"est"} to set survey selectivity to be an independent component of the model, i.e., as an age-specific index or estimated separately.
Note, this generally requires age \code{s_CAA} or length \code{s_CAL} compositions.
\item CAA - Fishery age composition matrix with nyears rows and OM@maxage columns. If multiple fleets: an array with dimension: nyears, OM@maxage, and nfleets.
\item CAL - Fishery Length composition matrix with nyears rows and columns indexing the length bin. If multiple fleets: an array with dimension: nyears,
length bins, and nfleets.
\item ML - A vector of fishery mean length observations (length OM@nyears), or if multiple fleets: matrix of dimension: nyears and nfleets. Generally, should not
be used if \code{CAL} is also provided, unless mean length and length comps are independently sampled.
\item ML_sd - The standard deviation (normal distribution) of the observed mean lengths. If there are multiple fleets, a vector of length nfleet.
If not provided, default value is \code{0.1 * mean(ML)}.
\item s_CAA - Survey age composition data, an array of dimension nyears, maxage, nsurvey.
\item s_CAL - Survey length composition data, an array of dimension nyears, length(length_bin), nsurvey.
\item length_bin - A vector for the midpoints of the length bins for \code{CAL} and \code{s_CAL}. All bin widths should be equal in size.
\item C_eq - A numeric vector of length nfleet for the equilibrium catch for each fleet in \code{Chist} prior to the first year of the operating model.
Zero (default) implies unfished conditions in year one. Otherwise, this is used to estimate depletion in the first year of the data. Alternatively,
if one has a full CAA matrix, one could instead estimate "artificial" rec devs to generate the initial numbers-at-age (and hence initial depletion) in the first year of the model (see additional arguments).
\item E_eq - The equilibrium effort for each fleet in \code{Ehist} prior to the first year of the operating model.
Zero (default) implies unfished conditions in year one. Otherwise, this is used to estimate depletion in the first year of the data.
\item abs_I - Optional, an integer vector to indicate which indices are in absolute magnitude. Use 1 to set q = 1, otherwise use 0 to estimate q.
\item I_units - Optional, an integer vector to indicate whether indices are biomass based (1) or abundance-based (0). By default, all are biomass-based.
\item age_error - Optional, a square matrix of maxage rows and columns to specify ageing error. The aa-th column assigns a proportion of the true age in the
a-th row to observed age. Thus, all rows should sum to 1. Default is an identity matrix (no ageing error).
\item sel_block - Optional, for time-varying fleet selectivity (in time blocks), a matrix of nyears x nfleet that assigns a selectivity function to a fleet-year combination.
See the \href{../doc/SRA_scope_sel.html}{selectivity} vignette for more details.
\item nsel_block - Optional, the number of selectivity blocks.
}
}

\section{Additional arguments}{

For \code{SRA_scope}, additional arguments can be passed to the model via \code{...}:

\itemize{
\item vul_par: A matrix of 3 rows and nfleet columns for starting values for fleet selectivity. The three rows correspond
to LFS (length of full selectivity), L5 (length of 5 percent selectivity), and Vmaxlen (selectivity at length Linf). By default,
the starting values are values from the OM object. If any selectivity = "free", then this matrix needs to be of maxage rows where
the row specifies the selectivity at age. See the \href{../doc/SRA_scope_sel.html}{selectivity} vignette for more information.
\item s_vul_par: A matrix of 3 rows and nsurvey columns for starting values for fleet selectivity. Same setup as vul_par. These values are only
used if \code{s_selectivity = "est"} for the corresponding fleet. Otherwise, placeholders should be used to complete the matrix.
\item map_vul_par: The map argument for vul_par in TMB, see \link[TMB]{MakeADFun}, which indicates whether selectivity parameters are fixed
or estimated. A matrix of the same dimension as vul_par. If an entry is \code{NA}, the corresponding parameter is fixed in the model to the starting
value. Otherwise, an integer for each independent parameter. By default, selectivity is fixed if there are no age or length composition for that fleet
or survey, otherwise estimated. Unused cells in the vul_par matrix should be given NA in the map matrix.
\item map_s_vul_par: The map argument for the survey selectivity parameters (same dimension as s_vul_par). Placeholder parameters should have a map value of NA.
\item map_log_early_rec_dev: A vector of length OM@maxage - 1 that indexes which recruitment deviates for the cohorts in the first year of the model are fixed (using NA) or estimated (a separate integer).
By default, no deviates are estimated.
\item map_log_rec_dev: A vector of length OM@nyears that indexes which recruitment deviates are fixed (using NA) or estimated (a separate integer).
By default, all deviates are estimated.
\item plusgroup: Logical for whether the maximum age is a plusgroup or not. By default, TRUE.
\item fix_dome: Logical for whether the dome selectivity parameter for fleets is fixed. Used primarily for backwards compatibility, this is overridden by map_vul_par.
\item resample: Logical, whether the OM conditioning parameters (recruitment, fishing mortality, SSB, selectivity, etc.) are obtained by sampling the Hessian matrix from
a single model fit. By default FALSE. This feature requires identical biological parameters among simulations.
}
}

\section{Likelihood weights}{

\code{LWT} is an optional named list containing the likelihood weights (values >= 0) with the possible options:
\itemize{
\item Chist: A vector of length nfleet.
\item Index: A vector of length nsurvey.
\item CAA, CAL, ML, C_eq: A vector of length nfleet for each.
\item s_CAA, s_CAL: A vector of length nsurvey for each.
}

By default, all likelihood weights are equal to one if not specified by the user. Weighting for CAA and CAL can also be adjusted by changing the
multinomial sample size. For \code{CAA}, \code{CAL}, \code{s_CAA}, and \code{s_CAL}, the arrays should be set up so that
the annual number of observations (summed over columns) should be equal to the presumed effective sample size. Argument \code{ESS} provides a shortcut
to cap the the effective sample size.

To play with alternative fits by excluding indices, for example, set the corresponding likelihood weight to zero. The model will still
generate the inferred index but the data won't enter the likelihood.
}

\seealso{
\link{plot.SRA} \linkS4class{SRA}
}
\author{
Q. Huynh
}
