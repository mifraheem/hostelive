from django.db import models
from django.contrib.auth import get_user_model

# Create your models here.


class ListingType(models.Model):
    name = models.CharField(max_length=100, unique=True)

    def __str__(self):
        return self.name


class SharedFacility(models.Model):
    name = models.CharField(max_length=100, unique=True)

    def __str__(self):
        return self.name


class Property(models.Model):
    owner = models.ForeignKey(get_user_model(), on_delete=models.CASCADE)
    type = models.ForeignKey(
        ListingType, on_delete=models.PROTECT, related_name='properties')
    title = models.CharField(max_length=255)
    address = models.TextField()
    city = models.CharField(max_length=100)
    description = models.TextField(blank=True, null=True)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    shared_facilities = models.ManyToManyField(
        SharedFacility, blank=True, related_name='properties')
    thumbnail = models.ImageField(upload_to='property_thumbnails/', blank=True, null=True)

    def __str__(self):
        return f"{self.title} ({self.type.name})"

class RoomFacility(models.Model):
    name = models.CharField(max_length=100, unique=True)

    def __str__(self):
        return self.name

class Room(models.Model):
    property = models.ForeignKey(
        Property, on_delete=models.CASCADE, related_name='rooms')
    room_number = models.CharField(max_length=20)
    room_type = models.CharField(max_length=100)
    capacity = models.PositiveIntegerField()
    rent_per_month = models.DecimalField(max_digits=8, decimal_places=2)
    is_available = models.BooleanField(default=True)
    facilities = models.ManyToManyField(RoomFacility, blank=True, related_name='rooms')
    thumbnail = models.ImageField(upload_to='room_thumbnails/', blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)


    def __str__(self):
        return f"{self.property.title} - Room {self.room_number}"
class RoomImage(models.Model):
    room = models.ForeignKey(Room, on_delete=models.CASCADE, related_name='images')
    image = models.ImageField(upload_to='room_images/')
    uploaded_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Image for {self.room}"




class Feedback(models.Model):
    property = models.ForeignKey(
        Property, on_delete=models.CASCADE, related_name='feedbacks')
    user = models.ForeignKey(get_user_model(), on_delete=models.CASCADE)
    rating = models.PositiveIntegerField()
    comment = models.TextField(blank=True, null=True)
    sentiment = models.CharField(
        max_length=20, 
        choices=[('positive', 'Positive'), ('neutral', 'Neutral'), ('negative', 'Negative')],
        blank=True,
        null=True
    )
    sentiment_score = models.FloatField(
        blank=True, null=True, help_text="Optional numeric confidence or polarity score (-1.0 to 1.0)"
    )
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Feedback for {self.property.title} by {self.user.username}"
