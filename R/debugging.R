# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# function_var_to_env
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' @title Puts all of the function variables in a specified environment
#' 
#' @param called_fun_txt quoted text of function to dig into
#' @param to_env environment into which the function variables will be put
#' 
#' @return No return value.
#' 
#' @section Side effects:
#' \itemize{
#'   \item declare the called function arguments into the specified environment.  
#'   \item declares the default values of the uncalled arguments
#'}
#'
#' @section Limitations:
#' \itemize{
#'   \item With the quoted function text one needs to be careful with single or double quote usage
#' }
#' 
#' @section See also:
#' \itemize{
#'   \item \code{\link{function_to_function}}
#' }
#' 
#' @export
function_var_to_env = function(
  called_fun_txt, 
  to_env = globalenv()
){
  # puts all of the function calls in to_env
  # get the called funciton arguemnts
  list_start = stringr::str_locate(called_fun_txt, "\\(")[1]
  called_arg_list = eval(parse(text = paste0("list", substring(called_fun_txt, list_start, nchar(called_fun_txt)))))
  
  # get the default arguments
  fun_name = substring(called_fun_txt, 1, (list_start-1))
  arg_txt = utils::capture.output(eval(parse(text = paste0("args(",fun_name, ")"))))
  arg_txt = arg_txt[arg_txt != "NULL"]
  arg_list = eval(parse(text = gsub("^function \\(", "list(", arg_txt)))
  
  # assign called values over default
  arg_list[names(called_arg_list)] = called_arg_list
  
  for ( list_index in 1:length(arg_list)){
    var_name = names(arg_list)[list_index]
    var_value = arg_list[[list_index]]
    assign(var_name, var_value, envir = to_env)
  }
  return(invisible(NULL))  # no return
  
}


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# function_to_function
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' @title Runs from start of fun1 and sets up args for fun2 when it gets to it.
#' 
#' @description
#' Runs function_1 from the beginning of \code{fun_name_1} to the start of 
#'  \code{fun_name_2} and then runs \code{\link{function_var_to_env}} on that second 
#'  function
#' 
#' @param fun_name_1 Name of the outmost function as a string.
#' @param fun_name_2 Name of the inner function as a string.
#' @param to_env Environment in which the arguments should be called.
#' 
#' @return No return value.  
#' 
#' @section Side effects:
#' \itemize{
#'   \item runs the first line of function_1 up to the first useage of function_2 in to_env
#'   \item runs \code{\link{function_var_to_env}} on function 2 in to_env
#'}
#'
#' @section Limitations:
#' \itemize{
#'   \item Can't use the name to fun_name_2 in comments or anything prior to it's usage
#'   \item Can only go into the first usage of fun_name_2
#'   \item Won't work if fun_name_2 is inside of any other data structure, even if/then statements.
#' }
#' 
#' @section See also:
#' \itemize{
#'   \item \code{\link{function_var_to_env}}
#' }
#' 
#' @export
function_to_function = function(
  fun_name_1, 
  fun_name_2, 
  to_env = globalenv()
){

  fun_text = utils::capture.output(eval(parse(text = fun_name_1)))
  
  fun_text = trimws(fun_text)
  fun_text = sapply(fun_text, function(each_line){
    comment_loci = stringr::str_locate(each_line, "\\#")[1]
    if(!is.na(comment_loci)){
      each_line = substring(each_line, 1, (comment_loci - 1))
    } 
    return(each_line)
  }, USE.NAMES = FALSE)
  fun_text = fun_text[nchar(fun_text) > 0]
  # find the first {
  line_with_first_bracket = which(grepl("{",fun_text, fixed = T))[1]
  # remove the lines prior to the bracket
  if(line_with_first_bracket > 1) fun_text = fun_text[(line_with_first_bracket -1):length(fun_text)]
  
  # remove everything up to the first bracket
  bracket_loci = stringr::str_locate(fun_text[1], "\\{")[[1]][1]
  fun_text[1] = substring(fun_text[1], bracket_loci+1)
  
  fun_2_first_line = which(grepl(paste0(fun_name_2, "("), fun_text, fixed = T))
  fun_2_last_line = which(fun_text[fun_2_first_line:length(fun_text)] == ")") + fun_2_first_line -1
  fun_2_text = paste0(fun_text[fun_2_first_line:fun_2_last_line], collapse = "")
  fun_2_text = gsub("}$", "", fun_2_text)
  eval(parse(text = fun_text[line_with_first_bracket:(fun_2_first_line - 1)]), envir = to_env)
  
  function_var_to_env(fun_2_text, to_env = to_env)
  
  return(invisible(NULL))  # no return
  
}



# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# report_df_values
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' @title Turns all df or dt columns into factors and reports the counts for each. 
#' 
#' @param my_df data.frame or data.table from which to report values
#' @param report_columns Vector of columns names to check. Will default to the names in my_df.
#' @param maxsum What is the max number of factors to report before goes to summary
#' 
#' @return No return value. Outputs message reporting the factors and counts of each column.
#' 
#' @export
report_df_values = function(my_df, report_columns = NULL, maxsum = 10){
  if(is.null(report_columns)){
    report_columns = names(my_df)
  }
  message("reporting value:count")

  for(this_name in report_columns){
    message()
    message(this_name)
    my_summary = summary(factor(my_df[[this_name]]), maxsum = maxsum)
    my_out = ""
    for (findex in 1:length(my_summary)){
      my_out = paste0(my_out, names(my_summary)[findex], ":", my_summary[findex], "; ")
    }
    my_out = gsub("; $", "", my_out)
    my_out = gsub("TRUE", "T", my_out)
    my_out = gsub("FALSE", "F", my_out)
    my_out = gsub("Complete Response", "CR", my_out)
    my_out = gsub("Partial Response", "PR", my_out)
    my_out = gsub("Stable Disease", "SD", my_out)
    my_out = gsub("Progressive Disease", "PD", my_out)
    message(my_out)
    message("")
  }
}




# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# report_environment_var
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' @title Puts all of the function variables in a specified environment
#' 
#' @param my_env environment into which the function variables will be put
#' @param skip_classes vector of classes to skip 
#' 
#' @return No return value. Outputs message reporting the environment variables
#' 
#' @export
report_environment_var = function(my_env, skip_classes = c("function", "data.frame", "data.table", "environment")){
  message()
  message("----------------------------")
  message("Environment variables ")
  message("----------------------------")
  message()
  all_val_names = ls(envir=my_env)
  invisible(lapply(ls(envir=my_env), function(var_name){
    my_value = eval(parse(text=var_name), envir = my_env)
    message(var_name);
    my_class = class(my_value)
    message(paste0("class: ", my_class));
    if(!(any(my_class %in% c(skip_classes)))){
      tryCatch(
        {
          for (value_index in 1:length(my_value)){
            my_name = names(my_value)[value_index]
            if (!is.null(my_name)){
              message(paste0("  ", my_name, ": ", my_value[value_index]));
            } else {
              message(as.character(my_value[value_index]))
            }
          }
        },
        error=function(cond) {
          message(paste0("Error: ", cond))
        },
        warning=function(cond) {
          message(paste0("Warning: ", cond))
        }
      )
    } else {
      message("Skipping '", my_class, "' classes.")
    }
    message()
  }))
  message("----------------------------")
  message()
}

