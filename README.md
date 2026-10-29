Reflection
After completing the application, answer the following questions:

1. Why does the application use SQLite instead of relying only on a Dart list?
   Ans: It is because it allows task records to remain saved even after the application is closed or restarted. If I relied only on a Dart list, the tasks would be lost when the application is terminated because the list exists only in memory.
2. What is the purpose of the primary key in the tasks table?
   Ans: The primary key uniquely identifies each task in the database. This allows the application to update the completion status or delete a specific task using its ID, even if other tasks have the same title. It also prevents two task records from having the same primary key.
3. How does the repository simplify the UI's interaction with the database?
   Ans: The repository separates database operations from the user interface, making the code more organized and easier to maintain. The UI in main.dart simply calls the separate methods in task_repository which makes the application easier to understand and allows database operations to be modified without significantly changing the UI code.
4. What would happen if a task were removed from the displayed list but not deleted from SQLite?
   Ans: If a task were removed only from the displayed list, it would disappear from the screen temporarily, but its record would remain in SQLite. When the application was reopened or the task list was reloaded, the deleted task would appear again because it was never removed from the database.
5. If the database schema later needed a new column for task priority, what parts of the application might
   need to change?
   Ans: Lots of part of the application might need to be updated to support task priority. For example, the task model would need a new priority property, and its toMap() and fromMap() methods would need to handle that property. Next, the TaskRepository might need updated methods to save, retrieve, and modify task priorities. Finally, main.dart could be updated to allow users to select a priority and display it beside each task.
