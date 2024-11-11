//reference our box
import 'package:heat_map_with_habit_task/datetime/date_time.dart';
import 'package:hive_flutter/hive_flutter.dart';

final _mybox = Hive.box("habit_database");

class HabitDatabase {
  List todaysHabitList = [];
  Map<DateTime, int> heatmapdataSet = {};
  //create initial default data
  void createdefaultData() {
    todaysHabitList = [
      ["Run", false],
      ["Read Book", false],
      ["Code App", false],
    ];
    _mybox.put("START_DATE", todaysDateFormatted());
  }

  //load data if it already exists
  void loadData() {
    //if it's a new day, get habit list from database
    if (_mybox.get(todaysDateFormatted()) == null) {
      todaysHabitList = _mybox.get("CURRENT_HABIT_LIST");
      //set all habit completed to false since its a new day
      for (int i = 0; i < todaysHabitList.length; i++) {
        todaysHabitList[i][1] = false;
      }
    }
    //if not a new day, load todays list
    else {
      todaysHabitList = _mybox.get(todaysDateFormatted());
    }
  }

  //update database
  void updateDatabase() {
    //update todays entry
    _mybox.put(todaysDateFormatted(), todaysHabitList);
    //update universal habit list in case it changed (new habit, edit habit, dalete habit)
    _mybox.put("CURRENT_HABIT_LIST", todaysHabitList);
    //caculate habit complete percentages for each day
    caculatePercentages();
    //load head map
    loadHeatmap();
  }

  void caculatePercentages() {
    int count = 0;
    for (int i = 0; i < todaysHabitList.length; i++) {
      if (todaysHabitList[i][1] == true) {
        count++;
      }
    }
    String percent = todaysHabitList.isEmpty
        ? '0.0'
        : (count / todaysHabitList.length).toStringAsFixed(1);
    //key PERCENTAGE_SUMMARY_yyyymmdd
    _mybox.put("PERCENTAGE_SUMMARY_${todaysDateFormatted()}", percent);
  }

  void loadHeatmap() {
    DateTime startDate = createDateTimeObject(_mybox.get("START_DATE"));
    //count the number od days to load
    int daysinBetween = DateTime.now().difference(startDate).inDays;
    //go from start date to today
    // "PERCENTAGE_SUMMARY_yyyymmdd" will be the key
    for (int i = 0; i <= daysinBetween; i++) {
      String yyyymmdd = convertDateTimeToString(
        startDate.add(Duration(days: i)),
      );
      double strength = double.parse(
        _mybox.get("PERCENTAGE_SUMMARY_$yyyymmdd") ?? "0.0",
      );
      //split datetime up like below
      //year
      int year = startDate.add(Duration(days: i)).year;
      //month
      int month = startDate.add(Duration(days: i)).month;
      //day
      int day = startDate.add(Duration(days: i)).day;
      final percentForEachDay = <DateTime, int>{
        DateTime(year, month, day): (10 * strength).toInt(),
      };
      heatmapdataSet.addEntries(percentForEachDay.entries);
    }
  }
}
