import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../database/database_helper.dart';
import '../models/destination_model.dart';

class AddDestinationScreen extends StatefulWidget {
  const AddDestinationScreen({super.key});

  @override
  State<AddDestinationScreen> createState() => _AddDestinationScreenState();
}

class _AddDestinationScreenState extends State<AddDestinationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  
  TimeOfDay? _openTime;
  TimeOfDay? _closeTime;
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();

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

  Future<void> _saveDestination() async {
    if (_formKey.currentState!.validate()) {
      try {
        final destination = Destination(
          name: _nameController.text,
          description: _descriptionController.text,
          latitude: double.parse(_latitudeController.text),
          longitude: double.parse(_longitudeController.text),
          openTime: _formatTime(_openTime),
          closeTime: _formatTime(_closeTime),
          imagePath: _imagePath,
          createdAt: DateTime.now().toIso8601String(),
        );

        await DatabaseHelper.instance.create(destination);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Destinasi berhasil ditambahkan!'),
              backgroundColor: Colors.green,
            ),
          );

          // Reset form
          _formKey.currentState!.reset();
          _nameController.clear();
          _descriptionController.clear();
          _latitudeController.clear();
          _longitudeController.clear();
          setState(() {
            _openTime = null;
            _closeTime = null;
            _imagePath = null;
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menyimpan: $e'),
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
        title: const Text('Tambah Destinasi'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image Picker
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[400]!),
                    ),
                    child: _imagePath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(_imagePath!),
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate,
                                  size: 60, color: Colors.grey[600]),
                              const SizedBox(height: 8),
                              Text(
                                'Tap untuk pilih foto',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // Nama Destinasi
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nama Destinasi',
                    prefixIcon: const Icon(Icons.place),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
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
                  decoration: InputDecoration(
                    labelText: 'Deskripsi',
                    prefixIcon: const Icon(Icons.description),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Deskripsi harus diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Latitude
                TextFormField(
                  controller: _latitudeController,
                  decoration: InputDecoration(
                    labelText: 'Latitude',
                    prefixIcon: const Icon(Icons.gps_fixed),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    hintText: 'Contoh: -6.200000',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true, signed: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Latitude harus diisi';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Latitude harus berupa angka';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Longitude
                TextFormField(
                  controller: _longitudeController,
                  decoration: InputDecoration(
                    labelText: 'Longitude',
                    prefixIcon: const Icon(Icons.gps_fixed),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    hintText: 'Contoh: 106.816666',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true, signed: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Longitude harus diisi';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Longitude harus berupa angka';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Waktu Buka dan Tutup
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _selectTime(context, true),
                        icon: const Icon(Icons.access_time),
                        label: Text(
                          _openTime != null
                              ? 'Buka: ${_formatTime(_openTime)}'
                              : 'Jam Buka',
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _selectTime(context, false),
                        icon: const Icon(Icons.access_time),
                        label: Text(
                          _closeTime != null
                              ? 'Tutup: ${_formatTime(_closeTime)}'
                              : 'Jam Tutup',
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Tombol Simpan
                ElevatedButton(
                  onPressed: _saveDestination,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Simpan Destinasi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
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