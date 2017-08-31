
Sys.setenv(MAPBOX_TOKEN = "pk.eyJ1IjoibnRuY21jaCIsImEiOiJjaXZyd2Zsa2kwMDJmMnptd295bDQ0bHpiIn0.CWHXelZYtFdThhAfEIi8ww") # use mapbox API

outcome_list <- c("cured", "dead", NA)

EPIWEEK_FIRST_DAY <- "Monday"

format_text <- function(x) {

	x %>% str_to_lower %>% 
	str_trim %>% 
	str_replace_all("[^[:alnum:]]+", "_") %>% 
	str_replace("[_]+\\b", "")

}

clean_text <- function(x) {

	x %>% str_replace_all("_", " ") %>% 
	str_to_title %>% 
	str_trim

}

symbol_to_latex <- function(x) {

	x %>% str_replace_all("<=", fixed("$\\\\leq$")) %>% 
	str_replace_all("<", fixed("$<$")) %>% 
	str_replace_all(">=", fixed("$\\\\geq$")) %>% 
	str_replace_all(">", fixed("$>$")) %>% 
	str_replace_all("sup_dagger", fixed("$^\\\\dagger$")) %>% 
	str_replace_all("sup_ddagger", fixed("$^\\\\ddagger$")) %>% 
	str_replace_all("sup_section", fixed("$^\\\\S$")) %>% 
	str_replace_all("sup_star", fixed("$^\\\\star$"))

}

symbol_to_html <- function(x) {

	x %>% str_replace_all("<=", "&le;") %>% 
	str_replace_all("<", "&lt;") %>% 
	str_replace_all(">=", "&ge;") %>% 
	str_replace_all(">", "&gt;") %>% 
	str_replace_all("sup_dagger", fixed("&dagger;")) %>% 
	str_replace_all("sup_ddagger", fixed("&Dagger;")) %>% 
	str_replace_all("sup_section", fixed("&sect;")) %>% 
	str_replace_all("break_line", fixed("<br>")) %>% 
	str_replace_all("sup_star", fixed("&star;"))

}


pretty_date <- function(x) {format(x, "%B-%d")}

pretty_percent <- function(x, digit=2) {round(x, digit) %>% paste0("%")}

pretty_value_sd <- function(mean, sd, prop_NA = NULL, digit=2) {sprintf("%s (%s)%s", round(mean, digit), round(sd, digit), ifelse(is.null(prop_NA), "", sprintf(" - %s", pretty_percent(100*prop_NA, digit))))}

pretty_value_conf <- function(value, IQR_low, IQR_up, prop_NA = NULL, digit=2, sep = " ") {sprintf("%s%s(%s - %s)%s", round(value, digit), sep, round(IQR_low, digit), round(IQR_up, digit), ifelse(is.null(prop_NA), "", sprintf(" - %s", pretty_percent(100*prop_NA, digit))))}

pretty_logical <- function(n_TRUE, length_na_rm, n_na = NULL, length = NULL, prop_NA = FALSE, digit = 2, show_denominator = TRUE){
	sprintf("%s%s (%s)%s",  n_TRUE, ifelse(show_denominator, sprintf("/%s", length_na_rm), ""), pretty_percent(100*n_TRUE/length_na_rm, digit), ifelse(prop_NA, pretty_percent(100*n_na/length, digit) ,""))
}

pretty_proportion <- function(numerator, denominator, digit = 2, show_num_denom = TRUE){
	sprintf("%s%s", pretty_percent(100*numerator/denominator, digit), ifelse(show_num_denom, sprintf(" (%s/%s)", numerator, denominator), ""))
}

pretty_value_percent <- function(numerator, denominator, digit = 2){
	# sprintf("%s (%s)", numerator, pretty_percent(100*numerator/denominator, digit))
	sprintf("%s (%s)", numerator, round(100*numerator/denominator, digit))
}


pretty_value_parenthesis <- function(value, parenthesis) {
	sprintf("%s (%s)", value, parenthesis)
}

pretty_interval <- function(x, y, digit = 1, sep = "-"){
	sprintf("%s %s %s", round(x, digit), sep, round(y, digit))	
}

pretty_percent_conf <- function(x, CI_lb, CI_ub, digit=1, sep = "to"){
	sprintf("%s (%s)", pretty_percent(100*x, 1), pretty_interval(100*CI_lb, 100*CI_ub, digit=digit, sep=sep))	
}

x_lab_angle <- theme(axis.text.x=element_text(angle=45, hjust=1, vjust=1))

print_year_epiweek <- function(year, epiweek) {
	sprintf("%s-W%s", year, str_sub(100+epiweek, 2L, 3L))
}

