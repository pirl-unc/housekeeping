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
  
  items_to_move = items_to_move[items_to_move %in% a_vector]
  if (my_position > length(a_vector)) {
    return_v = move_to_end(a_vector, items_to_move)
  }
  else if (my_position < 2) {
    return_v = move_to_front(a_vector, items_to_move)
  }
  else {
    move_vector <- a_vector[which(a_vector %in% items_to_move)]
    a_vector <- a_vector[!(a_vector %in% items_to_move)]
    return_v <- append(a_vector, move_vector, after = min(length(a_vector), my_position - 
                                                            1))
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
  if (exists("README_PATH", envir = .GlobalEnv)) {
  	if (!is.null(README_PATH)) {
  		if (README_PATH != "") {
	      cat(my_output, file = README_PATH, append = TRUE)
  		}
  	}
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

