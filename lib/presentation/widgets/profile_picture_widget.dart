import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'skeleton_image.dart';
import 'package:wedly/core/utils/permission_helper.dart' as permission;

class ProfilePictureWidget extends StatefulWidget {
  final String? profileImageUrl;
  final bool isEditable;
  final Function(File)? onImageSelected;
  final double size;
  final bool showEditIcon;

  const ProfilePictureWidget({
    super.key,
    this.profileImageUrl,
    this.isEditable = false,
    this.onImageSelected,
    this.size = 98,
    this.showEditIcon = true,
  });

  @override
  State<ProfilePictureWidget> createState() => _ProfilePictureWidgetState();
}

class _ProfilePictureWidgetState extends State<ProfilePictureWidget> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    if (!widget.isEditable) return;

    // Show dialog to choose between camera and gallery
    final source = await permission.PermissionHelper.showImageSourceDialog(context);
    if (source == null || !mounted) return;

    bool hasPermission = false;

    if (source == permission.ImageSource.camera) {
      // Request camera permission
      hasPermission = await permission.PermissionHelper.requestCameraPermission(context);
    } else {
      // Request storage/photos permission
      hasPermission = await permission.PermissionHelper.requestStoragePermission(context);
    }

    if (!hasPermission || !mounted) return;

    // Pick image from selected source
    final imageSource = source == permission.ImageSource.camera
        ? ImageSource.camera
        : ImageSource.gallery;

    final XFile? image = await _picker.pickImage(source: imageSource);
    if (image != null && mounted) {
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
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade200,
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
          ),
          child: _selectedImage != null
              ? ClipOval(
                  child: Image.file(
                    _selectedImage!,
                    width: widget.size,
                    height: widget.size,
                    fit: BoxFit.cover,
                  ),
                )
              : (widget.profileImageUrl != null
                  ? SkeletonCircleImage(
                      imageUrl: widget.profileImageUrl!,
                      size: widget.size,
                      errorWidget: Icon(
                        Icons.person,
                        size: widget.size * 0.5,
                        color: Colors.grey.shade400,
                      ),
                    )
                  : Icon(
                      Icons.person,
                      size: widget.size * 0.5,
                      color: Colors.grey.shade400,
                    )),
        ),
        if (widget.showEditIcon && widget.isEditable)
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
