init_packrat <- function(dir_project, force = FALSE) {

	library(packrat)

	setwd(dir = dir_project)

	if(file.exists("packrat") & !force){

		packrat::on()

	} else {

		packrat::init(options = list(vcs.ignore.src = TRUE))

	}
}


compile_Rmd <- function(input, output_dir, ...) {

	library(rmarkdown)

	render(input = input, output_dir = output_dir, output_format = html_document(self_contained = FALSE, lib_dir = file.path(output_dir, "libs"), ...))		

}


compile_website <- function(input_names = NULL, dir_Rmd, dir_website) {

	if(is.null(input_names)){

		# usually this needs to be compiled in a given order (eg cleaning before analysis)
		input_names <- c("index", "data_cleaning", "data_visualisation")
		
	}

	input_no_toc <- c("index")

	for(input_name in input_names){

		input <- file.path(dir_Rmd, sprintf("%s.Rmd", input_name))
		has_toc <- !input_name%in%input_no_toc

		compile_Rmd(input = input, output_dir = dir_website, toc = has_toc, toc_float = has_toc, code_folding = "hide", number_sections = TRUE, theme = "simplex", highlight = "tango")

	}	

}

main <- function() {

	dir_project <- path.expand("~/work/projects/template")
	dir_data <- file.path(dir_project, "data")
	dir_Rmd <- file.path(dir_project, "Rmd")
	dir_website <- file.path(dir_project, "website")
	dir_rds <- file.path(dir_project, "rds")

	for(dir in c(dir_data, dir_Rmd, dir_website, dir_rds)){
		if(!file.exists(dir)){
			dir.create(dir)
		}
	}

	# initialize packrat or switch in packrat mode if already done
	init_packrat(dir_project = dir_project)

	compile_website(input_names = NULL, dir_Rmd = dir_Rmd, dir_website = dir_website)

	# don't forget to switch off packrat mode at the end
	# packrat::off(project = dir_project)
}

main()
