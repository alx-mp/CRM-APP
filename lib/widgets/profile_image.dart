// lib/widgets/profile_image.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/profile_service.dart';

class ProfileImage extends StatefulWidget {
  final double radius;
  final VoidCallback? onTap;
  final String? userId;
  final Function(bool isLoading)? onLoadingChanged;

  const ProfileImage({
    super.key,
    this.radius = 20,
    this.onTap,
    this.userId,
    this.onLoadingChanged,
  });

  @override
  State<ProfileImage> createState() => _ProfileImageState();
}

class _ProfileImageState extends State<ProfileImage> {
  String? base64Image;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    if (widget.userId != null) {
      try {
        final imageBase64 =
            await ProfileService.getProfileImage(widget.userId!);
        if (mounted && imageBase64 != null) {
          setState(() {
            base64Image = imageBase64;
          });
        }
      } catch (e) {
        //print('Error loading profile image: $e');
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    if (widget.onTap == null) return;

    final ImagePicker picker = ImagePicker();

    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _isLoading = true;
        });
        widget.onLoadingChanged?.call(true);

        final file = File(image.path);
        final success = await ProfileService.updateProfileImage(file);

        if (!mounted) return;

        // Primero actualizamos la imagen si fue exitoso
        if (success) {
          await _loadProfileImage();
        }

        // Luego desactivamos el estado de carga
        setState(() {
          _isLoading = false;
        });
        widget.onLoadingChanged?.call(false);

        // Finalmente mostramos el mensaje
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Imagen de perfil actualizada'
                : 'Error al actualizar la imagen'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      } else {
        // Usuario canceló la selección
        if (!mounted) return;
        widget.onLoadingChanged?.call(false);
      }
    } catch (e) {
      //print('Error picking/uploading image: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      widget.onLoadingChanged?.call(false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al seleccionar o procesar la imagen'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  ImageProvider? _getImageProvider() {
    if (base64Image != null && base64Image!.isNotEmpty) {
      try {
        String cleanBase64 =
            base64Image!.replaceAll(RegExp(r'^data:image/[^;]+;base64,'), '');
        final imageBytes = base64Decode(cleanBase64);
        return MemoryImage(imageBytes);
      } catch (e) {
        //print('Error decoding image: $e');
        return null;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap == null
          ? null
          : (_isLoading ? null : _pickAndUploadImage),
      child: CircleAvatar(
        radius: widget.radius,
        backgroundColor: Colors.blue,
        backgroundImage: _getImageProvider(),
        child: _getImageProvider() == null
            ? Icon(
                Icons.person,
                size: widget.radius * 1.2,
                color: Colors.white,
              )
            : null,
      ),
    );
  }
}
