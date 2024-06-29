part of event_calendar;

class _DoctorPicker extends StatelessWidget {
  final List<User> users;
  _DoctorPicker(this.users);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            padding: const EdgeInsets.all(0),
            itemCount: users.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(

                leading: CircleAvatar(
                  backgroundImage: NetworkImage(
                      users[index].picture
                  ),
                ),
                contentPadding: const EdgeInsets.all(0),


                title: Text(users[index].name),
                onTap: () {
                  // ignore: always_specify_types
                  Future.delayed(const Duration(milliseconds: 200), () {
                    // When task is over, close the dialog
                    Navigator.pop(context,index);
                  });

                },
              );
            },
          )),
    );
  }
}
