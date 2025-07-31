from rest_framework import serializers
from ..models import Room, RoomFacility, RoomImage

class RoomFacilitySerializer(serializers.ModelSerializer):
    class Meta:
        model = RoomFacility
        fields = ['id', 'name']
        ref_name = 'RoomFacilitySerializer'


class RoomImageSerializer(serializers.ModelSerializer):
    class Meta:
        model = RoomImage
        fields = ['id', 'image', 'uploaded_at']
        read_only_fields = ['id', 'uploaded_at']


class RoomSerializer(serializers.ModelSerializer):
    facilities = serializers.PrimaryKeyRelatedField(
        queryset=RoomFacility.objects.all(), many=True, required=False, write_only=True
    )
    facilities_detail = RoomFacilitySerializer(source='facilities', many=True, read_only=True)

    thumbnail = serializers.ImageField(required=False, allow_null=True)
    thumbnail_url = serializers.SerializerMethodField()

    property_title = serializers.CharField(source='property.title', read_only=True)

    # NEW: multiple images
    images = serializers.ListField(
        child=serializers.ImageField(), write_only=True, required=False
    )
    images_detail = RoomImageSerializer(source='images', many=True, read_only=True)

    class Meta:
        model = Room
        fields = [
            'id', 'property', 'property_title', 'room_number', 'room_type',
            'capacity', 'rent_per_month', 'is_available',
            'facilities', 'facilities_detail',
            'thumbnail', 'thumbnail_url',
            'images', 'images_detail',
            'created_at'
        ]
        read_only_fields = ['id', 'created_at']

    def get_thumbnail_url(self, obj):
        request = self.context.get('request')
        if obj.thumbnail and hasattr(obj.thumbnail, 'url'):
            return request.build_absolute_uri(obj.thumbnail.url)
        return None

    def create(self, validated_data):
        images = validated_data.pop('images', [])
        room = super().create(validated_data)
        for image in images:
            RoomImage.objects.create(room=room, image=image)
        return room

    def update(self, instance, validated_data):
        images = validated_data.pop('images', [])
        room = super().update(instance, validated_data)
        for image in images:
            RoomImage.objects.create(room=room, image=image)
        return room

