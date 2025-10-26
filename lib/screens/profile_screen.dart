import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/user_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = true;
  bool isEditing = false;

  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;

  String? _selectedGender;
  String? _selectedGoal;
  String? _selectedDietType;
  String? _selectedAllergies;

  final List<String> goals = ['Lose Weight', 'Maintain Weight', 'Gain Muscle'];
  final List<String> dietTypes = ['Balanced', 'Vegan', 'Vegetarian', 'Keto', 'No Preference'];
  final List<String> allergies = ['None', 'Dairy', 'Gluten', 'Nuts', 'Seafood'];
  final List<String> genders = ['None', 'Male', 'Female'];

  String? username;

  @override
  void initState() {
    super.initState();
    _ageController = TextEditingController();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      username = await ApiService.getLoggedInUsername();
      if (username == null) throw Exception("No logged-in user found");

      final profile = await ApiService.getUserProfile(username!);
      setState(() {
        _ageController.text = profile.age?.toString() ?? '';
        _heightController.text = profile.height?.toString() ?? '';
        _weightController.text = profile.weight?.toString() ?? '';
        _selectedGender = profile.gender ?? genders.first;
        _selectedGoal = profile.goal ?? goals.first;
        _selectedDietType = profile.dietType ?? dietTypes.first;
        _selectedAllergies = profile.allergies ?? allergies.first;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading profile: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final updatedProfile = UserProfile(
      age: int.tryParse(_ageController.text),
      height: double.tryParse(_heightController.text),
      weight: double.tryParse(_weightController.text),
      gender: _selectedGender,
      goal: _selectedGoal,
      dietType: _selectedDietType,
      allergies: _selectedAllergies,
    );

    final username = await ApiService.getLoggedInUsername();
    if (username == null) throw Exception("No logged-in user found");

    await ApiService.updateUserProfile(username, updatedProfile);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Profile updated successfully!')),
    );
    setState(() => isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightGreen.shade50,
      appBar: AppBar(
        backgroundColor: Colors.lightGreen.shade600,
        elevation: 0,
        title: const Text("My Profile 🌿", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (isEditing) {
                _saveProfile();
              } else {
                setState(() => isEditing = true);
              }
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // --- Header Card with Username ---
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.lightGreen.shade100,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.shade200,
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person, size: 45, color: Colors.green),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              username ?? "User",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedGoal ?? "No goal set",
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildIconTextField("Age", Icons.cake, _ageController, isEditing),
                        _buildIconTextField("Height (cm)", Icons.height, _heightController, isEditing),
                        _buildIconTextField("Weight (kg)", Icons.monitor_weight, _weightController, isEditing),
                        _buildDropdownField("Gender", Icons.person, genders, _selectedGender, (val) => _selectedGender = val),
                        _buildDropdownField("Goal", Icons.flag, goals, _selectedGoal, (val) => _selectedGoal = val),
                        _buildDropdownField("Diet Type", Icons.restaurant_menu, dietTypes, _selectedDietType, (val) => _selectedDietType = val),
                        _buildDropdownField("Allergies", Icons.warning_amber_rounded, allergies, _selectedAllergies, (val) => _selectedAllergies = val),
                        const SizedBox(height: 25),

                        // --- Save Button ---
                        ElevatedButton.icon(
                          icon: const Icon(Icons.save, color: Colors.white),
                          label: const Text("Save Profile", style: TextStyle(fontSize: 16, color: Colors.white)),
                          onPressed: isEditing ? _saveProfile : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildIconTextField(String label, IconData icon, TextEditingController controller, bool editable) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        enabled: editable,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.green.shade700),
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        ),
        validator: (value) => (value == null || value.isEmpty) ? 'Enter $label' : null,
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    IconData icon,
    List<String> items,
    String? currentValue,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InputDecorator(
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.green.shade700),
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: currentValue,
            items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
            onChanged: isEditing ? (val) => setState(() => onChanged(val)) : null,
          ),
        ),
      ),
    );
  }
}
