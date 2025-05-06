from django.contrib.auth.models import AbstractUser
from django.db import models

class User(AbstractUser):
    email = models.EmailField(unique=True)
    phone = models.CharField(max_length=15, blank=True, null=True)
    address = models.CharField(max_length=255, blank=True, null=True)
    profile_picture = models.ImageField(upload_to='profile_pictures/', blank=True, null=True)
    has_property = models.BooleanField(default=False)


    def __str__(self):
        return self.email
    def get_full_name(self):
        return f"{self.first_name} {self.last_name}" if self.first_name and self.last_name else self.username
    def get_short_name(self):
        return self.first_name if self.first_name else self.username
    def get_profile_picture_url(self):
        if self.profile_picture:
            return self.profile_picture.url
        return None