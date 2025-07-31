# views.py

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .agentData import get_agent_knowledge
import google.generativeai as genai
from django.conf import settings




# Optional: move this to settings.py
GEMINI_API_KEY = settings.GEMINI_API_KEY

# Configure Gemini
genai.configure(api_key=GEMINI_API_KEY)
gemini_model = genai.GenerativeModel(
    model_name="gemini-2.0-flash-exp",
    generation_config={
        "temperature": 0.5,
        "top_p": 0.8,
        "top_k": 40,
        "max_output_tokens": 2048,
        "response_mime_type": "text/plain",
    }
)

class PropertyAssistantAPIView(APIView):
    def post(self, request):
        user_message = request.data.get("message")

        if not user_message:
            return Response({"error": "Message is required."}, status=status.HTTP_400_BAD_REQUEST)

        try:
            # Load property data
            data = get_agent_knowledge()

            # Start fresh chat per request
            chat = gemini_model.start_chat()

            system_prompt = (
                "You are a helpful assistant for HostelHive, a hostel/property listing platform.\n"
                "You must strictly answer only from the provided property data. Do not guess or generate imaginary information.\n"
                "If a user asks something not present in the data, politely say:\n"
                "\"Currently, I don't have that information. You can explore all hostels listed on HostelHive to find what suits you.\"\n"
                "If the question is unrelated to HostelHive (like general topics), respond with:\n"
                "\"Please ask a question related to HostelHive. I'm here to assist you with hostel or property-related queries only.\"\n"
                "Use a professional and helpful tone. Be concise and clear.\n\n"
                f"Here is the property data:\n{data}"
            )

            chat.send_message(system_prompt)
            ai_response = chat.send_message(user_message)

            return Response({
                "response": ai_response.text
            })

        except Exception as e:
            return Response({
                "error": str(e)
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
