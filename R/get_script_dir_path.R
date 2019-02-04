# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# get_script_dir_path
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' @title Gets the path of the script that runs it
#' 
#' @description 
#' Function returns the path to the script that ran it.  Can be used to put the 
#' script outputs right next to the script.  If run inside a function it will 
#' return the script that ran that function. Helps to run at the top of a sourced
#' function: \code{sample_script_path = get_script_path()}
#' And then use that script name in the function default:
#' \code{example_function = function(script_path = sample_script_path){script_path}}
#' Designed to work if run as Rscript, sourced via RStudio or console, or run 
#' via RStudio. Found most of the inspiration for this here: 
#' https://stackoverflow.com/questions/1815606/rscript-determine-path-of-the-executing-script
#' 
#' @param debug_mode Boolen on whether detailed messages should be output to help debug the code
#' @param sourced_file Boolean on whether the files expects to be sourced or not.  If so,
#'   and it's run as an rscript or sourced via the console it returns getwd.
#' @param include_file_name Boolean on whther the file name should be reutrned if possible
#' 
#' @return Returns the path to the script that ran it
#' 
#' @section Limitations:
#' \itemize{
#'   \item Only works through the console if it's sourcing a script that contains 
#'     it (no script there) 
#'   \item Only works on the first file that runs it.  After that all of the files 
#'     sourced by that file would return the first path.  The way around this is 
#'     to source the secondary files with chdir = T.  Then set sourced_file = T 
#'     and it should work (the sourced files will use \code{getwd()} to get the 
#'     path).  For functions to know where they are.  Write out a path for that 
#'     function and call that path to source the function.  The funciotn will then 
#'     take that path as one of it's parameters.  It will then have that path by 
#'     default indefinitely.
#'}
#' 
#' @export
get_script_dir_path <- function(debug_mode = FALSE, sourced_file = TRUE, include_file_name = FALSE) {
  return_dir_path = NULL
  cmdArgs = commandArgs(trailingOnly = FALSE)
  needle = "--file="
  match = grep(needle, cmdArgs)
  if(debug_mode) message("")
  if(debug_mode) message("Begin debug info for get_script_dir_path --------")
  
  if(debug_mode) message(paste0("cmdArgs: ", cmdArgs, "\n"))
  
  if (length(match) > 0) {
    # Rscript
    if(debug_mode) message("Run as an Rscript\n")
    if (sourced_file){
      return_dir_path = getwd()
    } else {
      return_dir_path = normalizePath(sub(needle, "", cmdArgs[match]))
    }
  } else {
    ls_vars = ls(sys.frames()[[1]])
    if(debug_mode) message(paste0("ls_vars: ", ls_vars, "\n"))
    
    if ("fileName" %in% ls_vars) {
      # Source'd via RStudio
      if(debug_mode) message(paste0("Source'd via RStudio", "\n"))
      
      return_dir_path = normalizePath(sys.frames()[[1]]$fileName)
      
    } else {
      # Source'd via R console
      if(debug_mode) message(paste0("Source'd R console", "\n"))
      
      my_sys_frames = sys.frames()[[1]]
      if("ofile" %in% names(my_sys_frames)){
        if (sourced_file){
          return_dir_path = getwd()
        } else {
          return_dir_path = normalizePath(my_sys_frames$ofile)
        }
      } else {
        # Run via RStudio
        if(debug_mode) message(paste0("Run via RStudio", "\n"))
        
        return_dir_path = rstudioapi::getActiveDocumentContext()$path
      }
    }
  }
  if(!include_file_name)
    if(grepl("\\.R$", return_dir_path)) return_dir_path = dirname(return_dir_path)
  
  if(debug_mode) message("End debug info for get_script_dir_path --------")
  if(debug_mode) message("")
  
  return(return_dir_path)
}

