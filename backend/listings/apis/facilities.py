from rest_framework import generics
from ..models import ListingType, RoomFacility, SharedFacility
from ..serializers.facilities import ListingTypeSerializer, RoomFacilitySerializer, SharedFacilitySerializer
from rest_framework.permissions import IsAuthenticatedOrReadOnly

class ListingTypeListCreateView(generics.ListCreateAPIView):
    queryset = ListingType.objects.all()
    serializer_class = ListingTypeSerializer
    permission_classes = [IsAuthenticatedOrReadOnly]
    pagination_class = None

class RoomFacilityListCreateView(generics.ListCreateAPIView):
    queryset = RoomFacility.objects.all()
    serializer_class = RoomFacilitySerializer
    permission_classes = [IsAuthenticatedOrReadOnly]
    pagination_class = None

class SharedFacilityListCreateView(generics.ListCreateAPIView):
    queryset = SharedFacility.objects.all()
    serializer_class = SharedFacilitySerializer
    permission_classes = [IsAuthenticatedOrReadOnly]
    pagination_class = None
