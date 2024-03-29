% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/annotation_control.R
\name{import_annotation}
\alias{import_annotation}
\title{Get annotation text at a path location.}
\usage{
import_annotation(my_path, note_regex = "readme")
}
\arguments{
\item{my_path}{Path to either a file next to or a folder containing the annotation file.}

\item{note_regex}{Reguar expression of file name to look for in my_path}
}
\value{
The character vector of the imported annotation.
}
\description{
Get annotation text at a path location.
}
