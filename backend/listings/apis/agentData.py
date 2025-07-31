from rest_framework.decorators import api_view
from rest_framework.response import Response
from ..agent_data import get_agent_knowledge

@api_view(['GET'])
def agent_knowledge_view(request):
    data = get_agent_knowledge()
    return Response({"knowledge_base": data})
