import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Import intl package

class TimelinePage extends StatefulWidget {
  @override
  _TimelinePageState createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  List<dynamic> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You are not authenticated. Please login.')),
      );
      return;
    }

    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/post/posts/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _posts = json.decode(response.body);
        _isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load posts')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    return DateFormat('dd MMMM yyyy').format(dateTime);
  }

  Future<void> _likePost(int postId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/post/posts/$postId/like/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      _fetchPosts(); // Refresh post list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to like post')),
      );
    }
  }

  Future<void> _commentOnPost(int postId, String text) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/api/comment/comments/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
      body: json.encode({
        'post': postId,
        'text': text,
      }),
    );

    if (response.statusCode == 201) {
      _fetchPosts(); // Refresh post list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to comment on post')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                final post = _posts[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(post['user_avatar'] ??
                                'https://via.placeholder.com/150'),
                          ),
                          title: Text(post['user']),
                        ),
                        post['image'] != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.network(
                                  post['image'],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 200,
                                ),
                              )
                            : SizedBox.shrink(),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            post['caption'] ?? '',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            _formatDate(post['created_at']),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.favorite,
                                  color: Colors
                                      .red), // Ganti dengan ikon hati berwarna merah
                              onPressed: () {
                                _likePost(post['id']);
                              },
                            ),
                            Text('${post['likes_count']} likes'),
                            IconButton(
                              icon: Icon(Icons.comment),
                              onPressed: () {
                                _showCommentDialog(post['id']);
                              },
                            ),
                          ],
                        ),
                        Divider(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: post['comments'].map<Widget>((comment) {
                            return ListTile(
                              title: Text(comment['user']),
                              subtitle: Text(comment['text']),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showCommentDialog(int postId) {
    final _commentController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Comment'),
          content: TextField(
            controller: _commentController,
            decoration: InputDecoration(hintText: "Write your comment"),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Submit'),
              onPressed: () {
                _commentOnPost(postId, _commentController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
