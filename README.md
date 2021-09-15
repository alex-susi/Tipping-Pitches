# Tipping Pitches

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
* Since I am trying to solve a classification problem, I will use the KNN model for this. The accuracy of the model will be the determining factor of how much a pitcher tips his pitches (i.e. if the model is able to predict the pitch type of a given pitcher with high accuracy based solely on the release point, this is an indicator that the pitcher tips his pitches).  


## Model Building
* To make sure I was looking at sufficiently large data sets, I filtered only for pitchers with at least 500 pitches thrown in the 2021 season.  
* Additionally, for each pitcher, I filtered out any pitch that accounted for less than 1% of their total pitches thrown. This was to avoid cases where a pitcher may have thrown a certain pitch only a couple times over the course of the season, and is not part of the pitcher's typical pitching arsenal.
* Additionally, there were some bad data points with N/A listed as either the [pitch_type], [release_pos_x], and/or [release_pos_z], so I made sure to drop these from the analysis
* The final KNN model is as follows:  
*pitch_type ~ release_pos_x + release_pos_z*  


## Results
* For each pitcher, I generated a confusion matrix, and calculated the accuracy of the model by looking at the diagonal of the confusion matrix. 
* Below are the top 10 pitchers with the highest score on the predictive model (i.e. these pitchers tip their pitches the most):   

| Rank | Pitcher            | Model Accuracy  | 
| ---- |:------------------:| ---------------:|
| 1    | Ian Kennedy        | 0.9142857       | 
| 2    | Edwin Diaz         | 0.9124579       | 
| 3    | Joey Lucchesi      | 0.9103774       |  
| 4    | Matt Wisler        | 0.9040000       | 
| 5    | Josh Hader         | 0.8959108       |
| 6    | Richard Rodriguez  | 0.8888889       |
| 7    | Jake McGee         | 0.8854167       |
| 8    | Sean Doolittle     | 0.8664122       |
| 9    | Amir Garrett       | 0.8658009       |
| 10   | Austin Adams       | 0.8655172       |
* For example, the model correctly predicted about 91.4% of Ian Kennedy's pitch types and about 91.2% of Edwin Diaz's pitch types based on the release points of their pitches.
* The graphs below display the release points of each pitch for Ian Kennedy and Edwin Diaz, colored by pitch type.
* Notice how for these 2 pitchers, they tend to consistently release certain pitches from roughly the same area.   

<img src="https://github.com/alex-susi/Tipping-Pitches/blob/master/Ian%20Kennedy.png" height="400"> <img src="https://github.com/alex-susi/Tipping-Pitches/blob/master/Edwin%20Diaz.png" height="400">
<br/><br/><br/><br/>


* And here are the pitchers who tip their pitches the least, according to the model:   

| Rank | Pitcher            | Model Accuracy  | 
| ---- |:------------------:| ---------------:|
| 1    | Kyle Gibson        | 0.2770186       | 
| 2    | Matt Harvey        | 0.2774566       | 
| 3    | Frankie Montas     | 0.2904368       |  
| 4    | Carlos Martinez    | 0.3024390       | 
| 5    | Alex Reyes         | 0.3057851       |
| 6    | Mike Foltynewicz   | 0.3083969       |
| 7    | Brandon Woodruff   | 0.3107275       |
| 8    | Tony Watson        | 0.3120000       |
| 9    | Corey Kluber       | 0.3125000       |
| 10   | Pablo Lopez        | 0.3125000       |
* In contrast, the model correctly predicted only about 27.7% of Kyle Gibson's and Matt Harvey's pitch types based on the release points.
* The graphs below display the release points of each pitch for Kyle Gibson and Matt Harvey, colored by pitch type.  
* For Gibson and Harvey, the release points vary much more for each pitch type in their arsenals. Therefore, the model had a harder time accurately predicting the kind of pitch these 2 pitchers were throwing based solely on release point.
<img src="https://github.com/alex-susi/Tipping-Pitches/blob/master/Kyle%20Gibson.png" height="310"> <img src="https://github.com/alex-susi/Tipping-Pitches/blob/master/Matt%20Harvey.png" height="310">

