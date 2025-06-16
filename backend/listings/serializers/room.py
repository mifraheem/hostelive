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
    thumbnail = serializers.ImageField(required=False, allow_null=True)
    thumbnail_url = serializers.SerializerMethodField()
    property_title = serializers.CharField(source='property.title', read_only=True)

    class Meta:
        model = Room
        fields = [
            'id', 'property','property_title', 'room_number', 'room_type', 'capacity',
            'rent_per_month', 'is_available',
            'facilities', 'facilities_detail',
            'thumbnail', 'thumbnail_url',
            'created_at'
        ]
        read_only_fields = ['id', 'created_at']

    def get_thumbnail_url(self, obj):
        request = self.context.get('request')
        if obj.thumbnail and hasattr(obj.thumbnail, 'url'):
            return request.build_absolute_uri(obj.thumbnail.url)
        return None
