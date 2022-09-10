import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:localstorage/localstorage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _loginController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final _loginKey = GlobalKey<FormState>();

  final LocalStorage storage = new LocalStorage('todo_app');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(
          top: 60,
          left: 40,
          right: 40,
        ),
        color: Colors.white,
        child: ListView(
          children: [
            //para icone
            /* SizedBox(
    width: 128,
    height: 128,
    child: Image.asset(""),
  ) */
            SizedBox(
              height: 20,
            ),
            // Email login
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              controller: _loginController,
              decoration: InputDecoration(
                labelText: "Email",
                labelStyle: TextStyle(
                  color: Colors.black38,
                  fontWeight: FontWeight.w400,
                  fontSize: 20,
                ),
              ),
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(
              height: 10,
            ),
            // Password
            TextFormField(
              keyboardType: TextInputType.text,
              obscureText: true,
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: "Senha",
                labelStyle: TextStyle(
                  color: Colors.black38,
                  fontWeight: FontWeight.w400,
                  fontSize: 20,
                ),
              ),
              style: TextStyle(fontSize: 20),
            ),
            // para recuperar senha
            Container(
              height: 40,
              alignment: Alignment.centerRight,
              child: TextButton(
                child: Text(
                  "Recuperar senha",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                onPressed: () {
                  print('Recuperar senha pressionado!');
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => ResetPasswordPage(),)
                  // )
                },
              ),
            ),
            Container(
              height: 60,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.3, 1],
                  colors: [
                    Color(0xFF0052D4),
                    Color(0XFF6FB1FC),
                  ],
                ),
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              child: SizedBox.expand(
                child: TextButton(
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  onPressed: () {
                    //Navigator.pushNamed(context, '/home');
                    /* print(_loginController);
                    print(_passwordController); */
                    var url = Uri.parse(
                        'http://192.168.0.5:8000/api/funcionario/login');
                    post(
                      url,
                      headers: <String, String>{
                        'Content-Type': 'application/json; charset=UTF-8',
                      },
                      body: jsonEncode(<String, String>{
                        'email': _loginController.text,
                        'password': _passwordController.text,
                      }),
                    )
                        .then((value) {
                          var response = value.body;

                          var obj = jsonDecode(response);

                          //print(obj.runtimeType);

                          if (obj['token'] != null) {
                            print(obj['token']);
                            storage.setItem(
                                '@FuncionarioToken', jsonEncode(obj));
                            Navigator.pushNamed(context, '/home');
                          }

                          /* _loginController.text = '';
                          _passwordController.text = ''; */
                        })
                        .catchError((e) => print(e))
                        .timeout(Duration(seconds: 10));
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class LoginPage extends StatelessWidget {
//   const LoginPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         padding: EdgeInsets.only(
//           top: 60,
//           left: 40,
//           right: 40,
//         ),
//         color: Colors.white,
//         child: ListView(
//           children: [
//             //para icone
//             /* SizedBox(
//     width: 128,
//     height: 128,
//     child: Image.asset(""),
//   ) */
//             SizedBox(
//               height: 20,
//             ),
//             // Email login
//             TextFormField(
//               keyboardType: TextInputType.emailAddress,
//               decoration: InputDecoration(
//                 labelText: "Email",
//                 labelStyle: TextStyle(
//                   color: Colors.black38,
//                   fontWeight: FontWeight.w400,
//                   fontSize: 20,
//                 ),
//               ),
//               style: TextStyle(fontSize: 20),
//             ),
//             SizedBox(
//               height: 10,
//             ),
//             // Password
//             TextFormField(
//               keyboardType: TextInputType.text,
//               obscureText: true,
//               decoration: InputDecoration(
//                 labelText: "Senha",
//                 labelStyle: TextStyle(
//                   color: Colors.black38,
//                   fontWeight: FontWeight.w400,
//                   fontSize: 20,
//                 ),
//               ),
//               style: TextStyle(fontSize: 20),
//             ),
//             // para recuperar senha
//             Container(
//               height: 40,
//               alignment: Alignment.centerRight,
//               child: TextButton(
//                 child: Text(
//                   "Recuperar senha",
//                   textAlign: TextAlign.right,
//                   style: TextStyle(
//                     color: Colors.black,
//                   ),
//                 ),
//                 onPressed: () {
//                   print('Recuperar senha pressionado!');
//                   // Navigator.push(
//                   //   context,
//                   //   MaterialPageRoute(builder: (context) => ResetPasswordPage(),)
//                   // )
//                 },
//               ),
//             ),
//             Container(
//               height: 60,
//               alignment: Alignment.centerLeft,
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   stops: [0.3, 1],
//                   colors: [
//                     Color(0xFFF58524),
//                     Color(0XFFF92B7F),
//                   ],
//                 ),
//                 borderRadius: BorderRadius.all(Radius.circular(5)),
//               ),
//               child: SizedBox.expand(
//                 child: TextButton(
//                   child: Container(
//                     alignment: Alignment.center,
//                     child: Text(
//                       'Login',
//                       style: TextStyle(
//                         color: Colors.black,
//                         fontSize: 20,
//                       ),
//                     ),
//                   ),
//                   onPressed: () {
//                     Navigator.pushNamed(context, '/home');
//                     print('logando...');
//                   },
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
