from tabula import read_pdf
import re
import json
import pandas as pd
import numpy as np

def parse_page(df):
	variables = [0, 3, 4, 7, 9, 10]
	ui_policy = df.iloc[:, variables]
	ui_policy.columns = ['state_abbrev', 'min_wba', 'max_wba',
	                     'benefit_weeks', 'taxable_wage_base', 'tax_rates']
	ui_policy = ui_policy[(ui_policy['benefit_weeks'].notnull())]
	ui_policy['min_tax_rate'] = ui_policy['tax_rates'].str.split('\r', expand = True).get(0)
	ui_policy['max_tax_rate'] = ui_policy['tax_rates'].str.split('\r', expand = True).get(1)
	ui_policy['new_tax_rate'] = ui_policy['tax_rates'].str.split('\r', expand = True).get(2)
	del ui_policy['tax_rates']
	ui_policy = ui_policy.apply(lambda x: x.str.replace(r'\r', ' '))
	return(ui_policy)

def parse_month(monthyr):
	pages_data = []
	for page in range(1, 5):
		df                 = read_pdf(f"../../data/interim/{monthyr}.pdf",
	                          pages          = str(page),
	                          spreadsheet    = True,
	                          pandas_options = {'header': 11})

		ui_data            = parse_page(df)
		ui_data['monthyr'] = monthyr
		pages_data.append(ui_data)
	return(pd.concat(pages_data))

months = ['January', 'July']

for year in range(2010, 2018):
	for month in months:
		monthyr   = f"{month}{year}"
		print(f"Working on {monthyr}...")
		try:
			monthdata = parse_month(monthyr)
			monthdata.to_csv(f"../../data/interim/{monthyr}.csv", index = False)
		except Exception as e:
			print(f"Failed on {monthyr}...{e}")


