from django.contrib.auth.models import User
from rest_framework import serializers
from .models import EmailVerification
import random

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['username', 'password', 'email']
        extra_kwargs = {'password': {'write_only': True}}

    def create(self, validated_data):
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data['email'],
            password=validated_data['password']
        )
        code = random.randint(100000, 999999)
        EmailVerification.objects.create(user=user, code=str(code))
        print(f'Verification code sent to {user.email}: {code}')
        return user

class EmailVerificationSerializer(serializers.Serializer):
    email = serializers.EmailField()
    code = serializers.CharField(max_length=6)

class LoginSerializer(serializers.Serializer):
    username = serializers.CharField()
    password = serializers.CharField(write_only=True)
