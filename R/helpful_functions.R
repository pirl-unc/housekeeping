# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# %ni%
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' @title 'Not in'
#' 
#' @description 
#' Negates %in%
#' 
#' @param None
#' 
#' @return The opposite of %in%
#' 
#' @export
`%ni%`<- Negate(`%in%`)


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# move_to_end
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' @title Move item to end of vector
#'
#' @param my_vector A vector
#' @param items_to_move Item or vector of items to move ( not indices )
#' 
#' @return Returns reordered vector
#' @export
move_to_end = function(
  my_vector, 
  items_to_move
){
  
  items_to_move = items_to_move[items_to_move %in% my_vector]
  start_items = my_vector[my_vector %ni% items_to_move]
  
  return(c(start_items, items_to_move))
}


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# move_to_front
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' @title Move item to front of vector
#'
#' @param my_vector A vector
#' @param items_to_move Item or vector of items to move ( not indices )
#' 
#' @return Returns reordered vector
#' 
#' @export
move_to_front = function(
  my_vector, 
  items_to_move
){
  items_to_move = items_to_move[items_to_move %in% my_vector]
  end_items = my_vector[my_vector %ni% items_to_move]
  
  return(c(items_to_move, end_items))
}


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# move_to_position
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' @title Move item to position of vector
#'
#' @param my_vector A vector
#' @param items_to_move Item or vector of items to move ( not indices )
#' @param my_position Integer/Index of the postion the items should be moved to move the items to
#' 
#' @return Returns reordered vector
#' 
#' @export
move_to_position = function(
  a_vector, 
  items_to_move, 
  my_position
){
  
  items_to_move = items_to_move[items_to_move %in% a_vector] # make sure items are there first
  
  
  if(my_position > length(a_vector)){
    return_v = move_to_end(a_vector, items_to_move)
  } else if (my_position < 2){
    return_v = move_to_front(a_vector, items_to_move)
  } else {
    a_vector = sapply(a_vector, function(x){paste0(x)})
    a_vector = append(a_vector, items_to_move,  after = my_position - 1)
    a_vector = a_vector[!(names(a_vector) %in% items_to_move)]
    names(a_vector) = NULL
    return_v = a_vector
  }
  return(return_v)
}


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# a
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' @title Adds annotations
#' 
#' @description 
#' Method to output text to configured readme file and to console
#'  
#' @param ... Text to output
#' 
#' @export
a <- function(...){
  my_output = paste0(...)
  my_output = paste0(my_output, "\n")
  if (!is.null(readme_path)) {
    cat(my_output, file = readme_path, append = TRUE)
  }
  cat(my_output)
}


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# configure_readme
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' @title Configure readme file
#' 
#' @description 
#' Method to set the README_PATH and remove existing readme file
#'  
#' @param output_dir path in which to save readme file
#' @param file_prefix value to use as prefix to _readme.txt file
#' 
#' @export
configure_readme = function( output_dir, file_prefix ){
  README_PATH <<- file.path(output_dir, paste0(file_prefix, "_readme.txt"))
  
  if(file.exists(README_PATH)) file.remove( README_PATH )
  
  a("Readme path set to: ", README_PATH)
  return(README_PATH)
}


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# list_missing_columns
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' @title Prints any column names not yet defined in data
#' 
#' @description 
#' Method to print out any col_names not yet defined in the data passed in. Intended to help with preparing valid data.
#'
#' @param dat data to look for column names within
#' @param col_names vector representing full set of column names expected
#' 
#' @return vector of missing column names ( also printed to console )
#' 
#' @export
#' 
list_missing_columns = function(dat, col_names){
  missing = setdiff(col_names, colnames(dat))
  #  missing = col_names[!(col_names %in% colnames(dat))]
  if(length(missing) == 0) cat("There are no missing columns.")
  else{
    cat(paste("There are ", length(missing), " missing columns:\n")) 
    cat(paste(missing, collapse="\n"))
  }
  return(missing)
}


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# use_nextflow_wd
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' @title Tries to set the wd to the wd found in the Nextflow log.
#' 
#' @description 
#' Looks along the script path to find the Nextflow 'log' folder and looks for the script name for the last Nextflow wd
#'
#' @param script_path path to being traversing down to look for a log folder
#' @param script_name name of script to look for in the Nextflow log
#' @param set_file_pane boolean indicating whether you'd like to have rstudio's file borwser pane directed to the wd
#' 
#' @return vector of missing column names ( also printed to console )
#' 
#' @export
#' 
use_nextflow_wd = function(script_path, script_name, set_file_pane=F){
  log_dir = find_file_along_path(script_path,'logs')
  if (!is.null(log_dir)){
    log_path = file.path(find_file_along_path(script_path,'logs'), ".nextflow.log")
    log_lines = readLines(log_path)
    log_lines %<>% grep(paste0(script_name, ":rscript"), ., value = T)
    log_lines = grep("Submitted|Cached", log_lines, value = T)
    if ( length(log_lines) > 0 ){
      work_string = substring(log_lines, unlist(gregexpr('\\[', log_lines))[2]+1, unlist(gregexpr('\\]', log_lines))[2]-1)
      my_folders = strsplit(  work_string, split = "/")[[1]]
      parent_work_dir = file.path(find_file_along_path(script_path,'^work$'), my_folders[1])
      work_folder = list.dirs(parent_work_dir, full.names = F, recursive = F)
      work_folder = grep(paste0("^", my_folders[2]), work_folder, value = T)
      work_dir = file.path(parent_work_dir, work_folder)
      message("Setting working directory to location of script in Nextflow log.")
      setwd(work_dir)
      if (set_file_pane) rstudioapi::filesPaneNavigate(work_dir)
      } else {
        message("Could not find script name in log file. Was Nextflow allowed to finish?")
      }
  } else {
    message("Could not find Nextflow log file.")
  }
}