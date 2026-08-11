import 'package:flutter/material.dart';

import 'data/db_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController descController = TextEditingController();

  bool isDark = false;

  List<Map<String, dynamic>> allNotes = [];

  DbHelper? dbRef;

  @override
  void initState() {
    super.initState();

    dbRef = DbHelper.getInstance;

    getNotes();
  }

  @override
  void dispose() {
    descController.dispose();

    super.dispose();
  }


  Future<void> getNotes() async {
    allNotes = await dbRef!.getAllNotes();

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF5F7FA),

      appBar: AppBar(
        backgroundColor: Colors.blueGrey,

        title: const Text(
          "Todo",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w600,
            color: Colors.red,
          ),
        ),

        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isDark = !isDark;
              });
            },
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 10),
        ],
      ),

      body: allNotes.isNotEmpty
          ? ListView.builder(
              itemCount: allNotes.length,

              itemBuilder: (context, index) {
                bool isCompleted =
                    allNotes[index][DbHelper.COLUMN_Todo_STATUS] == 1;

                return Card(
                  margin: const EdgeInsets.all(8),
                  color: isDark ? Colors.grey[900] : Colors.white,

                  child: ListTile(

                    leading: Transform.scale(
                      scale: 1.4,

                      child: Checkbox(

                        value: isCompleted,

                        shape: const CircleBorder(),

                        onChanged: (value) async {
                          int status = value == true ? 1 : 0;

                          bool updated = await dbRef!.updateStatus(
                            sno: allNotes[index][DbHelper.COLUMN_Todo_SNO],
                            status: status,
                          );

                          if (updated) {
                            await getNotes();
                          }
                        },
                      ),
                    ),

            //text
                    title: Text(
                      allNotes[index][DbHelper.COLUMN_Todo_DESC],
                      style: TextStyle(
                        fontSize: 22,
                        color: isDark ? Colors.white : Colors.blueGrey,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        decorationColor: isDark ? Colors.white : Colors.blueGrey,
                        decorationThickness: 2,
                      ),
                    ),

                    //Edite or delete

                    trailing: SizedBox(
                      width: 65,

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,

                        children: [
                          InkWell(
                            onTap: () {
                              descController.text =
                                  allNotes[index][DbHelper.COLUMN_Todo_DESC];

                              showModalBottomSheet(
                                context: context,

                                isScrollControlled: true,

                                builder: (context) {
                                  return FractionallySizedBox(
                                    heightFactor: 0.8,

                                    child: getBottomShitWidger(
                                      isUpdate: true,

                                      sno:
                                          allNotes[index][DbHelper
                                              .COLUMN_Todo_SNO],
                                    ),
                                  );
                                },
                              );
                            },

                            child: const Icon(Icons.edit, size: 22),
                          ),

                          const SizedBox(width: 10),

                          // Delete
                          InkWell(
                            onTap: () async {
                              bool check = await dbRef!.delete(
                                sno: allNotes[index][DbHelper.COLUMN_Todo_SNO],
                              );

                              if (check) {
                                await getNotes();

                                if (!mounted) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Todo deleted successfully"),
                                  ),
                                );
                              }
                            },

                            child: const Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )

          : Center(
              child: Text(
                "No Todo here",

                style: TextStyle(
                  fontSize: 25,

                  color: isDark ? Colors.white : Colors.red,
                ),
              ),
            ),

//floatingActionButton
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          descController.clear();

          showModalBottomSheet(
            context: context,

            isScrollControlled: true,

            builder: (context) {
              return FractionallySizedBox(
                heightFactor: 0.8,

                child: getBottomShitWidger(),
              );
            },
          );
        },

        child: const Icon(Icons.add),
      ),
    );
  }



  Widget getBottomShitWidger({bool isUpdate = false, int sno = 0}) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(16),

      child: SingleChildScrollView(
        child: Column(
          children: [

            Text(
              isUpdate ? "Update Todo" : "Add Todo",

              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 21),


            TextField(
              controller: descController,

              maxLines: 4,

              decoration: InputDecoration(
                labelText: "Enter the Todo here",

                hintText: "Enter Todo here",

                prefixIcon: const Icon(Icons.note),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 30),

            Row(
              children: [

                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      String desc = descController.text.trim();

                      // Empty
                      if (desc.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please enter Todo")),
                        );

                        return;
                      }

                      bool check;

                      // Update
                      if (isUpdate) {
                        check = await dbRef!.updateTodo(mDesc: desc, sno: sno);
                      }
                      // Add
                      else {
                        check = await dbRef!.addTodo(mDesc: desc);
                      }

                      if (check) {
                        descController.clear();

                        await getNotes();

                        if (!mounted) return;

                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isUpdate
                                  ? "Todo updated successfully"
                                  : "Todo added successfully",
                            ),
                          ),
                        );
                      }
                      else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Todo add failed")),
                        );
                      }
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,

                      foregroundColor: Colors.white,

                      elevation: 3,

                      padding: const EdgeInsets.symmetric(vertical: 15),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    child: Text(
                      isUpdate ? "Update Todo" : "Add Todo",

                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

             //cancel
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      descController.clear();

                      Navigator.pop(context);
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,

                      foregroundColor: Colors.white,

                      elevation: 3,

                      padding: const EdgeInsets.symmetric(vertical: 15),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    child: const Text(
                      "Cancel",

                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
