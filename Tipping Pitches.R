source("Statcast Scraper.R")
library(dplyr)
library(baseballr)
library(tidyverse)
library(DBI)
library(ggplot2)
library(reshape2)
library(caret)
library(class)


## Function to scrape Statcast data for an entire season -----------
annual_statcast_query <- function(season) {
  
  dates <- seq.Date(as.Date(paste0(season, '-03-01')),
                    as.Date(paste0(season, '-12-01')), by = 'week')
  
  date_grid <- tibble(start_date = dates, 
                      end_date = dates + 6)
  
  safe_savant <- safely(scrape_statcast_savant)
  
  payload <- map(.x = seq_along(date_grid$start_date), 
                 ~{message(paste0('\nScraping week of ', date_grid$start_date[.x], '...\n'))
                   
                   payload <- safe_savant(start_date = date_grid$start_date[.x], 
                                          end_date = date_grid$end_date[.x], type = 'pitcher')
                   
                   return(payload)
                 })
  
  payload_df <- map(payload, 'result')
  
  number_rows <- map_df(.x = seq_along(payload_df), 
                        ~{number_rows <- tibble(week = .x, 
                                                number_rows = length(payload_df[[.x]]$game_date))}) %>%
    filter(number_rows > 0) %>%
    pull(week)
  
  payload_df_reduced <- payload_df[number_rows]
  
  combined <- payload_df_reduced %>%
    bind_rows()
  
  return(combined)
  
}


## Cleaning and combining data with playerIDs ----------------------
statcast2021 <- annual_statcast_query(2021)


# Maps in Player Names to PlayerIDs
playerIDs <- read.csv("PlayerID Map.csv")
playerIDs <- playerIDs %>%
  select(PLAYERNAME, MLBID)


statcast2021_p <- merge(statcast2021, playerIDs, 
                        by.x = 'pitcher', by.y = 'MLBID')
statcast2021_p <- as.data.frame(statcast2021_p)



# EDA with Different Pitchers
cole <- statcast2021_p %>%
  filter(PLAYERNAME == "Gerrit Cole")

kershaw <- statcast2021_p %>%
  filter(PLAYERNAME == "Clayton Kershaw")

kluber <- statcast2021_p %>%
  filter(PLAYERNAME == "Corey Kluber")

lucchesi <- statcast2021_p %>%
  filter(PLAYERNAME == "Joey Lucchesi")


# RHP Graph
pitch_releases <- lucchesi %>%
  ggplot(aes(x = release_pos_x, y = release_pos_z)) +
  coord_equal() + 
  scale_x_continuous("Horizontal Release Point (ft.)", limits = c(-2.6, -1.4)) +  
  scale_y_continuous("Vertical Release Point (ft.)",  limits = c(5, 6.25)) +
  geom_point(aes(color = factor(pitch_type), size = 0.5))


# LHP Graph
pitch_releases <- lucchesi %>%
  ggplot(aes(x = release_pos_x, y = release_pos_z)) +
  coord_equal() + 
  scale_x_continuous("Horizontal Release Point (ft.)", limits = c(1.5, 3.5)) +  
  scale_y_continuous("Vertical Release Point (ft.)",  limits = c(5.25, 7)) +
  geom_point(aes(color = factor(pitch_type), size = 0.5))







## Model Building, testiing with Gerrit Cole ------------------------------------------

cishek <- cishek %>%
  select(PLAYERNAME, pitch_type, release_pos_x, release_pos_z) %>%
  filter(!is.na(pitch_type))

df <- count(cishek, pitch_type)
df <- df %>%
  mutate(freq = n / nrow(cishek))


cishek <- merge(cishek, df, by.x = 'pitch_type', by.y = 'pitch_type')


set.seed(1234)
ind <- sample(2, nrow(cishek), replace = TRUE, prob = c(0.67, 0.33))

cishek.training <- cishek[ind==1, 3:4]
head(cishek.training)

cishek.test <- cishek[ind==2, 3:4]
head(cishek.test)

cishek.trainLabels <- cishek[ind==1, 1]
head(cishek.trainLabels)

