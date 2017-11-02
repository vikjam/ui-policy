import datetime
import urllib.request
import math

months = ['January', 'July']

def urlrange(year):
	minyr = math.floor(year / 10) * 10
	maxyr = minyr + 9
	return(f"{minyr}-{maxyr}")

for year in range(1970, 2018):
	for month in months:
		filename = f"{month}{year}.pdf"
		url      = f"https://workforcesecurity.doleta.gov/unemploy/content/sigpros/{urlrange(year)}/{filename}"
		export   = f"../../data/interim/{filename}"
		urllib.request.urlretrieve(url, export)

