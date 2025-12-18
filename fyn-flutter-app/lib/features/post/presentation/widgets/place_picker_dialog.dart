import 'package:flutter/material.dart';
import '../../data/models/place_tag.dart';
import '../../../../theme/dating_colors.dart';

/// Dialog for selecting a place to tag in a post
class PlacePickerDialog extends StatefulWidget {
  const PlacePickerDialog({super.key});

  @override
  State<PlacePickerDialog> createState() => _PlacePickerDialogState();
}

class _PlacePickerDialogState extends State<PlacePickerDialog> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final places = PlaceTag.allPlaces.where((place) {
      if (_searchQuery.isEmpty) return true;
      return place.displayName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Dialog(
      backgroundColor: isDark ? DatingColors.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.location_city,
                  color: isDark ? DatingColors.darkPrimaryText : Colors.black87,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Chọn địa điểm',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? DatingColors.darkPrimaryText : Colors.black87,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: isDark ? DatingColors.darkSecondaryText : Colors.grey,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search field
            TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm địa điểm...',
                hintStyle: TextStyle(
                  color: isDark ? DatingColors.darkSecondaryText : Colors.grey,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark ? DatingColors.darkSecondaryText : Colors.grey,
                ),
                filled: true,
                fillColor: isDark ? DatingColors.darkSurfaceElevated : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(
                color: isDark ? DatingColors.darkPrimaryText : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Places list
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: places.length,
                itemBuilder: (context, index) {
                  final place = places[index];
                  return ListTile(
                    leading: Icon(
                      Icons.location_on,
                      color: DatingColors.indigo,
                    ),
                    title: Text(
                      place.displayName,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isDark ? DatingColors.darkPrimaryText : Colors.black87,
                      ),
                    ),
                    onTap: () => Navigator.of(context).pop(place),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hoverColor: isDark
                        ? DatingColors.darkSurfaceElevated
                        : Colors.grey.shade50,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
