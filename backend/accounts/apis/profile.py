from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from ..serializers import UserSerializer
from rest_framework.response import Response

class MeView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user
        serializer = UserSerializer(user)
        return Response(serializer.data)
