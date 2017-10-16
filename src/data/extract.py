from tabula import read_pdf
import re

def parse_page(df):
	taxes_cells = df[df[df.columns[-1]].notnull()][df.columns[-1]]
	state_cells = df[df[df.columns[0]].notnull()][df.columns[0]]

	taxes     = list()
	states    = list()
	ui_policy = dict()

	for cell in taxes_cells:
		percs = re.findall(r'\d+.\d+%|InAvg%', cell)
		taxes.extend(percs)

	for cell in state_cells:
		states.append(cell)

	for i, state in enumerate(states):
		begin_cell = 3 * i
		end_cell   = begin_cell + 3
		ui_policy[state] = taxes[begin_cell:end_cell]

	return(ui_policy)

ui_data = dict()
for page in range(1, 5):
	df = read_pdf('../../data/interim/July2011.pdf', pages = str(page))
	ui_data.update(parse_page(df))

print(ui_data)
