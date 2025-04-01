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
use_nextflow_wd = function(script_path, script_name, set_file_pane=F){
  script_name = sub(":rscript$", "", script_name)
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