from rest_framework import serializers
from .models import PostPic
from comment.serializers import CommentSerializer

class PostPicSerializer(serializers.ModelSerializer):
    user = serializers.ReadOnlyField(source='user.username')
    likes_count = serializers.IntegerField(source='likes.count', read_only=True)
    comments = CommentSerializer(many=True, read_only=True)

    class Meta:
        model = PostPic
        fields = ['id', 'user', 'image', 'caption', 'created_at', 'likes_count', 'comments']
