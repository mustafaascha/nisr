
#' Download and parse Stata file for a specific NIS year.
#'
#' This function is used by \code{read_nis}. Given a year between 2004 and 2012,
#' the function returns a dataframe
#' containing four components describing each NIS variable that is provided
#' for that year: (1) type, (2) name, (3) starting character number for
#' fixed-width reading, (4) ending character number for fixed-width reading.
#'
#' @param file This is the NIS file type that you would like to read. Choose one of c("core", "hospital", "dxpr", "severity")
#' @param file_year The year that your NIS file comes from.
#'
#' @return A data.frame with four vectors, each describing the fixed-width NIS file from \code{file_year}
# @example parse_year_format(2012)
#' @importFrom magrittr %>%
#' @importFrom stringr str_replace_all str_trim str_split



parse_year_format <- function(file, file_year) {

  #note: formatting pulled from stata
  #For core files
  if(file == "core"){
    url <- paste0("https://www.hcup-us.ahrq.gov/db/nation/nis/tools/pgms/StataLoad_NIS_", file_year, "_Core.Do")
  }

  #Example hospital URL:
  #https://www.hcup-us.ahrq.gov/db/nation/nis/tools/pgms/StataLoad_NIS_2012_Hospital.Do
  if(file == "hospital"){
    url <- paste0("https://www.hcup-us.ahrq.gov/db/nation/nis/tools/pgms/StataLoad_NIS_", file_year, "_Hospital.Do")
  }

  #Example DXPR URL:
  #https://www.hcup-us.ahrq.gov/db/nation/nis/tools/pgms/StataLoad_NIS_2012_DX_PR_GRPS.Do
  if(file == "dxpr"){
    url <- paste0("https://www.hcup-us.ahrq.gov/db/nation/nis/tools/pgms/StataLoad_NIS_", file_year, "_DX_PR_GRPS.Do")
  }

  #Example severity URL:
  #https://www.hcup-us.ahrq.gov/db/nation/nis/tools/pgms/StataLoad_NIS_2012_Severity.Do
  if(file == "severity"){
    url <- paste0("https://www.hcup-us.ahrq.gov/db/nation/nis/tools/pgms/StataLoad_NIS_", file_year, "_Severity.Do")
  }


  #read in data from appropriate year
  #make sure to change name of format to stata_format_file
  format  <-
    readLines(url)

  #select appropriate lines
  format <-
    format[grep(x = format, pattern = "infix"):
             (grep(x = format, pattern = "using") - 1)]


  #parse out each element
  format <-
    str_replace_all(format, pattern = "infix\\ |\\   \\///", replacement = "\\      ") %>%
    str_trim(side = "both") %>%
    str_replace_all(pattern = "\\ +", replacement = "\\.") %>%
    str_split(pattern = "\\.|\\-")

  #remove empty elements...there's gotta be a better way to do this
  format <-
    lapply(format, function(element)
      element[
        vapply(element,
               FUN = function(x) x != "",
               FUN.VALUE = logical(1))
        ]
    )


  #matrix approach is problematic bc of missing value @ row 5
  #make a container
  formatFrame <-
    data.frame(type = 1:length(format),
               name = 1:length(format),
               start = 1:length(format),
               end = 1:length(format))

  #fill the container
  for(i in 1:length(format[[1]])){
    formatFrame[,i] <-
      vapply(format, function(row) row[i], FUN.VALUE = character(1))
  }

  #maybe fix the type sometime
  #formatFrame <- formatFrame[,c(2:4)]
  # formatFrame$type[formatFrame$type == "str"] <-
  #   "character"
  #
  # formatFrame$type[formatFrame$type == "int" |
  #                      formatFrame$type == "byte" |
  #                      formatFrame$type == "double" |
  #                      formatFrame$type == "long"] <-
  #   "number"
  formatFrame$type <- NULL

  formatFrame$start <- as.numeric(formatFrame$start)
  formatFrame$end <- as.numeric(formatFrame$end)

  formatFrame

}

#testing -- integrate into testthat!
# test <- list()
#
# for(i in 2004:2013){
#   test[[as.character(i)]] <-
#     parse_year_format(file = "core", file_year = i)
# }


#' Read an NIS file from a specific year
#'
#' This function reads a single type of NIS file (between Core, Hospital,
#' Diagnosis/Procedure, and Severity) from a single year.
#'
#' @param file_path This is where the NIS file is located.
#' @param file_type This is the NIS file type that you would like to read. Choose one of c("core", "hospital", "dxpr", "severity")
#' @param year Choose a year between 2004 and 2012.
#' @return A data.frame with all NIS fields
# @example read_file(file_path = "path/to/file", file_type = "core", year = 2012)
#' @export
#' @importFrom readr read_fwf

read_nis <- function(file_path, file_type, year){

  if(!(file_type == "core" | file_type == "hospital" | file_type == "dxpr" | file_type == "severity")) {
    stop("Invalid file type specified, must be one of: core, hospital, dxpr, or severity")
    return(NULL)
  }

  if(year > 2012 | year < 2004) {
    stop("Year must be between 2004 and 2012")
    return(NULL)
  }

  formatFrame <-
    parse_year_format(file = file_type, file_year = year)

  #return the prize
  read_fwf(file_path,
          col_positions = fwf_positions(start = formatFrame$start,
                                        end = formatFrame$end,
                                        col_names = formatFrame$name))
}


