// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_datagrid/datagrid.dart';
//
//
//
// /// The home page of the application which hosts the datagrid.
// class MyHomePage extends StatefulWidget {
//   /// Creates the home page.
//   MyHomePage({Key? key}) : super(key: key);
//
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   List<Employee> employees = <Employee>[];
//   late EmployeeDataSource employeeDataSource;
//
//   @override
//   void initState() {
//     super.initState();
//     employees = getEmployeeData();
//     employeeDataSource = EmployeeDataSource(employeeData: employees);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar:null,
//       body:
//       // Column(
//       //
//       //   mainAxisAlignment: MainAxisAlignment.end,
//       //   children: [
//       //
//       //
//       //   Container(
//       //     width:300 ,
//       //     height: 44,
//       //     margin: EdgeInsets.symmetric(horizontal: 20),
//       //     child: ClipRRect(
//       //       borderRadius: BorderRadius.circular(20.0),
//       //       child: TextButton(
//       //         style: TextButton.styleFrom(
//       //
//       //           backgroundColor: Color(0xffD3A354)
//       //         ),
//       //           onPressed:(){
//       //
//       //           }, child: Text("START",style: TextStyle(
//       //         color: Colors.white
//       //       ),)),
//       //     ),
//       //   ),
//       //     SizedBox(height: 10,)
//       //
//       // ],)
//
//       SfDataGrid(
//         source: employeeDataSource,
//         columnWidthMode: ColumnWidthMode.fill,
//         columns: <GridColumn>[
//           GridColumn(
//               columnName: 'id',
//               label: Container(
//                   padding: EdgeInsets.all(16.0),
//                   alignment: Alignment.center,
//                   child: Text(
//                     'ID',
//                   ))),
//           GridColumn(
//               columnName: 'name',
//               label: Container(
//                   padding: EdgeInsets.all(8.0),
//                   alignment: Alignment.center,
//                   child: Text('Name'))),
//           GridColumn(
//               columnName: 'designation',
//               label: Container(
//                   padding: EdgeInsets.all(8.0),
//                   alignment: Alignment.center,
//                   child: Text(
//                     'Designation',
//                     overflow: TextOverflow.ellipsis,
//                   ))),
//           GridColumn(
//               columnName: 'salary',
//               label: Container(
//                   padding: EdgeInsets.all(8.0),
//                   alignment: Alignment.center,
//                   child: Text('Salary'))),
//         ],
//       ),
//     );
//   }
//
//   List<Employee> getEmployeeData() {
//     return [
//       Employee(10001, 'James', 'Project Lead', 20000),
//       Employee(10002, 'Kathryn', 'Manager', 30000),
//       Employee(10003, 'Lara', 'Developer', 15000),
//       Employee(10004, 'Michael', 'Designer', 15000),
//       Employee(10005, 'Martin', 'Developer', 15000),
//       Employee(10006, 'Newberry', 'Developer', 15000),
//       Employee(10007, 'Balnc', 'Developer', 15000),
//       Employee(10008, 'Perry', 'Developer', 15000),
//       Employee(10009, 'Gable', 'Developer', 15000),
//       Employee(10010, 'Grimes', 'Developer', 15000),
//       Employee(10001, 'James', 'Project Lead', 20000),
//       Employee(10002, 'Kathryn', 'Manager', 30000),
//       Employee(10003, 'Lara', 'Developer', 15000),
//       Employee(10004, 'Michael', 'Designer', 15000),
//       Employee(10005, 'Martin', 'Developer', 15000),
//       Employee(10006, 'Newberry', 'Developer', 15000),
//       Employee(10007, 'Balnc', 'Developer', 15000),
//       Employee(10008, 'Perry', 'Developer', 15000),
//       Employee(10009, 'Gable', 'Developer', 15000),
//       Employee(10010, 'Grimes', 'Developer', 15000),
//       Employee(10001, 'James', 'Project Lead', 20000),
//       Employee(10002, 'Kathryn', 'Manager', 30000),
//       Employee(10003, 'Lara', 'Developer', 15000),
//       Employee(10004, 'Michael', 'Designer', 15000),
//       Employee(10005, 'Martin', 'Developer', 15000),
//       Employee(10006, 'Newberry', 'Developer', 15000),
//       Employee(10007, 'Balnc', 'Developer', 15000),
//       Employee(10008, 'Perry', 'Developer', 15000),
//       Employee(10009, 'Gable', 'Developer', 15000),
//       Employee(10010, 'Grimes', 'Developer', 15000)
//     ];
//   }
// }
//
// /// Custom business object class which contains properties to hold the detailed
// /// information about the employee which will be rendered in datagrid.
// class Employee {
//   /// Creates the employee class with required details.
//   Employee(this.id, this.name, this.designation, this.salary);
//
//   /// Id of an employee.
//   final int id;
//
//   /// Name of an employee.
//   final String name;
//
//   /// Designation of an employee.
//   final String designation;
//
//   /// Salary of an employee.
//   final int salary;
// }
//
// /// An object to set the employee collection data source to the datagrid. This
// /// is used to map the employee data to the datagrid widget.
// class EmployeeDataSource extends DataGridSource {
//   /// Creates the employee data source class with required details.
//   EmployeeDataSource({required List<Employee> employeeData}) {
//     _employeeData = employeeData
//         .map<DataGridRow>((e) => DataGridRow(cells: [
//       DataGridCell<int>(columnName: 'id', value: e.id),
//       DataGridCell<String>(columnName: 'name', value: e.name),
//       DataGridCell<String>(
//           columnName: 'designation', value: e.designation),
//       DataGridCell<int>(columnName: 'salary', value: e.salary),
//     ]))
//         .toList();
//   }
//
//   List<DataGridRow> _employeeData = [];
//
//   @override
//   List<DataGridRow> get rows => _employeeData;
//
//   @override
//   DataGridRowAdapter buildRow(DataGridRow row) {
//     return DataGridRowAdapter(
//         cells: row.getCells().map<Widget>((e) {
//           return Container(
//             alignment: Alignment.center,
//             padding: EdgeInsets.all(8.0),
//             child: Text(e.value.toString()),
//           );
//         }).toList());
//   }
// }




