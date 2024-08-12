from django.urls import path
from .views import register, verify_email, login, logout

urlpatterns = [
    path('register/', register, name='register'),
    path('verify-email/', verify_email, name='verify_email'),
    path('login/', login, name='login'),
    path('logout/', logout, name='logout'),
]
