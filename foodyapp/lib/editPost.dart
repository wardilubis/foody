import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditPostPage extends StatefulWidget {
  final int postId;
  final String initialCaption;
  final String initialImage;

  EditPostPage({
    required this.postId,
    required this.initialCaption,
    required this.initialImage,
  });

  @override
  _EditPostPageState createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  TextEditingController _captionController = TextEditingController();
  File? _image;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _captionController.text = widget.initialCaption;
  }

  Future<void> _chooseImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _updatePost() async {
    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    var request = http.MultipartRequest(
      'PATCH',
      Uri.parse('http://10.0.2.2:8000/api/post/posts/${widget.postId}/'),
    );

    request.fields['caption'] = _captionController.text;

    if (_image != null) {
      request.files
          .add(await http.MultipartFile.fromPath('image', _image!.path));
    }

    request.headers.addAll({
      'Content-Type': 'application/json',
      'Authorization': 'Token $token',
    });

    final response = await request.send();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post updated successfully!')),
      );
      Navigator.of(context).pop(true); // Return true to indicate success
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update post')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Post'),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _chooseImage,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: _image == null
                    ? widget.initialImage.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              widget.initialImage,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          )
                        : Center(
                            child: Text(
                              'Tap to select an image',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 16,
                              ),
                            ),
                          )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _image!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _captionController,
              maxLines: null,
              style: TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Write a caption...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              ),
            ),
            SizedBox(height: 20),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _updatePost,
                    child: Text(
                      'Update Post',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
