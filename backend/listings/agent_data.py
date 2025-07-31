from .models import Property
from django.contrib.auth import get_user_model

def get_agent_knowledge():
    data = []

    for prop in Property.objects.prefetch_related(
        'shared_facilities',
        'rooms__facilities',
        'rooms__images',
        'feedbacks'
    ).select_related('type', 'owner'):
        
        property_data = {
            "title": prop.title,
            "type": prop.type.name,
            "owner": prop.owner.username,
            "city": prop.city,
            "address": prop.address,
            "description": prop.description,
            "is_active": prop.is_active,
            "thumbnail": prop.thumbnail.url if prop.thumbnail else None,
            "shared_facilities": [sf.name for sf in prop.shared_facilities.all()],
            "rooms": [],
            "feedbacks": []
        }

        for room in prop.rooms.all():
            room_data = {
                "room_number": room.room_number,
                "room_type": room.room_type,
                "capacity": room.capacity,
                "rent_per_month": float(room.rent_per_month),
                "is_available": room.is_available,
                "facilities": [f.name for f in room.facilities.all()],
                "thumbnail": room.thumbnail.url if room.thumbnail else None,
                "images": [img.image.url for img in room.images.all()]
            }
            property_data["rooms"].append(room_data)

        for fb in prop.feedbacks.all():
            feedback_data = {
                "user": fb.user.username,
                "rating": fb.rating,
                "comment": fb.comment,
                "sentiment": fb.sentiment,
                "sentiment_score": fb.sentiment_score,
            }
            property_data["feedbacks"].append(feedback_data)

        data.append(property_data)

    return data
