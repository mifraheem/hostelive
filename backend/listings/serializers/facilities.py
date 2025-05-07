from rest_framework import serializers
from ..models import ListingType, RoomFacility, SharedFacility

class ListingTypeSerializer(serializers.ModelSerializer):
    class Meta:
        model = ListingType
        fields = ['id', 'name']

class RoomFacilitySerializer(serializers.ModelSerializer):
    class Meta:
        model = RoomFacility
        fields = ['id', 'name']

class SharedFacilitySerializer(serializers.ModelSerializer):
    class Meta:
        model = SharedFacility
        fields = ['id', 'name']
