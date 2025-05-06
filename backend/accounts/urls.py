from django.urls import path
from rest_framework_simplejwt.views import TokenObtainPairView
from .apis.auth import RegisterView, CustomLoginView
urlpatterns = [
    path('login/', CustomLoginView.as_view(), name='token_obtain_pair'),
    path('register/', RegisterView.as_view(), name='register'),
]
