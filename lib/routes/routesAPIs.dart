class Routes {
  static String urlRoute() {
    return 'http://192.168.0.7:8000/api';
    //return 'https://mr-ponto.herokuapp.com/api';
  }

  static String login() {
    return urlRoute() + '/funcionario/login';
  }

  static String logout() {
    return urlRoute() + '/funcionario/logout';
  }

  static String historico() {
    return urlRoute() + '/funcionario/ponto/historico';
  }
}
