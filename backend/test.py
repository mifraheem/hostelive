from vaderSentiment.vaderSentiment import SentimentIntensityAnalyzer

analyzer = SentimentIntensityAnalyzer()

def analyze_sentiment(text):
    scores = analyzer.polarity_scores(text)
    score = scores['compound']

    if score >= 0.2:
        return 'positive', score
    elif score <= -0.2:
        return 'negative', score
    else:
        return 'neutral', score
