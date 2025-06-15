from rest_framework import viewsets, permissions
from ..models import Property
from ..serializers.property import PropertySerializer
from ..permissions import IsOwnerOrReadOnly
from drf_yasg.utils import swagger_auto_schema
from rest_framework.parsers import MultiPartParser, FormParser

from rest_framework import viewsets, permissions
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.decorators import action
from rest_framework.response import Response
from ..models import Property
from ..serializers.property import PropertySerializer
from ..permissions import IsOwnerOrReadOnly
from drf_yasg.utils import swagger_auto_schema

class PropertyViewSet(viewsets.ModelViewSet):
    serializer_class = PropertySerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly, IsOwnerOrReadOnly]
    parser_classes = [MultiPartParser, FormParser]

    def get_queryset(self):
        return Property.objects.all().order_by('-created_at')

    def perform_create(self, serializer):
        serializer.save(owner=self.request.user)

    @action(detail=False, methods=['get'], url_path='mylistings', permission_classes=[permissions.IsAuthenticated])
    def my_listings(self, request):
        user = request.user
        listings = Property.objects.filter(owner=user).order_by('-created_at')
        page = self.paginate_queryset(listings)
        if page is not None:
            serializer = self.get_serializer(page, many=True, context={'request': request})
            return self.get_paginated_response(serializer.data)
        serializer = self.get_serializer(listings, many=True, context={'request': request})
        return Response(serializer.data)
