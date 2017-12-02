
Text prediction app
========================================================
author: Sandeep
date: 11/28/2017
width: 1440
height: 900

About the app
========================================================

This app predits next word for a given N-gram/text phrase.

- <u>Input:</u> A text box on left hand side panel accepts an N-gram/text phrase as input.  
- <u>Output:</u> The prediction algorithm determines next word for the given input and displays the same in a text box at the top of the main panel.  
- <u>Algorithm:</u> A Katz back off n-gram model, that is trained on data sampled from a text Corpus, is used to determine conditional probabilty of possible words and maximum likelihood estimation is done to arrive at the output.  
- <u>Visualization:</u>: N-gram plots are displayed on main panel to compare probabilty of top words, upto maximum of 5 words, that have the maximum likelihood estimate. When smoothing is applied, plot for back off model is also displayed.

About the data
========================================================

* <u>Source:</u> Data is derived from a corpus of news, blogs and twitter feeds.  

```
                  Line_counts Character_counts
en_US.blogs.txt        899288        208361438
en_US.news.txt          77259         15683765
en_US.twitter.txt     2360148        162384825
```
* <u>Training:</u> Approximately 10% of souce data is sampled using rbinom function with probability 0.1.

```
                  Line_counts Character_counts
en_US.blogs.txt         89234         20668794
en_US.news.txt           7706          1553704
en_US.twitter.txt      236386         16283739
```
Preprocessing the data
========================================================

* <b><u>Cleaning:</u></b> Remove numbers, punctuations and stop words from training set. Convert to lower case.
* <b><u>Tokenizing:</u></b> Use an N-gram tokenizer function to create term document matrices for trigrams, bigrams and unigrams.
* <b><u>Smoothing:</u></b> Calculate good turing discount for N-gram frequencies r as:
      + For r <= k, d<sub>r</sub> = (r+1)N<sub>r+1</sub>/rN<sub>r</sub> where N<sub>r</sub> is frequency of frequency r
      + For r>k, d<sub>r</sub> = 1 since large counts are reliable
      + Apply Katz suggestion of k=5 for the smoothing.
* <b><u>Markov matrix:</u></b> Apply smoothing to calculate maximum likehood probabilities of trigram, bigram and unigram last terms and store the results in simple triplet matrix format, which is available in the "slam" package

Predictive algorithm
========================================================

* <b><u>Cleaning:</u></b> Remove numbers, punctuations and stop words from input text. Convert to lower case.
* <b><u>Trigram model:</u></b> Query trigram markov matrix for last 2 terms of input text. If there is no leftover probability &beta; from smoothing, the last trigram term with the maximum probability is the predicted text. If &beta; not equal to 0, then backoff to bigram model.
* <b><u>Bigram model:</u></b> If &beta; from trigram model not equal to 0, distribute &beta; among probabilities from bigram markov matrix for last term of input text where last bigram term was not in last trigram term. The maximum probability from trigram and bigram models together is the predicted text. If no trigrams were found in trigram model, then predicted text is determined in similar manner as trigram model.
* <b><u>Unigram model:</u></b> If &beta; from bigram model not equal to 0, distribute &beta; similar to bigram model. If no trigrams and bigrams were found,  maximum probability from unigram markov matrix is predicted text.
