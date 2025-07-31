from django_filters import rest_framework as filters
from .models import Property, Room, SharedFacility, RoomFacility, ListingType
from django.db import models
class PropertyFilter(filters.FilterSet):
    type = filters.ModelChoiceFilter(queryset=ListingType.objects.all())
    shared_facilities = filters.ModelMultipleChoiceFilter(
        field_name='shared_facilities',
        to_field_name='id',
        queryset=SharedFacility.objects.all()
    )

    search_city = filters.CharFilter(method='filter_by_city_or_address')

    class Meta:
        model = Property
        fields = ['type', 'shared_facilities', 'search_city']

    def filter_by_city_or_address(self, queryset, name, value):
        return queryset.filter(
            models.Q(city__icontains=value) |
            models.Q(address__icontains=value) |
            models.Q(title__icontains=value) 
        )


class RoomFilter(filters.FilterSet):
    room_type = filters.CharFilter()
    capacity = filters.NumberFilter()
    capacity__gte = filters.NumberFilter(field_name='capacity', lookup_expr='gte')
    capacity__lte = filters.NumberFilter(field_name='capacity', lookup_expr='lte')
    rent_min = filters.NumberFilter(field_name='rent_per_month', lookup_expr='gte')
    rent_max = filters.NumberFilter(field_name='rent_per_month', lookup_expr='lte')
    facilities = filters.ModelMultipleChoiceFilter(
        field_name='facilities__id',
        to_field_name='id',
        queryset=RoomFacility.objects.all()
    )

    class Meta:
        model = Room
        fields = [
            'room_type', 'capacity', 'capacity__gte', 'capacity__lte',
            'rent_min', 'rent_max', 'facilities'
        ]
