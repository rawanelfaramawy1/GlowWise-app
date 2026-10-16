import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class SkincareSchedulePage extends StatefulWidget {
  const SkincareSchedulePage({super.key});

  @override
  State<SkincareSchedulePage> createState() => _SkincareSchedulePageState();
}

class _SkincareSchedulePageState extends State<SkincareSchedulePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;

  final Map<String, bool> _morningRoutine = {
    'Cleanse': false,
    'Tone': false,
    'Vitamin C Serum': false,
    'Moisturize': false,
    'Sunscreen': false,
  };

  final Map<String, bool> _eveningRoutine = {
    'Makeup Removal': false,
    'Cleanse': false,
    'Tone': false,
    'Retinol Serum': false,
    'Night Cream': false,
  };

  final List<Map<String, dynamic>> _upcomingAppointments = [
    {
      'type': 'Facial Cleansing',
      'date': DateTime.now().add(const Duration(days: 5)),
      'time': '10:00 AM',
      'icon': Icons.face_retouching_natural,
    },
    {
      'type': 'Dermatologist',
      'date': DateTime.now().add(const Duration(days: 10)),
      'time': '2:30 PM',
      'icon': Icons.medical_services,
    },
    {
      'type': 'HydraFacial',
      'date': DateTime.now().add(const Duration(days: 15)),
      'time': '11:00 AM',
      'icon': Icons.water_drop,
    },
  ];

  final TextEditingController _reviewController = TextEditingController();
  String _selectedMood = 'Great';
  final List<String> _usedProducts = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  void _showAddProductDialog() {
    final TextEditingController productController = TextEditingController();
    final TextEditingController expiryController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Add New Product',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6A387A),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: productController,
                    decoration: InputDecoration(
                      labelText: 'Product Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: expiryController,
                    decoration: InputDecoration(
                      labelText: 'Expiry Date',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 730)),
                      );
                      if (picked != null) {
                        expiryController.text = picked.toString().split(' ')[0];
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          if (productController.text.isNotEmpty) {
                            setState(() {
                              _usedProducts.add(productController.text);
                            });
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Product added successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6A387A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showDailyReviewDialog() {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Daily Skin Review',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6A387A),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _moodOption('Great', Icons.sentiment_very_satisfied),
                      _moodOption('Good', Icons.sentiment_satisfied),
                      _moodOption('Okay', Icons.sentiment_neutral),
                      _moodOption('Bad', Icons.sentiment_dissatisfied),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _reviewController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'How did your skin feel today?',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Save the review
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Review saved successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A387A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Save Review'),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _moodOption(String mood, IconData icon) {
    final isSelected = _selectedMood == mood;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMood = mood;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6A387A) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.grey,
          size: 30,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F9),
      appBar: AppBar(
        title: const Text('Skincare Schedule'),
        backgroundColor: const Color(0xFF6A387A),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.schedule), text: 'Routine'),
            Tab(icon: Icon(Icons.calendar_today), text: 'Calendar'),
            Tab(icon: Icon(Icons.assignment), text: 'Reviews'),
            Tab(icon: Icon(Icons.medical_services), text: 'Products'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRoutineTab(),
          _buildCalendarTab(),
          _buildReviewsTab(),
          _buildProductsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            // Add routine
          } else if (_tabController.index == 1) {
            // Add appointment
          } else if (_tabController.index == 2) {
            _showDailyReviewDialog();
          } else {
            _showAddProductDialog();
          }
        },
        backgroundColor: const Color(0xFF6A387A),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildRoutineTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRoutineSection('Morning Routine', _morningRoutine),
          const SizedBox(height: 24),
          _buildRoutineSection('Evening Routine', _eveningRoutine),
          const SizedBox(height: 24),
          const Text(
            'Upcoming Appointments',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6A387A),
            ),
          ),
          const SizedBox(height: 16),
          ..._upcomingAppointments.map(
            (appointment) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(
                  appointment['icon'],
                  color: const Color(0xFF6A387A),
                ),
                title: Text(appointment['type']),
                subtitle: Text(
                  '${appointment['date'].toString().split(' ')[0]} at ${appointment['time']}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () {
                    // Set reminder
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Reminder set!')),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineSection(String title, Map<String, bool> routine) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6A387A),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children:
                routine.entries
                    .map(
                      (entry) => CheckboxListTile(
                        title: Text(entry.key),
                        value: entry.value,
                        onChanged: (bool? value) {
                          setState(() {
                            routine[entry.key] = value ?? false;
                          });
                          if (value ?? false) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${entry.key} completed!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                        activeColor: const Color(0xFF6A387A),
                      ),
                    )
                    .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarTab() {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2024, 1, 1),
          lastDay: DateTime.utc(2024, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
        ),
      ],
    );
  }

  Widget _buildReviewsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10, // Sample reviews
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Day ${index + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Icon(
                      Icons.sentiment_very_satisfied,
                      color: Color(0xFF6A387A),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Skin felt hydrated and smooth today. New moisturizer working great!',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _usedProducts.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: const Icon(Icons.spa, color: Color(0xFF6A387A)),
            title: Text(_usedProducts[index]),
            subtitle: const Text('Expires in 6 months'),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                setState(() {
                  _usedProducts.removeAt(index);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Product removed'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
