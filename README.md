# Tipping-Pitches

## Project Overview
* Using the KNN model to classify pitch type for each MLB pitcher based on release point.
* [Downloaded Statcast data](https://github.com/alex-susi/Tipping-Pitches/blob/master/Statcast%20Scraper.R) from the 2021 MLB Regular Season (as of September 13, 2021).
* Created Classification model to predict pitch type based on where a given pitcher released each pitch.
* Tested to see how accurate each pitcher's pitch type could be predicted using the KNN model.


## Code and Resources used
**R Version:** 4.02  
**RStudio Version:** 1.3.959  
**Packages:** dplyr, baseballr, tidyverse, DBI, ggplot2, reshape2, caret, class 

**Statcast Data Scraper:** https://github.com/BillPetti/baseballr/blob/master/R/scrape_statcast.R   



## Methodology
* I wanted to approach this problem from the perspective of a batter - pitchers will sometimes [tip their pitches](https://inningace.com/faqs/baseball/what-is-pitch-tipping/) with visual clues such as variations in their windups and holding their glove differently. A pitcher who is tipping his pitches inadvertently reveals clues as to what kind of pitch he is about to throw. If a hitter is able to pick up on these clues, it puts him at a considerable advantage over the pitcher. Unforunately, most of these visual clues are not tracked by Statcast (yet). However, there is one metric that can be investigated to see if a pitcher tips his pitches: release point. 
