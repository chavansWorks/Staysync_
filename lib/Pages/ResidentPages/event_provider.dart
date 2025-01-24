import 'package:flutter/material.dart';
import '../../API/db_helper.dart';
import 'Event.dart'; // Import your Event model

class EventProvider with ChangeNotifier {
  Map<DateTime, List<Event>> _events = {};
  List<Event> _selectedEvents = [];
  DateTime _selectedDay = DateTime.now();

  Map<DateTime, List<Event>> get events => _events;
  List<Event> get selectedEvents => _selectedEvents;

void loadEvents() async {
  final eventsData = await DatabaseHelper().getEvents();
  _events = {};

  for (var eventData in eventsData) {
    final eventDate = DateTime.parse(eventData['date']);
    if (!_events.containsKey(eventDate)) {
      _events[eventDate] = [];
    }
    _events[eventDate]!.add(Event.fromMap(eventData));
  }

  // Refresh selected day events after loading all events
  if (_selectedEvents.isEmpty || !_events.containsKey(_selectedDay)) {
    setSelectedDay(_selectedDay);  // Explicitly refresh the selected day's events
  }

  // Notify listeners after events are loaded
  notifyListeners();
}


void addEvent(Event event, DateTime selectedDay) async {
  final normalizedDate = selectedDay.toIso8601String().split('T')[0]; // Get only the date part
  final newEvent = Event(
    title: event.title,
    description: event.description,
    date: normalizedDate, // Store only the date part
  );

  // Insert event into the database
  await DatabaseHelper().insertEvent(newEvent.toMap());

  // Update the in-memory map of events
  if (_events[DateTime.parse(normalizedDate)] == null) {
    _events[DateTime.parse(normalizedDate)] = [];
  }
  _events[DateTime.parse(normalizedDate)]!.add(newEvent);

  // Notify listeners to update the UI
  notifyListeners();

  // After adding the event, refresh the events for the selected day to reflect the changes
  setSelectedDay(selectedDay);
}

void updateEvent(Event updatedEvent, DateTime date) async {
  // Normalize the date
  final normalizedDate = DateTime(date.year, date.month, date.day);

  // Update the event in the database
  await DatabaseHelper().updateEvent(updatedEvent.toMap());

  // Update the in-memory events map
  if (_events[normalizedDate] != null) {
    _events[normalizedDate] = _events[normalizedDate]!
        .map((e) => e.id == updatedEvent.id ? updatedEvent : e)
        .toList();
  }

  // Update selected events if the selected day is the same
  if (_selectedEvents.isNotEmpty && _selectedEvents[0].date == updatedEvent.date) {
    _selectedEvents = _events[normalizedDate]!;
  }

  // Notify listeners to update UI
  notifyListeners();

   setSelectedDay(date);
}

void removeEvent(Event event, DateTime date) async {
  final normalizedDate = date.toIso8601String().split('T')[0]; // Get only the date part
  await DatabaseHelper().deleteEvent(event.id!);

  // Remove event from the in-memory events map
  _events[DateTime.parse(normalizedDate)]?.remove(event);

  notifyListeners();
}

  void setSelectedDay(DateTime day) {
  final normalizedDate = DateTime(day.year, day.month, day.day); // Normalize the date
  _selectedEvents = _events[normalizedDate] ?? [];
  notifyListeners();
}

}