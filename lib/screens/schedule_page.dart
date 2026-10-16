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

  final Map<DateTime, List<dynamic>> _events = {};

  final Map<String, dynamic> _currentWeather = {
    'condition': 'sunny',
    'temperature': 25,
    'humidity': 60,
    'uvIndex': 7,
  };

  String _getWeatherBasedTip() {
    if (_currentWeather['uvIndex'] > 6) {
      return '☀️ High UV today! Don\'t forget extra sunscreen and reapply every 2 hours.';
    } else if (_currentWeather['humidity'] > 70) {
      return '💧 High humidity! Use lightweight, oil-free moisturizers today.';
    } else if (_currentWeather['humidity'] < 30) {
      return '🌵 Low humidity! Use extra moisturizer and hydrating serums.';
    }
    return '✨ Perfect weather for your regular skincare routine!';
  }

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

  void _showReminderDialog(Map<String, dynamic> appointment) {
    TimeOfDay selectedTime = TimeOfDay.now();
    List<bool> selectedDays = List.generate(
      3,
      (index) => false,
    ); // Days before appointment

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.notifications_active,
                              color: Color(0xFF6A387A),
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Set Reminder for ${appointment['type']}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6A387A),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Remind me before:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildReminderChip('1 day', selectedDays[0], (
                              value,
                            ) {
                              setState(() {
                                selectedDays[0] = value;
                              });
                            }),
                            _buildReminderChip('2 days', selectedDays[1], (
                              value,
                            ) {
                              setState(() {
                                selectedDays[1] = value;
                              });
                            }),
                            _buildReminderChip('3 days', selectedDays[2], (
                              value,
                            ) {
                              setState(() {
                                selectedDays[2] = value;
                              });
                            }),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ListTile(
                          leading: const Icon(Icons.access_time),
                          title: const Text('Reminder Time'),
                          subtitle: Text(selectedTime.format(context)),
                          onTap: () async {
                            final TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: selectedTime,
                            );
                            if (picked != null) {
                              setState(() {
                                selectedTime = picked;
                              });
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
                                // Here you would typically save the reminder settings
                                // and schedule actual notifications
                                Navigator.pop(context);
                                _showReminderConfirmation(
                                  appointment,
                                  selectedDays,
                                  selectedTime,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6A387A),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Set Reminder'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
          ),
    );
  }

  Widget _buildReminderChip(
    String label,
    bool isSelected,
    Function(bool) onSelected,
  ) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: const Color(0xFF6A387A).withOpacity(0.2),
      checkmarkColor: const Color(0xFF6A387A),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF6A387A) : Colors.black87,
      ),
    );
  }

  void _showReminderConfirmation(
    Map<String, dynamic> appointment,
    List<bool> selectedDays,
    TimeOfDay reminderTime,
  ) {
    int reminderCount = selectedDays.where((day) => day).length;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Reminder${reminderCount > 1 ? 's' : ''} set for ${appointment['type']} at ${reminderTime.format(context)}${reminderCount > 0 ? ' ($reminderCount day${reminderCount > 1 ? 's' : ''} before)' : ''}',
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () {
            _showViewRemindersDialog();
          },
        ),
      ),
    );
  }

  void _showViewRemindersDialog() {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.notifications_active,
                        color: Color(0xFF6A387A),
                        size: 28,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Active Reminders',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6A387A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 300,
                    child: ListView.builder(
                      itemCount: _upcomingAppointments.length,
                      itemBuilder: (context, index) {
                        final appointment = _upcomingAppointments[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Icon(
                              appointment['icon'],
                              color: const Color(0xFF6A387A),
                            ),
                            title: Text(appointment['type']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Date: ${appointment['date'].toString().split(' ')[0]}',
                                ),
                                Text('Time: ${appointment['time']}'),
                                const Text(
                                  'Reminders: 1 day before at 9:00 AM',
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Navigator.pop(context);
                                _showReminderDialog(appointment);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A387A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showAddEntryDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController notesController = TextEditingController();
    String selectedMood = 'Great';
    List<String> selectedProducts = [];

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Add New Entry',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6A387A),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'How is your skin feeling today?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _moodOption(
                              'Great',
                              Icons.sentiment_very_satisfied,
                            ),
                            _moodOption('Good', Icons.sentiment_satisfied),
                            _moodOption('Okay', Icons.sentiment_neutral),
                            _moodOption('Bad', Icons.sentiment_dissatisfied),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: titleController,
                          decoration: InputDecoration(
                            labelText: 'Title',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: notesController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Notes',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Text(
                              'Products Used:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('Add Product'),
                              onPressed: () {
                                // Show product selection dialog
                                setState(() {
                                  selectedProducts.add('Sample Product');
                                });
                              },
                            ),
                          ],
                        ),
                        if (selectedProducts.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            children:
                                selectedProducts
                                    .map(
                                      (product) => Chip(
                                        label: Text(product),
                                        onDeleted: () {
                                          setState(() {
                                            selectedProducts.remove(product);
                                          });
                                        },
                                      ),
                                    )
                                    .toList(),
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
                                // Save the entry
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Entry added successfully!'),
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
                              child: const Text('Save'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
          ),
    );
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    _showDayDetailsDialog(selectedDay);
  }

  void _showDayDetailsDialog(DateTime date) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${date.day}/${date.month}/${date.year}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6A387A),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          color: const Color(0xFF6A387A),
                          onPressed: () => _showAddEventDialog(date),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Skincare Routines:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6A387A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.wb_sunny,
                          color: Colors.orange,
                        ),
                        title: const Text('Morning Routine'),
                        subtitle: Text(
                          _morningRoutine.entries
                              .where((e) => e.value)
                              .map((e) => e.key)
                              .join(', '),
                        ),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.nightlight,
                          color: Color(0xFF6A387A),
                        ),
                        title: const Text('Evening Routine'),
                        subtitle: Text(
                          _eveningRoutine.entries
                              .where((e) => e.value)
                              .map((e) => e.key)
                              .join(', '),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Appointments:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6A387A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 150,
                      child: ListView.builder(
                        itemCount: _upcomingAppointments.length,
                        itemBuilder: (context, index) {
                          final appointment = _upcomingAppointments[index];
                          if (appointment['date'].year == date.year &&
                              appointment['date'].month == date.month &&
                              appointment['date'].day == date.day) {
                            return Card(
                              child: ListTile(
                                leading: Icon(
                                  appointment['icon'],
                                  color: const Color(0xFF6A387A),
                                ),
                                title: Text(appointment['type']),
                                subtitle: Text(appointment['time']),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.notifications_outlined,
                                      ),
                                      onPressed:
                                          () =>
                                              _showReminderDialog(appointment),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        // Edit appointment
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Notes:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6A387A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.sentiment_very_satisfied,
                                  color: Color(0xFF6A387A),
                                ),
                                SizedBox(width: 8),
                                Text('Skin feeling great today!'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Products used: Cleanser, Toner, Moisturizer',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Weather-Based Recommendations:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6A387A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _currentWeather['condition'] == 'sunny'
                                      ? Icons.wb_sunny
                                      : Icons.cloud,
                                  color: const Color(0xFF6A387A),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Weather: ${_currentWeather['temperature']}°C, ${_currentWeather['humidity']}% humidity',
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(_getWeatherBasedTip()),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  void _showAddEventDialog(DateTime date) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController timeController = TextEditingController();
    String selectedType = 'Appointment';
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Add New Event',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6A387A),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(
                              value: 'Appointment',
                              label: Text('Appointment'),
                              icon: Icon(Icons.calendar_today),
                            ),
                            ButtonSegment(
                              value: 'Routine',
                              label: Text('Routine'),
                              icon: Icon(Icons.schedule),
                            ),
                            ButtonSegment(
                              value: 'Note',
                              label: Text('Note'),
                              icon: Icon(Icons.note),
                            ),
                          ],
                          selected: {selectedType},
                          onSelectionChanged: (Set<String> newSelection) {
                            setState(() {
                              selectedType = newSelection.first;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: titleController,
                          decoration: InputDecoration(
                            labelText: 'Title',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(Icons.access_time),
                          title: const Text('Time'),
                          subtitle: Text(selectedTime.format(context)),
                          onTap: () async {
                            final TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: selectedTime,
                            );
                            if (picked != null) {
                              setState(() {
                                selectedTime = picked;
                              });
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
                                // Add the event to the calendar
                                if (titleController.text.isNotEmpty) {
                                  setState(() {
                                    if (_events[date] == null) {
                                      _events[date] = [];
                                    }
                                    _events[date]!.add({
                                      'type': selectedType,
                                      'title': titleController.text,
                                      'time': selectedTime.format(context),
                                    });
                                  });
                                  Navigator.pop(context);
                                  _showDayDetailsDialog(
                                    date,
                                  ); // Refresh the details dialog
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
            _showAddEntryDialog();
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
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () => _showReminderDialog(appointment),
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
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildWeatherCard(),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TableCalendar(
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _showDayDetailsDialog(selectedDay);
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarStyle: const CalendarStyle(
                markerDecoration: BoxDecoration(
                  color: Color(0xFF6A387A),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Color(0xFF6A387A),
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Color(0xFFE6D7EE),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(
                  color: Color(0xFF6A387A),
                  fontWeight: FontWeight.bold,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  color: Color(0xFF6A387A),
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildWeatherCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF6A387A),
              const Color(0xFF6A387A).withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Today\'s Skincare Forecast',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildWeatherInfo(
                    icon: Icons.thermostat,
                    label: 'Temperature',
                    value: '${_currentWeather['temperature']}°C',
                  ),
                  _buildWeatherInfo(
                    icon: Icons.water_drop,
                    label: 'Humidity',
                    value: '${_currentWeather['humidity']}%',
                  ),
                  _buildWeatherInfo(
                    icon: Icons.sunny,
                    label: 'UV Index',
                    value: '${_currentWeather['uvIndex']}',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.tips_and_updates, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getWeatherBasedTip(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
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
