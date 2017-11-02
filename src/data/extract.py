from tabula import read_pdf
import re, json
import pandas as pd
import numpy as np

def parse_ui_sig_prov_page(df):
    
    column_indexes    = [0, 3, 4, 7, 9, 10]
    ui_policy         = df.iloc[:, column_indexes]
    ui_policy.columns = ['state_abbrev', 'min_wba', 'max_wba', 'benefit_weeks',
                         'taxable_wage_base', 'tax_rates']
    ui_policy = ui_policy[(ui_policy['benefit_weeks'].notnull())]
    
    ui_policy['min_tax_rate']     = ui_policy['tax_rates'].str.split('\r', expand = True).get(0)
    ui_policy['max_tax_rate']     = ui_policy['tax_rates'].str.split('\r', expand = True).get(1)
    ui_policy['new_emp_tax_rate'] = ui_policy['tax_rates'].str.split('\r', expand = True).get(2)
    del ui_policy['tax_rates']
    
    ui_policy = ui_policy.apply(lambda x: x.str.replace(r'\r', ' '))
    
    return(ui_policy)

def parse_ui_sig_prov_pdf(month_year):
    
    ui_policy_pages = []
    for page in range(1, 5):
        df_page = read_pdf(f"../../data/interim/{month_year}.pdf",
                           pages          = str(page),
                           spreadsheet    = True,
                           pandas_options = {'header': 11})

        ui_policy_page = parse_ui_sig_prov_page(df_page)
        ui_policy_page['month_year'] = month_year
        ui_policy_pages.append(ui_policy_page)
    
    ui_policy_pdf = pd.concat(ui_policy_pages)
    return(ui_policy_pdf)

def parse_ui_sig_provs(months, years):

    for year in years:
        for month in months:
            month_year = f"{month}{year}"
            print(f"Parsing {month_year}...")
            try:
                month_year_data = parse_ui_sig_prov_pdf(month_year)
                month_year_data.to_csv(f"../../data/interim/{month_year}.csv", index = False)
            except Exception as e:
                print(f"Failed on {month_year}")
                print(f"{e}")

months = ['January', 'July']
years  = list(range(2010, 2018))

parse_ui_sig_provs(months = months, years = years)


