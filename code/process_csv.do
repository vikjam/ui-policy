version 13
clear all
set more off

program main
    local begin_year = 2006
    local end_year   = 2017

    forval y = `begin_year'/`end_year' {
        foreach m in january july {
            if `y' == 2017 & "`m'" == "july" continue 
            process_csv, month(`m') year(`y')
            isid state_abbrev
            save ../data/dta/`m'`y', replace 
        }
    }
    forval y = `begin_year'/`=`end_year' - 1' {
        append using ../data/dta/january`y'
        append using ../data/dta/july`y'
    }
    
    isid state_abbrev year month
    save ../data/dta/state_ui_laws_`begin_year'_`end_year', replace 
end 

program process_csv 
    syntax, month(str) year(str) [ industry_average_code(str) ]
    local csv_file "../data/csv/`=proper("`month'")'`year'.csv"
    insheet using `csv_file', comma clear names

    if "`industry_average_code'" == "" local industry_average_code "-9999"
    
    cap special_processing_`month'`year', industry_average_code(`industry_average_code')

    replace benefit_weeks = "26" if benefit_weeks == "Up to 26"
    replace benefit_weeks = "26" if benefit_weeks == "16 or 26"

    foreach v of varlist max_wba taxable_wage_base {
        replace `v' = subinstr(`v', "$", "", .)
        replace `v' = subinstr(`v', ",", "", .)
        replace `v' = subinstr(`v', " or ", "-", .)
    }
    foreach tax_var of varlist *_tax_rate {
        replace `tax_var' = subinstr(`tax_var', "%", "", 1)
        replace `tax_var' = subinstr(`tax_var', "InAvg", "`industry_average_code'", 1)
        replace `tax_var' = subinstr(`tax_var', "(", "", 1)
        replace `tax_var' = subinstr(`tax_var', ")", "", 1)
        replace `tax_var' = subinstr(`tax_var', ",", "", 1)
    } 
    
    split max_wba, p("-") gen(max_wba)
    split benefit_weeks, p("-") gen(benefit_weeks)
    drop max_wba benefit_weeks
    
    destring max_wba* benefit_weeks* taxable_wage_base *_tax_rate, replace
    gen max_wba_max   = max(max_wba1, max_wba2)
    gen ben_weeks_max = max(benefit_weeks1, benefit_weeks2) 

    gen year  = year(date(month_year, "MY"))
    gen month = month(date(month_year, "MY"))
    keep state_abbrev year month max_wba_max ben_weeks_max  ///
        taxable_wage_base *_tax_rate
end 

program special_processing_january2006
    syntax, industry_average_code(str)
    replace max_wba          = "496" if state_abbrev == "WA"
    replace min_tax_rate     = "" if state_abbrev == "MN"
    replace max_tax_rate     = "" if state_abbrev == "MN"
    replace new_emp_tax_rate = "" if state_abbrev == "MN"
    replace new_emp_tax_rate = "" if state_abbrev == "PR"
    replace new_emp_tax_rate = "3.25" if state_abbrev == "WI"
    replace new_emp_tax_rate = "`industry_average_code'" if state_abbrev == "WA"
end

program special_processing_july2006
    syntax, industry_average_code(str)
    replace max_wba          = "496" if state_abbrev == "WA"
    replace max_wba          = "457" if state_abbrev == "NC"
    replace max_wba          = "521" if state_abbrev == "MN"
    replace min_tax_rate     = "" if state_abbrev == "MN"
    replace max_tax_rate     = "" if state_abbrev == "MN"
    replace new_emp_tax_rate = "" if state_abbrev == "MN"
    replace new_emp_tax_rate = "" if state_abbrev == "PR"
    replace new_emp_tax_rate = "3.25" if state_abbrev == "WI"
    replace new_emp_tax_rate = "`industry_average_code'" if state_abbrev == "WA"
end

