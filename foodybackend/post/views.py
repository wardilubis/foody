from rest_framework import viewsets, permissions
from rest_framework.decorators import action
from rest_framework.response import Response
from .models import PostPic
from .serializers import PostPicSerializer

class PostPicViewSet(viewsets.ModelViewSet):
    serializer_class = PostPicSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

    @action(detail=True, methods=['post'])
    def like(self, request, pk=None):
        post = self.get_object()
        if request.user in post.likes.all():
            post.likes.remove(request.user)
            liked = False
        else:
            post.likes.add(request.user)
            liked = True
        return Response({'liked': liked, 'likes_count': post.likes.count()})
    
    def perform_update(self, serializer):
        serializer.save()

    def get_queryuserset(self):
        user = self.request.user
        return PostPic.objects.filter(user=user).order_by('-created_at')

    def get_queryset(self):
        if 'profile' in self.request.path:
            return self.get_queryuserset()
        return PostPic.objects.all().order_by('-created_at')
