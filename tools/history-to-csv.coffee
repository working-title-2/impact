fs = require 'fs'
csv = require 'csv'

csv()
.from.path("#{__dirname}/../data/world-population-history.csv")
.to.array((data, count) ->
  output = csv().to.path("#{__dirname}/../data/world-population-history-import.csv")
  header = true
  for country in data
    if header
      output.write ["Date", "Country", "Population"]
      header = false
      continue
    for year in [2000..2012]
      output.write [
        "1/1/#{year}"
        country[2]
        country[year-1997]
      ]
)
