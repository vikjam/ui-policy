import datetime
import urllib.request

months = ['January', 'July']

for year in range(2010, 2018):
	for month in months:
		filename = f"{month}{year}.pdf"
		url      = f"https://workforcesecurity.doleta.gov/unemploy/content/sigpros/2010-2019/{filename}"
		export   = f"../../data/interim/{filename}"
		urllib.request.urlretrieve(url, export)

