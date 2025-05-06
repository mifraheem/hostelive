from django.urls import path
from .apis.auth import RegisterView, CustomLoginView
from .apis.profile import MeView
urlpatterns = [
    path('login/', CustomLoginView.as_view(), name='token_obtain_pair'),
    path('register/', RegisterView.as_view(), name='register'),
    path('me/', MeView.as_view(), name='me')

]
