from django.urls import path
from .apis.listingTypes import ListingTypeListCreateView
from .apis.facilities import (
    ListingTypeListCreateView,
    RoomFacilityListCreateView,
    SharedFacilityListCreateView,
)
from .apis.property import PropertyViewSet
from .apis.rooms import RoomViewSet
from .apis.feedback import FeedbackViewSet
from rest_framework.routers import DefaultRouter
from .apis.agentData import agent_knowledge_view
from .apis.agent import PropertyAssistantAPIView

router = DefaultRouter()
router.register(r'properties', PropertyViewSet, basename='property')
router.register(r'rooms', RoomViewSet, basename='room')
router.register(r'feedbacks', FeedbackViewSet, basename='feedbacks')


urlpatterns = [
    path('types/', ListingTypeListCreateView.as_view(), name='listing-types'),
    path('room-facilities/', RoomFacilityListCreateView.as_view(), name='room-facilities'),
    path('shared-facilities/', SharedFacilityListCreateView.as_view(), name='shared-facilities'),
    path('agent/data/', agent_knowledge_view),
     path('ai-assistant/', PropertyAssistantAPIView.as_view(), name='ai-assistant'),
]
urlpatterns += router.urls
