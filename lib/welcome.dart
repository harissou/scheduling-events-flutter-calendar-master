part of event_calendar;

class Welcome extends StatelessWidget {
  const Welcome({Key? key}) : super(key: key);

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text("bienvenue"),),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (context) => EventCalendar()));
                  },
                  child: Text("calendrier"),
                  style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                      fixedSize: const Size(300, 100),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50))),
                ),
              ],

            ),
            SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (context) => MyHomePage()));
                  },
                  child: Text("liste des médecin"),
                  style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                      fixedSize: const Size(300, 100),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50))),
                )
              ],
            ),
            SizedBox(height: 50),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: Text("button 3"),
                  style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                      fixedSize: const Size(300, 100),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50))),
                ),
              ],
            ),
            SizedBox(height: 50),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: Text("button 4"),
                  style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                      fixedSize: const Size(300, 100),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50))),
                ),
              ],
            ),

          ],
        ),
      );

  }
}