date2epiweek <- function (date, firstday = "Sunday", format = c("year", "week", "year_week")) {
	
	format <- match.arg(format)

	date <- strptime(date, format = "%Y-%m-%d")

	date_na <- is.na(date)
	
	date <- date[!date_na]

	if (class(date)[2] != "POSIXt" || any(is.na(date))) {
		stop("Wrong format for date!")
	}
	if (!(firstday == "Sunday" || firstday == "Monday")) {
		stop("Wrong firstday!")
	}
	
	year <- 1900 + date$year
	jan4 <- strptime(paste(year, 1, 4, sep = "-"), format = "%Y-%m-%d")
	wday <- jan4$wday
	wday[wday == 0] <- 7
	wdaystart <- ifelse(firstday == "Sunday", 7, 1)
	
	lag <- ifelse(firstday == "Sunday", 0, 1)
	weekstart <- jan4
	weekstart_2 <- jan4 - (wday - lag) * 86400
	i_weekstart_2 <- (wday != wdaystart)
	weekstart[i_weekstart_2] <- weekstart_2[i_weekstart_2]

	weeknum <- ceiling(as.numeric((difftime(date, weekstart, units = "days") + 0.1)/7))

	mday <- date$mday
	wday <- date$wday
	lag <- ifelse(firstday == "Sunday", 29, 28)

	i_year <- (weeknum == 53 & mday - wday >= lag)
	year[i_year] <- year[i_year] + 1
	weeknum[i_year] <- 1
	
	year.shift <- year - 1
	jan4.shift <- strptime(paste(year.shift, 1, 4, sep = "-"), format = "%Y-%m-%d")

	wday <- jan4.shift$wday
	wday[wday == 0] <- 7
	wdaystart <- ifelse(firstday == "Sunday", 7, 1)
	lag <- ifelse(firstday == "Sunday", 0, 1)

	weekstart <- jan4.shift
	weekstart_2 <- jan4.shift - (wday - lag) * 86400
	i_weekstart_2 <- (wday != wdaystart)
	weekstart[i_weekstart_2] <- weekstart_2[i_weekstart_2]
	weeknum.shift <- ceiling(as.numeric((difftime(date, weekstart) + 0.1)/7))
	
	year <- ifelse(weeknum == 0, year.shift, year)
	weeknum <- ifelse(weeknum == 0, weeknum.shift, weeknum)

	year_final <- date_na
	year_final[!date_na] <- year
	year_final[date_na] <- NA

	weeknum_final <- date_na
	weeknum_final[!date_na] <- weeknum
	weeknum_final[date_na] <- NA

	year_week_final <- date_na
	year_week_final[!date_na] <- print_year_epiweek(year, weeknum)
	year_week_final[date_na] <- NA

	ans <- switch(format,
		year = year_final,
		week = weeknum_final,
		year_week = year_week_final		
		)

	return(ans)
}


epiweek2date <- function (year, week, firstday = "Sunday", epiweek_day = c("first", "last")) {

	epiweek_day <- match.arg(epiweek_day)

	if (!(firstday == "Sunday" || firstday == "Monday")) {
		stop("Wrong firstday!")
	}
	if (any(year < 0) || any(week < 0)) {
		stop("Wrong Input!")
	}

	jan4 <- strptime(paste(year, 1, 4, sep = "-"), format = "%Y-%m-%d")
	wday <- jan4$wday
	wday[wday == 0] <- 7
	wdaystart <- ifelse(firstday == "Sunday", 7, 1)
	lag <- ifelse(firstday == "Sunday", 0, 1)


	weekstart <- jan4
	weekstart_2 <- jan4 - (wday - lag) *24*3600
	i_weekstart_2 <- (wday != wdaystart)
	weekstart[i_weekstart_2] <- weekstart_2[i_weekstart_2]
	

	jan4_2 <- strptime(paste(year + 1, 1, 4, sep = "-"), format = "%Y-%m-%d")
	wday_2 <- jan4_2$wday
	wday_2[wday_2 == 0] <- 7
	wdaystart_2 <- ifelse(firstday == "Sunday", 7, 1)
	lag <- ifelse(firstday == "Sunday", 0, 1)


	weekstart_2 <- jan4_2
	weekstart_3 <- jan4_2 - (wday_2 - lag) *24*3600
	i_weekstart_3 <- (wday_2 != wdaystart_2)
	weekstart_2[i_weekstart_3] <- weekstart_3[i_weekstart_3]
	
	if (any(x <- (week > ((weekstart_2 - weekstart)/7)))) {
		stop("There are only ", sQuote(((weekstart_2 - weekstart)/7)[x]), " weeks in ", sQuote(year[x]), "!")
	}

	if(epiweek_day == "first"){
		ans <- weekstart + (week - 1) * 7 * 24 * 3600
	} else {
		ans <- weekstart + ((week - 1) * 7 + 6) * 24 * 3600
	}

	return(as.Date(ans, tz = ""))
}



