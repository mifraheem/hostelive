from rest_framework import serializers
from ..models import Property, SharedFacility

class SharedFacilitySerializer(serializers.ModelSerializer):
    class Meta:
        model = SharedFacility
        fields = ['id', 'name']

class PropertySerializer(serializers.ModelSerializer):
    shared_facilities = serializers.PrimaryKeyRelatedField(
        queryset=SharedFacility.objects.all(),
        many=True,
        write_only=True  # ✅ only used when sending data
    )
    shared_facilities_detail = SharedFacilitySerializer(
        source='shared_facilities',
        many=True,
        read_only=True     # ✅ shown in responses
    )

    class Meta:
        model = Property
        fields = [
            'id', 'type', 'title', 'address', 'city', 'description',
            'shared_facilities',        # input
            'shared_facilities_detail', # output
            'is_active', 'created_at'
        ]
        read_only_fields = ['id', 'owner', 'created_at']

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
