
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# detach_package
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' @title Unloads packages 
#' 
#' @param package_name name of the package to detach as string
#' 
#' @return No return value.  
#' 
#' @section Side effects:
#' \itemize{
#'   \item Unloads the named package  
#'}
#' 
#' @export
detach_package = function(package_name){
  search_item = paste0("package:", package_name)
  while(search_item %in% search())
  {detach(search_item, unload = TRUE, character.only = TRUE)}
}


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# remove_package_from_all_libraries
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' @title Searches all libraries in .libPaths() and deletes the named package in all of them
#' 
#' @param package_name name of the package to detach as string
#' 
#' @return No return value.  
#' 
#' @section Side effects:
#' \itemize{
#'   \item deletes the named package in all libraries
#'}
#' 
#' @export
remove_package_from_all_libraries = function(package_name){
  for(lib_path in .libPaths()){
    if(package_name %in% list.dirs(lib_path, full.names = FALSE, recursive = FALSE)){
      inert_err_msg = capture.output(remove.packages(package_name, lib_path))
    }
  }
}


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# package_is_loaded
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' @title Tells if package_name is currently loaded
#' 
#' @param package_name string name of the package
#' 
#' @return T/F on if the named packate is in sessionInfo()$otherPkgs
#' 
#' @export
package_is_loaded = function(package_name){
  loaded_packages = sessionInfo()
  running_packages =  names(loaded_packages$otherPkgs)
  return(package_name %in% running_packages)
}


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# get_loaded_package_version
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' @title Tells which version of the named package is loaded.
#' 
#' @param package_name string name of the package
#' 
#' @return T/F on if the named package is in sessionInfo()$otherPkgs
#' 
#' @export
get_loaded_package_version = function(package_name){
  my_return = NA
  if(package_is_loaded(package_name)){
    loaded_packages = sessionInfo()
    running_package =  loaded_packages$otherPkgs[[package_name]]
    my_return = running_package$Version
  }
  return(my_return)
}


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# matches_loaded_version
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' @title Tells if my_version matches the version returned from \code{get_loaded_package_version}
#' 
#' @param my_version version to test if it matches the one loaded in the session 
#' @param package_name string name of the package to check
#' 
#' @return T/F on if the named package is in sessionInfo()  
#' 
#' @export
matches_loaded_version = function(
  package_name,
  my_version
){
  my_return = FALSE
  loaded_version = get_loaded_package_version(package_name = package_name)
  if(!is.na(loaded_version)){
    my_return = loaded_version == BINFOTRON_VERSION
  }
  return(my_return)
}


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# get_package_version_listed_in_description
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' @title Gets the package version listed in the package description file
#' 
#' @param my_dir directory path to the library package
#' 
#' @return Version of the package found in the DESCRIPTION file
#' 
#' @export
get_package_version_listed_in_description = function(my_dir){
  
  description_file_path = file.path(my_dir, "DESCRIPTION")
  description_lines = readLines(description_file_path)# open connection
  version_line = NULL
  for(line_index in 1:length(description_lines)){
    this_line = description_lines[line_index]
    if(grepl("^Version:", this_line)){
      version_line = line_index
      version_string = this_line
      break
    } else {
      version_string = NULL
    }
  }
  my_version = gsub("Version: ", "", version_string)
  return(my_version)
}


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# assemble_package
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' @title Takes a local package and assembles it
#' 
#' @param package_name string name of the package
#' @param my_version string version the package should be named
#' @param my_dir directory path to the package
#' 
#' @return No return value
#' 
#' @section Side effects:
#' \itemize{
#'   \item Modifies the version listed in the DESCRIPTION file  
#'   \item Deletes the tar file from any older packages
#'   \item Runs roxygen on the package
#'   \item Builds the package
#'   \item Tries to load the package.  If it doesn't work, the DESCRIPTION file
#'   version name is set back to what is was.
#'}
#' 
#' @export
assemble_package = function(
  package_name, 
  my_version,
  my_dir
  ){
  
  library(magrittr)
  library(devtools)
  library(roxygen2)
  
  # need to update version on description file  
  description_file_path = file.path(my_dir, "DESCRIPTION")
  description_lines = readLines(description_file_path)# open connection
  version_line = NULL
  for(line_index in 1:length(description_lines)){
    this_line = description_lines[line_index]
    if(grepl("^Version:", this_line)){
      version_line = line_index
      old_version_string = this_line
      break
    } else {
      old_version_string = NULL
    }
  }
  if(version_line %>% is.null){
    warning("Could not update DESCRIPTION file version.\n")
  } else {
    description_lines[version_line] = paste0("Version: ", my_version)
    writeLines(description_lines, con = description_file_path, sep = "\n", useBytes = TRUE)
  }
  # remove old zipped package so it isn't built into the the new one
  old_packages = list.files(my_dir, pattern = ".tar.gz$", full.names = T)
  if(length(old_packages) > 0){
    message("Removing older compressed packages:")
    for(old_package in old_packages) message(paste0("* ", old_package))
    file.remove(old_package)
  }
  # if this has na error we have to change the name bakc so we don't think it's been updated
  roxygenize(my_dir)
  cat("Expect the following inert warning:\n'/usr/lib/R/bin/R'/Library/Frameworks/R.framework/Resources/bin/R' --no-site-file --no-environ --no-save --no-restore --quiet CMD build  \
          '<some path>' --no-resave-data --no-manual \n")
  build_location = build(my_dir, path = my_dir)

  detach_package(package_name)
  remove_package_from_all_libraries(package_name)
  successful_install = tryCatch({
    utils::install.packages(build_location, repos = NULL, type="source")
    TRUE
  }, warning = function(w) {
    FALSE
  }, error = function(e) {
    FALSE
  })
  
  if(successful_install){
    cat(paste0(package_name, " version ", my_version, " was loaded successfully. Must restart RStudio Session for updates in documentation to go into effect.")) # see https://github.com/hadley/devtools/issues/419
  } else {
    if(BGVLABPIPE_VERSION == my_version){
      warning(paste0("Could not install update of package, ", package_name, " v", my_version ,". Older version of ", old_version_string," is still installed."))
    } else {
      warning(paste0("Could not install package ", package_name, " v", my_version ,". Older package, ", old_version_string,", is still installed."))
    }
    # need to replace the old Version in the description file since we failed to modify it.
    if(version_line %>% is_not_null){
      description_lines[version_line] = old_version_string
      writeLines(description_lines, con = description_file_path, sep = "\n", useBytes = TRUE)
    }
  }
}