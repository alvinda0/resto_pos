import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/controller/theme/theme_controller.dart';

class ThemeFormDialog extends StatefulWidget {
  final bool isEdit;

  const ThemeFormDialog({
    super.key,
    this.isEdit = false,
  });

  @override
  State<ThemeFormDialog> createState() => _ThemeFormDialogState();
}

class _ThemeFormDialogState extends State<ThemeFormDialog> {
  late ThemeController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ThemeController>();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.isEdit ? 'Edit Tema' : 'Buat Tema Baru',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),

            // Form content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name field
                    _buildTextField(
                      controller: controller.nameController,
                      label: 'Nama Tema',
                      hint: 'Masukan Nama Tema',
                      required: true,
                    ),
                    const SizedBox(height: 16),

                    // Page title field
                    _buildTextField(
                      controller: controller.pageTitleController,
                      label: 'Page Title',
                      hint: 'Masukan page title',
                      required: true,
                    ),
                    const SizedBox(height: 16),

                    // Primary color field with color picker
                    _buildColorField(controller),
                    const SizedBox(height: 16),

                    // Is default checkbox
                    Obx(() => Card(
                          child: CheckboxListTile(
                            title: const Text('Tetapkan sebagai Tema Default'),
                            subtitle: const Text(
                                'Tema ini akan digunakan sebagai tema default'),
                            value: controller.isDefaultController.value,
                            onChanged: (value) {
                              controller.isDefaultController.value =
                                  value ?? false;
                            },
                            secondary: const Icon(Icons.star),
                          ),
                        )),

                    const SizedBox(height: 16),

                    // Logo upload
                    _buildImageUploadSection(
                      title: 'Logo',
                      subtitle: 'Unggah logo tema Anda',
                      selectedFile: controller.selectedLogo,
                      onTap: controller.pickLogo,
                      currentImageUrl: widget.isEdit
                          ? controller.currentTheme.value?.logoUrl
                          : null,
                    ),
                    const SizedBox(height: 24),

                    // Favicon upload
                    _buildImageUploadSection(
                      title: 'Favicon',
                      subtitle: 'Unggah favicon Anda (disarankan: 32x32px)',
                      selectedFile: controller.selectedFavicon,
                      onTap: controller.pickFavicon,
                      currentImageUrl: widget.isEdit
                          ? controller.currentTheme.value?.faviconUrl
                          : null,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Divider(),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Batal'),
                ),
                const SizedBox(width: 16),
                Obx(() => ElevatedButton(
                      onPressed: _getButtonState(controller, widget.isEdit)
                          ? null
                          : () async {
                              if (widget.isEdit) {
                                final currentTheme =
                                    controller.currentTheme.value;
                                if (currentTheme != null) {
                                  await controller.updateTheme(currentTheme.id);
                                }
                              } else {
                                await controller.createTheme();
                              }
                            },
                      child: _getButtonState(controller, widget.isEdit)
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(widget.isEdit ? 'Edit Tema' : 'Buat Tema'),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool required = false,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        hintText: hint,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildColorField(ThemeController controller) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller.primaryColorController,
            decoration: InputDecoration(
              labelText: 'Warna *',
              hintText: '#1e1e2f',
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            onChanged: (value) {
              // Trigger rebuild when color changes
              setState(() {});
            },
          ),
        ),
        const SizedBox(width: 16),
        Builder(builder: (context) {
          final colorString = controller.primaryColorController.text;
          final color = _parseColor(colorString);

          return InkWell(
            onTap: () => _showColorPicker(controller, color),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.palette,
                color: Colors.white,
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildImageUploadSection({
    required String title,
    required String subtitle,
    required Rx selectedFile,
    required VoidCallback onTap,
    String? currentImageUrl,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => InkWell(
              onTap: onTap,
              child: Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey[300]!,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[50],
                ),
                child: _buildImagePreview(selectedFile.value, currentImageUrl),
              ),
            )),
      ],
    );
  }

  Widget _buildImagePreview(dynamic selectedFile, String? currentImageUrl) {
    if (selectedFile != null) {
      // Show selected file
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          selectedFile,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildUploadPlaceholder();
          },
        ),
      );
    } else if (currentImageUrl != null && currentImageUrl.isNotEmpty) {
      // Show current image from URL
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(
          _decodeBase64Image(currentImageUrl),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildUploadPlaceholder();
          },
        ),
      );
    } else {
      // Show upload placeholder
      return _buildUploadPlaceholder();
    }
  }

  Widget _buildUploadPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.cloud_upload_outlined,
          size: 48,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 8),
        Text(
          'Klik untuk mengunggah gambar',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'JPG, PNG, GIF (max 5MB)',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _showColorPicker(ThemeController controller, Color currentColor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Warna'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Basic colors
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Colors.red,
                  Colors.pink,
                  Colors.purple,
                  Colors.deepPurple,
                  Colors.indigo,
                  Colors.blue,
                  Colors.lightBlue,
                  Colors.cyan,
                  Colors.teal,
                  Colors.green,
                  Colors.lightGreen,
                  Colors.lime,
                  Colors.yellow,
                  Colors.amber,
                  Colors.orange,
                  Colors.deepOrange,
                  Colors.brown,
                  Colors.grey,
                  Colors.blueGrey,
                  Colors.black,
                ]
                    .map((color) => GestureDetector(
                          onTap: () {
                            controller.primaryColorController.text =
                                '#${color.value.toRadixString(16).substring(2)}';
                            setState(() {}); // Rebuild to show new color
                            Get.back();
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey,
                                width: 1,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      if (colorString.isEmpty) return Colors.blue;

      // Remove # if present and add proper prefix
      String cleanColor = colorString.replaceFirst('#', '');
      if (cleanColor.length == 6) {
        return Color(int.parse('FF$cleanColor', radix: 16));
      }
      return Colors.blue;
    } catch (e) {
      return Colors.blue; // Default color
    }
  }

  Uint8List _decodeBase64Image(String base64String) {
    try {
      // Remove data URL prefix if present
      if (base64String.contains(',')) {
        base64String = base64String.split(',')[1];
      }
      return Uint8List.fromList(base64Decode(base64String));
    } catch (e) {
      return Uint8List(0);
    }
  }

  bool _getButtonState(ThemeController controller, bool isEdit) {
    return isEdit ? controller.isUpdating.value : controller.isCreating.value;
  }
}
