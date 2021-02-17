from django.urls import path
from . import views

urlpatterns = [
    path('', views.status_view, name='hm-status'),
]
