# utils/renderers.py

from rest_framework.renderers import JSONRenderer

class CustomRenderer(JSONRenderer):
    def render(self, data, accepted_media_type=None, renderer_context=None):
        response = renderer_context.get('response', None)
        status_code = getattr(response, 'status_code', 200)

        success = 200 <= status_code < 300
        message = "Success" if success else "Failure"

        # Already formatted? Don't double-wrap
        if isinstance(data, dict) and {'success', 'message', 'data', 'errors'} <= data.keys():
            return super().render(data, accepted_media_type, renderer_context)

        formatted = {
            'success': success,
            'message': message,
            'data': data if success else None,
            'errors': None if success else data,
        }

        return super().render(formatted, accepted_media_type, renderer_context)
