import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';

class HealthScreen extends StatefulWidget {
  const HealthScreen({Key? key}) : super(key: key);
  
  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final List<String> _uploadedFiles = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _conditionsController = TextEditingController();
  final TextEditingController _medicationsController = TextEditingController();
  final TextEditingController _implantsController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _emergencyContactController = TextEditingController();
  
  String? _bloodGroup;
  String? _gender;
  final List<String> _selectedAllergies = [];
  bool _isDataSaved = false;
  Map<String, dynamic>? _savedHealthData;
  
  final List<String> _bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];
  
  final List<String> _genders = ['Male', 'Female', 'Other', 'Prefer not to say'];
  
  final List<String> _commonAllergies = [
    'Penicillin', 'Peanuts', 'Shellfish', 'Latex', 
    'Aspirin', 'Iodine', 'Eggs', 'Pollen', 'Dust', 'Sulfa'
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  Future<void> _uploadDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: true,
      );
      
      if (result != null) {
        setState(() {
          for (var file in result.files) {
            if (!_uploadedFiles.contains(file.name)) {
              _uploadedFiles.add(file.name);
            }
          }
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.files.length} document(s) uploaded successfully'),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading file: ${e.message}'),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _generatePDF() async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Container(
              padding: const pw.EdgeInsets.only(bottom: 20),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(width: 2, color: PdfColors.blue),
                ),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'HEALTH PROFILE REPORT',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue800,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Generated on: ${DateTime.now().toString().split('.')[0]}',
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
            ),
            
            pw.SizedBox(height: 20),
            
            // Personal Information
            _buildPDFSection('Personal Information', [
              'Name: ${_nameController.text.isEmpty ? "Not specified" : _nameController.text}',
              'Age: ${_ageController.text.isEmpty ? "Not specified" : _ageController.text}',
              'Gender: ${_gender ?? "Not specified"}',
              'Blood Group: ${_bloodGroup ?? "Not specified"}',
              'Emergency Contact: ${_emergencyContactController.text.isEmpty ? "Not specified" : _emergencyContactController.text}',
            ]),
            
            pw.SizedBox(height: 15),
            
            // Allergies
            _buildPDFSection('Known Allergies', [
              _selectedAllergies.isEmpty ? 'No allergies specified' : _selectedAllergies.join(', '),
            ]),
            
            pw.SizedBox(height: 15),
            
            // Medical Information
            _buildPDFSection('Chronic Conditions', [
              _conditionsController.text.isEmpty ? 'No chronic conditions specified' : _conditionsController.text,
            ]),
            
            pw.SizedBox(height: 15),
            
            _buildPDFSection('Ongoing Medications', [
              _medicationsController.text.isEmpty ? 'No medications specified' : _medicationsController.text,
            ]),
            
            pw.SizedBox(height: 15),
            
            _buildPDFSection('Medical Implants/Devices', [
              _implantsController.text.isEmpty ? 'No implants/devices specified' : _implantsController.text,
            ]),
            
            pw.SizedBox(height: 15),
            
            _buildPDFSection('Emergency Notes', [
              _notesController.text.isEmpty ? 'No emergency notes specified' : _notesController.text,
            ]),
            
            pw.SizedBox(height: 15),
            
            // Uploaded Documents
            _buildPDFSection('Uploaded Documents', [
              _uploadedFiles.isEmpty ? 'No documents uploaded' : _uploadedFiles.join('\n'),
            ]),
            
            pw.SizedBox(height: 30),
            
            // Footer
            pw.Container(
              padding: const pw.EdgeInsets.only(top: 20),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(width: 1, color: PdfColors.grey400),
                ),
              ),
              child: pw.Column(
                children: [
                  pw.Text(
                    'IMPORTANT: This document contains sensitive medical information.',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.red,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'Keep this document secure and share only with authorized medical personnel.',
                    style: pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  pw.Widget _buildPDFSection(String title, List<String> content) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue700,
            ),
          ),
          pw.SizedBox(height: 8),
          ...content.map((text) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4),
            child: pw.Text(
              text,
              style: const pw.TextStyle(fontSize: 11),
            ),
          )),
        ],
      ),
    );
  }

  void _saveHealthData() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      final healthData = {
        'name': _nameController.text,
        'age': _ageController.text,
        'gender': _gender,
        'bloodGroup': _bloodGroup,
        'allergies': _selectedAllergies,
        'conditions': _conditionsController.text,
        'medications': _medicationsController.text,
        'implants': _implantsController.text,
        'notes': _notesController.text,
        'emergencyContact': _emergencyContactController.text,
        'uploadedFiles': _uploadedFiles,
        'savedAt': DateTime.now().toIso8601String(),
      };
      
      setState(() {
        _isDataSaved = true;
        _savedHealthData = healthData;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Health profile saved successfully!'),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: Colors.green[600],
          duration: const Duration(seconds: 3),
        ),
      );
      
      HapticFeedback.mediumImpact();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _conditionsController.dispose();
    _medicationsController.dispose();
    _implantsController.dispose();
    _notesController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 140,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                title: Text(
                  'Health Profile',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF1565C0), const Color(0xFF0D47A1)]
                          : [const Color(0xFF42A5F5), const Color(0xFF1976D2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Card
                      if (_isDataSaved) _buildStatusCard(theme),
                      
                      // Personal Information Section
                      _buildModernSection(
                        'Personal Information',
                        Icons.person,
                        theme,
                        [
                          _buildTextField(
                            controller: _nameController,
                            label: 'Full Name',
                            hint: 'Enter your full name',
                            icon: Icons.person_outline,
                            validator: (value) => value?.isEmpty == true ? 'Name is required' : null,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _ageController,
                                  label: 'Age',
                                  hint: 'Enter age',
                                  icon: Icons.cake_outlined,
                                  keyboardType: TextInputType.number,
                                  validator: (value) => value?.isEmpty == true ? 'Age is required' : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildDropdown(
                                  value: _gender,
                                  label: 'Gender',
                                  hint: 'Select gender',
                                  items: _genders,
                                  onChanged: (value) => setState(() => _gender = value),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _emergencyContactController,
                            label: 'Emergency Contact',
                            hint: 'Enter emergency contact number',
                            icon: Icons.emergency,
                            keyboardType: TextInputType.phone,
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Medical Information Section
                      _buildModernSection(
                        'Medical Information',
                        Icons.medical_services,
                        theme,
                        [
                          _buildDropdown(
                            value: _bloodGroup,
                            label: 'Blood Group',
                            hint: 'Select your blood type',
                            items: _bloodGroups,
                            onChanged: (value) => setState(() => _bloodGroup = value),
                          ),
                          const SizedBox(height: 24),
                          
                          Text(
                            'Known Allergies',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildAllergyChips(theme),
                          const SizedBox(height: 24),
                          
                          _buildTextField(
                            controller: _conditionsController,
                            label: 'Chronic Conditions',
                            hint: 'e.g., Diabetes, Asthma, Hypertension',
                            icon: Icons.monitor_heart,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          
                          _buildTextField(
                            controller: _medicationsController,
                            label: 'Current Medications',
                            hint: 'e.g., Metformin 500mg, Inhaler',
                            icon: Icons.medication,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          
                          _buildTextField(
                            controller: _implantsController,
                            label: 'Medical Implants/Devices',
                            hint: 'e.g., Pacemaker, Hearing Aid',
                            icon: Icons.health_and_safety,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 16),
                          
                          _buildTextField(
                            controller: _notesController,
                            label: 'Emergency Notes',
                            hint: 'Important information for medical personnel',
                            icon: Icons.note_alt,
                            maxLines: 4,
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Document Upload Section
                      _buildModernSection(
                        'Medical Documents',
                        Icons.attach_file,
                        theme,
                        [
                          Text(
                            'Upload medical reports, prescriptions, or test results',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          _buildUploadButton(theme),
                          
                          if (_uploadedFiles.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            ..._uploadedFiles.map((file) => _buildFileItem(file, theme)),
                          ],
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(
                              'Save Profile',
                              Icons.save,
                              _saveHealthData,
                              theme.colorScheme.primary,
                              Colors.white,
                            ),
                          ),
                          if (_isDataSaved) ...[
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildActionButton(
                                'Download PDF',
                                Icons.download,
                                _generatePDF,
                                theme.colorScheme.secondary,
                                Colors.white,
                              ),
                            ),
                          ],
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Safety Tips
                      _buildSafetyTips(theme),
                      
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[50]!, Colors.green[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[600],
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profile Saved Successfully',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.green[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your health information is ready for emergencies',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernSection(String title, IconData icon, ThemeData theme, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.onPrimaryContainer,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String label,
    required String hint,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildAllergyChips(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _commonAllergies.map((allergy) {
        final isSelected = _selectedAllergies.contains(allergy);
        return FilterChip(
          label: Text(
            allergy,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isSelected 
                ? theme.colorScheme.onPrimaryContainer 
                : theme.colorScheme.onSurface,
            ),
          ),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedAllergies.add(allergy);
              } else {
                _selectedAllergies.remove(allergy);
              }
            });
          },
          selectedColor: theme.colorScheme.primaryContainer,
          backgroundColor: theme.colorScheme.surface,
          checkmarkColor: theme.colorScheme.onPrimaryContainer,
          side: BorderSide(
            color: isSelected 
              ? theme.colorScheme.primary 
              : theme.colorScheme.outline,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUploadButton(ThemeData theme) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.primary,
          width: 2,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _uploadDocument,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Upload Medical Documents',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileItem(String fileName, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.insert_drive_file,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              fileName,
              style: theme.textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: Colors.red[600],
              size: 20,
            ),
            onPressed: () => setState(() => _uploadedFiles.remove(fileName)),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String text,
    IconData icon,
    VoidCallback onPressed,
    Color backgroundColor,
    Color textColor,
  ) {
    return Container(
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: textColor),
        label: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          shadowColor: backgroundColor.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildSafetyTips(ThemeData theme) {
    final tips = [
      {
        'title': 'Quick Access',
        'content': '65% of patients with accessible health info receive 40% faster treatment',
        'icon': Icons.speed,
        'color': Colors.blue,
      },
      {
        'title': 'Stay Updated',
        'content': 'Regular updates ensure accurate emergency response and better care',
        'icon': Icons.update,
        'color': Colors.green,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Health Tips',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ...tips.map((tip) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: (tip['color'] as Color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (tip['color'] as Color).withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: tip['color'] as Color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  tip['icon'] as IconData,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tip['title'] as String,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: tip['color'] as Color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tip['content'] as String,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }
}