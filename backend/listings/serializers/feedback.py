from rest_framework import serializers
from vaderSentiment.vaderSentiment import SentimentIntensityAnalyzer
from ..models import Feedback

class FeedbackSerializer(serializers.ModelSerializer):
    sentiment = serializers.CharField(read_only=True)
    sentiment_score = serializers.FloatField(read_only=True)
    user_name = serializers.CharField(source='user.get_full_name', read_only=True)

    class Meta:
        model = Feedback
        fields = ['id', 'property', 'user', 'user_name', 'rating', 'comment', 'sentiment', 'sentiment_score', 'created_at']
        read_only_fields = ['id', 'sentiment', 'sentiment_score', 'created_at', 'user']

    def create(self, validated_data):
        comment = validated_data.get('comment', '')
        analyzer = SentimentIntensityAnalyzer()
        score = analyzer.polarity_scores(comment)['compound']

        if score >= 0.2:
            sentiment = 'positive'
        elif score <= -0.2:
            sentiment = 'negative'
        else:
            sentiment = 'neutral'

        feedback = Feedback.objects.create(
            **validated_data,
            sentiment=sentiment,
            sentiment_score=score
        )
        return feedback
