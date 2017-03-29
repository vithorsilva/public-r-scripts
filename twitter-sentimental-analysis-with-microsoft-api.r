rm(list=ls(all=TRUE));

Consumer_API_Key <- 'REPLACE HERE';
Consumer_Secret <- 'REPLACE HERE';
Access_Token <- 'REPLACE HERE';
Access_Token_Secret <- 'REPLACE HERE';
Microsoft_API_Key <- 'REPLACE HERE';

# **********************************************************************************
# Twitter Social Analysis using Microsoft API Text Analytics
# Developed by Vithor Silva - vithor@vssti.com.br
# Twitter : vithorsilva
# Blog: http://www.vssti.com.br/blog/
# Youtube: https://www.youtube.com/channel/UCj1O1SCoSyzrX1lX5HFb_8A
# **********************************************************************************

#   Copyright (C) 2017 Vithor Silva, VSSTI.com.br
#   All rights reserved. 
#
#   For more scripts and sample code, check out 
#      http://vssti.com.br.com/blog/
#
#   You may alter this code for your own *non-commercial* purposes. You may
#   republish altered code as long as you include this copyright and give due credit. 
#
#
#   THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
#   ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
#   TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
#   PARTICULAR PURPOSE. 
# **********************************************************************************
# References:
# https://bigdataenthusiast.wordpress.com/2016/11/05/sentimental-analysis-in-r/

twitter_search_string <- "#yourhashtag";
library(twitteR);
library(jsonlite);
library(httr);

# Establish Authentication with Twitter
setup_twitter_oauth(Consumer_API_Key, Consumer_Secret, Access_Token, Access_Token_Secret);

# Search string on Twitter using twitter_search_string variable
tweets = searchTwitter(twitter_search_string, lang="pt", resultType="mixed", 1000);

# ------------------------- Start transformations and cleasing -------------------------#
tweets_df = do.call("rbind", lapply(tweets, as.data.frame));
tweets_df = subset(tweets_df, select = c(text));

#Tweet Cleasing
tweets_df$text = gsub('http.* *', '', tweets_df$text);
tweets_df$text = gsub("(RT|via)((?:\\b\\W*@\\w+)+)", " ",  tweets_df$text);
tweets_df$text = gsub(":", "", tweets_df$text);
# remove at people
tweets_df$text = gsub("@\\w+", "", tweets_df$text)
# remove punctuation
tweets_df$text = gsub("[[:punct:]]", "", tweets_df$text)
# remove numbers
tweets_df$text = gsub("[[:digit:]]", "", tweets_df$text)
# remove html links
tweets_df$text = gsub("http\\w+", "", tweets_df$text)
# remove unnecessary spaces
tweets_df$text = gsub("[ \t]{2,}", "", tweets_df$text)
tweets_df$text = gsub("^\\s+|\\s+$", "", tweets_df$text)
# Removing Duplicate tweets
tweets_df["DuplicateFlag"] = duplicated(tweets_df$text);
tweets_df = subset(tweets_df, tweets_df$DuplicateFlag=="FALSE");
tweets_df = subset(tweets_df, select = -c(DuplicateFlag));
# ------------------------- Finish transformations and cleasing -------------------------#

# Creating the request body for Text Analytics API
tweets_df["language"] = "pt";
tweets_df["id"] = seq.int(nrow(tweets_df));
request_body_twitter = tweets_df[c(2,3,1)];
 
# Converting tweets dataframe into JSON
request_body_json_twitter = toJSON(list(documents = request_body_twitter));

# Calling text analytics API
result_twitter_sentimental = POST("https://westus.api.cognitive.microsoft.com/text/analytics/v2.0/sentiment", 
                                  body = request_body_json_twitter, 
                                  add_headers(.headers = c("Content-Type"="application/json","Ocp-Apim-Subscription-Key"= Microsoft_API_Key)))

# Pegar a palavra chave ainda n?o est? dispon?vel em portugues
#result_twitter_keyPhrases = POST("https://westus.api.cognitive.microsoft.com/text/analytics/v2.0/keyPhrases", 
#                                 body = request_body_json_twitter, 
#                                 add_headers(.headers = c("Content-Type"="application/json","Ocp-Apim-Subscription-Key"= Microsoft_API_Key)))

# Transforming resulting in Data Frame (Sentimental)
Output_Sentimental = content(result_twitter_sentimental);
attach(Output_Sentimental);
rows <- length(documents);
score_twitter = data.frame(matrix(unlist(Output_Sentimental), nrow=rows, byrow=T));

score_twitter$X1 =  as.numeric(as.character(score_twitter$X1));
names(score_twitter)[names(score_twitter) == 'X1'] <- 'Score';
names(score_twitter)[names(score_twitter) == 'X2'] <- 'Id';
tweets_df$Score <- c(score_twitter$Score);
detach(Output_Sentimental);
rm(score_twitter);

## WORKING ON IT
# Transforming resulting in Data Frame (Key Phrases) - NOT WORKING TO PORTUGUESE
#Output_keyPhrases = content(result_twitter_keyPhrases);
#attach(Output_keyPhrases);
#rows <- length(documents);
#phrases_twitter = data.frame(matrix(unlist(Output_keyPhrases), nrow=rows, byrow=T));
 
