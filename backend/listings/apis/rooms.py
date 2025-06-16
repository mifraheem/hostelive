from rest_framework import viewsets, permissions
from ..models import Room, Property
from ..serializers.room import RoomSerializer
from rest_framework.exceptions import PermissionDenied
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser, FormParser, JSONParser
from ..filters import RoomFilter
from django_filters.rest_framework import DjangoFilterBackend

class RoomViewSet(viewsets.ModelViewSet):
    queryset = Room.objects.all().order_by('-id')
    serializer_class = RoomSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]
    parser_classes = [MultiPartParser, FormParser, JSONParser] 
    filter_backends = [DjangoFilterBackend]
    filterset_class = RoomFilter


    def perform_create(self, serializer):
        property_obj = serializer.validated_data['property']
        if property_obj.owner != self.request.user:
            raise PermissionDenied("You do not own this property.")
        serializer.save()

    def perform_update(self, serializer):
        property_obj = serializer.instance.property
        if property_obj.owner != self.request.user:
            raise PermissionDenied("You do not own this property.")
        serializer.save()

    def perform_destroy(self, instance):
        if instance.property.owner != self.request.user:
            raise PermissionDenied("You do not own this property.")
        instance.delete()

    @action(detail=False, url_path='property/(?P<property_id>[^/.]+)')
    def by_property(self, request, property_id=None):
        rooms = Room.objects.filter(property_id=property_id)
        page = self.paginate_queryset(rooms)
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            return self.get_paginated_response(serializer.data)
        serializer = self.get_serializer(rooms, many=True)
        return Response(serializer.data)
