from django.contrib import admin
from .models import Property, Room, ListingType, SharedFacility, RoomFacility

# Register your models here.
admin.site.register((Property, Room, ListingType, SharedFacility, RoomFacility))