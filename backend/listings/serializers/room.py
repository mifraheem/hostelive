from rest_framework import serializers
from ..models import Room, RoomFacility

class RoomFacilitySerializer(serializers.ModelSerializer):
    class Meta:
        model = RoomFacility
        fields = ['id', 'name']
        ref_name = 'RoomFacilitySerializer'

class RoomSerializer(serializers.ModelSerializer):
    facilities = serializers.PrimaryKeyRelatedField(
        queryset=RoomFacility.objects.all(), many=True, required=False, write_only=True
    )
    facilities_detail = RoomFacilitySerializer(
        source='facilities', many=True, read_only=True
    )

    class Meta:
        model = Room
        fields = [
            'id', 'property', 'room_number', 'room_type', 'capacity',
            'rent_per_month', 'is_available',
            'facilities', 'facilities_detail'
        ]
