class Task {
  static List<Task> _tasks = [
    Task('Choose topic', 'Decide on topic of the event'),
    Task('Drink coffee', null),
    Task('Order pizza', 'JustEat?'),
    Task('Prepare codelab', null),
  ];

  String name, details;
  bool completed = false;

  Task(this.name, this.details);

  static List<Task> get tasks => _tasks;

  static List<Task> get currentTasks =>
      _tasks.where((task) => !task.completed).toList();

  static List<Task> get completedTasks =>
      _tasks.where((task) => task.completed).toList();
}
