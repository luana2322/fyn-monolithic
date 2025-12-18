import 'package:flutter/material.dart';
import '../../../connections/data/models/search_filter.dart';

/// Bottom sheet để filter users (gender, age, location)
class UserFilterBottomSheet extends StatefulWidget {
  final SearchFilter currentFilter;
  final Function(SearchFilter) onApply;

  const UserFilterBottomSheet({
    Key? key,
    required this.currentFilter,
    required this.onApply,
  }) : super(key: key);

  @override
  State<UserFilterBottomSheet> createState() => _UserFilterBottomSheetState();
}

class _UserFilterBottomSheetState extends State<UserFilterBottomSheet> {
  late String? _selectedGender;
  late RangeValues _ageRange;
  late TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    _selectedGender = widget.currentFilter.gender;
    _ageRange = RangeValues(
      widget.currentFilter.minAge?.toDouble() ?? 18,
      widget.currentFilter.maxAge?.toDouble() ?? 60,
    );
    _locationController = TextEditingController(
      text: widget.currentFilter.location ?? '',
    );
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _resetFilters,
                  child: const Text(
                    'Reset',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const Text(
                  'Bộ lọc',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                TextButton(
                  onPressed: _applyFilters,
                  child: const Text(
                    'Áp dụng',
                    style: TextStyle(
                      color: Colors.pink,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.grey),
          // Filter options
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gender filter
                  const Text(
                    'Giới tính',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildGenderChip('Tất cả', null),
                      _buildGenderChip('Nam', 'MALE'),
                      _buildGenderChip('Nữ', 'FEMALE'),
                      _buildGenderChip('Khác', 'OTHER'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Age range
                  const Text(
                    'Độ tuổi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_ageRange.start.round()} tuổi',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      Text(
                        '${_ageRange.end.round()} tuổi',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    ],
                  ),
                  RangeSlider(
                    values: _ageRange,
                    min: 18,
                    max: 60,
                    divisions: 42,
                    activeColor: Colors.pink,
                    inactiveColor: Colors.grey[700],
                    labels: RangeLabels(
                      _ageRange.start.round().toString(),
                      _ageRange.end.round().toString(),
                    ),
                    onChanged: (values) {
                      setState(() {
                        _ageRange = values;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Location
                  const Text(
                    'Địa điểm',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _locationController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Nhập địa điểm (Hà Nội, TP HCM...)',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      filled: true,
                      fillColor: Colors.grey[850],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.location_on, color: Colors.grey[500]),
                      suffixIcon: _locationController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: Colors.grey[500]),
                              onPressed: () {
                                setState(() {
                                  _locationController.clear();
                                });
                              },
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderChip(String label, String? value) {
    final isSelected = _selectedGender == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedGender = selected ? value : null;
        });
      },
      selectedColor: Colors.pink,
      backgroundColor: Colors.grey[850],
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[400],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide.none,
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedGender = null;
      _ageRange = const RangeValues(18, 60);
      _locationController.clear();
    });
  }

  void _applyFilters() {
    final filter = SearchFilter(
      gender: _selectedGender,
      minAge: _ageRange.start.round(),
      maxAge: _ageRange.end.round(),
      location: _locationController.text.trim().isEmpty 
          ? null 
          : _locationController.text.trim(),
    );
    widget.onApply(filter);
    Navigator.of(context).pop();
  }
}
