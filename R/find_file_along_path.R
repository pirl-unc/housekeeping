# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# find_file_along_path
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' @title Goes up path component and looks for the file_name in each directory.
#' 
#' @param my_path character string path to search along
#' @param file_name character string to search for
#' 
#' @return Path to the file if it's along the path provided
#' 
#' @export
find_file_along_path = function(my_path, file_name){
  return_path = NULL
  while(nchar(my_path) > 0){
    if(file_name %in% list.files(my_path)){
      return_path = file.path(my_path, file_name)
      break
    }
    my_path = dirname(my_path)
  }
  
  if(is.null(return_path)) warning(paste0("Cannot find '",file_name,"' along path ", my_path))
  
  return(return_path)
}
