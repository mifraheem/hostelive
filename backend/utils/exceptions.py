from rest_framework.views import exception_handler
from rest_framework import status
from .response import api_response

def custom_exception_handler(exc, context):
    response = exception_handler(exc, context)

    if response is not None:
        errors = response.data

        # Extract detail if available and promote to message
        if isinstance(errors, dict) and 'detail' in errors and isinstance(errors['detail'], str):
            message = errors['detail']
            errors = None  # Optionally suppress `errors` if already promoted
        elif response.status_code == 400:
            message = "Validation error"
        else:
            message = "An error occurred"

        return api_response(
            success=False,
            message=message,
            data=None,
            errors=errors,
            status=response.status_code
        )

    return api_response(
        success=False,
        message="Unexpected server error",
        data=None,
        errors={'detail': str(exc)},
        status=status.HTTP_500_INTERNAL_SERVER_ERROR
    )
