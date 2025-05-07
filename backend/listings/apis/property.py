from rest_framework import viewsets, permissions
from ..models import Property
from ..serializers.property import PropertySerializer
from ..permissions import IsOwnerOrReadOnly

class PropertyViewSet(viewsets.ModelViewSet):
    serializer_class = PropertySerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly, IsOwnerOrReadOnly]

    def get_queryset(self):
        base_qs = Property.objects.all().order_by('-created_at')
        if self.action in ['update', 'partial_update', 'destroy']:
            return base_qs
        return base_qs

    def perform_create(self, serializer):
        serializer.save(owner=self.request.user)