program special_processing_january2007
    syntax, industry_average_code(str)
    replace max_wba          = "521" if state_abbrev == "MN"
    * 3.25 or 3.40
    replace new_emp_tax_rate = "3.25" if state_abbrev == "WI"
    replace new_emp_tax_rate = "`industry_average_code'" if state_abbrev == "WA"
end 

program special_processing_july2007
    syntax, industry_average_code(str)
    replace max_wba          = "340" if state_abbrev == "MD"
    replace max_wba          = "538" if state_abbrev == "MN"
    * 4.00 or 6.00
    replace new_emp_tax_rate = "4" if state_abbrev == "KS"
    * 3.25 or 3.40
    replace new_emp_tax_rate = "3.25" if state_abbrev == "WI"
    replace new_emp_tax_rate = "`industry_average_code'" if state_abbrev == "WA"
end 

program special_processing_january2008
    syntax, industry_average_code(str)
    replace max_wba          = "538" if state_abbrev == "MN"
    * 4.00 or 6.00
    replace new_emp_tax_rate = "4" if state_abbrev == "KS"
    * 3.25 or 3.40
    replace new_emp_tax_rate = "3.25" if state_abbrev == "WI"
    replace new_emp_tax_rate = "`industry_average_code'" if state_abbrev == "WA"
end

program special_processing_july2008
    syntax, industry_average_code(str)
    replace max_wba          = "538" if state_abbrev == "MN"
    * 4.00 or 6.00
    replace new_emp_tax_rate = "4" if state_abbrev == "KS"
    * 3.25 or 3.40
    replace new_emp_tax_rate = "3.25" if state_abbrev == "WI"
    replace new_emp_tax_rate = "`industry_average_code'" if state_abbrev == "WA"
end

program special_processing_july2009
    syntax, industry_average_code(str)
    replace max_wba = "380" if state_abbrev == "MD"
end 

program special_processing_july2010
    syntax, industry_average_code(str)
    replace max_wba = "410" if state_abbrev == "MD"
end 

program special_processing_july2011
    syntax, industry_average_code(str)
    replace max_wba = "522" if state_abbrev == "NC"
end 

program special_processing_january2012
    syntax, industry_average_code(str)
    replace max_wba           = "573" if state_abbrev == "CT"
    replace taxable_wage_base = "19,600" if state_abbrev == "RI"
end 

program special_processing_july2012
    syntax, industry_average_code(str)
    replace max_wba           = "560" if state_abbrev == "HI"
    replace max_wba           = "648" if state_abbrev == "CT"
    replace taxable_wage_base = "19,600" if state_abbrev == "RI"
end 

program special_processing_january2013
    syntax, industry_average_code(str)
    replace taxable_wage_base = "20,200" if state_abbrev == "RI"
end

program special_processing_july2013
    syntax, industry_average_code(str)
    replace taxable_wage_base = "20,200" if state_abbrev == "RI"
end

program special_processing_january2014
    syntax, industry_average_code(str)
    replace taxable_wage_base = "20,600" if state_abbrev == "RI"
end

program special_processing_july2014
    syntax, industry_average_code(str)
    replace taxable_wage_base = "20,600" if state_abbrev == "RI"
end

program special_processing_january2015
    syntax, industry_average_code(str)
    replace taxable_wage_base = "21,200" if state_abbrev == "RI"
end

program special_processing_july2015
    syntax, industry_average_code(str)
    replace max_wba           = "640" if state_abbrev == "MN"
    replace benefit_weeks     = "25" if state_abbrev == "AR"
    replace taxable_wage_base = "21,200" if state_abbrev == "RI"
end

program special_processing_january2016
    syntax, industry_average_code(str)
    replace taxable_wage_base = "22,000" if state_abbrev == "RI"
end 

program special_processing_july2016
    syntax, industry_average_code(str)
    replace taxable_wage_base = "22,000" if state_abbrev == "RI"
end 

program special_processing_january2017
    syntax, industry_average_code(str)
    replace taxable_wage_base = "22,400" if state_abbrev == "RI"
end 

main
