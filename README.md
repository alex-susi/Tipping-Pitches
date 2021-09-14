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
* I scraped Statcast data for the entire 2021 MLB Regular Season (as of 9/13/2021). The dataset includes all sorts of tracking data, but I was interested in examining [pitch_type], [release_pos_x], and [release_pos_z]. I wanted to figure out if it is possible to predict the pitch type based on the X and Z coordinates a pitch is thrown at. 
* Considering the goal at hand is trying to figure out specifically which pitchers tip their pitches, it made sense to look at pitches for each pitcher separately.


## Model Building
* To make sure I was looking at sufficiently large data sets, I filtered only for pitchers with at least 500 pitches thrown in the 2021 season.  
* Additionally, for each pitcher, I filtered out any pitch that accounted for less than 1% of their total pitches thrown. This was to avoid cases where a pitcher may have thrown a certain pitch only a couple times over the course of the season, and is not part of the pitcher's typical pitching arsenal.
* Additionally, there were some bad data points with N/A listed as either the [pitch_type], [release_pos_x], and/or [release_pos_z], so I made sure to drop these from the analysis
* The final KNN model is as follows:  
*pitch_type ~ release_pos_x + release_pos_z*


## Results

