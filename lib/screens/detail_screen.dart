import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../database/database_helper.dart';
import '../models/destination_model.dart';

class DetailScreen extends StatefulWidget {
  final Destination destination;

  const DetailScreen({super.key, required this.destination});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;

  bool _isEditing = false;
  TimeOfDay? _openTime;
  TimeOfDay? _closeTime;
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.destination.name);
    _descriptionController =
        TextEditingController(text: widget.destination.description);
    _latitudeController =
        TextEditingController(text: widget.destination.latitude.toString());
    _longitudeController =
        TextEditingController(text: widget.destination.longitude.toString());
    _imagePath = widget.destination.imagePath;

    // Parse open and close time
    if (widget.destination.openTime != null) {
      final parts = widget.destination.openTime!.split(':');
      _openTime = TimeOfDay(
          hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
    if (widget.destination.closeTime != null) {
      final parts = widget.destination.closeTime!.split(':');
      _closeTime = TimeOfDay(
          hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _imagePath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih gambar: $e')),
        );
      }
    }
  }

  Future<void> _selectTime(BuildContext context, bool isOpenTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isOpenTime) {
          _openTime = picked;
        } else {
          _closeTime = picked;
        }
      });
    }
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '';
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _updateDestination() async {
    if (_formKey.currentState!.validate()) {
      try {
        final updatedDestination = widget.destination.copyWith(
          name: _nameController.text,
          description: _descriptionController.text,
          latitude: double.parse(_latitudeController.text),
          longitude: double.parse(_longitudeController.text),
          openTime: _formatTime(_openTime),
          closeTime: _formatTime(_closeTime),
          imagePath: _imagePath,
        );

        await DatabaseHelper.instance.update(updatedDestination);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Destinasi berhasil diperbarui!'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            _isEditing = false;
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal memperbarui: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Destinasi' : 'Detail Destinasi'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _updateDestination,
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Section
              GestureDetector(
                onTap: _isEditing ? _pickImage : null,
                child: Stack(
                  children: [
                    if (_imagePath != null && _imagePath!.isNotEmpty)
                      Image.file(
                        File(_imagePath!),
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 250,
                            color: Colors.grey[300],
                            child:
                                const Icon(Icons.image_not_supported, size: 60),
                          );
                        },
                      )
                    else
                      Container(
                        height: 250,
                        color: Colors.teal[100],
                        child: Center(
                          child: Icon(Icons.location_on,
                              size: 80, color: Colors.teal[700]),
                        ),
                      ),
                    if (_isEditing)
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: FloatingActionButton.small(
                          onPressed: _pickImage,
                          backgroundColor: Colors.white,
                          child: const Icon(Icons.camera_alt, color: Colors.teal),
                        ),
                      ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Nama
                      TextFormField(
                        controller: _nameController,
                        enabled: _isEditing,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _isEditing ? Colors.black : Colors.black87,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Nama Destinasi',
                          border: _isEditing
                              ? const OutlineInputBorder()
                              : InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama destinasi harus diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Deskripsi
                      TextFormField(
                        controller: _descriptionController,
                        enabled: _isEditing,
                        maxLines: _isEditing ? 4 : null,
                        style: TextStyle(
                          fontSize: 16,
                          color: _isEditing ? Colors.black : Colors.grey[700],
                        ),
                        decoration: InputDecoration(
                          labelText: 'Deskripsi',
                          border: _isEditing
                              ? const OutlineInputBorder()
                              : InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Deskripsi harus diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Koordinat
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _latitudeController,
                              enabled: _isEditing,
                              decoration: InputDecoration(
                                labelText: 'Latitude',
                                prefixIcon: const Icon(Icons.gps_fixed),
                                border: _isEditing
                                    ? const OutlineInputBorder()
                                    : const UnderlineInputBorder(),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true, signed: true),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Invalid';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _longitudeController,
                              enabled: _isEditing,
                              decoration: InputDecoration(
                                labelText: 'Longitude',
                                prefixIcon: const Icon(Icons.gps_fixed),
                                border: _isEditing
                                    ? const OutlineInputBorder()
                                    : const UnderlineInputBorder(),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(
                                  decimal: true, signed: true),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Invalid';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Jam Operasional
                      const Text(
                        'Jam Operasional',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _isEditing
                                ? OutlinedButton.icon(
                                    onPressed: () => _selectTime(context, true),
                                    icon: const Icon(Icons.access_time),
                                    label: Text(
                                      _openTime != null
                                          ? _formatTime(_openTime)
                                          : 'Jam Buka',
                                    ),
                                  )
                                : Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.access_time, size: 20),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Buka: ${_formatTime(_openTime)}',
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _isEditing
                                ? OutlinedButton.icon(
                                    onPressed: () => _selectTime(context, false),
                                    icon: const Icon(Icons.access_time),
                                    label: Text(
                                      _closeTime != null
                                          ? _formatTime(_closeTime)
                                          : 'Jam Tutup',
                                    ),
                                  )
                                : Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.access_time, size: 20),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Tutup: ${_formatTime(_closeTime)}',
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }
}