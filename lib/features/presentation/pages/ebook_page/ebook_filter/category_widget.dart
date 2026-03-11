import 'package:flutter/material.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String selectedCategory = '';
  Map<String, bool> categorySelections = {
    'Technology': false,
    'Politics': false,
    'Sports': false,
    'Entertainment': false,
    'Science': false,
  };

  Map<String, bool> ageGroupSelections = {
    'Under 18': false,
    '18-24': false,
    '25-34': false,
    '35-44': false,
    '45+': false,
  };

  double _currentPriceRange = 100;
  String _selectedSection = 'Category';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Row(
              children: [
                _buildLeftPanel(),
                const VerticalDivider(thickness: 1),
                _buildRightPanel(),
              ],
            ),
          ),
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Filter Options',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftPanel() {
    return SizedBox(
      width: 120,
      child: Column(
        children: [
          _buildLeftPanelItem('Category'),
          _buildLeftPanelItem('Age Group'),
          _buildLeftPanelItem('Price Range'),
        ],
      ),
    );
  }

  Widget _buildLeftPanelItem(String title) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedSection = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: _selectedSection == title
              ? Colors.purple.withOpacity(0.1)
              : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: _selectedSection == title ? Colors.purple : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: _selectedSection == title ? Colors.purple : Colors.black,
            fontWeight: _selectedSection == title
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildRightPanel() {
    switch (_selectedSection) {
      case 'Category':
        return _buildCategoryOptions();
      case 'Age Group':
        return _buildAgeGroupOptions();
      case 'Price Range':
        return _buildPriceRangeOptions();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCategoryOptions() {
    return Expanded(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: categorySelections.entries.map((entry) {
          return ListTile(
            title: Text(entry.key),
            trailing: Switch(
              value: entry.value,
              onChanged: (bool value) {
                setState(() {
                  categorySelections[entry.key] = value;
                });
              },
              activeColor: Colors.purple,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAgeGroupOptions() {
    return Expanded(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: ageGroupSelections.entries.map((entry) {
          return ListTile(
            title: Text(entry.key),
            trailing: Switch(
              value: entry.value,
              onChanged: (bool value) {
                setState(() {
                  ageGroupSelections[entry.key] = value;
                });
              },
              activeColor: Colors.purple,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPriceRangeOptions() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Price Range: \$${_currentPriceRange.round()}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Slider(
              value: _currentPriceRange,
              min: 0,
              max: 1000,
              divisions: 100,
              label: '\$${_currentPriceRange.round()}',
              onChanged: (double value) {
                setState(() {
                  _currentPriceRange = value;
                });
              },
              activeColor: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  categorySelections.updateAll((key, value) => false);
                  ageGroupSelections.updateAll((key, value) => false);
                  _currentPriceRange = 100;
                });
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.purple),
              ),
              child: const Text(
                'Clear All',
                style: TextStyle(color: Colors.purple),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Implement apply filter logic
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Apply Filter',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
