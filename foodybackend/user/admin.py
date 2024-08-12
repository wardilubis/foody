from django.contrib import admin
from .models import EmailVerification

@admin.register(EmailVerification)
class EmailVerificationAdmin(admin.ModelAdmin):
    list_display = ('user', 'code', 'is_verified', 'created_at')
    search_fields = ('user__username', 'code')
    list_filter = ('is_verified', 'created_at')