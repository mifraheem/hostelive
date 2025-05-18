from rest_framework import viewsets, permissions
from ..models import Feedback
from ..serializers.feedback import FeedbackSerializer
from rest_framework.response import Response
from rest_framework.decorators import action

class FeedbackViewSet(viewsets.ModelViewSet):
    queryset = Feedback.objects.all().order_by('-created_at')
    serializer_class = FeedbackSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

    def get_queryset(self):
        if self.action == 'list':
            return Feedback.objects.none()  # prevent /feedbacks/ from listing everything
        return super().get_queryset()

    @action(detail=False, url_path='property/(?P<property_id>[^/.]+)')
    def by_property(self, request, property_id=None):
        feedbacks = Feedback.objects.filter(property_id=property_id).order_by('-created_at')
        page = self.paginate_queryset(feedbacks)
        if page is not None:
            serializer = self.get_serializer(page, many=True, context={'request': request})
            return self.get_paginated_response(serializer.data)
        serializer = self.get_serializer(feedbacks, many=True, context={'request': request})
        return Response(serializer.data)