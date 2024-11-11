import 'package:flutter/material.dart';
import 'package:heat_map_with_habit_task/data/habit_database.dart';
import 'package:heat_map_with_habit_task/habit_tile.dart';
import 'package:heat_map_with_habit_task/month_summary.dart';
import 'package:heat_map_with_habit_task/my_fab.dart';
import 'package:heat_map_with_habit_task/new_habit.dart';
import 'package:hive_flutter/adapters.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  HabitDatabase db = HabitDatabase();
  final _mybox = Hive.box("habit_database");
  @override
  void initState() {
    //if there is no current habit list, them it is the 1st time ever opening the app
    //create default data
    if (_mybox.get("CURRENT_HABIT_LIST") == null) {
      db.createdefaultData();
    }
    //this is not the 1st time
    else {
      db.loadData();
    }
    //update the database
    db.updateDatabase();
  }

  void checkBoxTapped(bool? value, int index) {
    setState(() {
      db.todaysHabitList[index][1] = value;
    });
    db.updateDatabase();
  }

  //save new habit
  void saveNewhabit() {
    //add new habit to todays habit list
    setState(() {
      db.todaysHabitList.add([_newhabitNameController.text, false]);
    });
    //clear textfield
    _newhabitNameController.clear();
    //pop dialog box
    Navigator.pop(context);
    db.updateDatabase();
  }

  //cancel new habit
  void cancelNewhabit() {
    //clear textfield
    _newhabitNameController.clear();
    //pop dialogbox
    Navigator.pop(context);
    db.updateDatabase();
  }

  //open habit setting
  void openHabitSettings(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return EnterNewHabitBox(
          controller: _newhabitNameController,
          onCancel: cancelNewhabit,
          onSave: () => saveNewnameHabit(index),
        );
      },
    );
  }

  //save new name habit
  void saveNewnameHabit(int index) {
    setState(() {
      db.todaysHabitList[index][0] = _newhabitNameController.text;
    });
    //clear textfield
    _newhabitNameController.clear();
    //pop dialog box
    Navigator.pop(context);
    db.updateDatabase();
  }

  //delete habit
  void deleteHabit(int index) {
    setState(() {
      db.todaysHabitList.removeAt(index);
    });
    db.updateDatabase();
  }

  final _newhabitNameController = TextEditingController();
  void createNewHabit() {
    //show alert dialog for user to enter the new habit details
    showDialog(
        context: context,
        builder: (context) {
          return EnterNewHabitBox(
            controller: _newhabitNameController,
            onCancel: cancelNewhabit,
            onSave: saveNewhabit,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      floatingActionButton: MyFloatingActionButton(onPressed: createNewHabit),
      body: ListView(
        children: [
          //monthly summary heat map
          MonthSummary(datasets: db.heatmapdataSet, startDate: _mybox.get("START_DATE")),
          ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: db.todaysHabitList.length,
          itemBuilder: (context, index) {
            return HabitTile(
              habitName: db.todaysHabitList[index][0],
              habitComplete: db.todaysHabitList[index][1],
              onChanged: (value) => checkBoxTapped(value, index),
              deleteTappped: (context) => deleteHabit(index),
              settingTapped: (context) => openHabitSettings(index),
            );
          }),
        ],
      )
    );
  }
}
