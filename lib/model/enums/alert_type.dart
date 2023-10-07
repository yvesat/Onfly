enum AlertType {
  error("Erro"),
  warning("Alerta"),
  sucess("Sucesso"),
  ;

  const AlertType(this.text);
  final String text;
}
