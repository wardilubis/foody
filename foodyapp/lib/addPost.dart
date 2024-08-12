import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddPostPage extends StatefulWidget {
  @override
  _AddPostPageState createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  File? _image;
  final _captionController = TextEditingController();
  final picker = ImagePicker();

  Future<void> _chooseImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _uploadPost() async {
    if (_image == null || _captionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an image and write a caption.')),
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('authToken');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You are not authenticated. Please login.')),
      );
      return;
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.0.2.2:8000/api/post/posts/'),
    );

    request.fields['caption'] = _captionController.text;
    request.files.add(await http.MultipartFile.fromPath('image', _image!.path));
    request.headers.addAll({
      'Authorization': 'Token $token', // Gunakan token yang disimpan
    });

    var response = await request.send();

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post created successfully!')),
      );
      setState(() {
        _image = null;
        _captionController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create post.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
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
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo,
                              color: Colors.grey[500], size: 50),
                          SizedBox(height: 8),
                          Text('Tap to select an image',
                              style: TextStyle(color: Colors.grey[500])),
                        ],
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
              decoration: InputDecoration(
                hintText: 'Write a caption...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadPost,
              child: Text('Upload Post', style: TextStyle(fontSize: 16)),
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
