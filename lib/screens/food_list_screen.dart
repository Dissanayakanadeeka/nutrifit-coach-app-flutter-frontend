import 'package:flutter/material.dart';
import '../models/food_item.dart';
import '../services/api_service.dart';

class FoodListScreen extends StatefulWidget {
  const FoodListScreen({super.key});

  @override
  State<FoodListScreen> createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> allFoods = [];
  List<Map<String, dynamic>> filteredFoods = [];
  String selectedSort = 'None';
  bool isLoading = true;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _fetchFoods();
  }

  Future<void> _fetchFoods() async {
    try {
      List<FoodItem> apiFoods = await ApiService.getAllFoodItems();
      setState(() {
        allFoods = apiFoods
            .map((f) => {
                  'name': f.name,
                  'calories': f.calories,
                  'protein': f.protein,
                  'carbs': f.carbs,
                  'fat': f.fat,
                })
            .toList();
        filteredFoods = List.from(allFoods);
        isLoading = false;
      });
      _controller.forward();
    } catch (e) {
      print("Error loading foods: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // --- FILTER ---
  void _filterFoods(String query) {
    setState(() {
      filteredFoods = allFoods
          .where((food) =>
              food['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
      _sortFoods();
    });
  }

  // --- SORT ---
  void _sortFoods() {
    setState(() {
      if (selectedSort == 'Highest Protein') {
        filteredFoods.sort((a, b) => b['protein'].compareTo(a['protein']));
      } else if (selectedSort == 'Lowest Calories') {
        filteredFoods.sort((a, b) => a['calories'].compareTo(b['calories']));
      } else if (selectedSort == 'Highest Calories') {
        filteredFoods.sort((a, b) => b['calories'].compareTo(a['calories']));
      } else if (selectedSort == 'Lowest Fat') {
        filteredFoods.sort((a, b) => a['fat'].compareTo(b['fat']));
      } else {
        filteredFoods = allFoods
            .where((food) => food['name']
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen.shade600,
        elevation: 0,
        
        title: const Text("Food List", style: TextStyle(fontWeight: FontWeight.bold)),
        
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
                  colors: [
        Color(0xFFE8F5E9), // light green shade
        Color(0xFFF1F8E9), // slightly different tone for subtle gradient
      ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        

                        // --- Search Field ---
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3))
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search, color: Colors.green),
                              hintText: 'Search food...',
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            ),
                            onChanged: _filterFoods,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // --- Sort Dropdown ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Sort by:',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54),
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedSort,
                                  icon: const Icon(Icons.arrow_drop_down),
                                  items: const [
                                    DropdownMenuItem(
                                        value: 'None', child: Text('None')),
                                    DropdownMenuItem(
                                        value: 'Highest Protein',
                                        child: Text('Highest Protein')),
                                    DropdownMenuItem(
                                        value: 'Lowest Calories',
                                        child: Text('Lowest Calories')),
                                    DropdownMenuItem(
                                        value: 'Highest Calories',
                                        child: Text('Highest Calories')),
                                    DropdownMenuItem(
                                        value: 'Lowest Fat',
                                        child: Text('Lowest Fat')),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      selectedSort = value!;
                                      _sortFoods();
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // --- Food List ---
                        Expanded(
                          child: filteredFoods.isEmpty
                              ? const Center(
                                  child: Text(
                                    "No foods found 😢",
                                    style: TextStyle(color: Colors.white, fontSize: 18),
                                  ),
                                )
                              : ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: filteredFoods.length,
                                  itemBuilder: (context, index) {
                                    final food = filteredFoods[index];
                                    return TweenAnimationBuilder(
                                      duration:
                                          Duration(milliseconds: 100 + (index * 50)),
                                      tween: Tween<double>(begin: 0, end: 1),
                                      builder: (context, value, child) {
                                        return Opacity(
                                          opacity: value,
                                          child: Transform.translate(
                                            offset: Offset(0, 50 * (1 - value)),
                                            child: child,
                                          ),
                                        );
                                      },
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16)),
                                        elevation: 4,
                                        margin:
                                            const EdgeInsets.symmetric(vertical: 6),
                                        child: ListTile(
                                          title: Text(
                                            food['name'],
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18),
                                          ),
                                          subtitle: Padding(
                                            padding: const EdgeInsets.only(top: 6.0),
                                            child: Wrap(
                                              spacing: 8,
                                              runSpacing: 4,
                                              children: [
                                                _nutrientChip(
                                                    "${food['calories']} kcal",
                                                    Colors.orange),
                                                _nutrientChip(
                                                    "${food['protein']}g protein",
                                                    Colors.green),
                                                _nutrientChip(
                                                    "${food['carbs']}g carbs",
                                                    Colors.blue),
                                                _nutrientChip(
                                                    "${food['fat']}g fat",
                                                    Colors.pink),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  // Nutrient badge style
  Widget _nutrientChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label,
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
