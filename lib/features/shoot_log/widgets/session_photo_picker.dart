import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Horizontal photo picker for target or session images.
class SessionPhotoPicker extends StatelessWidget {
  const SessionPhotoPicker({
    super.key,
    required this.photos,
    required this.onAdd,
    required this.onRemove,
    this.title = 'Photos',
    this.subtitle,
    this.maxPhotos = 6,
    this.emptyHint = 'Add photos from your camera or gallery',
  });

  final List<SessionPhotoDraft> photos;
  final Future<void> Function(ImageSource source) onAdd;
  final void Function(int index) onRemove;
  final String title;
  final String? subtitle;
  final int maxPhotos;
  final String emptyHint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canAdd = photos.length < maxPhotos;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 12),
        if (photos.isEmpty)
          _EmptyPhotoCard(
            hint: emptyHint,
            onCamera: canAdd ? () => onAdd(ImageSource.camera) : null,
            onGallery: canAdd ? () => onAdd(ImageSource.gallery) : null,
          )
        else
          SizedBox(
            height: 112,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: photos.length + (canAdd ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                if (index == photos.length) {
                  return _AddPhotoTile(
                    onCamera: () => onAdd(ImageSource.camera),
                    onGallery: () => onAdd(ImageSource.gallery),
                  );
                }
                final photo = photos[index];
                return _PhotoThumbnail(
                  photo: photo,
                  onRemove: () => onRemove(index),
                );
              },
            ),
          ),
        const SizedBox(height: 6),
        Text(
          '${photos.length}/$maxPhotos · Max 4 MB each · JPG or PNG',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class SessionPhotoDraft {
  const SessionPhotoDraft({
    required this.file,
    required this.previewBytes,
  });

  final XFile file;
  final Uint8List previewBytes;
}

class _EmptyPhotoCard extends StatelessWidget {
  const _EmptyPhotoCard({
    required this.hint,
    this.onCamera,
    this.onGallery,
  });

  final String hint;
  final VoidCallback? onCamera;
  final VoidCallback? onGallery;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          style: BorderStyle.solid,
        ),
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
      ),
      child: Column(
        children: [
          Icon(
            Icons.photo_camera_outlined,
            size: 36,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 8),
          Text(
            hint,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (onCamera != null)
                FilledButton.tonalIcon(
                  onPressed: onCamera,
                  icon: const Icon(Icons.camera_alt_outlined, size: 18),
                  label: const Text('Camera'),
                ),
              if (onCamera != null && onGallery != null) const SizedBox(width: 8),
              if (onGallery != null)
                OutlinedButton.icon(
                  onPressed: onGallery,
                  icon: const Icon(Icons.photo_library_outlined, size: 18),
                  label: const Text('Gallery'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddPhotoTile extends StatelessWidget {
  const _AddPhotoTile({
    required this.onCamera,
    required this.onGallery,
  });

  final VoidCallback onCamera;
  final VoidCallback onGallery;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopupMenuButton<ImageSource>(
      tooltip: 'Add photo',
      onSelected: (source) {
        if (source == ImageSource.camera) {
          onCamera();
        } else {
          onGallery();
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: ImageSource.camera,
          child: ListTile(
            leading: Icon(Icons.camera_alt_outlined),
            title: Text('Take photo'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem(
          value: ImageSource.gallery,
          child: ListTile(
            leading: Icon(Icons.photo_library_outlined),
            title: Text('Choose from gallery'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
      child: Container(
        width: 112,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.colorScheme.primary.withAlpha(100)),
          color: theme.colorScheme.primaryContainer.withAlpha(60),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined, color: theme.colorScheme.primary),
            const SizedBox(height: 4),
            Text(
              'Add',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoThumbnail extends StatelessWidget {
  const _PhotoThumbnail({
    required this.photo,
    required this.onRemove,
  });

  final SessionPhotoDraft photo;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.memory(
            photo.previewBytes,
            width: 112,
            height: 112,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: Material(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.close_rounded, color: Colors.white, size: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Future<SessionPhotoDraft?> pickSessionPhoto(ImageSource source) async {
  final picker = ImagePicker();
  final file = await picker.pickImage(
    source: source,
    maxWidth: 2048,
    maxHeight: 2048,
    imageQuality: 85,
  );
  if (file == null) return null;
  final bytes = await file.readAsBytes();
  if (bytes.length > 4 * 1024 * 1024) return null;
  return SessionPhotoDraft(file: file, previewBytes: bytes);
}