// import 'package:flutter/material.dart';
// import 'package:number_pagination/number_pagination.dart';
//
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'NumberPagenation Demo',
//       // theme: ThemeData(
//       //   primarySwatch: Colors.blue,
//       // ),
//       home: Scaffold(body: MyHomePage()),
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//
//
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   var selectedPageNumber = 3;
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.end,
//       children: [
//         // Expanded(
//         //   child: Flexible(
//         //     child: Container(
//         //       alignment: Alignment.center,
//         //       height: 100,
//         //       color: Colors.yellow[200],
//         //       child: Text('PAGE INFO $selectedPageNumber'), //do manage state
//         //     ),
//         //   ),
//         // ),
//
//         NumberPagination(
//
//
//           onPageChanged: (int pageNumber) {
//             //do somthing for selected page
//             setState(() {
//               selectedPageNumber = pageNumber;
//             });
//           },
//           pageTotal: 100,
//           pageInit: selectedPageNumber, // picked number when init page
//           colorPrimary: Colors.red,
//           colorSub: Colors.yellow,
//         ),
//         SizedBox(height: 30,)
//       ],
//     );
//   }
// }















































import 'package:flutter/material.dart';
import 'package:number_pagination/number_pagination.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // title: 'NumberPagenation Demo',
      // theme: ThemeData(
      //   primarySwatch: Colors.blue,
      // ),
      home: Scaffold(body: MyHomePage()),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedPageNumber = 3;

  @override
  Widget build(BuildContext context) {
    return Column(
      // crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Flexible(
        //   child: Container(
        //     alignment: Alignment.center,
        //     height: 100,
        //     color: Colors.yellow[200],
        //     child: Text('PAGE INFO $selectedPageNumber'), //do manage state
        //   ),
        // ),
        Expanded(
          child: NumberPagination(
            controlButton: SizedBox(width: 20,
           ),
            fontSize: 20,
            // iconNext:Container(
            //   color: Colors.red,
            //   child: IconButton(
            //     color: Colors.red,
            //
            //     icon:Icon(Icons.navigate_next) ,
            //     onPressed: (){
            //
            //       setState(() {
            //         print(selectedPageNumber);
            //       });
            //     },
            //   ),
            // ) ,
            // iconPrevious: ,
            // iconToFirst: ,
            // iconToLast: ,

            // controlButton: TextButton(
            //   onPressed: (){
            //
            //   },
            //   child: Text("new "),
            // ),
            onPageChanged: (int pageNumber) {

              //do something for selected page
              setState(() {
                selectedPageNumber = pageNumber;
              });
            },
            pageTotal: 100,
            pageInit: selectedPageNumber, // picked number when init page
            colorPrimary: Colors.red,
            threshold: 4,

            // colorSub: Colors.transparent,
          ),
        ),
      ],
    );
  }
}
