// lib/screens/photo_selection_modal.dart
import 'dart:io';
import 'package:flutter/material.dart';

class PhotoSelectionModal extends StatefulWidget {
  final String initialMode;

  const PhotoSelectionModal({super.key, required this.initialMode});

  @override
  State<PhotoSelectionModal> createState() => _PhotoSelectionModalState();
}

class _PhotoSelectionModalState extends State<PhotoSelectionModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<FileSystemEntity> _galleryImages = [];
  List<FileSystemEntity> _cameraImages = [];
  bool _isLoading = true;
  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialMode == 'camera' ? 1 : 0,
    );
    _loadImages();
  }

  Future<void> _loadImages() async {
    setState(() => _isLoading = true);

    try {
      await _loadRealImagesFromStorage();
    } catch (e) {
      print('Ошибка загрузки изображений: $e');
      _createDemoImages();
    }

    setState(() => _isLoading = false);
  }

  Future<void> _loadRealImagesFromStorage() async {
    final dcimDir = Directory('/storage/emulated/0/DCIM');

    if (await dcimDir.exists()) {
      final allFiles = await dcimDir.list().toList();

      final imageFiles = allFiles.where((file) {
        final path = file.path.toLowerCase();
        return FileSystemEntity.isFileSync(file.path) &&
            (path.endsWith('.jpg') ||
                path.endsWith('.jpeg') ||
                path.endsWith('.png'));
      }).toList();

      _galleryImages = imageFiles.where((file) {
        final name = file.path.toLowerCase();
        return name.contains('gallery');
      }).toList();

      _cameraImages = imageFiles.where((file) {
        final name = file.path.toLowerCase();
        return name.contains('photo_file') || name.contains('camera');
      }).toList();

      if (_galleryImages.isEmpty && _cameraImages.isEmpty) {
        _createDemoImages();
      }
    } else {
      _createDemoImages();
    }
  }

  void _createDemoImages() {
    final demoPaths = [
      '/storage/emulated/0/DCIM/Gallery_file_boy.jpg',
      '/storage/emulated/0/DCIM/Gallery_file_girl.jpg',
      '/storage/emulated/0/DCIM/Gallery_file_man.jpg',
      '/storage/emulated/0/DCIM/Photo_file_boy.jpg',
      '/storage/emulated/0/DCIM/Photo_file_girl.jpg',
      '/storage/emulated/0/DCIM/Photo_file_man.jpg',
    ];

    _galleryImages = demoPaths
        .where((path) => path.toLowerCase().contains('gallery'))
        .map((path) => File(path))
        .toList();

    _cameraImages = demoPaths
        .where((path) => path.toLowerCase().contains('photo'))
        .map((path) => File(path))
        .toList();
  }

  void _selectImage(String imagePath) {
    setState(() {
      _selectedImagePath = imagePath;
    });
  }

  void _confirmSelection() {
    if (_selectedImagePath != null) {
      Navigator.pop(context, _selectedImagePath);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Сначала выберите фото'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildImageGrid(List<FileSystemEntity> images, String category) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (images.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              category == 'gallery' ? Icons.photo_library : Icons.camera_alt,
              size: 80,
              color: Colors.grey.withOpacity(0.4),
            ),
            const SizedBox(height: 20),
            Text(
              category == 'gallery'
                  ? 'Нет фото в галерее'
                  : 'Нет фото с камеры',
              style: TextStyle(
                color: Colors.grey.withOpacity(0.6),
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        final file = images[index];
        final isSelected = _selectedImagePath == file.path;

        return GestureDetector(
          onTap: () => _selectImage(file.path),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? Colors.blueAccent
                    : Colors.grey.withOpacity(0.3),
                width: isSelected ? 3 : 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 3,
                      )
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        spreadRadius: 1,
                      )
                    ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(
                    File(file.path),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.withOpacity(0.1),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                category == 'gallery'
                                    ? Icons.photo_library
                                    : Icons.camera_alt,
                                size: 32,
                                color: Colors.grey.withOpacity(0.4),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: Colors.grey.withOpacity(0.6),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  if (isSelected)
                    Container(
                      color: Colors.blueAccent.withOpacity(0.2),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.blueAccent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: category == 'gallery'
                            ? Colors.green.withOpacity(0.8)
                            : Colors.orange.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        category == 'gallery' ? 'G' : 'C',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Выберите фото'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 2,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(
                  icon: Icon(Icons.photo_library, size: 24),
                  text: 'Gallery',
                ),
                Tab(
                  icon: Icon(Icons.camera_alt, size: 24),
                  text: 'Camera',
                ),
              ],
              indicatorColor: Colors.blueAccent,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.blueAccent,
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildImageGrid(_galleryImages, 'gallery'),
          _buildImageGrid(_cameraImages, 'camera'),
        ],
      ),
      bottomNavigationBar: _selectedImagePath != null
          ? Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _confirmSelection,
                      icon: const Icon(Icons.check_circle, size: 22),
                      label: const Text(
                        'Выбрать это фото',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
