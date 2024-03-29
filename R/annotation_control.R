# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# annotation_control
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# Summary ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   These scripts enable coders to write comments in their code that are output to 
# a note file, which is output with the results/data. Subsequently hese note files 
# will be imported along with the data and added to the note files of any scripts that 
# use the data.
#
# The ultimate goal is to provide a description in laymens terms of how any data were 
# processed.  This transparency will help our lab an collaborators to understand 
# what was done, allowing us to readily correct errors and redundancies as well as 
# reproduce the findings.

# Hopefully these notes will also encourage coders to add at least rudimentary comments
# to their code. The note files will look very awkward if this is not done. Additionally,
# since the descriptions are written along side the code, changes to the code will
# be more likely be updated in the annotations. 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# get_annotation_width
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' @title Get the annotation width that should be used for annotations.
#' 
#' @return Returns the default annotation width.
#' 
#' @export
get_annotation_width = function(){
  return(100)
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# get_annotation_indention
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' @title Get the indentation string length that should be used for annotations.
#' 
#' @return Returns the default annotation indentaion string length.
#' 
#' @export
get_annotation_indention = function(){
  return("    ")
}


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ljust
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' @title Left justifies my_string.
#' 
#' @description 
#' Adds filler characters to the right of my_string to have the text fill the line up
#' total_char characters. 
#' 
#' @param my_string String to be left justified
#' @param filler String character to be used to space the text over.
#' @param total_char Integer of how many characters the text should be when done.
#' 
#' @return Left justified text.
#' 
#' @export
ljust = function(
  my_string, 
  filler = " ", 
  total_char = get_annotation_width()
){
  
  n_char = nchar(my_string)
  
  if(n_char < total_char){
    add_char = paste0(rep(filler, total_char-n_char), collapse = "")
    my_string = paste0(my_string, add_char)
  }
  
  return(my_string)
}




# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# rjust
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' @title Right justifies my_string.
#' 
#' @description 
#' Adds filler characters to the left of my_string to have the text fill the line up
#' total_char characters. 
#' 
#' @param my_string String to be left justified
#' @param filler String character to be used to space the text over.
#' @param total_char Integer of how many characters the text should be when done.
#' 
#' @return Right justified text.
#' 
#' @export
rjust = function(
  my_string, 
  filler = " ", 
  total_char = get_annotation_width()
){
  
  n_char = nchar(my_string)
  
  if(n_char < total_char){
    add_char = paste0(rep(filler, total_char-n_char), collapse = "")
    my_string = paste0(add_char, my_string)
  }
  
  return(my_string)
}




# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# cjust
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' @title Applies center justification to my_string.
#' 
#' @description 
#' Adds filler characters to the left and right of my_string to have the text fill the 
#' line up total_char characters. 
#' 
#' @param my_string String to be centereded
#' @param filler String character to be used to space the text over.
#' @param total_char Integer of how many characters the text should be when done.
#' 
#' @return Centered text.
#' 
#' @export
cjust = function(
  my_string, 
  filler = " ", 
  total_char = get_annotation_width(), 
  pad = " "){
  
  my_string = paste0(pad, my_string, pad)
  
  n_char = nchar(my_string)
  l_filler = round((total_char - n_char)/2)
  
  my_string = ljust(my_string = my_string, filler = filler, total_char = n_char + l_filler)
  
  my_string = rjust(my_string = my_string, filler = filler, total_char = total_char)
  
  return(my_string)
}


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# get_note_extension
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' @title Gets the note extention from the global environment.
#' 
#' @param None
#' 
#' @return Returns the string that should be on the end of annotation files.
#' 
#' @export
get_note_extension = function(){
  warning("Method get_note_extension has been depricated after switching to more common readme files.")
  return(".note.txt")
}


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# get_annotation_path
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' @title Get the path to the annotation file.
#' 
#' @description 
#' Takes path to a folder or a file in a folder. Finds THE '.note.' file in the folder and returns the path.
#' Assumes there is only one '.note.' file in each folder.
#' 
#' @param my_path The path to a folder or a file.
#' @param note_regex The unique portion of the name to use for the annotation file, defaults to "readme"
#' 
#' @return The path to the found annotation file.
#' 
#' @export
get_annotation_path = function(my_path, note_regex="readme") {
  # takes path to a folder or a file in a folder
  # finds THE file in the folder matching the note_regex and returns the path
  # assumes there is only one file matching note_regex in each folder
  
  if(file_test("-f", my_path)){
    # return path to the folder
    my_path = dirname(my_path)
    
  }
  
  folder_files = list.files(my_path)
  found_index = grep(tolower(note_regex), tolower(folder_files), fixed = T)
  #if no file found matching note_regex pattern, check for file matching readme pattern
  #this may be redundant due to note_regex's default value, but just in case someone passes in a value for note_regex that is not "readme" and that file can't be found ...
  if(length(found_index) < 1 && note_regex != "readme"){
    message("Filename ", note_regex, " not found. Searching now for 'readme'.")
    found_index = grep("readme", tolower(folder_files))
  }
  
  return(file.path(my_path, folder_files[found_index]))
}


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# format_imported_annotation
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' @title Tabs out an imported annotations to isolate them visually.
#' 
#' @param annotation Character vector of imported annotation.
#' @param indentation String of ' ' to insert before each line of the annotation to tab it over. 
#' 
#' @return The modified character vector.
#' 
#' @export
format_imported_annotation = function(
  my_annotation#, 
  #indentation = get_annotation_indention()
  ){
  if(my_annotation[1] %>% is.null){return("")}
  
  # clean up whitespace lines
  while(gsub(" ", "", my_annotation[1]) == "" | is.na(my_annotation[1])){ # get rid of empty first lines
    my_annotation = my_annotation[2:length(my_annotation)]
  }
  while(gsub(" ", "", my_annotation[length(my_annotation)]) == "" | is.na(my_annotation[length(my_annotation)])){ # get rid of empty last lines
    my_annotation = my_annotation[1:(length(my_annotation)-1)]
  }
  # turn other NA lines in to ""
  my_annotation[is.na(my_annotation)] = ""
  
  # now space it over 
  my_annotation = paste0("> ",  my_annotation)
  
  my_annotation = c(my_annotation, "")
  
  return(my_annotation)
}


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# import_annotation
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' @title Get annotation text at a path location.
#' 
#' @param my_path Path to either a file next to or a folder containing the annotation file.
#' @param note_regex Reguar expression of file name to look for in my_path
#' 
#' @return The character vector of the imported annotation.
#' 
#' @export
import_annotation = function(my_path, note_regex="readme"){ # file or folder
  orig_path = my_path
  # assumes there is only one readme file in each folder
  my_path  = get_annotation_path(my_path, note_regex)
    
  if (length(my_path) > 0) {
    # annotation = read_tsv(my_path, col_names = FALSE, trim_ws = FALSE)[[1]]
    if (length(my_path) > 1) {
      warning(paste("Multiple annotations were found: ", paste(my_path,collapse="\n"), "Proceeding with the first one...", sep = "\n"))
      my_path = my_path[1]
    }
    annotation = readLines(my_path, warn = FALSE)
    
    return(format_imported_annotation(annotation))
  } else {
    cat(paste0("No annotation file found to accompany ", orig_path,".\n"))
    return("")
  }
  
}


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# add_filler
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' @title Adds a filler to the text.
#' 
#' @param my_string String to have filler added to it.
#' @param filler Character that will be repeated to create the filler
#' @param total_char Integer defining how long the final string will be. 
#' 
#' @return The created string.
#' 
#' @export
add_filler = function(
  my_string, 
  filler = "-", 
  total_char = get_annotation_indention()
  ){
  
  n_char = nchar(my_string)
  
  if(n_char < total_char){
    add_char = paste0(rep(filler, total_char-n_char), collapse = "")
    my_string = paste0(my_string, add_char)
  }
  
  return(my_string)
}




# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# as.header1
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' @title Adds horizontal lines above and below the text.
#' 
#' @param title_text String to use in the header.
#' 
#' @return The created character vector.
#' 
#' @export
as.header1 = function(title_text){
  
  return_text = paste0("## ", title_text)
  
  return(return_text)
  
}


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# as.header2
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' @title Adds filler to the text.
#' 
#' @param title_text String to use for the title.
#' 
#' @return The created string.
#' 
#' @export
as.header2 = function(title_text){
  
  return_text = paste0("#### ", title_text)
  
  return(return_text)
  
}


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# wrap_sentence
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' @title Breaks up a string into a character vector with strings of a specified character length.
#' 
#' @description 
#' A word that will cause a string to exceed the specified width will be used to start the next string/line.
#' 
#' @param string 
#' @param width 
#' 
#' @return The same string but broken up into lines.
#' 
#' @export
wrap_sentence <- function(
  string, 
  width = get_annotation_width()
){
  
  words <- unlist(strsplit(string, " "))
  fullsentence <- NULL
  checklen <- ""
  for(i in 1:length(words)) {
    if(nchar(checklen)>1){
      checklen <- paste(checklen, words[i])
    } else {
      checklen <- words[i]
    }
    
    if(nchar(checklen)>=(width)) {
      fullsentence <- c(fullsentence, checklen) # add full line
      checklen <- ""
    }
  }
  if(nchar(checklen)>1) { # add last incomplete line
    fullsentence <- c(fullsentence, checklen)
  }
  return(fullsentence)
}


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# break_sentence
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' @title Inserts newlines into strings after a specified character length.
#' 
#' @description 
#' A word that will cause a string to exceed the specified width will be used to start the next line.
#' 
#' @param string 
#' @param width 
#' 
#' @return The same string but broken up into lines.
#' 
#' @export
break_sentence <- function(
  string, 
  width = get_annotation_width()
){
  
  words <- unlist(strsplit(string, " "))
  fullsentence <- NULL
  checklen <- ""
  for(i in 1:length(words)) {
    if(nchar(checklen)>1){
      checklen <- paste(checklen, words[i])
    } else {
      checklen <- words[i]
    }
    
    if(nchar(checklen)>=(width)) {
      fullsentence <- paste0(fullsentence, checklen, sep = "\n") # add full line
      checklen <- ""
    }
  }
  if(nchar(checklen)>1) { # add last incomplete line
    fullsentence <- paste0(fullsentence, checklen, sep = "\n")
  }
  fullsentence = gsub("\\n$", "", fullsentence)
  return(fullsentence)
}


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# as.bullet
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' @title Formats text as a bullet.
#' 
#' @param string The string of text that should be bulleted over.
#' @param level Integer indicating what level of bullet this should be.
#' @param width Integer indicating the number of character that should make up a line of the annotation.
#' @param indentation String of spaces to use for the indentation of bullets. 
#' @param bullet_levels 
#' 
#' @return The bulleted string.
#' 
#' @export
as.bullet = function(
  string, 
  level = 1, 
  width = get_annotation_width(), 
  indentation = "  ",
  my_bullet = "* "
  ){
  
  check_integer(level, lower = 0)
  
  if (level == 1){
    indentation = "" 
  } else {
    indentation = paste0(rep(indentation, level-1), collapse = "")
  }
  # indentation = paste0(rep(indentation, level), collapse = "") # multiply intentation times the bullet level
  bullet = paste0(c(indentation, my_bullet), collapse = "") # add the bullet
  spacer = paste0(rep(" ", nchar(bullet)), collapse = "") # created spacer the same nchar as the bullet
  n_char = nchar(bullet)
  width = width - n_char
  
  string = wrap_sentence(string, width)
  
  string[1] = paste0(bullet, string[1], collapse = "")
  
  if(length(string) > 1){
    for (my_index in 2:length(string)){
      string[my_index] = paste0(spacer, string[my_index], collapse = "")
    }
  }
  
  return(string)
}


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# as.footer
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' @title Right justifies and add a filler to the text.
#' 
#' @param my_string String to be right justified with filler.
#' 
#' @return The right justified string with filler.
#' 
#' @export
as.footer = function(my_string){
  
  return(rjust(my_string %>% rjust("-",  get_annotation_width())))
  
}
