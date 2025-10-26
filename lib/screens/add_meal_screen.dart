import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../services/api_service.dart';
import '../models/food_item.dart';

class AddMealScreen extends StatefulWidget {
  const AddMealScreen({super.key});

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final _foodNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  DateTime _selectedDateTime = DateTime.now();
  FoodItem? _selectedFoodItem;
  bool _isSubmitting = false;

  Future<void> _submitMeal() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFoodItem == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Please select a food item")));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ApiService.addMeal(
        foodItemId: _selectedFoodItem!.id,
        quantityGrams: double.parse(_quantityController.text),
        consumedAt: _selectedDateTime,
      );
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Meal added successfully!")));
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to add meal: $e")));
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (time == null) return;

    setState(() {
      _selectedDateTime =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Meal Log"),
        backgroundColor: Colors.lightGreen.shade600,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Food Name Field
                TypeAheadField<FoodItem>(
                  controller: _foodNameController,
                  suggestionsCallback: (pattern) async {
                    if (pattern.isEmpty) return [];
                    return await ApiService.searchFoodItems(pattern);
                  },
                  itemBuilder: (context, suggestion) =>
                      ListTile(title: Text(suggestion.name)),
                  onSelected: (suggestion) {
                    setState(() {
                      _selectedFoodItem = suggestion;
                      _foodNameController.text = suggestion.name;
                    });
                  },
                  builder: (context, controller, focusNode) {
                    return TextFormField(
                      controller: _foodNameController,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        labelText: "Food Item",
                        prefixIcon: const Icon(Icons.fastfood),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (val) =>
                          _selectedFoodItem == null ? "Select a food item" : null,
                      onChanged: (_) => setState(() => _selectedFoodItem = null),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Quantity Field
                TextFormField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Quantity (grams)",
                    prefixIcon: const Icon(Icons.scale),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? "Enter quantity" : null,
                ),

                const SizedBox(height: 16),

                // DateTime Picker
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today, color: Colors.blue),
                  title: Text(
                    "Consumed At: ${_selectedDateTime.toLocal().toString().substring(0, 16)}",
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: _pickDateTime,
                  ),
                ),

                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(_isSubmitting ? "Saving..." : "Save Meal Log"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.lightGreen.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isSubmitting ? null : _submitMeal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.green.shade50,
    );
  }
}
