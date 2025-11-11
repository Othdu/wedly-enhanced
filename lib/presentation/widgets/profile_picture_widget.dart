import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePictureWidget extends StatefulWidget {
  final String? profileImageUrl;
  final bool isEditable;
  final Function(File)? onImageSelected;

  const ProfilePictureWidget({
    super.key,
    this.profileImageUrl,
    this.isEditable = false,
    this.onImageSelected, File? initialImageFile,
  });

  @override
  State<ProfilePictureWidget> createState() => _ProfilePictureWidgetState();
}

class _ProfilePictureWidgetState extends State<ProfilePictureWidget> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    if (!widget.isEditable) return;

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
      widget.onImageSelected?.call(_selectedImage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = Stack(
      children: [
        Container(
          width: 98,
          height: 98,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade200,
          ),
          child: _selectedImage != null
              ? ClipOval(
                  child: Image.file(
                    _selectedImage!,
                    width: 98,
                    height: 98,
                    fit: BoxFit.cover,
                  ),
                )
              : (widget.profileImageUrl != null
                  ? ClipOval(
                      child: Image.network(
                        widget.profileImageUrl!,
                        width: 98,
                        height: 98,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            size: 49,
                            color: Colors.grey.shade400,
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.person,
                      size: 49,
                      color: Colors.grey.shade400,
                    )),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.camera_alt,
              size: 16,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );

    if (widget.isEditable) {
      return GestureDetector(
        onTap: _pickImage,
        child: child,
      );
    }

    return child;
  }
}
