import 'package:flutter/material.dart';
import 'package:todo_list/models/todos.dart';
import 'package:todo_list/repositories/todo_repository.dart';
import 'package:todo_list/widgets/todo_list_item.dart';

class TodoListPage extends StatefulWidget {
  TodoListPage({Key? key}) : super(key: key);

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  List<Todo> todos = [];
  Todo? deletedTodo;
  int? deletedTodoPos;

  final TextEditingController todoController = TextEditingController();
  final TodoRepository todoRepository = TodoRepository();

  @override
  void initState() {
    super.initState();

    todoRepository.getTodoList().then((value) {
      setState(() {
        todos = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Lista de Tarefas"),
          centerTitle: true,
          backgroundColor: Color(0xff358192),
        ),
          body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: todoController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Adicionar atividade',
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color:Color(0xff358192),
                            width: 2
                          ),
                        ),
                        labelStyle: TextStyle(
                          color: Color(0xff358192),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  ElevatedButton(
                      onPressed: () {
                        String text = todoController.text;
                        if(text.isEmpty) {
                          Null;
                          return;
                        }
                        setState(() {
                          Todo newTodo = Todo(
                            title: text,
                            datesTime: DateTime.now(),
                          );
                          todos.add(newTodo);
                        });
                        todoController.clear();
                        todoRepository.saveTodoList(todos);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xff358192),
                        padding: EdgeInsets.all(3.5),
                      ),
                      child: Text(
                        '+',
                        style: TextStyle(
                          fontSize: 45,
                          fontWeight: FontWeight.w400,
                        ),
                      )),
                ],
              ),
              SizedBox(height: 16),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (Todo todo in todos)
                      TodoListItem(
                        todo: todo,
                        onDelete: onDelete,
                      ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      'Você possui ${todos.length} tarefas pendentes',
                    ),
                  ),
                  SizedBox(width: 15),
                  ElevatedButton(
                      onPressed: showDeleteTodoDialog,
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xff358192),
                        padding: EdgeInsets.all(3.5),
                      ),
                      child: Text(
                        'Limpar tudo',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      )),
                ],
              )
            ],
          ),
        ),
      )),
    );
  }

  void onDelete(Todo todo) {
    deletedTodo = todo;
    deletedTodoPos = todos.indexOf(todo);

    setState(() {
      todos.remove(todo);
    });
    todoRepository.saveTodoList(todos);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tarefa ${todo.title} foi removida'),
        action: SnackBarAction(
          label: 'Desfazer',
          onPressed: () {
            setState(() {
              todos.insert(deletedTodoPos!, deletedTodo!);
            });
            todoRepository.saveTodoList(todos);
          },
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void showDeleteTodoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Limpar tudo?'),
        content: Text('tem certeza que quer apagar tudo?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              deleteAllTodos();
            },
            style: TextButton.styleFrom(primary: Colors.red),
            child: Text('Limpar tudo'),
          ),
        ],
      ),
    );
  }

  void deleteAllTodos() {
    setState(() {
      todos.clear();
    });
    todoRepository.saveTodoList(todos);
  }
}
