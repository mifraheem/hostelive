from rest_framework import generics
from ..models import ListingType
from ..serializers.listingTypes import ListingTypeSerializer
from rest_framework.permissions import IsAuthenticatedOrReadOnly

class ListingTypeListCreateView(generics.ListCreateAPIView):
    queryset = ListingType.objects.all()
    serializer_class = ListingTypeSerializer
    permission_classes = [IsAuthenticatedOrReadOnly]
    pagination_class = None 