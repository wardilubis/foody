from django.contrib.auth.models import User
from django.contrib.auth import authenticate
from rest_framework.response import Response
from rest_framework.decorators import api_view, permission_classes
from rest_framework.authtoken.models import Token
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework import status
from .models import EmailVerification
from .serializers import UserSerializer, EmailVerificationSerializer, LoginSerializer

@api_view(['POST'])
@permission_classes([AllowAny])
def register(request):
    serializer = UserSerializer(data=request.data)
    if serializer.is_valid():
        user = serializer.save()
        verification_code = EmailVerification.objects.get(user=user).code
        return Response({
            'detail': 'Verification code sent to your email.',
            'verification_code': verification_code
        }, status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['POST'])
@permission_classes([AllowAny])
def verify_email(request):
    serializer = EmailVerificationSerializer(data=request.data)
    if serializer.is_valid():
        email = serializer.validated_data['email']
        code = serializer.validated_data['code']
        
        try:
            user = User.objects.get(email=email)
            verification = EmailVerification.objects.get(user=user, code=code)
            
            if verification.is_verified:
                return Response({'detail': 'Email already verified.'}, status=status.HTTP_400_BAD_REQUEST)
            
            verification.is_verified = True
            verification.save()

            return Response({'detail': 'Email successfully verified.'}, status=status.HTTP_200_OK)
        
        except User.DoesNotExist:
            return Response({'detail': 'User does not exist.'}, status=status.HTTP_400_BAD_REQUEST)
        except EmailVerification.DoesNotExist:
            return Response({'detail': 'Invalid verification code.'}, status=status.HTTP_400_BAD_REQUEST)
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['POST'])
@permission_classes([AllowAny])
def login(request):
    serializer = LoginSerializer(data=request.data)
    if serializer.is_valid():
        username = serializer.validated_data['username']
        password = serializer.validated_data['password']
        user = authenticate(username=username, password=password)
        if user:
            token, created = Token.objects.get_or_create(user=user)
            return Response({'token': token.key}, status=status.HTTP_200_OK)
        return Response({'error': 'Invalid credentials'}, status=status.HTTP_400_BAD_REQUEST)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def logout(request):
    try:
        request.user.auth_token.delete()
        return Response({'detail': 'Logout successful'}, status=status.HTTP_200_OK)
    except (AttributeError, Token.DoesNotExist):
        return Response({'detail': 'Invalid token'}, status=status.HTTP_400_BAD_REQUEST)
