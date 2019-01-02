# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# get_script_path
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
#' 
#' Designed to work if run as Rscript, sourced via RStudio or console, or run 
#' via RStudio. Found most of the inspiration for this here: 
#' https://stackoverflow.com/questions/1815606/rscript-determine-path-of-the-executing-script
#' 
#' @return Returns the path to the script that ran it
#' 
#' @section Limitations:
#' \itemize{
#'   \item Doesn't work through the console (no script there) 
#'   \item Works through a sourced file, but if sourced from a source script it 
#'   just returns the first source path.
#'}
#' 
#' @export
get_script_path <- function() {
  debug_mode = FALSE
  
  cmdArgs = commandArgs(trailingOnly = FALSE)
  needle = "--file="
  match = grep(needle, cmdArgs)
  if(debug_mode) cat(paste0("cmdArgs: ", cmdArgs, "\n"))
  
  if (length(match) > 0) {
    # Rscript
    if(debug_mode) cat("Rscript\n")
    return(normalizePath(sub(needle, "", cmdArgs[match])))
  } else {
    ls_vars = ls(sys.frames()[[1]])
    if(debug_mode) cat(paste0("ls_vars: ", ls_vars, "\n"))
    
    if ("fileName" %in% ls_vars) {
      # Source'd via RStudio
      if(debug_mode) cat(paste0("Source'd via RStudio", "\n"))
      
      return(normalizePath(sys.frames()[[1]]$fileName)) 
    } else {
      # Source'd via R console
      if(debug_mode) cat(paste0("Source'd R console", "\n"))
      
      my_sys_frames = sys.frames()[[1]]
      if("ofile" %in% names(my_sys_frames)){
        return(normalizePath(my_sys_frames$ofile))
      } else {
        # Run via RStudio
        if(debug_mode) cat(paste0("Run via RStudio", "\n"))
        return(rstudioapi::getActiveDocumentContext()$path)
      }
    }
  }
}
