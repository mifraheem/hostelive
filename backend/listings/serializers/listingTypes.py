from rest_framework import serializers
from ..models import ListingType

class ListingTypeSerializer(serializers.ModelSerializer):
    class Meta:
        model = ListingType
        fields = ['id', 'name']
