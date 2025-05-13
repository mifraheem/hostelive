from rest_framework import serializers
from ..models import Property, SharedFacility
from .facilities import SharedFacilitySerializer

class PropertySerializer(serializers.ModelSerializer):
    shared_facilities = serializers.PrimaryKeyRelatedField(
        queryset=SharedFacility.objects.all(),
        many=True,
        write_only=True
    )
    shared_facilities_detail = SharedFacilitySerializer(
        source='shared_facilities',
        many=True,
        read_only=True    
    )
    thumbnail = serializers.ImageField(required=False, allow_null=True)
    thumbnail_url = serializers.SerializerMethodField()

    class Meta:
        model = Property
        fields = [
            'id', 'type', 'title', 'address', 'city', 'description',
            'shared_facilities',       
            'shared_facilities_detail',
            'thumbnail', 'thumbnail_url',
            'is_active', 'created_at'
        ]
        read_only_fields = ['id', 'owner', 'created_at']

    def get_thumbnail_url(self, obj):
        request = self.context.get('request')
        if obj.thumbnail and hasattr(obj.thumbnail, 'url'):
            return request.build_absolute_uri(obj.thumbnail.url)
        return None

    def create(self, validated_data):
        shared_facilities = validated_data.pop('shared_facilities', [])
        property = Property.objects.create(**validated_data)
        property.shared_facilities.set(shared_facilities)
        return property

    def update(self, instance, validated_data):
        shared_facilities = validated_data.pop('shared_facilities', None)
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()
        if shared_facilities is not None:
            instance.shared_facilities.set(shared_facilities)
        return instance
