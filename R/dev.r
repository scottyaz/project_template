init_packrat <- function(dir_project, force = FALSE) {

	library(packrat)

	setwd(dir = dir_project)

	if(file.exists("packrat") & !force){

		packrat::on()

	} else {
		install_github_pkg()
		packrat::init(options = list(vcs.ignore.src = TRUE))

	}
}


render_html <- function(input_names = NULL, dir_Rmd, dir_website, dir_html, rm_cache = FALSE, code_folding = "none") {

	if(is.null(input_names)){

		# usually this needs to be compiled in a given order (eg cleaning before analysis)
		input_names <- c("data_cleaning", "index", "data_visualisation")
		
	}

	input_no_toc <- c("index", "data_visualisation")

	input_number_sections <- c("data_cleaning")

	input_static <- c("data_cleaning")

	input_no_google_analytics <- c("data_cleaning")

	has_google_analytics <- file.exits(file.path(dir_Rmd, "google_analytics.html"))

	for(input_name in input_names){

		input <- file.path(dir_Rmd, sprintf("%s.Rmd", input_name))
		has_toc <- !input_name%in%input_no_toc
		number_sections <- input_name %in% input_number_sections
		is_static <- input_name %in% input_static
		add_google_analytics <- (has_google_analytics & !(input_name %in% input_no_google_analytics))

		if(is_static){
			dir_output <- dir_html
			site_file <- "Rmd/_site.yml"
			if(file.exists(site_file)){
				file.rename(site_file, "Rmd/site.yml")				
			}

		} else {
			dir_output <- dir_website
			site_file <- "Rmd/site.yml"
			if(file.exists(site_file)){
				file.rename(site_file, "Rmd/_site.yml")				
			}
		}

		if(rm_cache) {
			unlink(sprintf("Rmd/%s_cache", input_name), recursive = TRUE)
		}

		render(input = input, output_dir = dir_output, output_format = 
			html_document(
				self_contained = is_static, 
				lib_dir = ifelse(is_static, NULL, file.path(dir_output, "libs")), 
				toc = has_toc, 
				toc_float = has_toc, 
				code_folding = code_folding, 
				number_sections = number_sections, 
				theme = "yeti", 
				highlight = "tango",
				includes = switch(add_google_analytics+1, NULL, includes(in_header = file.path(dir_Rmd, "google_analytics.html")))
				))

		if(is_static){
			site_file <- "Rmd/site.yml"
			if(file.exists(site_file)){
				file.rename(site_file, "Rmd/_site.yml")				
			}
		} 
	}	

}

setup_gitignore <- function(dir_project, force = FALSE) {

	# remove usual directories from version-control
	x <- "
	*.history\n
	*.sublime-project\n
	*.sublime-workspace\n
	data/\n
	doc/\n
	website/\n
	html/\n
	Rmd/*_cache\n
	rds/\n
	.env
	"

	gitignore <- file.path(dir_project, ".gitignore")

	if(!file.exists(gitignore) | force){
		write(x, gitignore)		
	} else {
		warning(".gitignore already exists")
	}

}

setup_google_analytics <- function(dir_Rmd, tracking_id, force = FALSE) {

	x <- sprintf("
		<script>
		(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
			(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
			m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
		})(window,document,'script','https://www.google-analytics.com/analytics.js','ga');

	ga('create', '%s', 'auto');
	ga('send', 'pageview');

	</script>", tracking_id)

	ga_file <- file.path(dir_Rmd, "google_analytics.html")

	if(!file.exists(ga_file) | force){
		write(x, ga_file)		
	} else {
		warning("google_analytics.html already exists")
	}

}

install_github_pkg <- function() {

	all_pkg <- c("bhaskarvk/leaflet.extras")

	for(pkg in all_pkg){
		install_github(pkg)
	}

}

main <- function() {

	dir_project <- path.expand("~/work/projects/template")
	dir_data <- file.path(dir_project, "data")
	dir_Rmd <- file.path(dir_project, "Rmd")
	dir_website <- file.path(dir_project, "website")
	dir_html <- file.path(dir_project, "html")
	dir_rds <- file.path(dir_project, "rds")
	dir_website_pdf <- file.path(dir_website, "pdf")

	for(dir in c(dir_data, dir_Rmd, dir_website, dir_html, dir_rds, dir_website_pdf)){
		if(!file.exists(dir)){
			dir.create(dir)
		}
	}

	# run only once, then warn (unless force = TRUE)
	setup_gitignore(dir_project, force = FALSE)
	
	# get a google analytics tracking number and everything should setup automatically
	tracking_id <- NULL
	if(!is.null(tracking_id)){
		setup_google_analytics(dir_Rmd = dir_Rmd, tracking_id = tracking_id, force = FALSE)		
	}

	# initialize packrat or switch in packrat mode if already done
	init_packrat(dir_project = dir_project)

	#load
	source("R/library.R", chdir = TRUE)

	render_html(input_names = NULL, dir_Rmd = dir_Rmd, dir_website = dir_website, dir_html = dir_html)

	# don't forget to switch off packrat mode at the end
	# packrat::off(project = dir_project)
}

main()
