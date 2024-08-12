from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import PostPicViewSet

router = DefaultRouter()
router.register(r'posts', PostPicViewSet, basename='post')

urlpatterns = [
    path('', include(router.urls)),
    path('profile/', PostPicViewSet.as_view({'get': 'list'}), name='profile-posts'),
]
