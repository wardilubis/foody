import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
// Import halaman post detail
import 'postDetail.dart';
import 'editPost.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<dynamic> _userPosts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserPosts();
  }

  Future<void> _fetchUserPosts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You are not authenticated. Please login.')),
      );
      return;
    }

    final response = await http.get(
      Uri.parse(
          'http://10.0.2.2:8000/api/post/profile/'), // Arahkan ke endpoint profile
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _userPosts = json.decode(response.body);
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

  void _showPostOptions(BuildContext context, int postId, String initialCaption,
      String initialImage) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit Post'),
                onTap: () async {
                  Navigator.of(context).pop();
                  bool? result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditPostPage(
                        postId: postId,
                        initialCaption: initialCaption,
                        initialImage: initialImage,
                      ),
                    ),
                  );
                  if (result == true) {
                    _fetchUserPosts(); // Refresh postingan setelah update
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('Delete Post'),
                onTap: () {
                  Navigator.of(context).pop();
                  _confirmDelete(context, postId);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deletePost(int postId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    final response = await http.delete(
      Uri.parse('http://10.0.2.2:8000/api/post/posts/$postId/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 204) {
      setState(() {
        _userPosts.removeWhere((post) => post['id'] == postId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post deleted successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete post')),
      );
    }
  }

  void _confirmDelete(BuildContext context, int postId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this post?'),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Delete'),
              onPressed: () {
                _deletePost(postId);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _viewPostDetails(int postId, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PostDetailPage(postId: postId, imageUrl: imageUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: _userPosts.length,
              itemBuilder: (context, index) {
                final post = _userPosts[index];
                return GestureDetector(
                  onTap: () {
                    _viewPostDetails(post['id'], post['image']);
                  },
                  onLongPress: () {
                    _showPostOptions(
                      context,
                      post['id'],
                      post['caption'],
                      post['image'],
                    );
                  },
                  child: Image.network(
                    post['image'],
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
    );
  }
}
