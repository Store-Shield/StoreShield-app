import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../model/event.dart';
import 'package:intl/intl.dart'; // DateFormat을 사용하기 위한 import 추가

class CalendarWidget extends StatelessWidget {
  final DateTime selectedDay;
  final DateTime focusedDay;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(DateTime)? onPageChanged; // onPageChanged 추가
  final Map<DateTime, List<Event>> events;

  const CalendarWidget({
    super.key,
    required this.selectedDay,
    required this.focusedDay,
    required this.onDaySelected,
    required this.events,
    this.onPageChanged, // 옵션으로 추가
  });

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      firstDay: DateTime.utc(2021, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: focusedDay,
      selectedDayPredicate: (day) {
        return isSameDay(selectedDay, day);
      },
      onDaySelected: onDaySelected,
      eventLoader: (day) {
        final dateKey = DateTime(day.year, day.month, day.day);
        final result = events[dateKey] ?? [];
        print(
            '${DateFormat('yyyy-MM-dd').format(day)} 이벤트 확인: ${result.length}개');
        return result;
      },
      calendarStyle: CalendarStyle(
        markerDecoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        selectedDecoration: const BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
      onPageChanged: onPageChanged, // 이벤트 핸들러 추가
    );
  }
}
