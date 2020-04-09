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

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# find_folder_along_path
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' @title Goes up path component and looks for the folder_name in each directory.
#' 
#' @param my_path character string path to search along
#' @param folder_name character string to search for
#' 
#' @return Path to the folder if it's along the path provided
#' 
#' @export
find_folder_along_path = function(my_path, folder_name){
  path_components = strsplit(my_path, "/")[[1]]
  for(path_index in length(path_components):1){
    path_components = path_components[-path_index]
    parent_path = paste0(path_components, collapse = "/")
    dir_folders = list.dirs(parent_path, full.names = FALSE, recursive = FALSE)
    found_index = which(tolower(dir_folders) %in% tolower(folder_name))
    if(length(found_index) > 0){
      return(file.path(parent_path, dir_folders[found_index]))
    }
  }
  warning(paste0("Cannot find '", folder_name,"' along path ", my_path))
  return(NULL)
}
