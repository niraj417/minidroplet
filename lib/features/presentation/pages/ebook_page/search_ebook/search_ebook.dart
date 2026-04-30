

import '../../../../../core/constant/app_export.dart';

class SearchEbookView extends StatelessWidget {
  const SearchEbookView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(onPressed: () {
          _showFilterBottomSheet(context);
        }, child: Text('Click')),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SizedBox(
          height: 500,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              // UI States
              String selectedOption = "Category"; // Default selected option
              bool isSwitchOn = false;
              double minPrice = 0;
              double maxPrice = 100;

              // Options for Category and Age Group
              final List<String> categoryOptions = ["Technology", "Politics", "Science"];
              final List<String> ageGroupOptions = ["0-10", "11-20", "21-30", "30+"];

              // Body Content Based on Selected Option
              Widget buildContent() {
                if (selectedOption == "Category") {
                  return Column(
                    children: categoryOptions.map((category) {
                      return ListTile(
                        title: Text(category),
                        trailing: Switch(
                          value: isSwitchOn,
                          onChanged: (value) {
                            setState(() {
                              isSwitchOn = value;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  );
                } else if (selectedOption == "Age Group") {
                  return Column(
                    children: ageGroupOptions.map((ageGroup) {
                      return ListTile(
                        title: Text(ageGroup),
                        trailing: Switch(
                          value: isSwitchOn,
                          onChanged: (value) {
                            setState(() {
                              isSwitchOn = value;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  );
                } else if (selectedOption == "Price") {
                  return Column(
                    children: [
                      Text("Select Price Range"),
                      Slider(
                        value: minPrice,
                        min: 0,
                        max: 100,
                        onChanged: (value) {
                          setState(() {
                            minPrice = value;
                          });
                        },
                      ),
                      Slider(
                        value: maxPrice,
                        min: 0,
                        max: 100,
                        onChanged: (value) {
                          setState(() {
                            maxPrice = value;
                          });
                        },
                      ),
                      Text("Min: \$${minPrice.toStringAsFixed(0)} - Max: \$${maxPrice.toStringAsFixed(0)}"),
                    ],
                  );
                }
                return Container();
              }

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      "Search & Choose Filters",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),

                    // Options: Category, Age Group, Price
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedOption = "Category";
                              });
                            },
                            child: Column(
                              children: [
                                Text("Category"),
                                if (selectedOption == "Category")
                                  Divider(
                                    thickness: 2,
                                    color: Colors.purple,
                                  )
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedOption = "Age Group";
                              });
                            },
                            child: Column(
                              children: [
                                Text("Age Group"),
                                if (selectedOption == "Age Group")
                                  Divider(
                                    thickness: 2,
                                    color: Colors.purple,
                                  )
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedOption = "Price";
                              });
                            },
                            child: Column(
                              children: [
                                Text("Price"),
                                if (selectedOption == "Price")
                                  Divider(
                                    thickness: 2,
                                    color: Colors.purple,
                                  )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Divider
                    Divider(thickness: 1),

                    // Dynamic Content
                    Expanded(child: buildContent()),

                    // Apply Filter Button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text("Apply Filter"),
                    )
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