cishek.testLabels <- cishek[ind==2, 1]
head(cishek.testLabels)


cishek_pred <- knn(train = cishek.training, 
                   test = cishek.test,
                   cl = cishek.trainLabels,
                   k = 3)
cishek_pred

cishekTestLabels <- data.frame(cishek.testLabels)
merge <- data.frame(cishek_pred, cishek.testLabels)
names(merge) <- c("Predicted Pitch",
                  "Observed Pitch")
merge


cm <- confusionMatrix(cishek_pred, as.factor(cishek.testLabels))

df <- data.frame(Pitcher = character(),
                 Model_Accuracy = numeric())

df[1,] <- c('cishek' , sum(diag(cm$table)/sum(cm$table)))









## KNN Function for any Pitcher ---------------------------------------------
tipping <- function(pp) {
  
  statcast_filtered <- statcast2021_p %>%
    filter(PLAYERNAME == pp, !is.na(pitch_type), 
           !is.na(release_pos_x), !is.na(release_pos_z))
  
  
  if ((length(unique(statcast_filtered$pitch_type)) > 1) && 
      (nrow(statcast_filtered)) > 500) {
    
    
    df <- count(statcast_filtered, pitch_type)
    df <- df %>%
      mutate(freq = n / nrow(statcast_filtered))
    
    
    statcast_filtered <- merge(statcast_filtered, df, 
                               by.x = 'pitch_type', by.y = 'pitch_type')
    
    statcast_filtered <- statcast_filtered %>%
      filter(freq > 0.01)
    
    statcast_filtered <- statcast_filtered %>%
      select(PLAYERNAME, pitch_type, release_pos_x, release_pos_z)
    
    set.seed(1234)
    ind <- sample(2, nrow(statcast_filtered), replace = TRUE, prob = c(0.67, 0.33))
    
    training <- statcast_filtered[ind==1, 3:4]
    head(training)
    
    test <- statcast_filtered[ind==2, 3:4]
    head(test)
    
    trainLabels <- statcast_filtered[ind==1, 2]
    head(trainLabels)
    
    testLabels <- statcast_filtered[ind==2, 2]
    head(testLabels)
    
    
    knn_pred <- knn(train = training, 
                    test = test,
                    cl = trainLabels,
                    k = 3)
    # knn_pred
    
    TestLabels <- data.frame(testLabels)
    merge <- data.frame(knn_pred, testLabels)
    names(merge) <- c("Predicted Pitch",
                      "Observed Pitch")
    
    
    
    cm <- confusionMatrix(knn_pred, as.factor(testLabels))
    accuracy <- sum(diag(cm$table)/sum(cm$table))
    
    results <- data.frame(Pitcher = character(),
                          Model_Accuracy = numeric())
    
    results[1,] <- c(pp, sum(diag(cm$table)/sum(cm$table)))
    
    
    return(results)
    
  }
}

tipping('Johnny Cueto')






all_pitchers <- unique(statcast2021_p$PLAYERNAME)
all_pitchers1 <- all_pitchers[1:602]


pitchers_tipping <- data.frame(Pitcher = character(),
                               Model_Accuracy = numeric())



# Loop to run KNN model for all pitchers
for (x in all_pitchers1) {
  pitchers_tipping <- rbind(pitchers_tipping, tipping(x))
}




pitchers_tipping
pitchers_tipping %>%
  arrange(desc(Model_Accuracy))
pitchers_tipping$Model_Accuracy <- as.numeric(pitchers_tipping$Model_Accuracy)


## Comparing Model Accuracy to Other Pitching Metrics ---------------------
fangraphs <- read.csv("fangraphs.csv")

pitchers_tipping <- merge(pitchers_tipping, fangraphs, 
                          by.x = "Pitcher", by.y = "Name")



pitchers_tipping %>%
  ggplot(aes(x = Model_Accuracy, y = SIERA)) +
  geom_point() + geom_smooth() + 
  scale_x_continuous(breaks = c(0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1),
                     labels = c(0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1)) 






