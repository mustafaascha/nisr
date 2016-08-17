# nisr
Easily read National Inpatient Sample data into R

This package makes it easier to read National Inpatient Sample (NIS) data into R. Reading NIS data itself isn't difficult, but setting up the command to do so can be annoying. Essentially, this package is a wrapper for `read_fwf` from the `readr` package, but with all of the options set up for you using the formatting files provided by the Agency for Healthcare Research and Quality. 

Of course, you will have to provide the data. Assuming you have the NIS ASCII file of interest, you can read it using `read_nis`. You'll have to specify the file path, the particular type of NIS file that you'd like to read ("core", "hospital", "severity", "diagnosis"), and the year. 

For example, if I wanted to read the data from the Core NIS file from 2012, I would run the following command:

> `NIS_core_data <- read_nis("CORE_NIS_2012", format = "core", year = 2012)`

Feel free to contribute or ask questions. 
