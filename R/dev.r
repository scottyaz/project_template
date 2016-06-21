
compile_Rmd <- function(input, output_dir, ...) {

	render(input = input, output_dir = output_dir, output_format = html_document(self_contained = FALSE, lib_dir = file.path(output_dir, "libs"), ...))		

}

compile_website <- function(dir_Rmd, dir_website) {

	input_files <- c("index")

	for(input_file in input_files){

		input <- file.path(dir_Rmd, sprintf("%s.Rmd", input_file))
		compile_Rmd(input, dir_website)

	}	

}

main <- function() {

	library(rmarkdown)

	dir_home <- "/Users/Tonton/work/projects/template"
	dir_data <- file.path(dir_home, "data")
	dir_Rmd <- file.path(dir_home, "Rmd")
	dir_website <- file.path(dir_home, "website")
	dir_rds <- file.path(dir_home, "rds")

	for(dir in c(dir_data, dir_Rmd, dir_website, dir_rds)){
		if(!file.exists(dir)){
			dir.create(dir)
		}
	}

	compile_website(dir_Rmd, dir_website)

}

main()