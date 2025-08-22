import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/controller/theme/theme_controller.dart';
import 'package:pos/models/theme/theme_model.dart' as ThemeModel;
import 'package:pos/screens/theme/theme_form_dialog.dart';

class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      init: ThemeController(),
      builder: (controller) {
        return Scaffold(
          body: Column(
            children: [
              // Theme list
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value && controller.themes.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading themes...'),
                        ],
                      ),
                    );
                  }

                  if (controller.themes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.palette_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No themes found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create your first theme to get started',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () =>
                                _showThemeForm(context, controller),
                            icon: const Icon(Icons.add),
                            label: const Text('Create Theme'),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: controller.refreshThemes,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.themes.length +
                          (controller.hasMore.value ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= controller.themes.length) {
                          // Load more indicator
                          controller.loadMore();
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final theme = controller.themes[index];
                        return _buildThemeCard(context, controller, theme);
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                heroTag: "refresh",
                mini: true,
                onPressed: controller.refreshThemes,
                tooltip: 'Refresh',
                backgroundColor: Colors.grey[600],
                child: const Icon(Icons.refresh, color: Colors.white),
              ),
              const SizedBox(height: 12),
              FloatingActionButton(
                heroTag: "add",
                onPressed: () => _showThemeForm(context, controller),
                tooltip: 'Add Theme',
                backgroundColor: Colors.blue,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeCard(
    BuildContext context,
    ThemeController controller,
    ThemeModel.Theme theme,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Theme preview circle
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _parseColor(theme.primaryColor),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  child: theme.logoUrl.isNotEmpty
                      ? ClipOval(
                          child: Image.memory(
                            _decodeBase64Image(theme.logoUrl),
                            width: 46,
                            height: 46,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.palette,
                                color: Colors.white,
                                size: 24,
                              );
                            },
                          ),
                        )
                      : const Icon(
                          Icons.palette,
                          color: Colors.white,
                          size: 24,
                        ),
                ),
                const SizedBox(width: 16),

                // Theme info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              theme.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (theme.isDefault)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Default',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Page Title: ${theme.pageTitle}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            'Color: ${theme.primaryColor}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: _parseColor(theme.primaryColor),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Actions menu
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        controller.prepareEdit(theme);
                        _showThemeForm(context, controller, isEdit: true);
                        break;
                      case 'set_default':
                        if (!theme.isDefault) {
                          controller.setDefaultTheme(theme.id, theme.name);
                        }
                        break;
                      case 'delete':
                        controller.deleteTheme(theme.id, theme.name);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 12),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    if (!theme.isDefault)
                      const PopupMenuItem(
                        value: 'set_default',
                        child: Row(
                          children: [
                            Icon(Icons.star, size: 20),
                            SizedBox(width: 12),
                            Text('Set as Default'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red, size: 20),
                          SizedBox(width: 12),
                          Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeForm(
    BuildContext context,
    ThemeController controller, {
    bool isEdit = false,
  }) {
    showDialog(
      context: context,
      builder: (context) => ThemeFormDialog(isEdit: isEdit),
    );
  }

  Color _parseColor(String colorString) {
    try {
      if (colorString.isEmpty) return Colors.blue;
      return Color(
        int.parse(colorString.replaceFirst('#', '0xFF')),
      );
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
}
