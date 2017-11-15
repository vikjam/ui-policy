version 13
clear all
set more off

program main
	forval y = 2006/2010 {
		process_csv ../data/csv/January`y'.csv, year(`y')
		isid state_abbrev
		save ../data/dta/January`y', replace 
	}
	
	forval y = 2006/2009 {
		append using ../data/dta/January`y'
	}
	
	isid state_abbrev year 
	save ../data/dta/January2006_2010, replace 
end 

program process_csv 
	syntax anything(name = csv_file), year(str)
	insheet using `csv_file', comma clear names
	
	cap special_processing_`year'
	replace max_wba = subinstr(max_wba, "$", "", 1)
	replace benefit_weeks = "26" if benefit_weeks == "Up to 26"
	replace benefit_weeks = "26" if benefit_weeks == "16 or 26"
	
	split max_wba, p("-") gen(max_wba)
	split benefit_weeks, p("-") gen(benefit_weeks)
	drop max_wba benefit_weeks
	
	destring max_wba* benefit_weeks*, replace
	gen max_wba_max   = max(max_wba1, max_wba2)
	gen ben_weeks_max = max(benefit_weeks1, benefit_weeks2) 

    gen year = year(date(month_year, "MY"))
	keep state_abbrev year max_wba_max ben_weeks_max
end 

program special_processing_2006
	replace max_wba = "496" if state_abbrev == "WA"
end

program special_processing_2007
	replace max_wba = "521" if state_abbrev == "MN"
end 

program special_processing_2008
	replace max_wba = "538" if state_abbrev == "MN"
end

main
