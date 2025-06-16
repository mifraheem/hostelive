from django.contrib import admin
from .models import (
    ListingType,
    SharedFacility,
    Property,
    RoomFacility,
    Room,
    Feedback
)

@admin.register(ListingType)
class ListingTypeAdmin(admin.ModelAdmin):
    list_display = ('id', 'name')

@admin.register(SharedFacility)
class SharedFacilityAdmin(admin.ModelAdmin):
    list_display = ('id', 'name')

@admin.register(Property)
class PropertyAdmin(admin.ModelAdmin):
    list_display = ('id', 'title', 'type', 'city', 'owner', 'is_active', 'created_at')

@admin.register(RoomFacility)
class RoomFacilityAdmin(admin.ModelAdmin):
    list_display = ('id', 'name')

@admin.register(Room)
class RoomAdmin(admin.ModelAdmin):
    list_display = ('id', 'property', 'room_number', 'room_type', 'capacity', 'rent_per_month', 'is_available', 'created_at')

@admin.register(Feedback)
class FeedbackAdmin(admin.ModelAdmin):
    list_display = ('id', 'property', 'user', 'rating', 'sentiment', 'sentiment_score', 'created_at')
