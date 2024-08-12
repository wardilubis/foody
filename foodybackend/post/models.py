from django.db import models
from django.contrib.auth.models import User

class PostPic(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    image = models.ImageField(upload_to='', blank=True)
    caption = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    likes = models.ManyToManyField(User, related_name='post_likes', blank=True)

    def __str__(self):
        return f'{self.user.username} - {self.caption[:20]}'
